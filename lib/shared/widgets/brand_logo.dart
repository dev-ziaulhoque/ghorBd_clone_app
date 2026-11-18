import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// GhorBD brand mark: an emerald-gradient rounded square with a home glyph,
/// optionally followed by the "GhorBD" wordmark.
///
/// Used on the splash screen and the auth screens so the brand is the first
/// thing a user sees (replaces the generic Material icons used before).
class BrandLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final Color? wordmarkColor;

  const BrandLogo({
    super.key,
    this.size = 72,
    this.showWordmark = true,
    this.wordmarkColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accentMint, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(size * 0.26),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(70),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.home_rounded,
            color: Colors.white,
            size: size * 0.58,
          ),
        ),
        if (showWordmark) ...[
          SizedBox(height: size * 0.18),
          Text(
            'GhorBD',
            style: TextStyle(
              fontSize: size * 0.34,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: wordmarkColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// Horizontal brand lockup (mark + wordmark side by side) for app bars and
/// compact headers.
class BrandLockup extends StatelessWidget {
  final double size;

  const BrandLockup({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accentMint, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(size * 0.26),
          ),
          child: Icon(Icons.home_rounded, color: Colors.white, size: size * 0.58),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'GhorBD',
          style: TextStyle(
            fontSize: size * 0.52,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
