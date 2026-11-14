// Linked REQ: REQ-023 | SCR-010 | API-010 (POST /auth/login)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/security/input_sanitizer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  final String? redirect;

  const LoginPage({super.key, this.redirect});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = InputSanitizer.normalizeEmail(_emailController.text);
      final password = _passwordController.text;

      context.read<AuthBloc>().add(
            AuthLoginRequested(email: email, password: password),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authLogin),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            final destination = widget.redirect ?? '/';
            context.go(destination);
          } else if (state is AuthOtpRequiredState) {
            context.push('/verify_otp', extra: {'email': state.email});
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: AppCard(
                    padding: AppSpacing.edgeInsetsXl,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 48,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.authLogin,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppTextField(
                            controller: _emailController,
                            label: l10n.authEmail,
                            hint: 'user@example.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.error_validation;
                              }
                              if (!InputSanitizer.isValidEmail(value.trim())) {
                                return l10n.error_validation;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _passwordController,
                            label: l10n.authPassword,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            onSubmitted: (_) => _onLoginPressed(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.error_validation;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppButton(
                            label: l10n.authLogin,
                            onPressed: _onLoginPressed,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            child: Text(
                              l10n.authDoNotHaveAccount,
                              style: TextStyle(
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
