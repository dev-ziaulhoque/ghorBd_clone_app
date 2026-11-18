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
import '../../../../shared/widgets/app_motion.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/google_sign_in_button.dart';
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
            final text = state.messageKey == 'error_google_unavailable'
                ? l10n.googleSignInUnavailable
                : state.messageKey == 'error_google_cancelled'
                    ? l10n.googleSignInCancelled
                    : state.message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(text),
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
                  // Round 4: the auth card rises in with the shared
                  // entrance instead of appearing flat.
                  child: FadeSlideIn(
                    child: AppCard(
                    padding: AppSpacing.edgeInsetsXl,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthBrandHeader(
                            title: l10n.authLogin,
                            subtitle: l10n.authLoginSubtitle,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          GoogleSignInButton(
                            onPressed: isLoading
                                ? null
                                : () => context
                                    .read<AuthBloc>()
                                    .add(const AuthGoogleSignInRequested()),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const AuthOrDivider(),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _emailController,
                            label: l10n.authEmail,
                            hint: 'user@example.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.validationEmailRequired;
                              }
                              if (!InputSanitizer.isValidEmail(value.trim())) {
                                return l10n.validationEmailInvalid;
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
                                return l10n.validationPasswordRequired;
                              }
                              return null;
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              key: const Key('login_forgot_password_button'),
                              onPressed: () => context.push('/forgot-password'),
                              child: Text(
                                l10n.authForgotPassword,
                                style: TextStyle(
                                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
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
            ),
          );
        },
      ),
    );
  }
}
