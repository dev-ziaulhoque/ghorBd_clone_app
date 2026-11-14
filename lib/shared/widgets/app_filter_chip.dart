import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// Pill filter chip used in property listings, search filters, and division selectors.
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Widget? icon;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = isDark
        ? AppColors.primaryDark.withAlpha(80)
        : AppColors.primary.withAlpha(30);

    final unselectedBg = isDark ? AppColors.surfaceDark : AppColors.cardLight;

    const selectedBorder = AppColors.primary;
    final unselectedBorder = isDark ? AppColors.borderDark : AppColors.borderLight;

    final selectedTextColor = isDark ? AppColors.primaryLight : AppColors.primaryDark;
    final unselectedTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return InkWell(
      onTap: () => onSelected(!isSelected),
      borderRadius: AppSpacing.borderRadiusPill,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: AppSpacing.borderRadiusPill,
          border: Border.all(
            color: isSelected ? selectedBorder : unselectedBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? selectedTextColor : unselectedTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
