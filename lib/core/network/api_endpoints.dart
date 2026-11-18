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
  // Google sign-in token exchange. NOTE: the backend must expose this
  // endpoint; until it does, the app surfaces a graceful
  // "Google sign-in is not available yet" error (never a fake success).
  static const String googleLogin = '/auth/google';
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

  // Contact & Inquiries (API-028, API-029)
  static String listingContact(String id) => '/listings/$id/contact';

  // Report (API-030)
  static String listingReport(String id) => '/listings/$id/report';

  // Favorites (API-031 to API-033)
  static const String favorites = '/listings/favorites';
  static String listingFavorite(String id) => '/listings/$id/favorite';

  // Geo & Map endpoints (API-049, API-050)
  static const String geoSearch = '/geo/search';
  static const String geoReverse = '/geo/reverse';

  // Owner & Listing Management (API-024, API-025, API-027, API-035 to API-043)
  static String listingTransition(String id) => '/listings/$id/transition';
  static const String myListings = '/listings/mine';
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerListings = '/owner/listings';
  static const String mediaUpload = '/media/upload';
  static const String mediaDelete = '/media';
  static const String documents = '/documents';
  static String documentFile(String id) => '/documents/$id/file';

  // Content & Community endpoints (API-051 to API-060, API-062 to API-069)
  static const String guides = '/content/guides';
  static String guideDetail(String slug) => '/content/guides/$slug';
  static String staticPage(String slug) => '/content/pages/$slug';
  static const String blogPosts = '/content/posts';
  static String blogPostDetail(String slug) => '/content/posts/$slug';
  static String postComments(String postId) => '/content/posts/$postId/comments';
  static const String qaStats = '/qa/stats';
  static const String qaQuestions = '/qa/questions';
  static String questionDetail(String idOrSlug) => '/qa/questions/$idOrSlug';
  static String questionAnswers(String questionId) => '/qa/questions/$questionId/answers';
  static const String myQuestions = '/qa/my-questions';
  // Plans & Pricing (API-061)
  static const String pricing = '/content/pricing';
}
