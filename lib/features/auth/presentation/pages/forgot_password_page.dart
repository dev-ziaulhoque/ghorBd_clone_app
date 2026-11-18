import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/security/input_sanitizer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/forgot_password_bloc.dart';

/// Password recovery request screen.
/// Linked to: REQ-023, SCR-010, API-014 (POST /auth/forgot).
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, ForgotPasswordBloc bloc) {
    if (_formKey.currentState?.validate() ?? false) {
      final sanitizedEmail =
          InputSanitizer.normalizeEmail(_emailController.text);
      bloc.add(ForgotPasswordSubmitted(email: sanitizedEmail));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => sl<ForgotPasswordBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.authForgotPasswordTitle),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
                  listener: (context, state) {
                    if (state is ForgotPasswordFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    } else if (state is ForgotPasswordSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.authResetLinkSent),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final bloc = context.read<ForgotPasswordBloc>();
                    final isLoading = state is ForgotPasswordLoading;
                    final isSuccess = state is ForgotPasswordSuccess;

                    return AppCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.authForgotPasswordTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              isSuccess
                                  ? l10n.authResetLinkSent
                                  : l10n.authForgotPasswordInstruction,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isSuccess
                                        ? AppColors.success
                                        : AppColors.textSecondaryLight,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            if (!isSuccess) ...[
                              AppTextField(
                                key: const Key('forgot_email_field'),
                                label: l10n.authEmail,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(Icons.email_outlined),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.validationEmailRequired;
                                  }
                                  if (!value.contains('@')) {
                                    return l10n.validationEmailInvalid;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              AppButton(
                                key: const Key('forgot_submit_button'),
                                label: l10n.authSendResetLink,
                                isLoading: isLoading,
                                onPressed: () => _submit(context, bloc),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            TextButton(
                              key: const Key('forgot_back_button'),
                              onPressed: () => context.go('/login'),
                              child: Text(l10n.authBackToLogin),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
