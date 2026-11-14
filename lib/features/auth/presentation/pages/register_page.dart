// Linked REQ: REQ-024 | SCR-011 | API-005 (POST /auth/register)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/security/input_sanitizer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_filter_chip.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';

class RegisterPage extends StatefulWidget {
  final String? initialRole;

  const RegisterPage({super.key, this.initialRole});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  late String _selectedRole;
  String? _selectedListerType;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? 'tenant';
    if (_selectedRole == 'owner') {
      _selectedListerType = 'owner';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = InputSanitizer.sanitizeText(_nameController.text);
      final email = InputSanitizer.normalizeEmail(_emailController.text);
      final phone = InputSanitizer.normalizeBdPhone(_phoneController.text) ?? _phoneController.text.trim();
      final password = _passwordController.text;

      context.read<RegisterBloc>().add(
            RegisterSubmitted(
              name: name,
              email: email,
              phone: phone,
              password: password,
              role: _selectedRole,
              listerType: _selectedRole == 'owner' ? (_selectedListerType ?? 'owner') : null,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authRegister),
      ),
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterOtpSent) {
            context.push('/verify_otp', extra: {
              'email': state.email,
              'devOtp': state.devEmailOtp,
            });
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: AppCard(
                    padding: AppSpacing.edgeInsetsXl,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            size: 48,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.authRegister,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Role Selector
                          Text(
                            l10n.authSelectRole,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.sm,
                            children: [
                              AppFilterChip(
                                label: l10n.authRoleTenant,
                                isSelected: _selectedRole == 'tenant',
                                onSelected: (_) {
                                  setState(() {
                                    _selectedRole = 'tenant';
                                    _selectedListerType = null;
                                  });
                                },
                              ),
                              AppFilterChip(
                                label: l10n.authRoleOwner,
                                isSelected: _selectedRole == 'owner',
                                onSelected: (_) {
                                  setState(() {
                                    _selectedRole = 'owner';
                                    _selectedListerType = 'owner';
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Name
                          AppTextField(
                            controller: _nameController,
                            label: l10n.authName,
                            hint: 'Rahim Uddin',
                            prefixIcon: const Icon(Icons.person_outline, size: 20),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return l10n.error_validation;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Email
                          AppTextField(
                            controller: _emailController,
                            label: l10n.authEmail,
                            hint: 'rahim@example.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                            validator: (val) {
                              if (val == null || !InputSanitizer.isValidEmail(val.trim())) {
                                return l10n.error_validation;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Phone
                          AppTextField(
                            controller: _phoneController,
                            label: l10n.authPhone,
                            hint: '01711000000',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                            validator: (val) {
                              if (val == null || !InputSanitizer.isValidBdPhone(val)) {
                                return l10n.error_validation;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Password
                          AppTextField(
                            controller: _passwordController,
                            label: l10n.authPassword,
                            isPassword: true,
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            validator: (val) {
                              if (val == null || val.length < 6) {
                                return l10n.error_validation;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          AppButton(
                            label: l10n.authRegister,
                            onPressed: _onRegisterPressed,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: () => context.push('/login'),
                            child: Text(
                              l10n.authAlreadyHaveAccount,
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
