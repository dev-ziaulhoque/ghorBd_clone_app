// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'GhorBD';

  @override
  String get heroTitle => 'Find your preferred home easily';

  @override
  String get searchHint => 'Search by area, type or budget';

  @override
  String get loginToViewPhone => 'Login to view phone number';

  @override
  String get loginToSendMessage => 'Login to send message';

  @override
  String get safetyNotice =>
      'Inspect the property in person before paying any advance money.';

  @override
  String get reportListing => 'Report this listing';

  @override
  String get reportListingHint => 'Fake, fraud or incorrect info? Let us know.';

  @override
  String get noMapLocationNotice =>
      'This listing does not have a map location specified.';

  @override
  String get error_network =>
      'No internet connection. Please verify your network.';

  @override
  String get error_timeout => 'Connection timed out. Please try again.';

  @override
  String get error_unauthorized => 'Please login to continue.';

  @override
  String get error_token_expired => 'Session expired. Please login again.';

  @override
  String get error_token_invalid =>
      'Invalid authentication token. Please login again.';

  @override
  String get error_invalid_credentials => 'Invalid email or password.';

  @override
  String get error_refresh_token_invalid =>
      'Refresh session invalid. Please login again.';

  @override
  String get error_password_changed =>
      'Password was changed. Please login again.';

  @override
  String get error_account_missing => 'Account not found.';

  @override
  String get error_forbidden =>
      'You do not have permission to perform this action.';

  @override
  String get error_email_not_verified =>
      'Email not verified. Please verify using OTP.';

  @override
  String get error_not_found => 'Resource not found.';

  @override
  String get error_no_contact_phone =>
      'No contact phone number provided for this listing.';

  @override
  String get error_question_not_found => 'Question not found.';

  @override
  String get error_conflict => 'Conflict with an existing resource.';

  @override
  String get error_account_exists =>
      'An account already exists with this email address.';

  @override
  String get error_duplicate_listing => 'Duplicate listing already posted.';

  @override
  String get error_invalid_transition =>
      'Invalid status transition for this listing.';

  @override
  String get error_already_reported =>
      'You have already reported this listing.';

  @override
  String get error_area_in_use => 'Area is already in use.';

  @override
  String get error_validation =>
      'Validation failed. Please correct the fields.';

  @override
  String get error_invalid_id => 'Invalid ID provided.';

  @override
  String get error_reset_token_invalid =>
      'Password reset token is invalid or expired.';

  @override
  String get error_email_otp_invalid => 'Invalid OTP code entered.';

  @override
  String get error_email_otp_expired => 'OTP code has expired.';

  @override
  String get error_document_limit_reached => 'Document upload limit reached.';

  @override
  String get error_self_inquiry => 'You cannot inquire about your own listing.';

  @override
  String get error_own_listing => 'Action not permitted on your own listing.';

  @override
  String get error_rate_limit =>
      'Too many requests. Please wait before retrying.';

  @override
  String get error_email_otp_attempts =>
      'Too many failed attempts. Please request a new OTP code.';

  @override
  String get error_file_too_large =>
      'File size exceeds limit (Photos max 5MB, documents max 1MB).';

  @override
  String get error_server => 'Server error occurred. Please try again later.';

  @override
  String get error_geocoder_unavailable =>
      'Geocoding service is temporarily unavailable.';

  @override
  String get error_unknown => 'An unexpected error occurred. Please try again.';

  @override
  String get btnRetry => 'Retry';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnSave => 'Save';

  @override
  String get btnSubmit => 'Submit';

  @override
  String get emptyTitle => 'No data found';

  @override
  String get emptyMessage => 'There is nothing to display here.';

  @override
  String get offlineTitle => 'Offline Mode';

  @override
  String get offlineMessage => 'Please check your internet connection.';

  @override
  String get authLogin => 'Login';

  @override
  String get authRegister => 'Register';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authName => 'Name';

  @override
  String get authPhone => 'Phone Number';

  @override
  String get authOtp => 'OTP';

  @override
  String get authVerify => 'Verify';

  @override
  String get authResendOtp => 'Resend OTP';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authResetPassword => 'Reset Password';

  @override
  String get authLogout => 'Logout';

  @override
  String get authDoNotHaveAccount => 'Don\'t have an account? Register';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? Login';

  @override
  String get authRoleTenant => 'Tenant / Buyer';

  @override
  String get authRoleOwner => 'Owner / Lister';

  @override
  String get authOtpInstruction =>
      'A 6-digit verification code has been sent to your email.';

  @override
  String get authListerType => 'Lister Type';

  @override
  String get authSelectRole => 'Select your role';
}
