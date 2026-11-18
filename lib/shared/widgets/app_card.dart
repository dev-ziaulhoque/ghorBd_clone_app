import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// Reusable Card component respecting theme tokens, border, and elevation.
///
/// Round 4 premium treatment: on dark, cards get a soft deep shadow
/// plus a 1px lighter TOP highlight border (a lit upper edge) so they
/// read as raised surfaces over the emerald-black gradient; on light
/// they get a slightly richer soft shadow over the flat background —
/// one premium family in both themes.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.edgeInsetsMd,
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.color,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = color ?? (isDark ? AppColors.cardDark : AppColors.cardLight);
    final effectiveRadius = borderRadius ?? AppSpacing.borderRadiusCard;

    Widget content = Container(
      padding: padding,
      child: child,
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: effectiveRadius,
        border: border ??
            (isDark
                ? const Border(
                    top: BorderSide(color: AppColors.cardHighlightDark, width: 1),
                    left: BorderSide(color: AppColors.borderDark, width: 1),
                    right: BorderSide(color: AppColors.borderDark, width: 1),
                    bottom: BorderSide(color: AppColors.borderDark, width: 1),
                  )
                : Border.all(color: AppColors.borderLight, width: 1)),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(102),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(16),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: effectiveRadius,
                child: content,
              )
            : content,
      ),
    );
  }
}
