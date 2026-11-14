import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations (l10n)', () {
    testWidgets('loads default Bangla (bn) translations', (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('bn'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(l10n.appName, 'ঘরবিডি');
      expect(l10n.heroTitle, 'আপনার পছন্দের ঘর খুঁজুন সহজেই');
      expect(l10n.searchHint, 'এলাকা, ধরন বা বাজেট দিয়ে খুঁজুন');
      expect(l10n.loginToViewPhone, 'নম্বর দেখতে লগইন করুন');
      expect(l10n.loginToSendMessage, 'মেসেজ পাঠাতে লগইন করুন');
      expect(l10n.safetyNotice, contains('বাসাটি সরাসরি দেখে নিন'));

      // Error keys
      expect(l10n.error_network, contains('ইন্টারনেট সংযোগ নেই'));
      expect(l10n.error_timeout, contains('সময় শেষ'));
      expect(l10n.error_unauthorized, contains('লগইন'));
      expect(l10n.error_token_expired, contains('মেয়াদ শেষ'));
      expect(l10n.error_invalid_credentials, contains('ভুল ইমেইল'));
      expect(l10n.error_validation, contains('প্রদত্ত তথ্য সঠিক নয়'));
      expect(l10n.error_rate_limit, contains('অতিরিক্ত অনুরোধ'));
    });

    testWidgets('loads English (en) translations', (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(l10n.appName, 'GhorBD');
      expect(l10n.heroTitle, 'Find your preferred home easily');
      expect(l10n.searchHint, 'Search by area, type or budget');
      expect(l10n.loginToViewPhone, 'Login to view phone number');

      // Error keys
      expect(l10n.error_network, contains('No internet connection'));
      expect(l10n.error_timeout, contains('Connection timed out'));
      expect(l10n.error_unauthorized, contains('Please login'));
      expect(l10n.error_invalid_credentials, contains('Invalid email or password'));
      expect(l10n.error_rate_limit, contains('Too many requests'));
    });
  });
}
