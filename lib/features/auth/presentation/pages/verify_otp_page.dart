// Linked REQ: REQ-024 | SCR-011 | API-006 (POST /auth/verify-email-otp), API-007 (POST /auth/resend-email-otp)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;
  final String? devOtp;

  const VerifyOtpPage({super.key, required this.email, this.devOtp});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.devOtp != null && widget.devOtp!.isNotEmpty) {
      _otpController.text = widget.devOtp!;
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onVerifyPressed() {
    final rawOtp = _otpController.text.trim();
    if (rawOtp.isNotEmpty) {
      final cleanOtp = AppFormatters.fromBanglaDigits(rawOtp);
      context.read<RegisterBloc>().add(
            VerifyOtpSubmitted(email: widget.email, otp: cleanOtp),
          );
    }
  }

  void _onResendPressed() {
    context.read<RegisterBloc>().add(
          ResendOtpRequested(email: widget.email),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authVerify),
      ),
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            context.go('/');
          } else if (state is OtpVerificationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is RegisterOtpSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('নয়া ওটিপি কোড পাঠানো হয়েছে।'),
                backgroundColor: AppColors.success,
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
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: AppCard(
                    padding: AppSpacing.edgeInsetsXl,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.mark_email_read_outlined,
                          size: 48,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.authVerify,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.email,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.authOtpInstruction,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          controller: _otpController,
                          label: l10n.authOtp,
                          hint: '123456',
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                          onSubmitted: (_) => _onVerifyPressed(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppButton(
                          label: l10n.authVerify,
                          onPressed: _onVerifyPressed,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: l10n.authResendOtp,
                          variant: AppButtonVariant.text,
                          onPressed: isLoading ? null : _onResendPressed,
                        ),
                      ],
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
