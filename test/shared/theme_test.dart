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
      expect(AppColors.backgroundDark, const Color(0xFF0B1017));
    });

    test('AppSpacing provides consistent 4/8dp baseline scale', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.buttonHeight, 48.0);
    });

    test('AppTypography provides light and dark TextThemes', () {
      expect(AppTypography.lightTextTheme.displayLarge?.fontSize, 32);
      expect(AppTypography.darkTextTheme.displayLarge?.fontSize, 32);
      expect(AppTypography.lightTextTheme.bodyMedium?.fontSize, 14);
    });

    test('AppTheme.lightTheme initializes with valid Material 3 config', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.backgroundLight);
    });

    test('AppTheme.darkTheme initializes with dark palette and #0B1017 background', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF0B1017));
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
