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
import '../../../../shared/widgets/app_motion.dart';
import '../../../../shared/widgets/app_filter_chip.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/google_sign_in_button.dart';

/// Registration screen, modelled on ghorbd.com/owner/register:
/// Google button first, "অথবা" divider, role cards
/// (বাসা খুঁজছি / আমার বাসা/সম্পত্তি ভাড়া দিতে চাই), then
/// name / email / mobile / password, an owner-only "আপনি কে?" selector
/// (মালিক/এজেন্ট/ডেভেলপার-কোম্পানি → owner/agent/builder), and the
/// terms/privacy note.
///
/// NOTE: the website's 4th "আপনি কে?" option ("অন্যের হয়ে") has no
/// backend value in the documented set (owner|agent|builder), so it is
/// intentionally NOT shown/sent until the backend confirms a value.
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

  /// Website password rule: at least 8 characters, with at least one
  /// letter and one digit.
  static bool _isValidPassword(String value) {
    if (value.length < 8) return false;
    final hasLetter = value.contains(RegExp(r'[A-Za-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    return hasLetter && hasDigit;
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
            // NOTE: the dev OTP from the backend is deliberately NOT
            // forwarded — the user must type the code they received.
            context.push('/verify_otp', extra: {
              'email': state.email,
            });
          } else if (state is RegisterSuccess) {
            context.go('/');
          } else if (state is RegisterFailure) {
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
          final isLoading = state is RegisterLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  // Round 4: shared entrance for the auth card.
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
                            title: l10n.authRegister,
                            subtitle: l10n.authRegisterSubtitle,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // 1. Google first (website order)
                          GoogleSignInButton(
                            onPressed: isLoading
                                ? null
                                : () => context
                                    .read<RegisterBloc>()
                                    .add(const GoogleSignInRequested()),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const AuthOrDivider(),
                          const SizedBox(height: AppSpacing.lg),

                          // 2. Role cards
                          Text(
                            l10n.authSelectRole,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _RoleCard(
                                  key: const Key('register_role_tenant_card'),
                                  icon: Icons.search_rounded,
                                  label: l10n.authRoleTenantCard,
                                  isSelected: _selectedRole == 'tenant',
                                  isDark: isDark,
                                  onTap: () {
                                    setState(() {
                                      _selectedRole = 'tenant';
                                      _selectedListerType = null;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _RoleCard(
                                  key: const Key('register_role_owner_card'),
                                  icon: Icons.home_work_rounded,
                                  label: l10n.authRoleOwnerCard,
                                  isSelected: _selectedRole == 'owner',
                                  isDark: isDark,
                                  onTap: () {
                                    setState(() {
                                      _selectedRole = 'owner';
                                      _selectedListerType = 'owner';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          // 3. "আপনি কে?" — owner only, backend values only
                          if (_selectedRole == 'owner') ...[
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              l10n.authWhoAreYou,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              key: const Key('register_lister_type_selector'),
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.xs,
                              children: [
                                AppFilterChip(
                                  label: l10n.listerOwner,
                                  isSelected: _selectedListerType == 'owner',
                                  onSelected: (_) => setState(() => _selectedListerType = 'owner'),
                                ),
                                AppFilterChip(
                                  label: l10n.listerAgent,
                                  isSelected: _selectedListerType == 'agent',
                                  onSelected: (_) => setState(() => _selectedListerType = 'agent'),
                                ),
                                AppFilterChip(
                                  label: l10n.listerBuilder,
                                  isSelected: _selectedListerType == 'builder',
                                  onSelected: (_) => setState(() => _selectedListerType = 'builder'),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),

                          // 4. Fields (website wording, * = required)
                          AppTextField(
                            controller: _nameController,
                            label: '${l10n.authFullName} *',
                            hint: 'মোঃ রহিম উদ্দিন',
                            prefixIcon: const Icon(Icons.person_outline, size: 20),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return l10n.validationNameRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          AppTextField(
                            controller: _emailController,
                            label: '${l10n.authEmail} *',
                            hint: 'rahim@example.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return l10n.validationEmailRequired;
                              }
                              if (!InputSanitizer.isValidEmail(val.trim())) {
                                return l10n.validationEmailInvalid;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          AppTextField(
                            controller: _phoneController,
                            label: '${l10n.authMobileNumber} *',
                            hint: '01XXXXXXXXX',
                            helperText: l10n.authPhoneVerifyNote,
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return l10n.validationPhoneRequired;
                              }
                              if (!InputSanitizer.isValidBdPhone(val)) {
                                return l10n.validationPhoneInvalid;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          AppTextField(
                            controller: _passwordController,
                            label: '${l10n.authPassword} *',
                            isPassword: true,
                            helperText: l10n.validationPasswordRule,
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return l10n.validationPasswordRequired;
                              }
                              if (!_isValidPassword(val)) {
                                return l10n.validationPasswordRule;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          AppButton(
                            label: l10n.authRegister,
                            onPressed: _onRegisterPressed,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Terms / privacy note + links
                          Text(
                            l10n.authTermsNote,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () => context.push('/terms'),
                                child: Text(l10n.termsTitle),
                              ),
                              TextButton(
                                onPressed: () => context.push('/privacy'),
                                child: Text(l10n.privacyTitle),
                              ),
                            ],
                          ),
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
            ),
          );
        },
      ),
    );
  }
}

/// Selectable role card (website style): icon + label, emerald border and
/// tinted background when selected.
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleCard({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.borderDark : AppColors.borderLight);
    final bgColor = isSelected
        ? AppColors.primary.withAlpha(isDark ? 36 : 22)
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    return Material(
      color: bgColor,
      borderRadius: AppSpacing.borderRadiusCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusCard,
        child: Container(
          padding: AppSpacing.edgeInsetsMd,
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusCard,
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
