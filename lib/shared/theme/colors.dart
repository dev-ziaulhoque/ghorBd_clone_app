import 'package:flutter/material.dart';

/// Design tokens for GhorBD application colors.
/// Round 2 (user-confirmed): LIGHT-first — clean white / #F8FAFC surfaces,
/// #E2E8F0 borders, slate text, emerald primary; deep emerald (#059669)
/// for prices/highlights on light surfaces, mint (#34D399) only on dark.
/// Round 3 (user-confirmed): the navy/slate family (#0F172A / #1A2436,
/// slate text/borders) is RETIRED from the entire app — both themes.
/// The dark palette is EMERALD-BLACK (deep green-black surfaces, emerald
/// #10B981 + mint #34D399 accents, green-tinted greys for secondary
/// text/borders). Light-theme greys were likewise re-tinted from slate
/// to a green-tinted neutral so no slate token survives anywhere. All
/// surfaces app-wide consume these tokens (theme.dart + the isDark
/// branches), and the map painter/markers use the same family, so this
/// file is the single source of truth for the palette.
/// `browserBarTheme` keeps the website metadata value (`#0B1017`, AST-001).
class AppColors {
  AppColors._();

  // Known from website metadata (AST-001)
  static const Color browserBarTheme = Color(0xFF0B1017);

  // Brand: emerald primary (#10B981), mint accent (#34D399)
  static const Color primary = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF34D399);

  /// Mint accent used for prices and highlights on dark surfaces.
  static const Color accentMint = Color(0xFF34D399);

  // TODO(design): Secondary accent color placeholder (not from screenshots, see ISS-029)
  static const Color secondary = Color(0xFF0284C7); // Sky blue
  static const Color secondaryLight = Color(0xFF38BDF8);

  // Status & Feedback colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Light theme backgrounds and surfaces (white family, green-tinted
  // neutrals — the slate-tinted #F8FAFC/#E2E8F0 were retired in Round 3)
  static const Color backgroundLight = Color(0xFFF7FAF7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFDFE9E1);
  static const Color dividerLight = Color(0xFFEAF2EB);

  // Dark theme backgrounds and surfaces — EMERALD-BLACK (Round 3,
  // user-chosen): deep green-black background, slightly lighter
  // green-black cards/surfaces, green-tinted dark borders.
  static const Color backgroundDark = Color(0xFF0B1511);
  static const Color surfaceDark = Color(0xFF122019);
  static const Color cardDark = Color(0xFF15251C);
  static const Color borderDark = Color(0xFF1F3A29);
  static const Color dividerDark = Color(0xFF1A2E22);

  // Round 4 PREMIUM dark treatment — layered depth instead of flat
  // surfaces, still strictly inside the emerald-black family:
  /// Top stop of the dark scaffold's subtle vertical gradient
  /// (a touch lighter/greener than [backgroundDark]).
  static const Color backgroundDarkTop = Color(0xFF0E1D15);

  /// Bottom stop of the dark scaffold gradient (deepest green-black).
  static const Color backgroundDarkBottom = Color(0xFF060D09);

  /// 1px top-highlight border for dark cards — the lighter edge that
  /// makes a card read as a raised, lit surface rather than a flat box.
  static const Color cardHighlightDark = Color(0xFF2A5240);

  /// Translucent dark surface used by the glassy app bars
  /// (over a backdrop blur).
  static const Color glassDark = Color(0xCC122019);

  /// Translucent light surface used by the glassy app bars.
  static const Color glassLight = Color(0xD9FFFFFF);

  /// Soft emerald glow shadow colour for primary CTAs on dark
  /// (used sparingly — CTA buttons only).
  static const Color ctaGlowDark = Color(0x5905C46A);

  /// The premium CTA gradient (deep emerald → emerald), shared by
  /// [AppButton] primary and other hero actions.
  static const List<Color> ctaGradient = [Color(0xFF059669), Color(0xFF10B981)];

  /// Gradient tint for category icon tiles (emerald → mint).
  static const List<Color> iconTileGradient = [
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];

  /// Scaffold decoration: subtle vertical gradient on dark, flat
  /// background colour on light (one premium family, two moods).
  static BoxDecoration scaffoldDecoration(bool isDark) {
    if (!isDark) return const BoxDecoration(color: backgroundLight);
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [backgroundDarkTop, backgroundDark, backgroundDarkBottom],
        stops: [0, 0.35, 1],
      ),
    );
  }

  // Light theme text (green-tinted near-black / greys, no slate)
  static const Color textPrimaryLight = Color(0xFF101613);
  static const Color textSecondaryLight = Color(0xFF5A6B60);
  static const Color textMutedLight = Color(0xFF8A9A8F);

  // Dark theme text (off-white primary; muted GREEN-tinted greys —
  // no blue-grey slate)
  static const Color textPrimaryDark = Color(0xFFF4F8F5);
  static const Color textSecondaryDark = Color(0xFF9DB4A6);
  static const Color textMutedDark = Color(0xFF6E8577);

  // Verified Badge color
  static const Color verifiedBadge = Color(0xFF0284C7);

  // Price tag color (deep emerald, readable on light surfaces;
  // use [accentMint] on dark surfaces)
  static const Color priceTag = Color(0xFF059669);
}
