import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/reset_password_bloc.dart';

/// Password reset screen with token and new password.
/// Linked to: REQ-023, SCR-010, API-015 (POST /auth/reset).
class ResetPasswordPage extends StatefulWidget {
  final String? initialToken;

  const ResetPasswordPage({super.key, this.initialToken});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokenController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.initialToken ?? '');
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, ResetPasswordBloc bloc) {
    if (_formKey.currentState?.validate() ?? false) {
      bloc.add(
        ResetPasswordSubmitted(
          token: _tokenController.text,
          newPassword: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => sl<ResetPasswordBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.authResetPassword),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
                  listener: (context, state) {
                    if (state is ResetPasswordFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    } else if (state is ResetPasswordSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.authPasswordResetSuccess),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      context.go('/login');
                    }
                  },
                  builder: (context, state) {
                    final bloc = context.read<ResetPasswordBloc>();
                    final isLoading = state is ResetPasswordLoading;

                    return AppCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.authResetPassword,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            AppTextField(
                              key: const Key('reset_token_field'),
                              label: l10n.authResetToken,
                              controller: _tokenController,
                              prefixIcon: const Icon(Icons.vpn_key_outlined),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.error_validation;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              key: const Key('reset_password_field'),
                              label: l10n.authNewPassword,
                              controller: _passwordController,
                              isPassword: true,
                              prefixIcon: const Icon(Icons.lock_outline),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.validationPasswordRequired;
                                }
                                // Same website rule as registration:
                                // 8+ characters with a letter and a digit.
                                final hasLetter = value.contains(RegExp(r'[A-Za-z]'));
                                final hasDigit = value.contains(RegExp(r'[0-9]'));
                                if (value.length < 8 || !hasLetter || !hasDigit) {
                                  return l10n.validationPasswordRule;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              key: const Key('reset_confirm_password_field'),
                              label: l10n.authConfirmPassword,
                              controller: _confirmPasswordController,
                              isPassword: true,
                              prefixIcon: const Icon(Icons.lock_outline),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return l10n.error_validation;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              key: const Key('reset_submit_button'),
                              label: l10n.authResetPassword,
                              isLoading: isLoading,
                              onPressed: () => _submit(context, bloc),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextButton(
                              key: const Key('reset_back_button'),
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
