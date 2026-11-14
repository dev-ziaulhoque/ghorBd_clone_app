/// Centralized API endpoint constants mapped directly from API_AUDIT.md.
/// Added strictly when features need them.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth endpoints (API-005 to API-016)
  static const String register = '/auth/register';
  static const String verifyEmailOtp = '/auth/verify-email-otp';
  static const String resendEmailOtp = '/auth/resend-email-otp';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendEmail = '/auth/resend-email';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot';
  static const String resetPassword = '/auth/reset';
  static const String changePassword = '/auth/password';

  // Browse & Listings endpoints (API-022, API-023, API-034, API-048)
  static const String listings = '/listings';
  static String listingDetail(String idOrSlug) => '/listings/$idOrSlug';
  static const String search = '/search';
  static const String areas = '/areas';
}
