import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import 'dhaka_map_painter.dart';

class MapControlsOverlay extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRecenter;
  final VoidCallback onToggleStyle;
  final MapThemeStyle currentStyle;

  const MapControlsOverlay({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
    required this.onToggleStyle,
    required this.currentStyle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final iconColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 30),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.add,
            tooltip: l10n.mapZoomIn,
            onPressed: onZoomIn,
            iconColor: iconColor,
          ),
          _buildDivider(isDark),
          _buildButton(
            icon: Icons.remove,
            tooltip: l10n.mapZoomOut,
            onPressed: onZoomOut,
            iconColor: iconColor,
          ),
          _buildDivider(isDark),
          _buildButton(
            icon: Icons.my_location,
            tooltip: l10n.mapRecenter,
            onPressed: onRecenter,
            iconColor: AppColors.primary,
          ),
          _buildDivider(isDark),
          _buildButton(
            icon: _getStyleIcon(),
            tooltip: l10n.mapStyle,
            onPressed: onToggleStyle,
            iconColor: iconColor,
          ),
        ],
      ),
    );
  }

  IconData _getStyleIcon() {
    switch (currentStyle) {
      case MapThemeStyle.modern:
        return Icons.layers_outlined;
      case MapThemeStyle.satelliteNight:
        return Icons.dark_mode_outlined;
      case MapThemeStyle.blueprint:
        return Icons.grid_4x4_outlined;
    }
  }

  Widget _buildButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color iconColor,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 20, color: iconColor),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 32,
      height: 1,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}
