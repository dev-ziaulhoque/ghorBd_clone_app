import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/shared/theme/colors.dart';
import 'package:ghorbad_clone_app/shared/theme/spacing.dart';
import 'package:ghorbad_clone_app/shared/theme/theme.dart';
import 'package:ghorbad_clone_app/shared/theme/typography.dart';

void main() {
  group('AppTheme & Design Tokens', () {
    test('AppColors verifies known browser bar theme color #0B1017', () {
      expect(AppColors.browserBarTheme, const Color(0xFF0B1017));
      // Round 3: the dark palette is EMERALD-BLACK (user-chosen); the
      // old navy #0F172A family is retired from the entire app.
      expect(AppColors.backgroundDark, const Color(0xFF0B1511));
      expect(AppColors.cardDark, const Color(0xFF15251C));
      expect(AppColors.surfaceDark, const Color(0xFF122019));
    });

    test('no navy/slate tokens survive in AppColors', () {
      const retired = [
        Color(0xFF0F172A),
        Color(0xFF1A2436),
        Color(0xFF16213A),
        Color(0xFF64748B),
        Color(0xFF94A3B8),
        Color(0xFFE2E8F0),
      ];
      final tokens = [
        AppColors.backgroundLight,
        AppColors.surfaceLight,
        AppColors.cardLight,
        AppColors.borderLight,
        AppColors.dividerLight,
        AppColors.backgroundDark,
        AppColors.surfaceDark,
        AppColors.cardDark,
        AppColors.borderDark,
        AppColors.dividerDark,
        AppColors.textPrimaryLight,
        AppColors.textSecondaryLight,
        AppColors.textMutedLight,
        AppColors.textPrimaryDark,
        AppColors.textSecondaryDark,
        AppColors.textMutedDark,
      ];
      for (final token in tokens) {
        expect(retired, isNot(contains(token)), reason: '$token is retired');
      }
    });

    test('Round 4 premium dark tokens stay in the emerald-black family', () {
      expect(AppColors.backgroundDarkTop, const Color(0xFF0E1D15));
      expect(AppColors.backgroundDarkBottom, const Color(0xFF060D09));
      expect(AppColors.cardHighlightDark, const Color(0xFF2A5240));
      expect(AppColors.ctaGradient,
          [const Color(0xFF059669), const Color(0xFF10B981)]);
      // The scaffold decoration is a gradient on dark, flat on light.
      final dark = AppColors.scaffoldDecoration(true);
      expect(dark.gradient, isA<LinearGradient>());
      final light = AppColors.scaffoldDecoration(false);
      expect(light.color, AppColors.backgroundLight);
    });

    test('AppSpacing provides consistent 4/8dp baseline scale', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      // Round 2 tightened upper-mid scale: lg 14, xl 16, xxl 20,
      // xxxl 24, massive 32; section gap is xl (16).
      expect(AppSpacing.lg, 14.0);
      expect(AppSpacing.xl, 16.0);
      expect(AppSpacing.xxl, 20.0);
      expect(AppSpacing.xxxl, 24.0);
      expect(AppSpacing.massive, 32.0);
      expect(AppSpacing.sectionGap, 16.0);
      expect(AppSpacing.buttonHeight, 48.0);
    });

    test('AppTypography provides light and dark TextThemes', () {
      // Round 2 reduced scale: display 28/24/22, headline 22/19/17,
      // titles 17/16, body 15/14.
      expect(AppTypography.lightTextTheme.displayLarge?.fontSize, 28);
      expect(AppTypography.darkTextTheme.displayLarge?.fontSize, 28);
      expect(AppTypography.lightTextTheme.displayMedium?.fontSize, 24);
      expect(AppTypography.lightTextTheme.headlineLarge?.fontSize, 22);
      expect(AppTypography.lightTextTheme.headlineSmall?.fontSize, 17);
      expect(AppTypography.lightTextTheme.titleLarge?.fontSize, 17);
      expect(AppTypography.lightTextTheme.titleMedium?.fontSize, 16);
      expect(AppTypography.lightTextTheme.bodyLarge?.fontSize, 15);
      expect(AppTypography.lightTextTheme.bodyMedium?.fontSize, 14);
    });

    test('AppTheme.lightTheme initializes with valid Material 3 config', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.backgroundLight);
    });

    test('AppTheme.darkTheme initializes with emerald-black palette', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF0B1511));
    });

    testWidgets('ElevatedButton inside a Row lays out cleanly without infinite width exception', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Row(
              children: [
                const Text('Hello'),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Button'),
                ),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Button'), findsOneWidget);
    });
  });
}
