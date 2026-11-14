import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/qa_bloc.dart';

/// Screen to ask a new question.
/// Traceability: REQ-036, SCR-018, API-064.
class AskQuestionPage extends StatelessWidget {
  const AskQuestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QaBloc>(),
      child: const _AskQuestionForm(),
    );
  }
}

class _AskQuestionForm extends StatefulWidget {
  const _AskQuestionForm();

  @override
  State<_AskQuestionForm> createState() => _AskQuestionFormState();
}

class _AskQuestionFormState extends State<_AskQuestionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _category = 'land';

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<QaBloc>().add(
          AskQuestionEvent(
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
            category: _category,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.askQuestion,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<QaBloc, QaState>(
        listener: (context, state) {
          if (state is QaLoaded && state.actionSuccessMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionSuccessMessage!),
                backgroundColor: AppColors.primary,
              ),
            );
            context.pop();
          } else if (state is QaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is QaLoaded && state.isSubmitting;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  l10n.categoryLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _category,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'land', child: Text('জমি (Land)')),
                    DropdownMenuItem(value: 'rent', child: Text('ভাড়া (Rent)')),
                    DropdownMenuItem(value: 'buy_sell', child: Text('ক্রয়-বিক্রয় (Buy/Sell)')),
                    DropdownMenuItem(value: 'legal', child: Text('আইনগত (Legal)')),
                    DropdownMenuItem(value: 'finance', child: Text('অর্থায়ন (Finance)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _titleController,
                  label: l10n.questionTitleLabel,
                  hint: 'যেমন: খতিয়ানে নামের ভুল থাকলে করণীয় কী?',
                  validator: (val) =>
                      val == null || val.trim().length < 5 ? 'ন্যূনতম ৫ অক্ষর হতে হবে' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _bodyController,
                  label: l10n.questionBodyLabel,
                  hint: 'আপনার সমস্যাটি বিস্তারিত ব্যাখ্যা করুন...',
                  maxLines: 5,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'বিবরণ লিখুন' : null,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: l10n.submitQuestion,
                  isLoading: isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
