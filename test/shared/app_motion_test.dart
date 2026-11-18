import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/shared/widgets/app_motion.dart';

void main() {
  group('FadeSlideIn', () {
    testWidgets('starts transparent and settles at full opacity',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeSlideIn(child: Text('Hello')),
          ),
        ),
      );

      final opacityFinder = find.descendant(
        of: find.byType(FadeSlideIn),
        matching: find.byType(Opacity),
      );
      expect(tester.widget<Opacity>(opacityFinder).opacity, lessThan(1));

      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(opacityFinder).opacity, 1);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('staggered variant also settles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                for (var i = 0; i < 3; i++)
                  FadeSlideIn.staggered(
                    index: i,
                    child: Text('Item $i'),
                  ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        expect(find.text('Item $i'), findsOneWidget);
      }
    });

    testWidgets('reduce-motion shows the child immediately', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: FadeSlideIn(child: Text('Static')),
            ),
          ),
        ),
      );
      // A single frame is enough — no animation runs.
      await tester.pump();

      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(FadeSlideIn),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 1);
      expect(find.text('Static'), findsOneWidget);
    });
  });

  group('ScrollReveal', () {
    double revealOpacity(WidgetTester tester) {
      return tester
          .widget<Opacity>(
            find.descendant(
              of: find.byType(ScrollReveal),
              matching: find.byType(Opacity),
            ),
          )
          .opacity;
    }

    testWidgets('visible item reveals and settles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [ScrollReveal(child: Text('Card'))],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(revealOpacity(tester), 1);
      expect(find.text('Card'), findsOneWidget);
    });

    testWidgets('below-fold item reveals when scrolled into view',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 30,
              itemBuilder: (_, i) => SizedBox(
                height: 100,
                child: ScrollReveal(child: Text('Item $i')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Far below the fold the lazy list has not even built the item.
      expect(find.text('Item 20'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('Item 20'),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(find.text('Item 20'), findsOneWidget);
      final reveal = find.ancestor(
        of: find.text('Item 20'),
        matching: find.byType(ScrollReveal),
      );
      final opacity = tester.widget<Opacity>(
        find.descendant(of: reveal, matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, 1);
    });

    testWidgets('reduce-motion shows the child immediately', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: ListView(
                children: const [ScrollReveal(child: Text('Static'))],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(revealOpacity(tester), 1);
    });
  });

  group('CrossfadeSwitcher', () {
    testWidgets('crossfades between keyed children and settles',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CrossfadeSwitcher(
              child: SizedBox(key: ValueKey('a'), child: Text('A')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CrossfadeSwitcher(
              child: SizedBox(key: ValueKey('b'), child: Text('B')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
      expect(find.text('A'), findsNothing);
    });
  });

  group('PressScale', () {
    testWidgets('scales down while pressed and lets taps through',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(
              child: InkWell(
                onTap: () => taps++,
                child: const SizedBox(
                  width: 100,
                  height: 100,
                  child: Text('Tap me'),
                ),
              ),
            ),
          ),
        ),
      );

      AnimatedScale scaleWidget() =>
          tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scaleWidget().scale, 1);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Tap me')),
      );
      await tester.pump();
      expect(scaleWidget().scale, 0.97);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(scaleWidget().scale, 1);
      expect(taps, 1);
    });
  });
}
