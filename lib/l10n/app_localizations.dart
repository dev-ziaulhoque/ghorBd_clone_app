import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In bn, this message translates to:
  /// **'ঘরবিডি'**
  String get appName;

  /// No description provided for @heroTitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার পছন্দের ঘর খুঁজুন সহজেই'**
  String get heroTitle;

  /// No description provided for @searchHint.
  ///
  /// In bn, this message translates to:
  /// **'এলাকা, ধরন বা বাজেট দিয়ে খুঁজুন'**
  String get searchHint;

  /// No description provided for @loginToViewPhone.
  ///
  /// In bn, this message translates to:
  /// **'নম্বর দেখতে লগইন করুন'**
  String get loginToViewPhone;

  /// No description provided for @loginToSendMessage.
  ///
  /// In bn, this message translates to:
  /// **'মেসেজ পাঠাতে লগইন করুন'**
  String get loginToSendMessage;

  /// No description provided for @safetyNotice.
  ///
  /// In bn, this message translates to:
  /// **'যোগাযোগের আগে বাসাটি সরাসরি দেখে নিন। অগ্রিম টাকা পাঠাবেন না।'**
  String get safetyNotice;

  /// No description provided for @reportListing.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপনটি রিপোর্ট করুন'**
  String get reportListing;

  /// No description provided for @reportListingHint.
  ///
  /// In bn, this message translates to:
  /// **'ভুয়া, প্রতারণা বা ভুল তথ্য? আমাদের জানান।'**
  String get reportListingHint;

  /// No description provided for @noMapLocationNotice.
  ///
  /// In bn, this message translates to:
  /// **'এই বিজ্ঞাপনের অবস্থান দেওয়া নেই, তাই এটি মানচিত্রে নেই।'**
  String get noMapLocationNotice;

  /// No description provided for @error_network.
  ///
  /// In bn, this message translates to:
  /// **'ইন্টারনেট সংযোগ নেই। আপনার নেটওয়ার্ক চেক করুন।'**
  String get error_network;

  /// No description provided for @error_timeout.
  ///
  /// In bn, this message translates to:
  /// **'সংযোগের সময় শেষ হয়েছে। আবার চেষ্টা করুন।'**
  String get error_timeout;

  /// No description provided for @error_unauthorized.
  ///
  /// In bn, this message translates to:
  /// **'অনুগ্রহ করে লগইন করুন।'**
  String get error_unauthorized;

  /// No description provided for @error_token_expired.
  ///
  /// In bn, this message translates to:
  /// **'সেশনের মেয়াদ শেষ হয়েছে, আবার লগইন করুন।'**
  String get error_token_expired;

  /// No description provided for @error_token_invalid.
  ///
  /// In bn, this message translates to:
  /// **'টোকেন সঠিক নয়। আবার লগইন করুন।'**
  String get error_token_invalid;

  /// No description provided for @error_invalid_credentials.
  ///
  /// In bn, this message translates to:
  /// **'ভুল ইমেইল বা পাসওয়ার্ড।'**
  String get error_invalid_credentials;

  /// No description provided for @error_refresh_token_invalid.
  ///
  /// In bn, this message translates to:
  /// **'লগইন সেশন অবৈধ হয়েছে। আবার লগইন করুন।'**
  String get error_refresh_token_invalid;

  /// No description provided for @error_password_changed.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড পরিবর্তিত হয়েছে। আবার লগইন করুন।'**
  String get error_password_changed;

  /// No description provided for @error_account_missing.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্টটি পাওয়া যায়নি।'**
  String get error_account_missing;

  /// No description provided for @error_forbidden.
  ///
  /// In bn, this message translates to:
  /// **'এই অ্যাকশনটি সম্পাদন করার অনুমতি আপনার নেই।'**
  String get error_forbidden;

  /// No description provided for @error_email_not_verified.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল যাচাই করা হয়নি। কোড দিয়ে যাচাই করুন।'**
  String get error_email_not_verified;

  /// No description provided for @error_not_found.
  ///
  /// In bn, this message translates to:
  /// **'তথ্যটি পাওয়া যায়নি।'**
  String get error_not_found;

  /// No description provided for @error_no_contact_phone.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপনদাতার ফোন নম্বর পাওয়া যায়নি।'**
  String get error_no_contact_phone;

  /// No description provided for @error_question_not_found.
  ///
  /// In bn, this message translates to:
  /// **'প্রশ্নটি পাওয়া যায়নি।'**
  String get error_question_not_found;

  /// No description provided for @error_conflict.
  ///
  /// In bn, this message translates to:
  /// **'তথ্যটি ইতিমধ্যেই বিদ্যমান বা সংঘাত তৈরি করছে।'**
  String get error_conflict;

  /// No description provided for @error_account_exists.
  ///
  /// In bn, this message translates to:
  /// **'এই ইমেইল দিয়ে ইতিমধ্যে অ্যাকাউন্ট খোলা আছে।'**
  String get error_account_exists;

  /// No description provided for @error_duplicate_listing.
  ///
  /// In bn, this message translates to:
  /// **'একই বিজ্ঞাপন ইতিমধ্যে দেওয়া আছে।'**
  String get error_duplicate_listing;

  /// No description provided for @error_invalid_transition.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপনের এই স্ট্যাটাস পরিবর্তনটি বৈধ নয়।'**
  String get error_invalid_transition;

  /// No description provided for @error_already_reported.
  ///
  /// In bn, this message translates to:
  /// **'আপনি ইতিমধ্যে এই বিজ্ঞাপনে রিপোর্ট করেছেন।'**
  String get error_already_reported;

  /// No description provided for @error_area_in_use.
  ///
  /// In bn, this message translates to:
  /// **'এই এলাকাটি ইতিমধ্যে ব্যবহৃত হচ্ছে।'**
  String get error_area_in_use;

  /// No description provided for @error_validation.
  ///
  /// In bn, this message translates to:
  /// **'প্রদত্ত তথ্য সঠিক নয়। অনুগ্রহ করে সংশোধন করুন।'**
  String get error_validation;

  /// No description provided for @error_invalid_id.
  ///
  /// In bn, this message translates to:
  /// **'আইডি সঠিক নয়।'**
  String get error_invalid_id;

  /// No description provided for @error_reset_token_invalid.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড রিসেট টোকেন মেয়াদোত্তীর্ণ বা অবৈধ।'**
  String get error_reset_token_invalid;

  /// No description provided for @error_email_otp_invalid.
  ///
  /// In bn, this message translates to:
  /// **'ভুল ওটিপি (OTP) কোড।'**
  String get error_email_otp_invalid;

  /// No description provided for @error_email_otp_expired.
  ///
  /// In bn, this message translates to:
  /// **'ওটিপি (OTP) কোডের মেয়াদ শেষ হয়েছে।'**
  String get error_email_otp_expired;

  /// No description provided for @error_document_limit_reached.
  ///
  /// In bn, this message translates to:
  /// **'সর্বোচ্চ সংখ্যক ডকুমেন্ট আপলোড করা হয়েছে।'**
  String get error_document_limit_reached;

  /// No description provided for @error_self_inquiry.
  ///
  /// In bn, this message translates to:
  /// **'নিজের বিজ্ঞাপনে অনুসন্ধান পাঠানো যাবে না।'**
  String get error_self_inquiry;

  /// No description provided for @error_own_listing.
  ///
  /// In bn, this message translates to:
  /// **'নিজের বিজ্ঞাপনে এই কাজটি করা যাবে না।'**
  String get error_own_listing;

  /// No description provided for @error_rate_limit.
  ///
  /// In bn, this message translates to:
  /// **'অতিরিক্ত অনুরোধ পাঠানো হয়েছে। অনুগ্রহ করে কিছুক্ষণ অপেক্ষা করুন।'**
  String get error_rate_limit;

  /// No description provided for @error_email_otp_attempts.
  ///
  /// In bn, this message translates to:
  /// **'অনেকবার ভুল কোড দেওয়া হয়েছে। নতুন কোডের অনুরোধ করুন।'**
  String get error_email_otp_attempts;

  /// No description provided for @error_file_too_large.
  ///
  /// In bn, this message translates to:
  /// **'ফাইলের সাইজ সীমার চেয়ে বেশি (ছবি সর্বোচ্চ ৫MB, ডকুমেন্ট সর্বোচ্চ ১MB)।'**
  String get error_file_too_large;

  /// No description provided for @error_server.
  ///
  /// In bn, this message translates to:
  /// **'সার্ভারে ত্রুটি হয়েছে। অনুগ্রহ করে পরে আবার চেষ্টা করুন।'**
  String get error_server;

  /// No description provided for @error_geocoder_unavailable.
  ///
  /// In bn, this message translates to:
  /// **'ঠিকানা খোঁজার সেবাটি সাময়িকভাবে বন্ধ আছে।'**
  String get error_geocoder_unavailable;

  /// No description provided for @error_unknown.
  ///
  /// In bn, this message translates to:
  /// **'অপ্রত্যাশিত কোনো ত্রুটি ঘটেছে।'**
  String get error_unknown;

  /// No description provided for @btnRetry.
  ///
  /// In bn, this message translates to:
  /// **'আবার চেষ্টা করুন'**
  String get btnRetry;

  /// No description provided for @btnCancel.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল'**
  String get btnCancel;

  /// No description provided for @btnSave.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ করুন'**
  String get btnSave;

  /// No description provided for @btnSubmit.
  ///
  /// In bn, this message translates to:
  /// **'জমা দিন'**
  String get btnSubmit;

  /// No description provided for @emptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'কোনো তথ্য পাওয়া যায়নি'**
  String get emptyTitle;

  /// No description provided for @emptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'এখানে প্রদর্শনের মতো কোনো তথ্য নেই।'**
  String get emptyMessage;

  /// No description provided for @offlineTitle.
  ///
  /// In bn, this message translates to:
  /// **'অফলাইন মোড'**
  String get offlineTitle;

  /// No description provided for @offlineMessage.
  ///
  /// In bn, this message translates to:
  /// **'ইন্টারনেট সংযোগ চালু করুন।'**
  String get offlineMessage;

  /// No description provided for @authLogin.
  ///
  /// In bn, this message translates to:
  /// **'লগইন'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In bn, this message translates to:
  /// **'রেজিস্ট্রেশন'**
  String get authRegister;

  /// No description provided for @authEmail.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড'**
  String get authPassword;

  /// No description provided for @authName.
  ///
  /// In bn, this message translates to:
  /// **'নাম'**
  String get authName;

  /// No description provided for @authPhone.
  ///
  /// In bn, this message translates to:
  /// **'ফোন নম্বর'**
  String get authPhone;

  /// No description provided for @authOtp.
  ///
  /// In bn, this message translates to:
  /// **'ওটিপি (OTP)'**
  String get authOtp;

  /// No description provided for @authVerify.
  ///
  /// In bn, this message translates to:
  /// **'যাচাই করুন'**
  String get authVerify;

  /// No description provided for @authResendOtp.
  ///
  /// In bn, this message translates to:
  /// **'পুনরায় ওটিপি পাঠান'**
  String get authResendOtp;

  /// No description provided for @authForgotPassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড ভুলে গেছেন?'**
  String get authForgotPassword;

  /// No description provided for @authResetPassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড রিসেট'**
  String get authResetPassword;

  /// No description provided for @authLogout.
  ///
  /// In bn, this message translates to:
  /// **'লগআউট'**
  String get authLogout;

  /// No description provided for @authDoNotHaveAccount.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট নেই? রেজিস্ট্রেশন করুন'**
  String get authDoNotHaveAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In bn, this message translates to:
  /// **'ইতিমধ্যে অ্যাকাউন্ট আছে? লগইন করুন'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authRoleTenant.
  ///
  /// In bn, this message translates to:
  /// **'ভাড়াটিয়া / ক্রেতা'**
  String get authRoleTenant;

  /// No description provided for @authRoleOwner.
  ///
  /// In bn, this message translates to:
  /// **'মালিক / লিস্টার'**
  String get authRoleOwner;

  /// No description provided for @authOtpInstruction.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ইমেইলে ৬ ডিজিটের ওটিপি কোড পাঠানো হয়েছে।'**
  String get authOtpInstruction;

  /// No description provided for @authListerType.
  ///
  /// In bn, this message translates to:
  /// **'লিস্টার টাইপ'**
  String get authListerType;

  /// No description provided for @authSelectRole.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ভূমিকা নির্বাচন করুন'**
  String get authSelectRole;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড পুনরুদ্ধার'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordInstruction.
  ///
  /// In bn, this message translates to:
  /// **'আপনার অ্যাকাউন্টের ইমেইল দিন। পাসওয়ার্ড রিসেটের লিংক পাঠানো হবে।'**
  String get authForgotPasswordInstruction;

  /// No description provided for @authSendResetLink.
  ///
  /// In bn, this message translates to:
  /// **'রিসেট লিংক পাঠান'**
  String get authSendResetLink;

  /// No description provided for @authResetLinkSent.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড রিসেট লিংক আপনার ইমেইলে পাঠানো হয়েছে।'**
  String get authResetLinkSent;

  /// No description provided for @authNewPassword.
  ///
  /// In bn, this message translates to:
  /// **'নতুন পাসওয়ার্ড'**
  String get authNewPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড নিশ্চিত করুন'**
  String get authConfirmPassword;

  /// No description provided for @authResetToken.
  ///
  /// In bn, this message translates to:
  /// **'রিসেট টোকেন'**
  String get authResetToken;

  /// No description provided for @authPasswordResetSuccess.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে। এখন লগইন করুন।'**
  String get authPasswordResetSuccess;

  /// No description provided for @authBackToLogin.
  ///
  /// In bn, this message translates to:
  /// **'লগইনে ফিরে যান'**
  String get authBackToLogin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
