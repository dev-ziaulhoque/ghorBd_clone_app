// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'GhorBD';

  @override
  String get heroTitle => 'আপনার পছন্দের ঘর খুঁজুন সহজেই';

  @override
  String get searchHint => 'এলাকা, ধরন বা বাজেট দিয়ে খুঁজুন';

  @override
  String get loginToViewPhone => 'নম্বর দেখতে লগইন করুন';

  @override
  String get loginToSendMessage => 'মেসেজ পাঠাতে লগইন করুন';

  @override
  String get safetyNotice =>
      'অগ্রিম টাকা পাঠানোর আগে বাসাটি সরেজমিনে গিয়ে দেখে নিন।';

  @override
  String get reportListing => 'বিজ্ঞাপন রিপোর্ট করুন';

  @override
  String get reportListingHint => 'ভুয়া, প্রতারণা বা ভুল তথ্য? আমাদের জানান।';

  @override
  String get noMapLocationNotice =>
      'এই বিজ্ঞাপনের অবস্থান দেওয়া নেই, তাই এটি মানচিত্রে নেই।';

  @override
  String get error_network => 'ইন্টারনেট সংযোগ নেই। আপনার নেটওয়ার্ক চেক করুন।';

  @override
  String get error_timeout => 'সংযোগের সময় শেষ হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get error_unauthorized => 'অনুগ্রহ করে লগইন করুন।';

  @override
  String get error_token_expired => 'সেশনের মেয়াদ শেষ হয়েছে, আবার লগইন করুন।';

  @override
  String get error_token_invalid => 'টোকেন সঠিক নয়। আবার লগইন করুন।';

  @override
  String get error_invalid_credentials => 'ভুল ইমেইল বা পাসওয়ার্ড।';

  @override
  String get error_refresh_token_invalid =>
      'লগইন সেশন অবৈধ হয়েছে। আবার লগইন করুন।';

  @override
  String get error_password_changed =>
      'পাসওয়ার্ড পরিবর্তিত হয়েছে। আবার লগইন করুন।';

  @override
  String get error_account_missing => 'অ্যাকাউন্টটি পাওয়া যায়নি।';

  @override
  String get error_forbidden => 'এই অ্যাকশনটি সম্পাদন করার অনুমতি আপনার নেই।';

  @override
  String get error_email_not_verified =>
      'ইমেইল যাচাই করা হয়নি। কোড দিয়ে যাচাই করুন।';

  @override
  String get error_not_found => 'তথ্যটি পাওয়া যায়নি।';

  @override
  String get error_no_contact_phone => 'বিজ্ঞাপনদাতার ফোন নম্বর পাওয়া যায়নি।';

  @override
  String get error_question_not_found => 'প্রশ্নটি পাওয়া যায়নি।';

  @override
  String get error_conflict => 'তথ্যটি ইতিমধ্যেই বিদ্যমান বা সংঘাত তৈরি করছে।';

  @override
  String get error_account_exists =>
      'এই ইমেইল দিয়ে ইতিমধ্যে অ্যাকাউন্ট খোলা আছে।';

  @override
  String get error_duplicate_listing => 'একই বিজ্ঞাপন ইতিমধ্যে দেওয়া আছে।';

  @override
  String get error_invalid_transition =>
      'বিজ্ঞাপনের এই স্ট্যাটাস পরিবর্তনটি বৈধ নয়।';

  @override
  String get error_already_reported =>
      'আপনি ইতিমধ্যে এই বিজ্ঞাপনে রিপোর্ট করেছেন।';

  @override
  String get error_area_in_use => 'এই এলাকাটি ইতিমধ্যে ব্যবহৃত হচ্ছে।';

  @override
  String get error_validation =>
      'প্রদত্ত তথ্য সঠিক নয়। অনুগ্রহ করে সংশোধন করুন।';

  @override
  String get error_invalid_id => 'আইডি সঠিক নয়।';

  @override
  String get error_reset_token_invalid =>
      'পাসওয়ার্ড রিসেট টোকেন মেয়াদোত্তীর্ণ বা অবৈধ।';

  @override
  String get error_email_otp_invalid => 'ভুল ওটিপি (OTP) কোড।';

  @override
  String get error_email_otp_expired => 'ওটিপি (OTP) কোডের মেয়াদ শেষ হয়েছে।';

  @override
  String get error_document_limit_reached =>
      'সর্বোচ্চ সংখ্যক ডকুমেন্ট আপলোড করা হয়েছে।';

  @override
  String get error_self_inquiry => 'নিজের বিজ্ঞাপনে অনুসন্ধান পাঠানো যাবে না।';

  @override
  String get error_own_listing => 'নিজের বিজ্ঞাপনে এই কাজটি করা যাবে না।';

  @override
  String get error_rate_limit =>
      'অতিরিক্ত অনুরোধ পাঠানো হয়েছে। অনুগ্রহ করে কিছুক্ষণ অপেক্ষা করুন।';

  @override
  String get error_email_otp_attempts =>
      'অনেকবার ভুল কোড দেওয়া হয়েছে। নতুন কোডের অনুরোধ করুন।';

  @override
  String get error_file_too_large =>
      'ফাইলের সাইজ সীমার চেয়ে বেশি (ছবি সর্বোচ্চ ৫MB, ডকুমেন্ট সর্বোচ্চ ১MB)।';

  @override
  String get error_server =>
      'সার্ভারে ত্রুটি হয়েছে। অনুগ্রহ করে পরে আবার চেষ্টা করুন।';

  @override
  String get error_geocoder_unavailable =>
      'ঠিকানা খোঁজার সেবাটি সাময়িকভাবে বন্ধ আছে।';

  @override
  String get error_unknown =>
      'কিছু একটা সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get btnRetry => 'আবার চেষ্টা করুন';

  @override
  String get btnCancel => 'বাতিল';

  @override
  String get btnSave => 'সংরক্ষণ করুন';

  @override
  String get btnSubmit => 'জমা দিন';

  @override
  String get emptyTitle => 'কিছু পাওয়া যায়নি';

  @override
  String get emptyMessage =>
      'এই মুহূর্তে কিছু পাওয়া যাচ্ছে না। অন্য শব্দে খুঁজুন বা ফিল্টার বদলে আবার চেষ্টা করুন।';

  @override
  String get offlineTitle => 'ইন্টারনেট সংযোগ নেই';

  @override
  String get offlineMessage => 'ইন্টারনেট সংযোগ চেক করে আবার চেষ্টা করুন।';

  @override
  String get authLogin => 'লগইন';

  @override
  String get authRegister => 'রেজিস্ট্রেশন';

  @override
  String get authEmail => 'ইমেইল';

  @override
  String get authPassword => 'পাসওয়ার্ড';

  @override
  String get authName => 'নাম';

  @override
  String get authPhone => 'ফোন নম্বর';

  @override
  String get authOtp => 'ওটিপি (OTP)';

  @override
  String get authVerify => 'যাচাই করুন';

  @override
  String get authResendOtp => 'পুনরায় ওটিপি পাঠান';

  @override
  String get authForgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get authResetPassword => 'পাসওয়ার্ড রিসেট';

  @override
  String get authLogout => 'লগআউট';

  @override
  String get authDoNotHaveAccount => 'অ্যাকাউন্ট নেই? রেজিস্ট্রেশন করুন';

  @override
  String get authAlreadyHaveAccount => 'ইতিমধ্যে অ্যাকাউন্ট আছে? লগইন করুন';

  @override
  String get authRoleTenant => 'ভাড়াটিয়া / ক্রেতা';

  @override
  String get authRoleOwner => 'মালিক / লিস্টার';

  @override
  String get authOtpInstruction =>
      'আপনার ইমেইলে ৬ ডিজিটের ওটিপি কোড পাঠানো হয়েছে।';

  @override
  String get authListerType => 'লিস্টার টাইপ';

  @override
  String get authSelectRole => 'আপনার ভূমিকা নির্বাচন করুন';

  @override
  String get authForgotPasswordTitle => 'পাসওয়ার্ড পুনরুদ্ধার';

  @override
  String get authForgotPasswordInstruction =>
      'আপনার অ্যাকাউন্টের ইমেইল দিন। পাসওয়ার্ড রিসেটের লিংক পাঠানো হবে।';

  @override
  String get authSendResetLink => 'রিসেট লিংক পাঠান';

  @override
  String get authResetLinkSent =>
      'পাসওয়ার্ড রিসেট লিংক আপনার ইমেইলে পাঠানো হয়েছে।';

  @override
  String get authNewPassword => 'নতুন পাসওয়ার্ড';

  @override
  String get authConfirmPassword => 'পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get authResetToken => 'রিসেট টোকেন';

  @override
  String get authPasswordResetSuccess =>
      'পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে। এখন লগইন করুন।';

  @override
  String get authBackToLogin => 'লগইনে ফিরে যান';

  @override
  String get navHome => 'হোম';

  @override
  String get navListings => 'তালিকা';

  @override
  String get navMap => 'মানচিত্র';

  @override
  String get navFavorites => 'পছন্দ';

  @override
  String get navProfile => 'প্রোফাইল';

  @override
  String get featuredListings => 'বিশেষ বিজ্ঞাপন';

  @override
  String get popularAreas => 'জনপ্রিয় এলাকা';

  @override
  String get recentRentListings => 'ভাড়ার নতুন বিজ্ঞাপন';

  @override
  String get recentSaleListings => 'বিক্রির নতুন বিজ্ঞাপন';

  @override
  String get filterTitle => 'ফিল্টার';

  @override
  String get filterApply => 'ফিল্টার প্রয়োগ করুন';

  @override
  String get filterReset => 'রিসেট';

  @override
  String get filterPurpose => 'বিজ্ঞাপনের ধরন';

  @override
  String get filterPropertyType => 'প্রপার্টির ধরন';

  @override
  String get filterBedrooms => 'বেডরুম';

  @override
  String get filterPriceRange => 'ভাড়া / মূল্য সীমা';

  @override
  String get filterVerifiedOnly => 'শুধু যাচাইকৃত বিজ্ঞাপন';

  @override
  String get all => 'সব';

  @override
  String get rent => 'ভাড়া';

  @override
  String get sale => 'বিক্রি';

  @override
  String get apartment => 'অ্যাপার্টমেন্ট';

  @override
  String get house => 'বাড়ি';

  @override
  String get room => 'রুম';

  @override
  String get shop => 'দোকান';

  @override
  String get office => 'অফিস';

  @override
  String get hotel => 'হোটেল';

  @override
  String get land => 'জমি';

  @override
  String get hostel => 'মেস / হোস্টেল';

  @override
  String get perMonth => '/মাস';

  @override
  String bedroomsCount(Object count) {
    return '$count বেড';
  }

  @override
  String bathroomsCount(Object count) {
    return '$count বাথ';
  }

  @override
  String sizeSqft(Object size) {
    return '$size বর্গফুট';
  }

  @override
  String get verifiedBadge => 'যাচাইকৃত';

  @override
  String viewCount(Object count) {
    return '$count জন দেখেছেন';
  }

  @override
  String get similarListings => 'অনুরূপ বিজ্ঞাপন';

  @override
  String get propertyOverview => 'বিস্তারিত তথ্য';

  @override
  String get amenities => 'সুবিধাসমূহ';

  @override
  String get address => 'ঠিকানা';

  @override
  String get floorNumber => 'তলা';

  @override
  String get sortNewest => 'নতুন আগে';

  @override
  String get sortPriceAsc => 'দাম কম থেকে বেশি';

  @override
  String get sortPriceDesc => 'দাম বেশি থেকে কম';

  @override
  String get sortPopular => 'জনপ্রিয়';

  @override
  String foundResults(Object count) {
    return '$countটি বিজ্ঞাপন পাওয়া গেছে';
  }

  @override
  String get contactOwner => 'বিজ্ঞাপনদাতার সাথে যোগাযোগ';

  @override
  String get callOwner => 'কল করুন';

  @override
  String get sendMessage => 'মেসেজ পাঠান';

  @override
  String get phoneRevealed => 'ফোন নম্বর';

  @override
  String get noPhoneAvailable => 'কোনো ফোন নম্বর পাওয়া যায়নি';

  @override
  String get inquiryMessage => 'আপনার মেসেজ লিখুন';

  @override
  String get inquiryPlaceholder =>
      'ফ্ল্যাটটি কি এখনো খালি আছে? আমি দেখতে চাই...';

  @override
  String get send => 'পাঠান';

  @override
  String get inquirySentSuccess => 'আপনার মেসেজ সফলভাবে পাঠানো হয়েছে!';

  @override
  String get selfInquiryError => 'নিজের বিজ্ঞাপনে মেসেজ পাঠানো যাবে না';

  @override
  String get loginToContact => 'যোগাযোগ করতে লগইন করুন';

  @override
  String get reportReason => 'রিপোর্টের কারণ নির্বাচন করুন';

  @override
  String get reasonScam => 'প্রতারণামূলক বা ভুয়া বিজ্ঞাপন';

  @override
  String get reasonWrongInfo => 'ভুল তথ্য দেওয়া হয়েছে';

  @override
  String get reasonAlreadyRented => 'ইতিমধ্যে ভাড়া বা বিক্রি হয়ে গেছে';

  @override
  String get reasonOffensive => 'আপত্তিকর বিষয়বস্তু';

  @override
  String get reasonOther => 'অন্যান্য';

  @override
  String get reportDetails => 'বিস্তারিত বিবরণ (ঐচ্ছিক)';

  @override
  String get submitReport => 'রিপোর্ট জমা দিন';

  @override
  String get reportSuccess =>
      'আপনার রিপোর্ট সফলভাবে জমা হয়েছে। পর্যালোচনার জন্য ধন্যবাদ।';

  @override
  String get ownListingReportError => 'নিজের বিজ্ঞাপন রিপোর্ট করা যাবে না';

  @override
  String get favoritesTitle => 'পছন্দের তালিকা';

  @override
  String get favoritesEmpty => 'কোনো বিজ্ঞাপন পছন্দ তালিকায় রাখা হয়নি';

  @override
  String get favoritesEmptySubtitle =>
      'যেকোনো বিজ্ঞাপনে হার্ট আইকনে চাপ দিলেই তা এখানে সংরক্ষিত থাকবে।';

  @override
  String get addToFavorites => 'পছন্দ তালিকায় যুক্ত করুন';

  @override
  String get removeFromFavorites => 'পছন্দ তালিকা থেকে সরান';

  @override
  String get addedToFavoritesSuccess => 'পছন্দ তালিকায় যুক্ত হয়েছে';

  @override
  String get removedFromFavoritesSuccess => 'পছন্দ তালিকা থেকে সরানো হয়েছে';

  @override
  String get loginToFavorite => 'বিজ্ঞাপন সেভ করতে লগইন করুন';

  @override
  String get browseListings => 'বিজ্ঞাপন দেখুন';

  @override
  String get mapTitle => 'মানচিত্র';

  @override
  String get searchPlaceHint => 'স্থান বা ঠিকানা খুঁজুন...';

  @override
  String get selectedLocation => 'নির্বাচিত এলাকা';

  @override
  String get nearbyListings => 'আশেপাশের বিজ্ঞাপন';

  @override
  String get noLocationListings => 'এই এলাকায় কোনো বিজ্ঞাপন পাওয়া যায়নি';

  @override
  String get viewList => 'তালিকা দেখুন';

  @override
  String get allAreas => 'সব এলাকা';

  @override
  String get mapRecenter => 'পুনরায় কেন্দ্র করুন';

  @override
  String get mapZoomIn => 'জুম ইন';

  @override
  String get mapZoomOut => 'জুম আউট';

  @override
  String get mapStyle => 'ম্যাপের ধরন';

  @override
  String get allMarket => 'সব মার্কেট';

  @override
  String get rentMarket => 'ভাড়া মার্কেট';

  @override
  String get saleMarket => 'বিক্রয় মার্কেট';

  @override
  String get viewDetails => 'বিস্তারিত দেখুন';

  @override
  String get landTitle => 'জমির বিজ্ঞাপন';

  @override
  String get landType => 'জমির ধরন';

  @override
  String get landTypeResidential => 'আবাসিক';

  @override
  String get landTypeCommercial => 'বাণিজ্যিক';

  @override
  String get landTypeAgricultural => 'কৃষি';

  @override
  String get landTypeIndustrial => 'শিল্প';

  @override
  String get landArea => 'জমির পরিমাপ';

  @override
  String get landRoadWidth => 'রাস্তার প্রস্থ';

  @override
  String landRoadWidthFt(Object width) {
    return '$width ফুট রাস্তা';
  }

  @override
  String get landFacing => 'মুখোমুখি';

  @override
  String get katha => 'কাঠা';

  @override
  String get bigha => 'বিঘা';

  @override
  String get shotok => 'শতক';

  @override
  String get decimal => 'ডেসিমেল';

  @override
  String foundLandResults(Object count) {
    return '$countটি জমির বিজ্ঞাপন পাওয়া গেছে';
  }

  @override
  String get noLandListings => 'কোনো জমির বিজ্ঞাপন পাওয়া যায়নি';

  @override
  String get dashboardTitle => 'ড্যাশবোর্ড';

  @override
  String get myListings => 'আমার বিজ্ঞাপন';

  @override
  String get postNewAd => 'বিজ্ঞাপন দিন';

  @override
  String get editListing => 'বিজ্ঞাপন সম্পাদনা';

  @override
  String get createListingTitle => 'নতুন বিজ্ঞাপন দিন';

  @override
  String get listingTitle => 'বিজ্ঞাপনের শিরোনাম';

  @override
  String get listingDescription => 'বিস্তারিত বর্ণনা';

  @override
  String get purpose => 'উদ্দেশ্য';

  @override
  String get city => 'শহর';

  @override
  String get area => 'এলাকা';

  @override
  String get unitNumber => 'ইউনিট নম্বর';

  @override
  String get bedrooms => 'বেডরুম';

  @override
  String get bathrooms => 'বাথরুম';

  @override
  String get size => 'আয়তন (বর্গফুট)';

  @override
  String get sizeLabel => 'আয়তন';

  @override
  String get priceRent => 'ভাড়া / দাম (টাকা)';

  @override
  String get contactPhone => 'যোগাযোগের ফোন নম্বর';

  @override
  String get allowDirectContact => 'সরাসরি ফোন যোগাযোগের অনুমতি দিন';

  @override
  String get photos => 'ছবি';

  @override
  String get uploadPhotos => 'ছবি যোগ করুন';

  @override
  String get submitListing => 'বিজ্ঞাপন পোস্ট করুন';

  @override
  String get updateListing => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get listingCreatedSuccess => 'বিজ্ঞাপন সফলভাবে তৈরি হয়েছে!';

  @override
  String get listingUpdatedSuccess => 'বিজ্ঞাপন সফলভাবে আপডেট হয়েছে!';

  @override
  String get totalListings => 'মোট বিজ্ঞাপন';

  @override
  String get activeListings => 'সক্রিয়';

  @override
  String get pendingListings => 'অপেক্ষমান';

  @override
  String get archivedListings => 'আর্কাইভ';

  @override
  String get views => 'ভিউ';

  @override
  String get saved => 'সেভ করা';

  @override
  String get status => 'অবস্থা';

  @override
  String get statusActive => 'সক্রিয়';

  @override
  String get statusPending => 'অপেক্ষমান';

  @override
  String get statusDraft => 'খসড়া';

  @override
  String get statusArchived => 'আর্কাইভকৃত';

  @override
  String get statusWithdrawn => 'প্রত্যাহারকৃত';

  @override
  String get actionSubmit => 'জমা দিন';

  @override
  String get actionWithdraw => 'প্রত্যাহার করুন';

  @override
  String get actionArchive => 'আর্কাইভ করুন';

  @override
  String get actionEdit => 'সম্পাদনা';

  @override
  String get verificationTitle => 'অ্যাকাউন্ট ভেরিফিকেশন';

  @override
  String get verificationSubtitle =>
      'যাচাইকৃত ব্যাজ পেতে আপনার জাতীয় পরিচয়পত্র বা ইউটিলিটি বিল আপলোড করুন';

  @override
  String get uploadDocument => 'ডকুমেন্ট আপলোড করুন';

  @override
  String get documentUploadedSuccess => 'ডকুমেন্ট সফলভাবে আপলোড হয়েছে';

  @override
  String get noDocumentsUploaded => 'কোনো ডকুমেন্ট আপলোড করা হয়নি';

  @override
  String get noOwnerListings => 'আপনার কোনো বিজ্ঞাপন নেই';

  @override
  String get noOwnerListingsSubtitle =>
      'আপনার সম্পত্তি ভাড়া বা বিক্রি করতে নতুন বিজ্ঞাপন পোস্ট করুন।';

  @override
  String get blogTitle => 'ব্লগ';

  @override
  String get qaTitle => 'প্রশ্নোত্তর';

  @override
  String get askQuestion => 'প্রশ্ন করুন';

  @override
  String get myQuestions => 'আমার প্রশ্ন';

  @override
  String get answers => 'উত্তর';

  @override
  String get writeAnswer => 'আপনার উত্তর লিখুন';

  @override
  String get postAnswer => 'উত্তর পোস্ট করুন';

  @override
  String get guidesTitle => 'গাইড';

  @override
  String get aboutTitle => 'আমাদের সম্পর্কে';

  @override
  String get contactUsTitle => 'যোগাযোগ';

  @override
  String get privacyTitle => 'প্রাইভেসি পলিসি';

  @override
  String get termsTitle => 'শর্তাবলী';

  @override
  String get helpTitle => 'হেল্প সেন্টার';

  @override
  String get infoServicesTitle => 'তথ্য সেবা';

  @override
  String get questionTitleLabel => 'প্রশ্নের শিরোনাম';

  @override
  String get questionBodyLabel => 'বিস্তারিত বিবরণ';

  @override
  String get categoryLabel => 'ক্যাটাগরি';

  @override
  String get submitQuestion => 'প্রশ্ন জমা দিন';

  @override
  String get comments => 'মন্তব্য';

  @override
  String get writeComment => 'একটি মন্তব্য লিখুন...';

  @override
  String get postComment => 'মন্তব্য করুন';

  @override
  String get readMore => 'আরও পড়ুন';

  @override
  String get pricingTitle => 'সাবস্ক্রিপশন প্ল্যান';

  @override
  String get pricingSubtitle => 'আপনার প্রয়োজন অনুযায়ী প্ল্যানটি বেছে নিন';

  @override
  String get vatExclusionNotice => 'সকল দাম ভ্যাট ছাড়া';

  @override
  String get mostPopular => 'জনপ্রিয়';

  @override
  String get currentPlan => 'বর্তমান প্ল্যান';

  @override
  String get choosePlan => 'প্ল্যান নির্বাচন করুন';

  @override
  String get contactSales => 'সেলস টিমের সাথে যোগাযোগ করুন';

  @override
  String get oneTime => 'এককালীন';

  @override
  String get freePrice => 'বিনামূল্যে';

  @override
  String get pricingFeaturesIncluded => 'সুবিধাসমূহ';

  @override
  String get unlimitedListings => 'সীমাহীন বিজ্ঞাপন';

  @override
  String get tenantAccountBannerTitle => 'ভাড়াটিয়া অ্যাকাউন্ট';

  @override
  String get tenantAccountBannerSubtitle =>
      'আপনি ভাড়াটিয়া হিসেবে লগইন করেছেন। বিজ্ঞাপনের বিস্তারিত অ্যানালিটিক্স প্রপার্টি মালিকদের জন্য প্রযোজ্য। আপনি কি প্রপার্টি বিজ্ঞাপন দিতে চান?';

  @override
  String get onboardingTitle1 => 'পছন্দের বাসা খুঁজুন';

  @override
  String get onboardingBody1 =>
      'মালিকদের দেওয়া ফ্ল্যাট, বাড়ি, রুম ও জমির বিজ্ঞাপন থেকে আপনার পছন্দেরটি বেছে নিন — কোনো মধ্যস্বত্বভোগী ছাড়াই।';

  @override
  String get onboardingTitle2 => 'সরাসরি বাড়িওয়ালার সাথে যোগাযোগ';

  @override
  String get onboardingBody2 =>
      'মালিকের নম্বরে কল করুন বা মেসেজ পাঠান — কোনো মধ্যস্বত্বভোগী নয়।';

  @override
  String get onboardingTitle3 => 'যাচাইকৃত ব্যাজ, সম্পূর্ণ বিনামূল্যে';

  @override
  String get onboardingBody3 =>
      'যাচাইকৃত ব্যাজ থাকা বিজ্ঞাপনগুলো আমাদের টিম যাচাই করে, আর ঘরবিডিতে খোঁজা সবসময়ই বিনামূল্যে।';

  @override
  String get onboardingSkip => 'এড়িয়ে যান';

  @override
  String get onboardingNext => 'পরবর্তী';

  @override
  String get onboardingStart => 'শুরু করুন';

  @override
  String get setupTitle => 'আপনার পছন্দ বেছে নিন';

  @override
  String get setupSubtitle =>
      'থিম ও ভাষা এখনই ঠিক করুন — পরে প্রোফাইল সেটিংস থেকেও বদলাতে পারবেন।';

  @override
  String get prefThemeLabel => 'থিম';

  @override
  String get prefLanguageLabel => 'ভাষা';

  @override
  String get themeOptionLight => 'লাইট';

  @override
  String get themeOptionDark => 'ডার্ক';

  @override
  String get themeOptionSystem => 'সিস্টেম';

  @override
  String get langOptionBanglaSub => 'বাংলায় অ্যাপ ব্যবহার করুন';

  @override
  String get langOptionEnglishSub => 'ইংরেজিতে অ্যাপ ব্যবহার করুন';

  @override
  String get settingsLanguageTitle => 'ভাষা নির্বাচন';

  @override
  String get settingsThemeTitle => 'থিম (Appearance)';

  @override
  String get authGoogleContinue => 'গুগল দিয়ে চালিয়ে যান';

  @override
  String get authOrDivider => 'অথবা';

  @override
  String get authLoginSubtitle => 'স্বাগতম — চালিয়ে যেতে লগইন করুন';

  @override
  String get authRegisterSubtitle => 'শুরু করতে একটি অ্যাকাউন্ট খুলুন';

  @override
  String get authRoleTenantCard => 'বাসা খুঁজছি';

  @override
  String get authRoleOwnerCard => 'আমার বাসা/সম্পত্তি ভাড়া দিতে চাই';

  @override
  String get authWhoAreYou => 'আপনি কে?';

  @override
  String get listerOwner => 'মালিক';

  @override
  String get listerAgent => 'এজেন্ট';

  @override
  String get listerBuilder => 'ডেভেলপার/কোম্পানি';

  @override
  String get validationNameRequired => 'পুরো নাম লিখুন';

  @override
  String get validationEmailRequired => 'ইমেইল লিখুন';

  @override
  String get validationEmailInvalid => 'সঠিক ইমেইল ঠিকানা দিন';

  @override
  String get validationPhoneRequired => 'মোবাইল নম্বর লিখুন';

  @override
  String get validationPhoneInvalid =>
      'সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন (01XXXXXXXXX)';

  @override
  String get validationPasswordRequired => 'পাসওয়ার্ড লিখুন';

  @override
  String get validationPasswordRule =>
      'পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে এবং এতে অক্ষর ও সংখ্যা দুটোই থাকতে হবে';

  @override
  String get authPhoneVerifyNote => 'যাচাইকরণের কোড এই নম্বরে পাঠানো হবে';

  @override
  String get authFullName => 'পুরো নাম';

  @override
  String get authMobileNumber => 'মোবাইল নম্বর';

  @override
  String get authTermsNote =>
      'চালিয়ে গেলে আপনি আমাদের শর্তাবলি ও গোপনীয়তা নীতিতে সম্মত হচ্ছেন।';

  @override
  String get googleSignInUnavailable =>
      'গুগল সাইন-ইন এখনো চালু হয়নি। ইমেইল দিয়ে চালিয়ে যান।';

  @override
  String get googleSignInCancelled => 'গুগল সাইন-ইন বাতিল করা হয়েছে।';

  @override
  String get filterMinPrice => 'সর্বনিম্ন ৳';

  @override
  String get filterMaxPrice => 'সর্বোচ্চ ৳';

  @override
  String get offlineBanner => 'ইন্টারনেট সংযোগ নেই — আগের তথ্য দেখানো হচ্ছে';

  @override
  String get shareListing => 'শেয়ার করুন';

  @override
  String get callFailed => 'কল করা যাচ্ছে না';
}
