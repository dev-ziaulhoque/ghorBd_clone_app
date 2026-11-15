import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/security/deep_link_validator.dart';

void main() {
  group('DeepLinkValidator Unit Tests (Security Table Row 14)', () {
    test('isAllowedPath allows valid static and dynamic routes', () {
      expect(DeepLinkValidator.isAllowedPath('/'), isTrue);
      expect(DeepLinkValidator.isAllowedPath('/listings'), isTrue);
      expect(DeepLinkValidator.isAllowedPath('/listings/sale'), isTrue);
      expect(DeepLinkValidator.isAllowedPath('/listings/verified'), isTrue);
      expect(DeepLinkValidator.isAllowedPath('/map'), isTrue);
      expect(DeepLinkValidator.isAllowedPath('/land'), isTrue);
      expect(DeepLinkValidator.isAllowedPath('/pricing'), isTrue);
      expect(DeepLinkValidator.isAllowedPath('/listings/mirpur-flat-102'), isTrue);
      expect(DeepLinkValidator.isAllowedPath('/listings/507f1f77bcf86cd799439011/edit'), isTrue);
      expect(DeepLinkValidator.isAllowedPath('/listings/৩-বেডরুম-ফ্ল্যাট-বাসা-ভাড়া-মিরপুর-ঢাকা'), isTrue);
      expect(DeepLinkValidator.isAllowedPath('/rent/dhaka/mirpur'), isTrue);
      expect(DeepLinkValidator.isAllowedPath('/blog/property-buying-guide'), isTrue);
      expect(DeepLinkValidator.isAllowedPath('/qa/507f1f77bcf86cd799439011'), isTrue);
      expect(DeepLinkValidator.isAllowedPath('/guides/land-registration-bd'), isTrue);
    });

    test('isAllowedPath rejects unauthorized, dangerous, or traversal paths', () {
      expect(DeepLinkValidator.isAllowedPath('/unknown/secret/admin'), isFalse);
      expect(DeepLinkValidator.isAllowedPath('/listings/../../etc/passwd'), isFalse);
      expect(DeepLinkValidator.isAllowedPath('/listings/\\windows\\system32'), isFalse);
      expect(DeepLinkValidator.isAllowedPath('/listings/<script>alert(1)</script>'), isFalse);
      expect(DeepLinkValidator.isAllowedPath('/listings/item\x00extra'), isFalse);
      expect(DeepLinkValidator.isAllowedPath(''), isFalse);
    });

    test('sanitizeSlug cleans and normalizes slugs', () {
      expect(DeepLinkValidator.sanitizeSlug('mirpur-2-bedroom-flat'), 'mirpur-2-bedroom-flat');
      expect(DeepLinkValidator.sanitizeSlug('Dhaka_Uttara-Apartment_12'), 'dhaka_uttara-apartment_12');
      expect(DeepLinkValidator.sanitizeSlug('../../etc/passwd'), 'etcpasswd');
      expect(DeepLinkValidator.sanitizeSlug('<script>alert("xss")</script>'), 'scriptalertxssscript');
      expect(
        DeepLinkValidator.sanitizeSlug('৩-বেডরুম-ফ্ল্যাট-বাসা-ভাড়া-মিরপুর-ঢাকা'),
        '৩-বেডরুম-ফ্ল্যাট-বাসা-ভাড়া-মিরপুর-ঢাকা',
      );
      expect(DeepLinkValidator.sanitizeSlug('------'), isNull);
      expect(DeepLinkValidator.sanitizeSlug('---'), isNull);
      expect(DeepLinkValidator.sanitizeSlug(null), isNull);
      expect(DeepLinkValidator.sanitizeSlug('   '), isNull);
    });

    test('sanitizeId validates 24-character hexadecimal MongoDB ObjectIds', () {
      const validId = '507f1f77bcf86cd799439011';
      expect(DeepLinkValidator.sanitizeId(validId), validId);
      expect(DeepLinkValidator.sanitizeId('507F1F77BCF86CD799439011'), validId);
      expect(DeepLinkValidator.sanitizeId('invalid-id'), isNull);
      expect(DeepLinkValidator.sanitizeId('507f1f77bcf86cd79943901'), isNull); // 23 chars
      expect(DeepLinkValidator.sanitizeId('507f1f77bcf86cd79943901122'), isNull); // 26 chars
      expect(DeepLinkValidator.sanitizeId(null), isNull);
    });

    test('sanitizeRedirectUrl prevents Open Redirect vulnerabilities', () {
      // Valid internal redirects
      expect(DeepLinkValidator.sanitizeRedirectUrl('/dashboard'), '/dashboard');
      expect(DeepLinkValidator.sanitizeRedirectUrl('/favorites'), '/favorites');
      expect(DeepLinkValidator.sanitizeRedirectUrl('/listings/new'), '/listings/new');

      // Malicious external redirects
      expect(DeepLinkValidator.sanitizeRedirectUrl('https://evil.com'), isNull);
      expect(DeepLinkValidator.sanitizeRedirectUrl('http://evil.com/phishing'), isNull);
      expect(DeepLinkValidator.sanitizeRedirectUrl('//evil.com/fake'), isNull);
      expect(DeepLinkValidator.sanitizeRedirectUrl(r'\\evil.com\share'), isNull);
      expect(DeepLinkValidator.sanitizeRedirectUrl('/unauthorized-admin-path'), isNull);
      expect(DeepLinkValidator.sanitizeRedirectUrl(null), isNull);
    });

    test('sanitizeQueryParams strips unauthorized keys and sanitizes search parameters', () {
      final input = {
        'search': '<script>alert(1)</script> 2 BHK Flat',
        'purpose': 'rent',
        'malicious_key': 'drop table',
        'featured': 'true',
      };

      final sanitized = DeepLinkValidator.sanitizeQueryParams(input);

      expect(sanitized.containsKey('malicious_key'), isFalse);
      expect(sanitized['purpose'], 'rent');
      expect(sanitized['featured'], 'true');
      expect(sanitized['search'], isNot(contains('<script>')));
      expect(sanitized['search'], contains('2 BHK Flat'));
    });
  });
}
