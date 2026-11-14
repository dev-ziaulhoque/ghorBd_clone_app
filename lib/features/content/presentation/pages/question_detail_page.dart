import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../bloc/qa_bloc.dart';

/// Question detail and answer thread page.
/// Traceability: REQ-036, SCR-019, API-065, API-067, API-068.
class QuestionDetailPage extends StatelessWidget {
  final String id;
  const QuestionDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QaBloc>()..add(FetchQuestionDetailEvent(id)),
      child: _QuestionDetailView(id: id),
    );
  }
}

class _QuestionDetailView extends StatefulWidget {
  final String id;
  const _QuestionDetailView({required this.id});

  @override
  State<_QuestionDetailView> createState() => _QuestionDetailViewState();
}

class _QuestionDetailViewState extends State<_QuestionDetailView> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submitAnswer(String questionId) {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    context.read<QaBloc>().add(PostAnswerEvent(questionId: questionId, body: text));
    _answerController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qaTitle),
      ),
      body: BlocConsumer<QaBloc, QaState>(
        listener: (context, state) {
          if (state is QaLoaded && state.actionSuccessMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.actionSuccessMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state is QaLoading || state is QaInitial) {
            return const AppLoadingView();
          }

          if (state is QaError) {
            return AppErrorView(
              message: state.message,
              onRetry: () {
                context.read<QaBloc>().add(FetchQuestionDetailEvent(widget.id));
              },
            );
          }

          if (state is QaLoaded && state.selectedQuestion != null) {
            final q = state.selectedQuestion!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      q.category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Question Title
                  Text(
                    q.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'লেখক: ${q.authorName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Question Body
                  if (q.body != null && q.body!.isNotEmpty)
                    Text(
                      q.body!,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  const Divider(height: 48),

                  // Answers Section Header
                  Text(
                    '${l10n.answers} (${state.answers.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Post an answer input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _answerController,
                          decoration: InputDecoration(
                            hintText: l10n.writeAnswer,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primary),
                        onPressed: state.isSubmitting
                            ? null
                            : () => _submitAnswer(q.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Answers list
                  if (state.answers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Text(
                        'এখনো কোনো উত্তর প্রদান করা হয়নি। প্রথম উত্তরটি আপনিই দিন!',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.answers.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final ans = state.answers[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withAlpha(25),
                            child: const Icon(Icons.check, color: AppColors.primary, size: 18),
                          ),
                          title: Text(
                            ans.authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(ans.body, style: const TextStyle(fontSize: 14, height: 1.4)),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
