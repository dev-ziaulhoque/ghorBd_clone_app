import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/content_entities.dart';
import '../bloc/qa_bloc.dart';

/// Q&A community page.
/// Traceability: REQ-036, SCR-017, API-062, API-063.
class QaPage extends StatelessWidget {
  const QaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QaBloc>()..add(const FetchQuestionsEvent()),
      child: const _QaView(),
    );
  }
}

class _QaView extends StatelessWidget {
  const _QaView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.qaTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.person_outline, size: 18),
            label: Text(l10n.myQuestions),
            onPressed: () {
              context.read<QaBloc>().add(const FetchMyQuestionsEvent());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/qa/ask'),
        icon: const Icon(Icons.question_answer_outlined),
        label: Text(l10n.askQuestion),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<QaBloc, QaState>(
        builder: (context, state) {
          if (state is QaLoading || state is QaInitial) {
            return const AppLoadingView();
          }

          if (state is QaError) {
            return AppErrorView(
              message: state.message,
              onRetry: () {
                context.read<QaBloc>().add(const FetchQuestionsEvent());
              },
            );
          }

          if (state is QaLoaded) {
            final questions = state.myQuestions.isNotEmpty ? state.myQuestions : state.questions;

            return Column(
              children: [
                // Category chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ('all', l10n.all),
                        ('land', l10n.land),
                        ('rent', l10n.rent),
                        ('legal', 'আইনগত'),
                        ('finance', 'অর্থায়ন'),
                      ].map((item) {
                        final isSelected = state.activeCategory == item.$1;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: FilterChip(
                            label: Text(item.$2),
                            selected: isSelected,
                            onSelected: (_) {
                              context.read<QaBloc>().add(FetchQuestionsEvent(category: item.$1));
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Questions list
                Expanded(
                  child: questions.isEmpty
                      ? const AppEmptyView(
                          title: 'কোনো প্রশ্ন পাওয়া যায়নি',
                          message: 'সম্পত্তি সম্পর্কিত আপনার যেকোনো জিজ্ঞাসা পোস্ট করুন।',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: questions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final q = questions[index];
                            return _buildQuestionCard(context, q, isDark);
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    QuestionEntity question,
    bool isDark,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        onTap: () => context.push('/qa/${question.id}'),
        title: Text(
          question.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.excerpt != null) ...[
              const SizedBox(height: 4),
              Text(
                question.excerpt!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    question.category,
                    style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.mode_comment_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${question.answersCount} উত্তর',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.visibility_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${question.views}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
