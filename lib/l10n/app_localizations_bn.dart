// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'ঘরবিডি';

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
      'যোগাযোগের আগে বাসাটি সরাসরি দেখে নিন। অগ্রিম টাকা পাঠাবেন না।';

  @override
  String get reportListing => 'বিজ্ঞাপনটি রিপোর্ট করুন';

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
  String get error_unknown => 'অপ্রত্যাশিত কোনো ত্রুটি ঘটেছে।';

  @override
  String get btnRetry => 'আবার চেষ্টা করুন';

  @override
  String get btnCancel => 'বাতিল';

  @override
  String get btnSave => 'সংরক্ষণ করুন';

  @override
  String get btnSubmit => 'জমা দিন';

  @override
  String get emptyTitle => 'কোনো তথ্য পাওয়া যায়নি';

  @override
  String get emptyMessage => 'এখানে প্রদর্শনের মতো কোনো তথ্য নেই।';

  @override
  String get offlineTitle => 'অফলাইন মোড';

  @override
  String get offlineMessage => 'ইন্টারনেট সংযোগ চালু করুন।';

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
}
