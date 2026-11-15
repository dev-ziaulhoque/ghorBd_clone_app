import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/utils/formatters.dart';

void main() {
  group('AppFormatters - Digit Conversion', () {
    test('toBanglaDigits converts 0-9 to Bangla digits', () {
      expect(AppFormatters.toBanglaDigits('0123456789'), '০১২৩৪৫৬৭৮৯');
      expect(AppFormatters.toBanglaDigits(12345), '১২৩৪৫');
      expect(AppFormatters.toBanglaDigits(0), '০');
    });

    test('toBanglaDigits preserves text and punctuation', () {
      expect(
        AppFormatters.toBanglaDigits('Phone: +880 1712-345678'),
        'Phone: +৮৮০ ১৭১২-৩৪৫৬৭৮',
      );
      expect(AppFormatters.toBanglaDigits(''), '');
      expect(AppFormatters.toBanglaDigits(null), '');
    });

    test('fromBanglaDigits converts Bangla digits back to English digits', () {
      expect(AppFormatters.fromBanglaDigits('০১২৩৪৫৬৭৮৯'), '0123456789');
      expect(
        AppFormatters.fromBanglaDigits('ফোন: +৮৮০ ১৭১২-৩৪৫৬৭৮'),
        'ফোন: +880 1712-345678',
      );
    });
  });

  group('AppFormatters - BDT Lakh & Crore Currency Formatting', () {
    test('formats 7,200,000 to "৭২,০০,০০০ ৳" in Bangla per user requirement', () {
      expect(AppFormatters.formatBdt(7200000), '৭২,০০,০০০ ৳');
    });

    test('formats 7,200,000 to "72,00,000 ৳" in English when isBangla is false', () {
      expect(AppFormatters.formatBdt(7200000, isBangla: false), '72,00,000 ৳');
    });

    test('formats various South Asian amounts accurately with lakh/crore grouping', () {
      expect(AppFormatters.formatBdt(0), '০ ৳');
      expect(AppFormatters.formatBdt(100), '১০০ ৳');
      expect(AppFormatters.formatBdt(1000), '১,০০০ ৳');
      expect(AppFormatters.formatBdt(25000), '২৫,০০০ ৳');
      expect(AppFormatters.formatBdt(100000), '১,০০,০০০ ৳'); // 1 lakh
      expect(AppFormatters.formatBdt(10000000), '১,০০,০০,০০০ ৳'); // 1 crore
      expect(AppFormatters.formatBdt(157200000), '১৫,৭২,০০,০০০ ৳'); // 15 crore 72 lakh
    });

    test('omits currency symbol when includeSymbol is false', () {
      expect(AppFormatters.formatBdt(7200000, includeSymbol: false), '৭২,০০,০০০');
      expect(
        AppFormatters.formatBdt(7200000, isBangla: false, includeSymbol: false),
        '72,00,000',
      );
    });

    test('handles negative amounts', () {
      expect(AppFormatters.formatBdt(-7200000), '-৭২,০০,০০০ ৳');
      expect(AppFormatters.formatBdt(-50000, isBangla: false), '-50,000 ৳');
    });

    test('handles fractional amounts (poisha)', () {
      expect(AppFormatters.formatBdt(25000.5), '২৫,০০০.৫০ ৳');
      expect(AppFormatters.formatBdt(25000.5, isBangla: false), '25,000.50 ৳');
    });
  });

  group('AppFormatters - Compact BDT Formatting (Map Markers & Badges)', () {
    test('formats crores compactly in Bangla', () {
      expect(AppFormatters.formatCompactBdt(12500000), '৳ ১.২৫ কোটি');
      expect(AppFormatters.formatCompactBdt(10000000), '৳ ১ কোটি');
      expect(AppFormatters.formatCompactBdt(157000000), '৳ ১৫.৭ কোটি');
    });

    test('formats lakhs compactly in Bangla', () {
      expect(AppFormatters.formatCompactBdt(7200000), '৳ ৭২ লাখ');
      expect(AppFormatters.formatCompactBdt(800000), '৳ ৮ লাখ');
      expect(AppFormatters.formatCompactBdt(150000), '৳ ১.৫ লাখ');
    });

    test('formats thousands compactly in Bangla', () {
      expect(AppFormatters.formatCompactBdt(28000), '৳ ২৮ হাজার');
      expect(AppFormatters.formatCompactBdt(10000), '৳ ১০ হাজার');
      expect(AppFormatters.formatCompactBdt(8500), '৳ ৮.৫ হাজার');
    });

    test('formats amounts less than 1,000 in Bangla', () {
      expect(AppFormatters.formatCompactBdt(500), '৳ ৫০০');
      expect(AppFormatters.formatCompactBdt(0), '৳ ০');
    });

    test('formats compact BDT in English when isBangla is false', () {
      expect(AppFormatters.formatCompactBdt(12500000, isBangla: false), '৳ 1.25 Cr');
      expect(AppFormatters.formatCompactBdt(7200000, isBangla: false), '৳ 72 Lac');
      expect(AppFormatters.formatCompactBdt(10000, isBangla: false), '৳ 10 k');
    });

    test('supports suffix symbol and omitting symbol', () {
      expect(AppFormatters.formatCompactBdt(12500000, prefixSymbol: false), '১.২৫ কোটি ৳');
      expect(AppFormatters.formatCompactBdt(12500000, includeSymbol: false), '১.২৫ কোটি');
    });
  });
}
