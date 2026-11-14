import 'package:flutter/material.dart';

/// Design tokens for GhorBD application colors.
/// Baseline values taken from client_assets website metadata (`#0B1017`).
/// Any missing mobile-specific tokens are marked with `// TODO(design)`.
class AppColors {
  AppColors._();

  // Known from website metadata (AST-001)
  static const Color browserBarTheme = Color(0xFF0B1017);

  // TODO(design): Primary brand color placeholder until mobile Figma arrives
  static const Color primary = Color(0xFF059669); // Emerald/Green marketplace accent
  static const Color primaryDark = Color(0xFF047857);
  static const Color primaryLight = Color(0xFF34D399);

  // TODO(design): Secondary accent color
  static const Color secondary = Color(0xFF0284C7); // Sky blue
  static const Color secondaryLight = Color(0xFF38BDF8);

  // Status & Feedback colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Light theme backgrounds and surfaces
  // TODO(design): Confirm surface palette with client design
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerLight = Color(0xFFF1F5F9);

  // Dark theme backgrounds and surfaces (based on #0B1017)
  static const Color backgroundDark = Color(0xFF0B1017);
  static const Color surfaceDark = Color(0xFF131B26);
  static const Color cardDark = Color(0xFF182232);
  static const Color borderDark = Color(0xFF26354A);
  static const Color dividerDark = Color(0xFF1E2B3C);

  // Light theme text
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Dark theme text
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Verified Badge color
  static const Color verifiedBadge = Color(0xFF0284C7);

  // Price tag color
  static const Color priceTag = Color(0xFF047857);
}
