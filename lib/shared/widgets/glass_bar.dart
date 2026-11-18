import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Glassy/translucent app-bar background (Round 4 premium treatment):
/// a backdrop blur under a translucent emerald-black (dark) or white
/// (light) tint, so content scrolling beneath a floating app bar reads
/// as frosted glass instead of a hard flat strip.
///
/// Used as `flexibleSpace` of the floating [SliverAppBar]s on Home and
/// Listings. The blur is skipped when the OS reduce-motion /
/// accessibility setting asks for reduced transparency-like effects
/// via `MediaQuery.disableAnimations` — in that case a solid surface
/// colour is painted instead.
class GlassBarBackground extends StatelessWidget {
  const GlassBarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? AppColors.glassDark : AppColors.glassLight;
    if (MediaQuery.disableAnimationsOf(context)) {
      return ColoredBox(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      );
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: ColoredBox(color: tint),
      ),
    );
  }
}
