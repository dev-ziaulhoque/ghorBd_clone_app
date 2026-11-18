import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/shared/widgets/user_avatar.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('UserAvatar', () {
    testWidgets('guest state shows a login icon, not a person icon',
        (tester) async {
      await tester.pumpWidget(
        harness(const UserAvatar(isGuest: true, radius: 20)),
      );

      expect(find.byKey(const Key('user_avatar_guest')), findsOneWidget);
      expect(find.byIcon(Icons.login_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person), findsNothing);
      expect(find.byIcon(Icons.person_outline), findsNothing);
    });

    testWidgets('logged in without photo shows the name initial',
        (tester) async {
      await tester.pumpWidget(
        harness(const UserAvatar(
          isGuest: false,
          name: 'Riad Khan',
          radius: 20,
        )),
      );

      expect(find.text('R'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets('logged in with photo uses CachedNetworkImage with the URL',
        (tester) async {
      await tester.pumpWidget(
        harness(const UserAvatar(
          isGuest: false,
          name: 'Riad Khan',
          photoUrl: 'https://example.com/avatar.png',
          radius: 20,
        )),
      );
      await tester.pump();

      expect(find.byKey(const Key('user_avatar_photo')), findsOneWidget);
      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(image.imageUrl, 'https://example.com/avatar.png');
    });

    testWidgets('photo load failure falls back to the initial avatar',
        (tester) async {
      // The default test HTTP client answers 400, so the image load
      // fails and the error fallback (initial letter) must appear —
      // never a broken-image icon.
      await tester.pumpWidget(
        harness(const UserAvatar(
          isGuest: false,
          name: 'Riad Khan',
          photoUrl: 'https://example.com/avatar.png',
          radius: 20,
        )),
      );
      await tester.pumpAndSettle();

      expect(find.text('R'), findsWidgets);
      expect(find.byIcon(Icons.broken_image), findsNothing);
      expect(find.byIcon(Icons.error), findsNothing);
    });

    testWidgets('Bengali name initial is preserved', (tester) async {
      await tester.pumpWidget(
        harness(const UserAvatar(
          isGuest: false,
          name: 'রিয়াদ খান',
          radius: 20,
        )),
      );

      expect(find.text('র'), findsOneWidget);
    });
  });
}
