import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// Reusable offline view displaying a network-disconnected icon and retry button.
class AppOfflineView extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const AppOfflineView({super.key, this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayTitle = l10n?.offlineTitle ?? 'অফলাইন মোড';
    final displayMessage = message ?? l10n?.offlineMessage ?? 'ইন্টারনেট সংযোগ চালু করুন।';
    final displayRetry = l10n?.btnRetry ?? 'আবার চেষ্টা করুন';

    return Center(
      child: Padding(
        padding: AppSpacing.edgeInsetsXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AppSpacing.edgeInsetsLg,
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              displayTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(displayRetry),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, AppSpacing.buttonHeight),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
