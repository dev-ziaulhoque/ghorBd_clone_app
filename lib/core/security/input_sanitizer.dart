import '../utils/formatters.dart';

/// Utility class for sanitizing and validating user inputs client-side.
class InputSanitizer {
  InputSanitizer._();

  /// Regex for script tags and inline event handlers
  static final RegExp _scriptTagRegex = RegExp(
    r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
    caseSensitive: false,
    multiLine: true,
  );

  static final RegExp _htmlTagRegex = RegExp(
    r'<[^>]*>',
    multiLine: true,
  );

  /// Regex for standard BD mobile phone numbers (+8801[3-9]XXXXXXXX, 8801[3-9]XXXXXXXX, or 01[3-9]XXXXXXXX)
  static final RegExp _bdPhoneRegex = RegExp(
    r'^(?:\+?8801|01)[3-9]\d{8}$',
  );

  /// Standard RFC 5322 compliant simplified email regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Sanitizes generic text input by stripping script tags, HTML tags, and trimming.
  static String sanitizeText(String? input, {bool stripHtml = true}) {
    if (input == null) return '';
    var text = input;

    // Remove script tags entirely
    text = text.replaceAll(_scriptTagRegex, '');

    // Optionally strip HTML tags or keep plain text
    if (stripHtml) {
      text = text.replaceAll(_htmlTagRegex, '');
    }

    // Strip ASCII null characters and dangerous control characters
    text = text.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    return text.trim();
  }

  /// Escapes common HTML entities to prevent XSS injection.
  static String escapeHtml(String? input) {
    if (input == null) return '';
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  /// Normalizes Bangladeshi phone numbers into canonical E.164 format (+8801XXXXXXXXX).
  /// Converts Bangla numerals to English numerals automatically.
  static String? normalizeBdPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return null;

    // Convert any Bangla digits to English
    var cleaned = AppFormatters.fromBanglaDigits(phone.trim());

    // Remove spaces, hyphens, parentheses
    cleaned = cleaned.replaceAll(RegExp(r'[\s\-()]'), '');

    // Check against BD phone format
    if (!_bdPhoneRegex.hasMatch(cleaned)) {
      return null;
    }

    // Convert to canonical E.164: +8801XXXXXXXXX
    if (cleaned.startsWith('+8801')) {
      return cleaned;
    } else if (cleaned.startsWith('8801')) {
      return '+$cleaned';
    } else if (cleaned.startsWith('01')) {
      return '+88$cleaned';
    }

    return null;
  }

  /// Normalizes email addresses: strips whitespace and converts to lowercase.
  static String normalizeEmail(String? email) {
    if (email == null) return '';
    return email.trim().toLowerCase();
  }

  /// Validates Bangladeshi phone numbers.
  static bool isValidBdPhone(String? phone) {
    if (phone == null) return false;
    final normalized = normalizeBdPhone(phone);
    return normalized != null;
  }

  /// Validates email format.
  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// Validates password strength:
  /// Minimum 8 characters, at least one uppercase letter, one lowercase letter, one number, and one special character.
  static bool isValidPassword(String? password) {
    if (password == null || password.length < 8) return false;

    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }

  /// Normalizes search queries by removing leading/trailing punctuation and redundant whitespace.
  static String sanitizeSearchQuery(String? query) {
    if (query == null) return '';
    final sanitized = sanitizeText(query, stripHtml: true);
    // Replace multiple whitespace with single space
    return sanitized.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
