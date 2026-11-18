import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:ghorbad_clone_app/shared/widgets/app_button.dart';
import 'package:ghorbad_clone_app/shared/widgets/app_card.dart';
import 'package:ghorbad_clone_app/shared/widgets/app_filter_chip.dart';
import 'package:ghorbad_clone_app/shared/widgets/app_text_field.dart';
import 'package:ghorbad_clone_app/shared/widgets/empty_view.dart';
import 'package:ghorbad_clone_app/shared/widgets/error_view.dart';
import 'package:ghorbad_clone_app/shared/widgets/loading_view.dart';
import 'package:ghorbad_clone_app/shared/widgets/offline_view.dart';

Widget _buildTestableWidget(Widget child, {Locale locale = const Locale('bn')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('Shared Widgets', () {
    testWidgets('AppLoadingView renders progress indicator and optional message', (tester) async {
      await tester.pumpWidget(_buildTestableWidget(
        const AppLoadingView(message: 'তথ্য লোড হচ্ছে...'),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('তথ্য লোড হচ্ছে...'), findsOneWidget);
    });

    testWidgets('AppErrorView renders message and triggers onRetry callback', (tester) async {
      var retryCalled = false;
      await tester.pumpWidget(_buildTestableWidget(
        AppErrorView(
          message: 'সার্ভারে সংযোগ বিচ্ছিন্ন',
          onRetry: () => retryCalled = true,
        ),
      ));

      expect(find.text('সার্ভারে সংযোগ বিচ্ছিন্ন'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('AppEmptyView renders title, message and optional action', (tester) async {
      await tester.pumpWidget(_buildTestableWidget(
        const AppEmptyView(
          title: 'কোনো বিজ্ঞাপন নেই',
          message: 'আপনার পছন্দের ফিল্টারে কিছু পাওয়া যায়নি',
          action: Text('নতুন ফিল্টার'),
        ),
      ));

      expect(find.text('কোনো বিজ্ঞাপন নেই'), findsOneWidget);
      expect(find.text('আপনার পছন্দের ফিল্টারে কিছু পাওয়া যায়নি'), findsOneWidget);
      expect(find.text('নতুন ফিল্টার'), findsOneWidget);
    });

    testWidgets('AppOfflineView renders offline UI and triggers retry', (tester) async {
      var retryCalled = false;
      await tester.pumpWidget(_buildTestableWidget(
        AppOfflineView(
          onRetry: () => retryCalled = true,
        ),
      ));

      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text('ইন্টারনেট সংযোগ নেই'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('AppCard renders child and triggers onTap', (tester) async {
      var tapCalled = false;
      await tester.pumpWidget(_buildTestableWidget(
        AppCard(
          onTap: () => tapCalled = true,
          child: const Text('কার্ড কন্টেন্ট'),
        ),
      ));

      expect(find.text('কার্ড কন্টেন্ট'), findsOneWidget);
      await tester.tap(find.text('কার্ড কন্টেন্ট'));
      await tester.pump();

      expect(tapCalled, isTrue);
    });

    testWidgets('AppButton handles normal press, loading spinner, and icon', (tester) async {
      var buttonPressed = false;

      // Normal state
      await tester.pumpWidget(_buildTestableWidget(
        AppButton(
          label: 'সাবমিট',
          onPressed: () => buttonPressed = true,
          icon: Icons.check,
        ),
      ));

      expect(find.text('সাবমিট'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('সাবমিট'));
      await tester.pump();
      expect(buttonPressed, isTrue);

      // Loading state
      await tester.pumpWidget(_buildTestableWidget(
        AppButton(
          label: 'সাবমিট',
          onPressed: () {},
          isLoading: true,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('সাবমিট'), findsNothing);
    });

    testWidgets('AppTextField handles text input and password obscure toggle', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(_buildTestableWidget(
        AppTextField(
          controller: controller,
          label: 'পাসওয়ার্ড',
          isPassword: true,
        ),
      ));

      expect(find.text('পাসওয়ার্ড'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap toggle
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('AppFilterChip toggles selection state when tapped', (tester) async {
      var selectedValue = false;

      await tester.pumpWidget(_buildTestableWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return AppFilterChip(
              label: 'ফ্ল্যাট',
              isSelected: selectedValue,
              onSelected: (val) {
                setState(() => selectedValue = val);
              },
            );
          },
        ),
      ));

      expect(find.text('ফ্ল্যাট'), findsOneWidget);
      expect(selectedValue, isFalse);

      await tester.tap(find.text('ফ্ল্যাট'));
      await tester.pump();

      expect(selectedValue, isTrue);
    });
  });
}
