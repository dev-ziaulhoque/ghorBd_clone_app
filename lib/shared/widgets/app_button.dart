import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
}

/// Standard button component supporting variants, icons, and integrated loading indicator.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = AppSpacing.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget child;
    if (isLoading) {
      child = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      child = Text(label);
    }

    final buttonStyle = _getButtonStyle(context);

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: child,
        );
        break;
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: child,
        );
        break;
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: child,
        );
        break;
    }

    // Round 4 premium CTA: the primary variant renders the shared
    // emerald CTA gradient with a soft glow shadow (stronger on dark)
    // instead of a flat fill. The button itself is transparent so the
    // gradient shows through; ripple/press states are unchanged.
    if (variant == AppButtonVariant.primary) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      button = DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: AppColors.ctaGradient,
          ),
          borderRadius: AppSpacing.borderRadiusPill,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppColors.ctaGlowDark
                  : AppColors.primary.withAlpha(46),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: button,
      );
    }

    if (width != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return button;
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.primary:
        // Transparent: the emerald CTA gradient is painted by the
        // DecoratedBox wrapper in build() (Round 4 premium CTA).
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          minimumSize: Size(width ?? double.infinity, height),
          shape: const RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusPill),
          elevation: 0,
        );
      case AppButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          minimumSize: Size(width ?? double.infinity, height),
          shape: const RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusPill),
          elevation: 0,
        );
      case AppButtonVariant.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: Size(width ?? double.infinity, height),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusPill),
        );
      case AppButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: Size(width ?? 64, height),
          shape: const RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusPill),
        );
    }
  }
}
