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
  String get reportListing => 'Report Listing';

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

  @override
  String get authForgotPasswordTitle => 'Password Recovery';

  @override
  String get authForgotPasswordInstruction =>
      'Enter your account email. A password reset link will be sent.';

  @override
  String get authSendResetLink => 'Send Reset Link';

  @override
  String get authResetLinkSent =>
      'Password reset link has been sent to your email.';

  @override
  String get authNewPassword => 'New Password';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authResetToken => 'Reset Token';

  @override
  String get authPasswordResetSuccess =>
      'Password has been reset successfully. Please log in.';

  @override
  String get authBackToLogin => 'Back to Login';

  @override
  String get navHome => 'Home';

  @override
  String get navListings => 'Listings';

  @override
  String get navMap => 'Map';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get featuredListings => 'Featured Listings';

  @override
  String get popularAreas => 'Popular Areas';

  @override
  String get recentRentListings => 'Recent Rent Listings';

  @override
  String get recentSaleListings => 'Sale Listings';

  @override
  String get filterTitle => 'Filters';

  @override
  String get filterApply => 'Apply Filters';

  @override
  String get filterReset => 'Reset';

  @override
  String get filterPurpose => 'Purpose';

  @override
  String get filterPropertyType => 'Property Type';

  @override
  String get filterBedrooms => 'Bedrooms';

  @override
  String get filterPriceRange => 'Price Range';

  @override
  String get filterVerifiedOnly => 'Verified Only';

  @override
  String get all => 'All';

  @override
  String get rent => 'Rent';

  @override
  String get sale => 'Sale';

  @override
  String get apartment => 'Apartment';

  @override
  String get house => 'House';

  @override
  String get room => 'Room';

  @override
  String get shop => 'Shop';

  @override
  String get office => 'Office';

  @override
  String get land => 'Land';

  @override
  String get hostel => 'Hostel';

  @override
  String get perMonth => '/month';

  @override
  String bedroomsCount(Object count) {
    return '$count Beds';
  }

  @override
  String bathroomsCount(Object count) {
    return '$count Baths';
  }

  @override
  String sizeSqft(Object size) {
    return '$size sqft';
  }

  @override
  String get verifiedBadge => 'Verified';

  @override
  String viewCount(Object count) {
    return '$count views';
  }

  @override
  String get similarListings => 'Similar Listings';

  @override
  String get propertyOverview => 'Property Overview';

  @override
  String get amenities => 'Amenities';

  @override
  String get address => 'Address';

  @override
  String get floorNumber => 'Floor';

  @override
  String get sortNewest => 'Newest First';

  @override
  String get sortPriceAsc => 'Price: Low to High';

  @override
  String get sortPriceDesc => 'Price: High to Low';

  @override
  String get sortPopular => 'Most Popular';

  @override
  String foundResults(Object count) {
    return '$count listings found';
  }

  @override
  String get contactOwner => 'Contact Advertiser';

  @override
  String get callOwner => 'Call';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get phoneRevealed => 'Phone Number';

  @override
  String get noPhoneAvailable => 'No phone number available';

  @override
  String get inquiryMessage => 'Write your message';

  @override
  String get inquiryPlaceholder =>
      'Is the flat still available? I would like to visit...';

  @override
  String get send => 'Send';

  @override
  String get inquirySentSuccess => 'Your message has been sent successfully!';

  @override
  String get selfInquiryError =>
      'You cannot send an inquiry about your own listing';

  @override
  String get loginToContact => 'Please log in to contact';

  @override
  String get reportReason => 'Select Report Reason';

  @override
  String get reasonScam => 'Fraudulent or fake listing';

  @override
  String get reasonWrongInfo => 'Incorrect information provided';

  @override
  String get reasonAlreadyRented => 'Already rented or sold';

  @override
  String get reasonOffensive => 'Offensive content';

  @override
  String get reasonOther => 'Other';

  @override
  String get reportDetails => 'Details (optional)';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get reportSuccess =>
      'Your report has been submitted. Thank you for helping keep GhorBD safe.';

  @override
  String get ownListingReportError => 'You cannot report your own listing';

  @override
  String get favoritesTitle => 'Saved Favorites';

  @override
  String get favoritesEmpty => 'No saved listings yet';

  @override
  String get favoritesEmptySubtitle =>
      'Save properties to easily review them later.';

  @override
  String get addToFavorites => 'Save to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get addedToFavoritesSuccess => 'Saved to favorites';

  @override
  String get removedFromFavoritesSuccess => 'Removed from favorites';

  @override
  String get loginToFavorite => 'Please log in to save favorites';

  @override
  String get browseListings => 'Browse Listings';

  @override
  String get mapTitle => 'Map View';

  @override
  String get searchPlaceHint => 'Search place or address...';

  @override
  String get selectedLocation => 'Selected Location';

  @override
  String get nearbyListings => 'Nearby Listings';

  @override
  String get noLocationListings => 'No listings found in this area';

  @override
  String get viewList => 'View List';

  @override
  String get allAreas => 'All Areas';

  @override
  String get mapRecenter => 'Recenter';

  @override
  String get mapZoomIn => 'Zoom In';

  @override
  String get mapZoomOut => 'Zoom Out';

  @override
  String get mapStyle => 'Map Style';

  @override
  String get allMarket => 'All Markets';

  @override
  String get rentMarket => 'Rent Market';

  @override
  String get saleMarket => 'Sale Market';

  @override
  String get viewDetails => 'View Details';

  @override
  String get landTitle => 'Land Marketplace';

  @override
  String get landType => 'Land Type';

  @override
  String get landTypeResidential => 'Residential';

  @override
  String get landTypeCommercial => 'Commercial';

  @override
  String get landTypeAgricultural => 'Agricultural';

  @override
  String get landTypeIndustrial => 'Industrial';

  @override
  String get landArea => 'Land Area';

  @override
  String get landRoadWidth => 'Road Width';

  @override
  String landRoadWidthFt(Object width) {
    return '$width ft Road';
  }

  @override
  String get landFacing => 'Facing';

  @override
  String get katha => 'Katha';

  @override
  String get bigha => 'Bigha';

  @override
  String get shotok => 'Shotok';

  @override
  String get decimal => 'Decimal';

  @override
  String foundLandResults(Object count) {
    return '$count land listings found';
  }

  @override
  String get noLandListings => 'No land listings found';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get myListings => 'My Listings';

  @override
  String get postNewAd => 'Post New Ad';

  @override
  String get editListing => 'Edit Listing';

  @override
  String get createListingTitle => 'Post a New Listing';

  @override
  String get listingTitle => 'Listing Title';

  @override
  String get listingDescription => 'Detailed Description';

  @override
  String get purpose => 'Purpose';

  @override
  String get city => 'City';

  @override
  String get area => 'Area';

  @override
  String get unitNumber => 'Unit Number';

  @override
  String get bedrooms => 'Bedrooms';

  @override
  String get bathrooms => 'Bathrooms';

  @override
  String get size => 'Size (sqft)';

  @override
  String get priceRent => 'Rent / Price (BDT)';

  @override
  String get contactPhone => 'Contact Phone';

  @override
  String get allowDirectContact => 'Allow Direct Contact';

  @override
  String get photos => 'Photos';

  @override
  String get uploadPhotos => 'Add Photos';

  @override
  String get submitListing => 'Post Listing';

  @override
  String get updateListing => 'Save Changes';

  @override
  String get listingCreatedSuccess => 'Listing posted successfully!';

  @override
  String get listingUpdatedSuccess => 'Listing updated successfully!';

  @override
  String get totalListings => 'Total Ads';

  @override
  String get activeListings => 'Active';

  @override
  String get pendingListings => 'Pending';

  @override
  String get archivedListings => 'Archived';

  @override
  String get views => 'Views';

  @override
  String get saved => 'Saved';

  @override
  String get status => 'Status';

  @override
  String get statusActive => 'Active';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusArchived => 'Archived';

  @override
  String get statusWithdrawn => 'Withdrawn';

  @override
  String get actionSubmit => 'Submit';

  @override
  String get actionWithdraw => 'Withdraw';

  @override
  String get actionArchive => 'Archive';

  @override
  String get actionEdit => 'Edit';

  @override
  String get verificationTitle => 'Account Verification';

  @override
  String get verificationSubtitle =>
      'Upload your NID or utility bill to get the verified badge';

  @override
  String get uploadDocument => 'Upload Document';

  @override
  String get documentUploadedSuccess => 'Document uploaded successfully';

  @override
  String get noDocumentsUploaded => 'No documents uploaded';

  @override
  String get noOwnerListings => 'You have no listings yet';

  @override
  String get noOwnerListingsSubtitle =>
      'Post a new ad now to quickly rent or sell your property.';

  @override
  String get blogTitle => 'Blog';

  @override
  String get qaTitle => 'Q&A Community';

  @override
  String get askQuestion => 'Ask Question';

  @override
  String get myQuestions => 'My Questions';

  @override
  String get answers => 'Answers';

  @override
  String get writeAnswer => 'Write your answer';

  @override
  String get postAnswer => 'Post Answer';

  @override
  String get guidesTitle => 'Guides';

  @override
  String get aboutTitle => 'About Us';

  @override
  String get contactUsTitle => 'Contact Us';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get termsTitle => 'Terms of Service';

  @override
  String get helpTitle => 'Help Center';

  @override
  String get infoServicesTitle => 'Information Services';

  @override
  String get questionTitleLabel => 'Question Title';

  @override
  String get questionBodyLabel => 'Question Details';

  @override
  String get categoryLabel => 'Category';

  @override
  String get submitQuestion => 'Submit Question';

  @override
  String get comments => 'Comments';

  @override
  String get writeComment => 'Write a comment...';

  @override
  String get postComment => 'Post Comment';

  @override
  String get readMore => 'Read More';

  @override
  String get pricingTitle => 'Subscription Plans';

  @override
  String get pricingSubtitle => 'Choose the best plan tailored to your needs';

  @override
  String get vatExclusionNotice => 'All prices exclude VAT';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get choosePlan => 'Choose Plan';

  @override
  String get contactSales => 'Contact Sales';

  @override
  String get oneTime => 'One-time';

  @override
  String get freePrice => 'Free';

  @override
  String get pricingFeaturesIncluded => 'Features Included';

  @override
  String get unlimitedListings => 'Unlimited Listings';

  @override
  String get tenantAccountBannerTitle => 'Tenant Account';

  @override
  String get tenantAccountBannerSubtitle =>
      'You are signed in as a tenant. Detailed listing analytics are reserved for property owners. Want to list a property?';
}
