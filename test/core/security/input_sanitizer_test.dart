import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/security/input_sanitizer.dart';

void main() {
  group('InputSanitizer', () {
    test('sanitizeText strips <script> tags and html', () {
      const malicious = '<script>alert("hack")</script>Hello <b>World</b><script src="bad.js"/>';
      final clean = InputSanitizer.sanitizeText(malicious);
      expect(clean, 'Hello World');
    });

    test('sanitizeText strips control characters and null bytes', () {
      const input = 'Dangerous\x00String\x08With\x1FControl';
      final clean = InputSanitizer.sanitizeText(input);
      expect(clean, 'DangerousStringWithControl');
    });

    test('escapeHtml encodes special HTML characters', () {
      const input = '<div class="test" data-id=\'1\'>&"\'</div>';
      final escaped = InputSanitizer.escapeHtml(input);
      expect(
        escaped,
        '&lt;div class=&quot;test&quot; data-id=&#x27;1&#x27;&gt;&amp;&quot;&#x27;&lt;/div&gt;',
      );
    });

    test('normalizeBdPhone handles standard Bangladeshi mobile numbers', () {
      expect(InputSanitizer.normalizeBdPhone('01712345678'), '+8801712345678');
      expect(InputSanitizer.normalizeBdPhone('8801812345678'), '+8801812345678');
      expect(InputSanitizer.normalizeBdPhone('+8801912345678'), '+8801912345678');
      expect(InputSanitizer.normalizeBdPhone('01300000000'), '+8801300000000');
    });

    test('normalizeBdPhone converts Bangla numerals to canonical E.164 phone number', () {
      expect(InputSanitizer.normalizeBdPhone('০১৭১২৩৪৫৬৭৮'), '+8801712345678');
      expect(InputSanitizer.normalizeBdPhone('+৮৮০১৮১২৩৪৫৬৭৮'), '+8801812345678');
      expect(InputSanitizer.normalizeBdPhone('০১৯-১২৩৪-৫৬৭৮'), '+8801912345678');
    });

    test('normalizeBdPhone returns null for invalid formats', () {
      expect(InputSanitizer.normalizeBdPhone('01234567890'), isNull); // 012 is not valid BD prefix
      expect(InputSanitizer.normalizeBdPhone('017123456'), isNull); // too short
      expect(InputSanitizer.normalizeBdPhone('abcd'), isNull);
      expect(InputSanitizer.normalizeBdPhone(null), isNull);
    });

    test('isValidBdPhone returns true for valid BD mobile and false for invalid', () {
      expect(InputSanitizer.isValidBdPhone('01712345678'), isTrue);
      expect(InputSanitizer.isValidBdPhone('০১৭১২৩৪৫৬৭৮'), isTrue);
      expect(InputSanitizer.isValidBdPhone('01112345678'), isFalse);
    });

    test('normalizeEmail lowercases and trims', () {
      expect(InputSanitizer.normalizeEmail('  User@Example.COM  '), 'user@example.com');
    });

    test('isValidEmail validates emails correctly', () {
      expect(InputSanitizer.isValidEmail('test@ghorbd.com'), isTrue);
      expect(InputSanitizer.isValidEmail('user.name+tag@sub.domain.co'), isTrue);
      expect(InputSanitizer.isValidEmail('plainaddress'), isFalse);
      expect(InputSanitizer.isValidEmail('@missingusername.com'), isFalse);
    });

    test('isValidPassword enforces strength rules', () {
      expect(InputSanitizer.isValidPassword('Pass123!'), isTrue);
      expect(InputSanitizer.isValidPassword('short1!'), isFalse); // < 8 chars
      expect(InputSanitizer.isValidPassword('nouppercase123!'), isFalse);
      expect(InputSanitizer.isValidPassword('NOLOWERCASE123!'), isFalse);
      expect(InputSanitizer.isValidPassword('NoSpecialChar123'), isFalse);
      expect(InputSanitizer.isValidPassword('NoDigits!@#\$%'), isFalse);
    });

    test('sanitizeSearchQuery cleans multiple spaces and tags', () {
      expect(
        InputSanitizer.sanitizeSearchQuery('  Mirpur   10   <b>flat</b>  '),
        'Mirpur 10 flat',
      );
    });
  });
}
