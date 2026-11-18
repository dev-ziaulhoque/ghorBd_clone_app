import 'package:flutter/material.dart';

/// Spacing, dimension, and border-radius tokens.
/// TODO(design): Pending client mobile Figma designs; using standard 4/8dp baseline grid.
class AppSpacing {
  AppSpacing._();

  // Spacing scale. Round 2: the upper-mid range was compressed one
  // step (lg 16→14, xl 20→16, xxl 24→20, xxxl 32→24, massive 48→32)
  // because stacked section gaps and page padding read too loose.
  // Consequences that flow app-wide: section gaps are now 16 (xl),
  // page bottom padding 20 (xxl), input horizontal padding 14 (lg).
  // The 2/4/8/12 anchors and card padding (md = 12) are unchanged.
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 14.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
  static const double xxxl = 24.0;
  static const double massive = 32.0;

  /// Semantic alias: vertical gap between page sections.
  static const double sectionGap = xl;

  // Insets
  static const EdgeInsets edgeInsetsXs = EdgeInsets.all(xs);
  static const EdgeInsets edgeInsetsSm = EdgeInsets.all(sm);
  static const EdgeInsets edgeInsetsMd = EdgeInsets.all(md);
  static const EdgeInsets edgeInsetsLg = EdgeInsets.all(lg);
  static const EdgeInsets edgeInsetsXl = EdgeInsets.all(xl);
  static const EdgeInsets edgeInsetsXxl = EdgeInsets.all(xxl);

  // Screen horizontal padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // Border radius tokens
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;

  /// Card radius from the ghorbd.com design audit (~18).
  static const double radiusCard = 18.0;
  static const double radiusPill = 999.0;

  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusCard = BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius borderRadiusPill = BorderRadius.all(Radius.circular(radiusPill));

  // Heights
  static const double buttonHeight = 48.0;
  static const double inputHeight = 48.0;
  static const double bottomBarHeight = 64.0;
  static const double listingCardImageHeight = 180.0;

  /// Aspect ratio (width / height) for listing photos, so card image height
  /// scales with card width instead of a fixed pixel height.
  static const double listingImageAspectRatio = 16 / 10;

  // ---------------------------------------------------------------------------
  // Responsive layout (V2): phone / tablet / foldable, 320–1024+ logical px.
  // Pure functions of width so widgets and tests can share the same rules.
  // ---------------------------------------------------------------------------

  /// Width at/above which a layout counts as tablet-sized.
  static const double tabletBreakpoint = 600.0;

  /// Width at/above which a layout counts as large (wide tablet / desktop).
  static const double largeBreakpoint = 1024.0;

  /// Max width of page content; wider screens centre content instead of
  /// stretching the phone layout edge-to-edge.
  static const double contentMaxWidth = 1200.0;

  /// Horizontal page padding that grows with available width.
  static double pagePadding(double width) {
    if (width >= largeBreakpoint) return xxxl;
    if (width >= tabletBreakpoint) return xxl;
    return lg;
  }

  /// Listing grid columns: 1 on phones, 2 on tablets, 3 on large screens.
  static int listingColumns(double width) {
    if (width >= largeBreakpoint) return 3;
    if (width >= tabletBreakpoint) return 2;
    return 1;
  }

  /// Home category grid columns: 4 on phones, 6 on tablets and up.
  static int categoryColumns(double width) =>
      width >= tabletBreakpoint ? 6 : 4;

  /// Key/value spec grid columns (listing detail): 2 on phones, 3 on wider.
  static int specColumns(double width) => width >= tabletBreakpoint ? 3 : 2;
}
