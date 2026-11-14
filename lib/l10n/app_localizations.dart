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
  /// **'বিজ্ঞাপন রিপোর্ট করুন'**
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

  /// No description provided for @navHome.
  ///
  /// In bn, this message translates to:
  /// **'হোম'**
  String get navHome;

  /// No description provided for @navListings.
  ///
  /// In bn, this message translates to:
  /// **'তালিকা'**
  String get navListings;

  /// No description provided for @navMap.
  ///
  /// In bn, this message translates to:
  /// **'মানচিত্র'**
  String get navMap;

  /// No description provided for @navFavorites.
  ///
  /// In bn, this message translates to:
  /// **'পছন্দ'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In bn, this message translates to:
  /// **'প্রোফাইল'**
  String get navProfile;

  /// No description provided for @featuredListings.
  ///
  /// In bn, this message translates to:
  /// **'বিশেষ বিজ্ঞাপন'**
  String get featuredListings;

  /// No description provided for @popularAreas.
  ///
  /// In bn, this message translates to:
  /// **'জনপ্রিয় এলাকা'**
  String get popularAreas;

  /// No description provided for @recentRentListings.
  ///
  /// In bn, this message translates to:
  /// **'ভাড়ার নতুন বিজ্ঞাপন'**
  String get recentRentListings;

  /// No description provided for @recentSaleListings.
  ///
  /// In bn, this message translates to:
  /// **'বিক্রির বিজ্ঞাপন'**
  String get recentSaleListings;

  /// No description provided for @filterTitle.
  ///
  /// In bn, this message translates to:
  /// **'ফিল্টার'**
  String get filterTitle;

  /// No description provided for @filterApply.
  ///
  /// In bn, this message translates to:
  /// **'ফিল্টার প্রয়োগ করুন'**
  String get filterApply;

  /// No description provided for @filterReset.
  ///
  /// In bn, this message translates to:
  /// **'রিসেট'**
  String get filterReset;

  /// No description provided for @filterPurpose.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপনের ধরন'**
  String get filterPurpose;

  /// No description provided for @filterPropertyType.
  ///
  /// In bn, this message translates to:
  /// **'প্রপার্টির ধরন'**
  String get filterPropertyType;

  /// No description provided for @filterBedrooms.
  ///
  /// In bn, this message translates to:
  /// **'বেডরুম'**
  String get filterBedrooms;

  /// No description provided for @filterPriceRange.
  ///
  /// In bn, this message translates to:
  /// **'ভাড়া / মূল্য সীমা'**
  String get filterPriceRange;

  /// No description provided for @filterVerifiedOnly.
  ///
  /// In bn, this message translates to:
  /// **'শুধু যাচাইকৃত বিজ্ঞাপন'**
  String get filterVerifiedOnly;

  /// No description provided for @all.
  ///
  /// In bn, this message translates to:
  /// **'সব'**
  String get all;

  /// No description provided for @rent.
  ///
  /// In bn, this message translates to:
  /// **'ভাড়া'**
  String get rent;

  /// No description provided for @sale.
  ///
  /// In bn, this message translates to:
  /// **'বিক্রি'**
  String get sale;

  /// No description provided for @apartment.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাপার্টমেন্ট'**
  String get apartment;

  /// No description provided for @house.
  ///
  /// In bn, this message translates to:
  /// **'বাড়ি'**
  String get house;

  /// No description provided for @room.
  ///
  /// In bn, this message translates to:
  /// **'রুম'**
  String get room;

  /// No description provided for @shop.
  ///
  /// In bn, this message translates to:
  /// **'দোকান'**
  String get shop;

  /// No description provided for @office.
  ///
  /// In bn, this message translates to:
  /// **'অফিস'**
  String get office;

  /// No description provided for @land.
  ///
  /// In bn, this message translates to:
  /// **'জমি'**
  String get land;

  /// No description provided for @hostel.
  ///
  /// In bn, this message translates to:
  /// **'মেস / হোস্টেল'**
  String get hostel;

  /// No description provided for @perMonth.
  ///
  /// In bn, this message translates to:
  /// **'/মাস'**
  String get perMonth;

  /// No description provided for @bedroomsCount.
  ///
  /// In bn, this message translates to:
  /// **'{count} বেড'**
  String bedroomsCount(Object count);

  /// No description provided for @bathroomsCount.
  ///
  /// In bn, this message translates to:
  /// **'{count} বাথ'**
  String bathroomsCount(Object count);

  /// No description provided for @sizeSqft.
  ///
  /// In bn, this message translates to:
  /// **'{size} বর্গফুট'**
  String sizeSqft(Object size);

  /// No description provided for @verifiedBadge.
  ///
  /// In bn, this message translates to:
  /// **'যাচাইকৃত'**
  String get verifiedBadge;

  /// No description provided for @viewCount.
  ///
  /// In bn, this message translates to:
  /// **'{count} জন দেখেছেন'**
  String viewCount(Object count);

  /// No description provided for @similarListings.
  ///
  /// In bn, this message translates to:
  /// **'অনুরূপ বিজ্ঞাপন'**
  String get similarListings;

  /// No description provided for @propertyOverview.
  ///
  /// In bn, this message translates to:
  /// **'বিস্তারিত তথ্য'**
  String get propertyOverview;

  /// No description provided for @amenities.
  ///
  /// In bn, this message translates to:
  /// **'সুবিধাসমূহ'**
  String get amenities;

  /// No description provided for @address.
  ///
  /// In bn, this message translates to:
  /// **'ঠিকানা'**
  String get address;

  /// No description provided for @floorNumber.
  ///
  /// In bn, this message translates to:
  /// **'তলা'**
  String get floorNumber;

  /// No description provided for @sortNewest.
  ///
  /// In bn, this message translates to:
  /// **'নতুন আগে'**
  String get sortNewest;

  /// No description provided for @sortPriceAsc.
  ///
  /// In bn, this message translates to:
  /// **'দাম কম থেকে বেশি'**
  String get sortPriceAsc;

  /// No description provided for @sortPriceDesc.
  ///
  /// In bn, this message translates to:
  /// **'দাম বেশি থেকে কম'**
  String get sortPriceDesc;

  /// No description provided for @sortPopular.
  ///
  /// In bn, this message translates to:
  /// **'জনপ্রিয়'**
  String get sortPopular;

  /// No description provided for @foundResults.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি বিজ্ঞাপন পাওয়া গেছে'**
  String foundResults(Object count);

  /// No description provided for @contactOwner.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপনদাতার সাথে যোগাযোগ'**
  String get contactOwner;

  /// No description provided for @callOwner.
  ///
  /// In bn, this message translates to:
  /// **'কল করুন'**
  String get callOwner;

  /// No description provided for @sendMessage.
  ///
  /// In bn, this message translates to:
  /// **'মেসেজ পাঠান'**
  String get sendMessage;

  /// No description provided for @phoneRevealed.
  ///
  /// In bn, this message translates to:
  /// **'ফোন নম্বর'**
  String get phoneRevealed;

  /// No description provided for @noPhoneAvailable.
  ///
  /// In bn, this message translates to:
  /// **'কোনো ফোন নম্বর পাওয়া যায়নি'**
  String get noPhoneAvailable;

  /// No description provided for @inquiryMessage.
  ///
  /// In bn, this message translates to:
  /// **'আপনার মেসেজ লিখুন'**
  String get inquiryMessage;

  /// No description provided for @inquiryPlaceholder.
  ///
  /// In bn, this message translates to:
  /// **'ফ্ল্যাটটি কি এখনো খালি আছে? আমি দেখতে চাই...'**
  String get inquiryPlaceholder;

  /// No description provided for @send.
  ///
  /// In bn, this message translates to:
  /// **'পাঠান'**
  String get send;

  /// No description provided for @inquirySentSuccess.
  ///
  /// In bn, this message translates to:
  /// **'আপনার মেসেজ সফলভাবে পাঠানো হয়েছে!'**
  String get inquirySentSuccess;

  /// No description provided for @selfInquiryError.
  ///
  /// In bn, this message translates to:
  /// **'নিজের বিজ্ঞাপনে মেসেজ পাঠানো যাবে না'**
  String get selfInquiryError;

  /// No description provided for @loginToContact.
  ///
  /// In bn, this message translates to:
  /// **'যোগাযোগ করতে লগইন করুন'**
  String get loginToContact;

  /// No description provided for @reportReason.
  ///
  /// In bn, this message translates to:
  /// **'রিপোর্টের কারণ নির্বাচন করুন'**
  String get reportReason;

  /// No description provided for @reasonScam.
  ///
  /// In bn, this message translates to:
  /// **'প্রতারণামূলক বা ভুয়া বিজ্ঞাপন'**
  String get reasonScam;

  /// No description provided for @reasonWrongInfo.
  ///
  /// In bn, this message translates to:
  /// **'ভুল তথ্য দেওয়া হয়েছে'**
  String get reasonWrongInfo;

  /// No description provided for @reasonAlreadyRented.
  ///
  /// In bn, this message translates to:
  /// **'ইতিমধ্যে ভাড়া বা বিক্রি হয়ে গেছে'**
  String get reasonAlreadyRented;

  /// No description provided for @reasonOffensive.
  ///
  /// In bn, this message translates to:
  /// **'আপত্তিকর বিষয়বস্তু'**
  String get reasonOffensive;

  /// No description provided for @reasonOther.
  ///
  /// In bn, this message translates to:
  /// **'অন্যান্য'**
  String get reasonOther;

  /// No description provided for @reportDetails.
  ///
  /// In bn, this message translates to:
  /// **'বিস্তারিত বিবরণ (ঐচ্ছিক)'**
  String get reportDetails;

  /// No description provided for @submitReport.
  ///
  /// In bn, this message translates to:
  /// **'রিপোর্ট জমা দিন'**
  String get submitReport;

  /// No description provided for @reportSuccess.
  ///
  /// In bn, this message translates to:
  /// **'আপনার রিপোর্ট সফলভাবে জমা হয়েছে। পর্যালোচনার জন্য ধন্যবাদ।'**
  String get reportSuccess;

  /// No description provided for @ownListingReportError.
  ///
  /// In bn, this message translates to:
  /// **'নিজের বিজ্ঞাপন রিপোর্ট করা যাবে না'**
  String get ownListingReportError;

  /// No description provided for @favoritesTitle.
  ///
  /// In bn, this message translates to:
  /// **'পছন্দের তালিকা'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In bn, this message translates to:
  /// **'কোনো বিজ্ঞাপন পছন্দ তালিকায় রাখা হয়নি'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার পছন্দের ফ্ল্যাট বা জমির বিজ্ঞাপনগুলো পরবর্তীতে সহজে দেখতে এখানে সংরক্ষণ করুন।'**
  String get favoritesEmptySubtitle;

  /// No description provided for @addToFavorites.
  ///
  /// In bn, this message translates to:
  /// **'পছন্দ তালিকায় যুক্ত করুন'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In bn, this message translates to:
  /// **'পছন্দ তালিকা থেকে সরান'**
  String get removeFromFavorites;

  /// No description provided for @addedToFavoritesSuccess.
  ///
  /// In bn, this message translates to:
  /// **'পছন্দ তালিকায় যুক্ত হয়েছে'**
  String get addedToFavoritesSuccess;

  /// No description provided for @removedFromFavoritesSuccess.
  ///
  /// In bn, this message translates to:
  /// **'পছন্দ তালিকা থেকে সরানো হয়েছে'**
  String get removedFromFavoritesSuccess;

  /// No description provided for @loginToFavorite.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপন সেভ করতে লগইন করুন'**
  String get loginToFavorite;

  /// No description provided for @browseListings.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপন দেখুন'**
  String get browseListings;

  /// No description provided for @mapTitle.
  ///
  /// In bn, this message translates to:
  /// **'মানচিত্র'**
  String get mapTitle;

  /// No description provided for @searchPlaceHint.
  ///
  /// In bn, this message translates to:
  /// **'স্থান বা ঠিকানা খুঁজুন...'**
  String get searchPlaceHint;

  /// No description provided for @selectedLocation.
  ///
  /// In bn, this message translates to:
  /// **'নির্বাচিত এলাকা'**
  String get selectedLocation;

  /// No description provided for @nearbyListings.
  ///
  /// In bn, this message translates to:
  /// **'আশেপাশের বিজ্ঞাপন'**
  String get nearbyListings;

  /// No description provided for @noLocationListings.
  ///
  /// In bn, this message translates to:
  /// **'এই এলাকায় কোনো বিজ্ঞাপন পাওয়া যায়নি'**
  String get noLocationListings;

  /// No description provided for @landTitle.
  ///
  /// In bn, this message translates to:
  /// **'জমির বিজ্ঞাপন'**
  String get landTitle;

  /// No description provided for @landType.
  ///
  /// In bn, this message translates to:
  /// **'জমির ধরন'**
  String get landType;

  /// No description provided for @landTypeResidential.
  ///
  /// In bn, this message translates to:
  /// **'আবাসিক'**
  String get landTypeResidential;

  /// No description provided for @landTypeCommercial.
  ///
  /// In bn, this message translates to:
  /// **'বাণিজ্যিক'**
  String get landTypeCommercial;

  /// No description provided for @landTypeAgricultural.
  ///
  /// In bn, this message translates to:
  /// **'কৃষি'**
  String get landTypeAgricultural;

  /// No description provided for @landTypeIndustrial.
  ///
  /// In bn, this message translates to:
  /// **'শিল্প'**
  String get landTypeIndustrial;

  /// No description provided for @landArea.
  ///
  /// In bn, this message translates to:
  /// **'জমির পরিমাপ'**
  String get landArea;

  /// No description provided for @landRoadWidth.
  ///
  /// In bn, this message translates to:
  /// **'রাস্তার প্রস্থ'**
  String get landRoadWidth;

  /// No description provided for @landRoadWidthFt.
  ///
  /// In bn, this message translates to:
  /// **'{width} ফুট রাস্তা'**
  String landRoadWidthFt(Object width);

  /// No description provided for @landFacing.
  ///
  /// In bn, this message translates to:
  /// **'মুখোমুখি'**
  String get landFacing;

  /// No description provided for @katha.
  ///
  /// In bn, this message translates to:
  /// **'কাঠা'**
  String get katha;

  /// No description provided for @bigha.
  ///
  /// In bn, this message translates to:
  /// **'বিঘা'**
  String get bigha;

  /// No description provided for @shotok.
  ///
  /// In bn, this message translates to:
  /// **'শতক'**
  String get shotok;

  /// No description provided for @decimal.
  ///
  /// In bn, this message translates to:
  /// **'ডেসিমেল'**
  String get decimal;

  /// No description provided for @foundLandResults.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি জমির বিজ্ঞাপন পাওয়া গেছে'**
  String foundLandResults(Object count);

  /// No description provided for @noLandListings.
  ///
  /// In bn, this message translates to:
  /// **'কোনো জমির বিজ্ঞাপন পাওয়া যায়নি'**
  String get noLandListings;

  /// No description provided for @dashboardTitle.
  ///
  /// In bn, this message translates to:
  /// **'ড্যাশবোর্ড'**
  String get dashboardTitle;

  /// No description provided for @myListings.
  ///
  /// In bn, this message translates to:
  /// **'আমার বিজ্ঞাপন'**
  String get myListings;

  /// No description provided for @postNewAd.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপন দিন'**
  String get postNewAd;

  /// No description provided for @editListing.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপন সম্পাদনা'**
  String get editListing;

  /// No description provided for @createListingTitle.
  ///
  /// In bn, this message translates to:
  /// **'নতুন বিজ্ঞাপন দিন'**
  String get createListingTitle;

  /// No description provided for @listingTitle.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপনের শিরোনাম'**
  String get listingTitle;

  /// No description provided for @listingDescription.
  ///
  /// In bn, this message translates to:
  /// **'বিস্তারিত বর্ণনা'**
  String get listingDescription;

  /// No description provided for @purpose.
  ///
  /// In bn, this message translates to:
  /// **'উদ্দেশ্য'**
  String get purpose;

  /// No description provided for @city.
  ///
  /// In bn, this message translates to:
  /// **'শহর'**
  String get city;

  /// No description provided for @area.
  ///
  /// In bn, this message translates to:
  /// **'এলাকা'**
  String get area;

  /// No description provided for @unitNumber.
  ///
  /// In bn, this message translates to:
  /// **'ইউনিট নম্বর'**
  String get unitNumber;

  /// No description provided for @bedrooms.
  ///
  /// In bn, this message translates to:
  /// **'বেডরুম'**
  String get bedrooms;

  /// No description provided for @bathrooms.
  ///
  /// In bn, this message translates to:
  /// **'বাথরুম'**
  String get bathrooms;

  /// No description provided for @size.
  ///
  /// In bn, this message translates to:
  /// **'আয়তন (বর্গফুট)'**
  String get size;

  /// No description provided for @priceRent.
  ///
  /// In bn, this message translates to:
  /// **'ভাড়া / দাম (টাকা)'**
  String get priceRent;

  /// No description provided for @contactPhone.
  ///
  /// In bn, this message translates to:
  /// **'যোগাযোগের ফোন নম্বর'**
  String get contactPhone;

  /// No description provided for @allowDirectContact.
  ///
  /// In bn, this message translates to:
  /// **'সরাসরি ফোন যোগাযোগের অনুমতি দিন'**
  String get allowDirectContact;

  /// No description provided for @photos.
  ///
  /// In bn, this message translates to:
  /// **'ছবি'**
  String get photos;

  /// No description provided for @uploadPhotos.
  ///
  /// In bn, this message translates to:
  /// **'ছবি যোগ করুন'**
  String get uploadPhotos;

  /// No description provided for @submitListing.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপন পোস্ট করুন'**
  String get submitListing;

  /// No description provided for @updateListing.
  ///
  /// In bn, this message translates to:
  /// **'পরিবর্তন সংরক্ষণ করুন'**
  String get updateListing;

  /// No description provided for @listingCreatedSuccess.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপন সফলভাবে তৈরি হয়েছে!'**
  String get listingCreatedSuccess;

  /// No description provided for @listingUpdatedSuccess.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপন সফলভাবে আপডেট হয়েছে!'**
  String get listingUpdatedSuccess;

  /// No description provided for @totalListings.
  ///
  /// In bn, this message translates to:
  /// **'মোট বিজ্ঞাপন'**
  String get totalListings;

  /// No description provided for @activeListings.
  ///
  /// In bn, this message translates to:
  /// **'সক্রিয়'**
  String get activeListings;

  /// No description provided for @pendingListings.
  ///
  /// In bn, this message translates to:
  /// **'অপেক্ষমান'**
  String get pendingListings;

  /// No description provided for @archivedListings.
  ///
  /// In bn, this message translates to:
  /// **'আর্কাইভ'**
  String get archivedListings;

  /// No description provided for @views.
  ///
  /// In bn, this message translates to:
  /// **'ভিউ'**
  String get views;

  /// No description provided for @saved.
  ///
  /// In bn, this message translates to:
  /// **'সেভ করা'**
  String get saved;

  /// No description provided for @status.
  ///
  /// In bn, this message translates to:
  /// **'অবস্থা'**
  String get status;

  /// No description provided for @statusActive.
  ///
  /// In bn, this message translates to:
  /// **'সক্রিয়'**
  String get statusActive;

  /// No description provided for @statusPending.
  ///
  /// In bn, this message translates to:
  /// **'অপেক্ষমান'**
  String get statusPending;

  /// No description provided for @statusDraft.
  ///
  /// In bn, this message translates to:
  /// **'খসড়া'**
  String get statusDraft;

  /// No description provided for @statusArchived.
  ///
  /// In bn, this message translates to:
  /// **'আর্কাইভকৃত'**
  String get statusArchived;

  /// No description provided for @statusWithdrawn.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাহারকৃত'**
  String get statusWithdrawn;

  /// No description provided for @actionSubmit.
  ///
  /// In bn, this message translates to:
  /// **'জমা দিন'**
  String get actionSubmit;

  /// No description provided for @actionWithdraw.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাহার করুন'**
  String get actionWithdraw;

  /// No description provided for @actionArchive.
  ///
  /// In bn, this message translates to:
  /// **'আর্কাইভ করুন'**
  String get actionArchive;

  /// No description provided for @actionEdit.
  ///
  /// In bn, this message translates to:
  /// **'সম্পাদনা'**
  String get actionEdit;

  /// No description provided for @verificationTitle.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট ভেরিফিকেশন'**
  String get verificationTitle;

  /// No description provided for @verificationSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'যাচাইকৃত ব্যাজ পেতে আপনার জাতীয় পরিচয়পত্র বা ইউটিলিটি বিল আপলোড করুন'**
  String get verificationSubtitle;

  /// No description provided for @uploadDocument.
  ///
  /// In bn, this message translates to:
  /// **'ডকুমেন্ট আপলোড করুন'**
  String get uploadDocument;

  /// No description provided for @documentUploadedSuccess.
  ///
  /// In bn, this message translates to:
  /// **'ডকুমেন্ট সফলভাবে আপলোড হয়েছে'**
  String get documentUploadedSuccess;

  /// No description provided for @noDocumentsUploaded.
  ///
  /// In bn, this message translates to:
  /// **'কোনো ডকুমেন্ট আপলোড করা হয়নি'**
  String get noDocumentsUploaded;

  /// No description provided for @noOwnerListings.
  ///
  /// In bn, this message translates to:
  /// **'আপনার কোনো বিজ্ঞাপন নেই'**
  String get noOwnerListings;

  /// No description provided for @noOwnerListingsSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার সম্পত্তি দ্রুত ভাড়া বা বিক্রি করতে এখনই নতুন বিজ্ঞাপন পোস্ট করুন।'**
  String get noOwnerListingsSubtitle;

  /// No description provided for @blogTitle.
  ///
  /// In bn, this message translates to:
  /// **'ব্লগ'**
  String get blogTitle;

  /// No description provided for @qaTitle.
  ///
  /// In bn, this message translates to:
  /// **'প্রশ্নোত্তর'**
  String get qaTitle;

  /// No description provided for @askQuestion.
  ///
  /// In bn, this message translates to:
  /// **'প্রশ্ন করুন'**
  String get askQuestion;

  /// No description provided for @myQuestions.
  ///
  /// In bn, this message translates to:
  /// **'আমার প্রশ্ন'**
  String get myQuestions;

  /// No description provided for @answers.
  ///
  /// In bn, this message translates to:
  /// **'উত্তর'**
  String get answers;

  /// No description provided for @writeAnswer.
  ///
  /// In bn, this message translates to:
  /// **'আপনার উত্তর লিখুন'**
  String get writeAnswer;

  /// No description provided for @postAnswer.
  ///
  /// In bn, this message translates to:
  /// **'উত্তর পোস্ট করুন'**
  String get postAnswer;

  /// No description provided for @guidesTitle.
  ///
  /// In bn, this message translates to:
  /// **'গাইড'**
  String get guidesTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In bn, this message translates to:
  /// **'আমাদের সম্পর্কে'**
  String get aboutTitle;

  /// No description provided for @contactUsTitle.
  ///
  /// In bn, this message translates to:
  /// **'যোগাযোগ'**
  String get contactUsTitle;

  /// No description provided for @privacyTitle.
  ///
  /// In bn, this message translates to:
  /// **'প্রাইভেসি পলিসি'**
  String get privacyTitle;

  /// No description provided for @termsTitle.
  ///
  /// In bn, this message translates to:
  /// **'শর্তাবলী'**
  String get termsTitle;

  /// No description provided for @helpTitle.
  ///
  /// In bn, this message translates to:
  /// **'হেল্প সেন্টার'**
  String get helpTitle;

  /// No description provided for @infoServicesTitle.
  ///
  /// In bn, this message translates to:
  /// **'তথ্য সেবা'**
  String get infoServicesTitle;

  /// No description provided for @questionTitleLabel.
  ///
  /// In bn, this message translates to:
  /// **'প্রশ্নের শিরোনাম'**
  String get questionTitleLabel;

  /// No description provided for @questionBodyLabel.
  ///
  /// In bn, this message translates to:
  /// **'বিস্তারিত বিবরণ'**
  String get questionBodyLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটাগরি'**
  String get categoryLabel;

  /// No description provided for @submitQuestion.
  ///
  /// In bn, this message translates to:
  /// **'প্রশ্ন জমা দিন'**
  String get submitQuestion;

  /// No description provided for @comments.
  ///
  /// In bn, this message translates to:
  /// **'মন্তব্য'**
  String get comments;

  /// No description provided for @writeComment.
  ///
  /// In bn, this message translates to:
  /// **'একটি মন্তব্য লিখুন...'**
  String get writeComment;

  /// No description provided for @postComment.
  ///
  /// In bn, this message translates to:
  /// **'মন্তব্য করুন'**
  String get postComment;

  /// No description provided for @readMore.
  ///
  /// In bn, this message translates to:
  /// **'আরও পড়ুন'**
  String get readMore;
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
