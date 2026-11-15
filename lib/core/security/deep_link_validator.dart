import 'input_sanitizer.dart';

/// Service to validate and sanitize incoming deep link URIs, routes, and parameters.
/// Fulfills Security Requirement (Row 14): "Deep links: Validate all incoming link parameters".
class DeepLinkValidator {
  DeepLinkValidator._();

  /// Whitelisted route path patterns supported by the GhorBD application.
  static const Set<String> allowedStaticPaths = {
    '/',
    '/listings',
    '/listings/sale',
    '/listings/verified',
    '/map',
    '/land',
    '/login',
    '/register',
    '/verify-otp',
    '/verify_otp',
    '/forgot-password',
    '/reset-password',
    '/dashboard',
    '/favorites',
    '/listings/new',
    '/blog',
    '/qa',
    '/qa/ask',
    '/guides',
    '/about',
    '/contact',
    '/privacy',
    '/terms',
    '/help',
    '/pricing',
    '/settings',
  };

  /// MongoDB ObjectId pattern (24-character hex).
  static final RegExp _objectIdRegex = RegExp(r'^[0-9a-fA-F]{24}$');

  /// Safe slug pattern: lowercase alphanumeric, hyphens, and underscores (1 to 100 chars).
  static final RegExp _slugRegex = RegExp(r'^[a-z0-9][a-z0-9-_]{0,99}$', caseSensitive: false);

  /// Validates whether a route path or deep link URI is allow-listed and safe.
  static bool isAllowedPath(String path) {
    if (path.isEmpty) return false;

    // Check for directory traversal attempts or null-byte injections
    if (path.contains('..') || path.contains(r'\') || path.contains('\x00') || path.contains('<')) {
      return false;
    }

    final uri = Uri.tryParse(path);
    if (uri == null) return false;

    final cleanPath = uri.path;

    // Exact static match
    if (allowedStaticPaths.contains(cleanPath)) {
      return true;
    }

    // Dynamic patterns
    // /listings/:slug
    if (RegExp(r'^/listings/[a-zA-Z0-9-_]+$').hasMatch(cleanPath) &&
        !cleanPath.endsWith('/new') &&
        !cleanPath.endsWith('/sale') &&
        !cleanPath.endsWith('/verified')) {
      return true;
    }

    // /listings/:id/edit
    if (RegExp(r'^/listings/[0-9a-fA-F]{24}/edit$').hasMatch(cleanPath)) {
      return true;
    }

    // /listings/division/:slug
    if (RegExp(r'^/listings/division/[a-zA-Z0-9-_]+$').hasMatch(cleanPath)) {
      return true;
    }

    // /rent/dhaka/:area
    if (RegExp(r'^/rent/dhaka/[a-zA-Z0-9-_]+$').hasMatch(cleanPath)) {
      return true;
    }

    // /blog/:slug
    if (RegExp(r'^/blog/[a-zA-Z0-9-_]+$').hasMatch(cleanPath)) {
      return true;
    }

    // /qa/:id
    if (RegExp(r'^/qa/[0-9a-fA-F]{24}$').hasMatch(cleanPath)) {
      return true;
    }

    // /guides/:slug
    if (RegExp(r'^/guides/[a-zA-Z0-9-_]+$').hasMatch(cleanPath)) {
      return true;
    }

    return false;
  }

  /// Validates and sanitizes a slug parameter.
  /// Returns a clean slug string or null if invalid or dangerous.
  static String? sanitizeSlug(String? slug) {
    if (slug == null || slug.trim().isEmpty) return null;
    final trimmed = slug.trim().toLowerCase();

    // Reject path traversals, scripts, and non-slug characters
    if (!_slugRegex.hasMatch(trimmed)) {
      // Clean non-alphanumeric/hyphen characters
      final sanitized = trimmed.replaceAll(RegExp(r'[^a-z0-9-_]'), '');
      if (sanitized.isEmpty) return null;
      return sanitized.length > 100 ? sanitized.substring(0, 100) : sanitized;
    }

    return trimmed;
  }

  /// Validates a 24-character hexadecimal MongoDB ObjectId.
  /// Returns the clean ID or null if invalid.
  static String? sanitizeId(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    final trimmed = id.trim();
    if (_objectIdRegex.hasMatch(trimmed)) {
      return trimmed.toLowerCase();
    }
    return null;
  }

  /// Sanitizes an internal redirect URL to prevent Open Redirect attacks.
  /// Must be an allowed internal relative path; rejects absolute URLs, '//evil.com', schemes, etc.
  static String? sanitizeRedirectUrl(String? redirect) {
    if (redirect == null || redirect.trim().isEmpty) return null;
    final trimmed = redirect.trim();

    // Reject if starts with scheme or protocol-relative '//'
    if (trimmed.startsWith('//') ||
        trimmed.contains('://') ||
        trimmed.startsWith(r'\\') ||
        trimmed.contains('@')) {
      return null;
    }

    // Must start with a single slash
    if (!trimmed.startsWith('/')) {
      return null;
    }

    // Parse path and query
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;

    if (!isAllowedPath(uri.path)) {
      return null;
    }

    return trimmed;
  }

  /// Sanitizes incoming query parameters for search and filtering.
  static Map<String, String> sanitizeQueryParams(Map<String, String> params) {
    final sanitized = <String, String>{};
    for (final entry in params.entries) {
      final key = entry.key.trim();
      final val = entry.value.trim();

      // Only allow known safe query keys
      const allowedKeys = {
        'search',
        'purpose',
        'type',
        'propertyType',
        'area',
        'areaSlug',
        'division',
        'featured',
        'verified',
        'page',
        'perPage',
        'token',
        'email',
        'role',
        'redirect',
      };

      if (allowedKeys.contains(key)) {
        sanitized[key] = InputSanitizer.sanitizeSearchQuery(val);
      }
    }
    return sanitized;
  }
}
