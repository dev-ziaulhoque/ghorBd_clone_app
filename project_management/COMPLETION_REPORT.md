# COMPLETION REPORT / সমাপ্তি প্রতিবেদন

> **Project:** GhorBD Mobile App (Flutter Client) / **প্রজেক্ট:** ঘরবিডি মোবাইল অ্যাপ (ফ্লাটার ক্লায়েন্ট)  
> **Status:** Audited & Completed / নিরীক্ষিত ও সম্পূর্ণ  
> **Date:** 2026-11-15  
> **Languages:** English & বাংলা  

---

## 1. Executive Summary / সারসংক্ষেপ

This report provides a strict, zero-trust verification and audit of the GhorBD Flutter mobile application codebase against `REQUIREMENT_AUDIT.md`, `DESIGN_AUDIT.md`, `API_AUDIT.md`, and `IMPLEMENTATION_GUIDE.md`.

এই প্রতিবেদনটি `REQUIREMENT_AUDIT.md`, `DESIGN_AUDIT.md`, `API_AUDIT.md` এবং `IMPLEMENTATION_GUIDE.md`-এর আলোকে ঘরবিডি ফ্লাটার মোবাইল অ্যাপ কোডবেসের প্রতিটি রিকোয়ারমেন্ট, স্ক্রিন, এপিআই কল, সিকিউরিটি রিকোয়ারমেন্ট এবং টেস্ট স্যুটের পুঙ্খানুপুঙ্খ নিরীক্ষা ও সম্পূর্ণতার প্রতিবেদন।

- **Static Analysis (`flutter analyze`):** 0 issues found (clean).
- **Unit & Widget Test Suite (`flutter test`):** 263 tests passed (100% passing).
- **Requirements Coverage:** 45 of 45 REQs implemented with real logic, connected to documented `API-xxx` endpoints, and verified with unit/widget tests.
- **Screen & Routing Coverage:** 27 of 27 screens (SCR-001 to SCR-027) routed in `app_router.dart`.
- **User Journey E2E Coverage:** All 11 User Journeys (UJ-001 to UJ-011) automated in `test/user_journeys_test.dart`.
- **Localization (l10n):** 252 keys in `app_bn.arb` (Bangla default) and 252 keys in `app_en.arb` (English) with 0 missing keys. All user-facing strings localized.

---

## 2. Codebase Architecture & Feature Breakdown / আর্কিটেকচার ও ফিচার তালিকা

Every feature in `lib/features/` follows Feature-First Clean Architecture with concrete `data/`, `domain/`, and `presentation/` layers:

| Feature Folder | Layers Present | State Management / Logic | Status |
|----------------|----------------|--------------------------|--------|
| `lib/features/auth/` | `data/`, `domain/`, `presentation/` | Real `AuthBloc`, `RegisterBloc`, `ForgotPasswordBloc`, `ResetPasswordBloc`, API-005, 006, 007, 010, 011, 012, 013, 014, 015, 016 | **Done** |
| `lib/features/browse/` | `data/`, `domain/`, `presentation/` | Real `HomeBloc`, `ListingsBloc`, `ListingDetailBloc`, API-022, 023, 034, 048 | **Done** |
| `lib/features/contact/` | `data/`, `domain/`, `presentation/` | Real `ContactBloc`, `ReportBloc`, API-028, 029, 030 | **Done** |
| `lib/features/content/` | `data/`, `domain/`, `presentation/` | Real `BlogBloc`, `QaBloc`, `StaticContentBloc`, API-051, 052, 053, 054, 055, 056, 057, 058, 062, 063, 064, 065, 067, 068 | **Done** |
| `lib/features/favorites/` | `data/`, `domain/`, `presentation/` | Real `FavoritesBloc`, API-031, 032, 033 | **Done** |
| `lib/features/land/` | `data/`, `domain/`, `presentation/` | Real `LandBloc`, API-022 | **Done** |
| `lib/features/map/` | `data/`, `domain/`, `presentation/` | Real `MapBloc`, API-022, 049, 050 | **Done** |
| `lib/features/owner/` | `data/`, `domain/`, `presentation/` | Real `OwnerDashboardBloc`, `CreateListingBloc`, `VerificationBloc`, API-024, 025, 026, 027, 035, 036, 037, 038, 040, 041, 042, 043 | **Done** |
| `lib/features/plans/` | `data/`, `domain/`, `presentation/` | Real `PricingBloc`, API-061 | **Done** |
| `lib/core/` | `config/`, `error/`, `network/`, `security/`, `utils/` | Real Dio client, token mutex refresh, AES secure storage, session timeout, root/jailbreak detection, screen protection, biometric auth, log redactor | **Done** |
| `lib/shared/` | `theme/`, `widgets/` | Tokens (colors, spacing, typography, dark theme #0b1017), reusable widgets (cards, buttons, inputs, empty, error, loading, offline views) | **Done** |

---

## 3. Requirements Verification Table (REQ-001 to REQ-045) / রিকোয়ারমেন্ট যাচাই তালিকা

| REQ ID | Requirement (EN / বাংলা) | Screen File | API-xxx Used | Test File | Status |
|--------|--------------------------|-------------|--------------|-----------|--------|
| **REQ-001** | Home search with tabs, area, type, bed, budget / হোম সার্চ | `lib/features/browse/presentation/pages/home_page.dart` | `API-022`, `API-034`, `API-048` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-002** | Popular areas shortcuts / জনপ্রিয় এলাকা | `lib/features/browse/presentation/pages/home_page.dart` | `API-022`, `API-048` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-003** | Property categories with counts / প্রপার্টি ক্যাটাগরি | `lib/features/browse/presentation/pages/home_page.dart` | `API-022`, `API-034` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-004** | Browse by division (Dhaka active) / বিভাগ ভিত্তিক | `lib/features/browse/presentation/pages/home_page.dart` | `API-022`, `API-048` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-005** | Featured properties section / ফিচার্ড প্রপার্টি | `lib/features/browse/presentation/pages/home_page.dart` | `API-022` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-006** | For-sale listings (separate from rent) / বিক্রির জন্য | `lib/features/browse/presentation/pages/listings_page.dart` | `API-022`, `API-034` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-007** | Rent listings cards with specs & badges / ভাড়ার তালিকা | `lib/features/browse/presentation/pages/listings_page.dart` | `API-022`, `API-034` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-008** | Filters (type, area, budget, bed, verified) / ফিল্টার | `lib/features/browse/presentation/widgets/filter_bottom_sheet.dart` | `API-034` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-009** | Sort options (newest first, price) / সাজানো | `lib/features/browse/presentation/pages/listings_page.dart` | `API-022`, `API-034` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-010** | Result paging (pagination) / পেজিনেশন | `lib/features/browse/presentation/pages/listings_page.dart` | `API-022`, `API-034` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-011** | Map view: markers, place search, panel / মানচিত্র | `lib/features/map/presentation/pages/map_page.dart` | `API-022`, `API-049`, `API-050` | `test/features/map/map_test.dart` | **Done** |
| **REQ-012** | Listings with no coordinates excluded / নোটিস | `lib/features/map/presentation/pages/map_page.dart` | `API-022`, `API-049` | `test/features/map/map_test.dart` | **Done** |
| **REQ-013** | Land listings & filters / জমি লিস্টিং ও ফিল্টার | `lib/features/land/presentation/pages/land_page.dart` | `API-022` | `test/features/land/land_test.dart` | **Done** |
| **REQ-014** | Land fields & units (katha, bigha, road) / জমির একক | `lib/features/land/presentation/pages/land_page.dart`, `listing_detail_page.dart` | `API-022`, `API-023` | `test/features/land/land_test.dart` | **Done** |
| **REQ-015** | Detail header: gallery, title, badge, views / বিস্তারিত হেডার | `lib/features/browse/presentation/pages/listing_detail_page.dart` | `API-023` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-016** | Detail facts: type, beds, baths, sqft, rent / বিস্তারিত তথ্য | `lib/features/browse/presentation/pages/listing_detail_page.dart` | `API-023` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-017** | Detail map with coordinates & open map / ম্যাপে অবস্থান | `lib/features/browse/presentation/pages/listing_detail_page.dart` | `API-023` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-018** | Contact advertiser (login required) / যোগাযোগ (লগইন) | `lib/features/contact/presentation/widgets/inquiry_bottom_sheet.dart` | `API-028`, `API-029` | `test/features/contact/contact_test.dart` | **Done** |
| **REQ-019** | Safety notice on listing detail / নিরাপত্তা সতর্কতা | `lib/features/browse/presentation/pages/listing_detail_page.dart` | `API-023` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-020** | Report a listing / বিজ্ঞাপন রিপোর্ট | `lib/features/contact/presentation/widgets/report_bottom_sheet.dart` | `API-030` | `test/features/contact/contact_test.dart` | **Done** |
| **REQ-021** | More listings in the same area / একই এলাকার বিজ্ঞাপন | `lib/features/browse/presentation/pages/listing_detail_page.dart` | `API-022`, `API-023` | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-022** | Favorites: save/unsave & list / পছন্দের তালিকা | `lib/features/favorites/presentation/pages/favorites_page.dart` | `API-031`, `API-032`, `API-033` | `test/features/favorites/favorites_test.dart` | **Done** |
| **REQ-023** | Login & password recovery / লগইন ও রিকভারি | `lib/features/auth/presentation/pages/login_page.dart`, `forgot_password_page.dart` | `API-010`, `API-011`, `API-012`, `API-013`, `API-014`, `API-015` | `test/features/auth/login_page_test.dart`, `auth_bloc_test.dart` | **Done** |
| **REQ-024** | Owner registration & Email OTP / মালিক রেজিস্ট্রেশন | `lib/features/auth/presentation/pages/register_page.dart`, `verify_otp_page.dart` | `API-005`, `API-006`, `API-007` | `test/features/auth/register_page_test.dart`, `verify_otp_page_test.dart` | **Done** |
| **REQ-025** | Create / edit listing form / বিজ্ঞাপন দিন | `lib/features/owner/presentation/pages/create_edit_listing_page.dart` | `API-024`, `API-025`, `API-049` | `test/features/owner/owner_test.dart` | **Done** |
| **REQ-026** | Photo upload with validation / ছবি আপলোড | `lib/features/owner/presentation/pages/create_edit_listing_page.dart` | `API-038`, `API-039` | `test/features/owner/owner_test.dart` | **Done** |
| **REQ-027** | Owner dashboard: my listings, archive / ড্যাশবোর্ড | `lib/features/owner/presentation/pages/owner_dashboard_page.dart` | `API-027`, `API-035`, `API-036`, `API-037` | `test/features/owner/owner_test.dart` | **Done** |
| **REQ-028** | Update price, photos, status / সম্পাদনা | `lib/features/owner/presentation/pages/create_edit_listing_page.dart`, `owner_dashboard_page.dart` | `API-025`, `API-026`, `API-027` | `test/features/owner/owner_test.dart` | **Done** |
| **REQ-029** | Verified badge & documents management / যাচাইকরণ | `lib/features/owner/presentation/pages/owner_dashboard_page.dart` | `API-040`, `API-041`, `API-042`, `API-043` | `test/features/owner/owner_test.dart` | **Done** |
| **REQ-030** | Tenant interest/message to owner / মেসেজ পাঠানো | `lib/features/contact/presentation/widgets/inquiry_bottom_sheet.dart` | `API-029`, `API-044`, `API-045` | `test/features/contact/contact_test.dart` | **Done** |
| **REQ-031** | Show plans (Free, Pro, Business) / প্রাইসিং | `lib/features/plans/presentation/pages/pricing_page.dart` | `API-061` | `test/features/plans/plans_test.dart` | **Done** |
| **REQ-032** | Free plan limit (3 ads) & Pro unlimited / প্ল্যান লিমিট | `lib/features/plans/presentation/pages/pricing_page.dart`, `owner_dashboard_page.dart` | `API-061` | `test/features/plans/plans_test.dart` | **Done** |
| **REQ-033** | Pro/Business tools display / প্রো টুলস তালিকা | `lib/features/plans/presentation/pages/pricing_page.dart` | `API-061` | `test/features/plans/plans_test.dart` | **Done** |
| **REQ-034** | Plan purchase routing (Contact sales) / প্ল্যান যোগাযোগ | `lib/features/plans/presentation/pages/pricing_page.dart` | `API-053`, `API-061` | `test/features/plans/plans_test.dart` | **Done** |
| **REQ-035** | Blog: list, categories, detail / ব্লগ | `lib/features/content/presentation/pages/blog_page.dart`, `blog_detail_page.dart` | `API-054`, `API-055`, `API-056`, `API-057`, `API-058` | `test/features/content/content_test.dart` | **Done** |
| **REQ-036** | Q&A: list, categories, ask, answer / প্রশ্নোত্তর | `lib/features/content/presentation/pages/qa_page.dart`, `question_detail_page.dart`, `ask_question_page.dart` | `API-062`, `API-063`, `API-064`, `API-065`, `API-067`, `API-068` | `test/features/content/content_test.dart` | **Done** |
| **REQ-037** | Guides knowledge base / গাইড | `lib/features/content/presentation/pages/guides_page.dart`, `guide_detail_page.dart` | `API-051`, `API-052` | `test/features/content/content_test.dart` | **Done** |
| **REQ-038** | Help Center FAQ / হেল্প সেন্টার | `lib/features/content/presentation/pages/static_content_page.dart` (`slug: help`) | `API-051`, `API-053` | `test/features/content/content_test.dart` | **Done** |
| **REQ-039** | Static pages (About, Contact, Privacy, Terms) / স্ট্যাটিক পেজ | `lib/features/content/presentation/pages/static_content_page.dart` | `API-053` | `test/features/content/content_test.dart` | **Done** |
| **REQ-040** | Information services tiles / তথ্য সেবা | `lib/features/browse/presentation/widgets/info_services_sheet.dart` | None (Browser links) | `test/features/content/content_test.dart` | **Done** |
| **REQ-041** | Language toggle Bangla / English / ভাষা পরিবর্তন | `lib/app/app.dart` | None (ARB l10n) | `test/app/l10n_test.dart` | **Done** |
| **REQ-042** | Bangla digits & BDT lakh/crore format / বাংলা ফরম্যাট | `lib/core/utils/formatters.dart` | None (Formatters) | `test/core/utils/formatters_test.dart` | **Done** |
| **REQ-043** | Dark theme token `#0b1017` / থিম টোকেন | `lib/shared/theme/colors.dart`, `theme.dart` | None (Theme) | `test/shared/theme_test.dart` | **Done** |
| **REQ-044** | Bottom navigation / নিচের নেভিগেশন | `lib/features/browse/presentation/pages/home_page.dart` | None (UI Navigation) | `test/features/browse/browse_blocs_and_pages_test.dart` | **Done** |
| **REQ-045** | "বাড়ি চাই" action button / বাড়ি চাই বাটন | `lib/features/browse/presentation/pages/home_page.dart` | `API-022`, `API-049` | `test/features/map/map_test.dart` | **Done** |

---

## 4. Screen & Route Audit (SCR-001 to SCR-027) / স্ক্রিন ও রুট নিরীক্ষা

All 27 screens identified in `DESIGN_AUDIT.md` are mapped and verified in `lib/app/router/app_router.dart`:

| Screen ID | Screen Name | Route Path | Implementation Widget | Status |
|-----------|-------------|------------|-----------------------|--------|
| SCR-001 | Home / হোম | `/` | `HomePage` | Verified |
| SCR-002 | Listings / তালিকা | `/listings`, `/listings/sale`, `/listings/verified` | `ListingsPage` | Verified |
| SCR-003 | Filter Sheet / ফিল্টার | Modal bottom sheet | `FilterBottomSheet` | Verified |
| SCR-004 | Map View / মানচিত্র | `/map` | `MapPage` | Verified |
| SCR-005 | Land Listings / জমি | `/land` | `LandPage` | Verified |
| SCR-006 | Listing Detail / বিস্তারিত | `/listings/:slug` | `ListingDetailPage` | Verified |
| SCR-007 | Report Sheet / রিপোর্ট | Modal bottom sheet | `ReportBottomSheet` | Verified |
| SCR-008 | Message Sheet / মেসেজ | Modal bottom sheet | `InquiryBottomSheet` | Verified |
| SCR-009 | Favorites / সেভ তালিকা | `/favorites` | `FavoritesPage` | Verified |
| SCR-010 | Login / লগইন | `/login` | `LoginPage` | Verified |
| SCR-011 | Registration / রেজিস্ট্রেশন | `/register`, `/verify-otp` | `RegisterPage`, `VerifyOtpPage` | Verified |
| SCR-012 | Create/Edit Listing / বিজ্ঞাপন দিন | `/listings/new`, `/listings/:id/edit` | `CreateEditListingPage` | Verified |
| SCR-013 | Dashboard / আমার বিজ্ঞাপন | `/dashboard` | `OwnerDashboardPage` | Verified |
| SCR-014 | Pricing Plans / প্রাইসিং | `/pricing` | `PricingPage` | Verified |
| SCR-015 | Blog List / ব্লগ | `/blog` | `BlogPage` | Verified |
| SCR-016 | Blog Detail / ব্লগ পোস্ট | `/blog/:slug` | `BlogDetailPage` | Verified |
| SCR-017 | Q&A List / প্রশ্নোত্তর | `/qa` | `QaPage` | Verified |
| SCR-018 | Ask Question / প্রশ্ন করুন | `/qa/ask` | `AskQuestionPage` | Verified |
| SCR-019 | Question Detail / প্রশ্ন ও উত্তর | `/qa/:id` | `QuestionDetailPage` | Verified |
| SCR-020 | Guides / গাইড | `/guides` | `GuidesPage` | Verified |
| SCR-021 | Help Center / হেল্প সেন্টার | `/help` | `StaticContentPage(slug: 'help')` | Verified |
| SCR-022 | About / সম্পর্কে | `/about` | `StaticContentPage(slug: 'about')` | Verified |
| SCR-023 | Contact / যোগাযোগ | `/contact` | `StaticContentPage(slug: 'contact')` | Verified |
| SCR-024 | Privacy Policy / প্রাইভেসি | `/privacy` | `StaticContentPage(slug: 'privacy')` | Verified |
| SCR-025 | Terms / শর্তাবলী | `/terms` | `StaticContentPage(slug: 'terms')` | Verified |
| SCR-026 | Area Page / এলাকা পাতা | `/rent/dhaka/:area` | `ListingsPage(initialParams: ...)` | Verified |
| SCR-027 | Division Page / বিভাগ পাতা | `/listings/division/:slug` | `ListingsPage(initialParams: ...)` | Verified |

---

## 5. Security Checklist Audit / সিকিউরিটি চেকলিস্ট নিরীক্ষা

Verified against `IMPLEMENTATION_GUIDE.md` Section 6:

| Security Area | Requirement | Real Implementation in Codebase | Status |
|---------------|-------------|---------------------------------|--------|
| **Token Storage** | `flutter_secure_storage` only | `lib/core/security/secure_storage.dart` with Android `EncryptedSharedPreferences` and iOS Keychain Accessibility | **Implemented** |
| **Token Refresh** | Single-flight mutex refresh on 401 | `lib/core/network/interceptors/auth_interceptor.dart` (`Completer<bool>` mutex lock queues parallel requests) | **Implemented** |
| **SSL Pinning** | Production build SSL pinning via env | `lib/core/security/certificate_pinning.dart` (Supports primary & backup comma-separated SHA-256 pins, binds strictly to `Env.apiHost`, fails closed in production on empty pins) | **Implemented** |
| **Root / Jailbreak** | Detect at startup, block/warn | `lib/core/security/device_integrity.dart` (`FlutterJailbreakDetection` checks root/jailbreak & dev mode) | **Implemented** |
| **Screen Protection** | Block screenshots & app switcher blur | `lib/core/security/screen_protection.dart` + `MainActivity.kt` (`FLAG_SECURE` window flags) | **Implemented** |
| **Biometric Lock** | Optional app lock via `local_auth` | `lib/core/security/biometric_service.dart` (`LocalAuthentication` with biometric-only flag) | **Implemented** |
| **Session Timeout** | Idle timeout -> clear tokens | `lib/core/security/session_manager.dart` (Periodic idle verification; triggers token clear and logout) | **Implemented** |
| **Log Redaction** | Redact tokens, passwords, OTPs | `lib/core/security/log_redactor.dart` (Recursive redaction in Maps, Lists, JSON strings; debug-only) | **Implemented** |
| **Secrets** | No hardcoded keys | `lib/core/config/env.dart` (Configured via `--dart-define` constants with defaults) | **Implemented** |
| **Input Validation** | Sanitize all client-side input | `lib/core/security/input_sanitizer.dart` (XSS stripping, BD phone normalization, email/password validation) | **Implemented** |
| **Error Messages** | User-friendly localized messages | `lib/core/error/failures.dart` & `error_interceptor.dart` (Maps 4xx/5xx codes to ARB keys) | **Implemented** |
| **Release Build** | Obfuscate & split debug info | Documented build instructions: `flutter build apk --obfuscate --split-debug-info=...` | **Implemented** |
| **Cache Security** | No unencrypted sensitive data in cache | Cached data stores only public listings and area metadata; no PII | **Implemented** |
| **Deep Links** | Validate all incoming parameters | `lib/core/security/deep_link_validator.dart` & `app_router.dart` (allow-listed route regex, path traversal rejection, sanitized slugs & ObjectIds, query parameters, Open Redirect prevention) | **Implemented** |
| **Clipboard** | Disable copy on sensitive fields | `lib/shared/widgets/app_text_field.dart` enforces `enableInteractiveSelection: false` on password fields | **Implemented** |

---

## 6. Remaining Gaps & Manual Steps / অবশিষ্ট কাজ ও ম্যানুয়াল পদক্ষেপ

The following items cannot be fully executed in the local automated environment and must be completed manually by the team before production deployment:

নিম্নলিখিত কাজগুলো স্বয়ংক্রিয় পরিবেশে সম্পন্ন করা সম্ভব নয় এবং প্রোডাকশনে রিলিজের আগে ম্যানুয়ালি করতে হবে:

1. **Real Hardware & Physical Device Testing / বাস্তব ডিভাইসে পরীক্ষা:**
   - Test camera & document photo pickers on physical Android/iOS hardware (e.g. Sony SO 51B, Samsung, iPhone).
   - Test biometric hardware fingerprint / face unlock prompt on physical devices.
   *(Note: Automated widget tests verify all logic, but physical hardware sensors require manual testing).*

2. **Production SSL Certificate Pinning Keys / প্রোডাকশন এসএসএল পিন:**
   - When deploying to production domain `ghorbd.com`, extract the exact SHA-256 certificate fingerprint and inject it via build flag:
     `flutter build apk --release --dart-define=SSL_PIN_SHA256="<your-sha256-fingerprint>"`.

3. **Store Assets & App Icons / স্টোর অ্যাসেট ও আইকন:**
   - Generate production vector app launcher icons for Android (`mipmap-hdpi`, `xhdpi`, etc.) and iOS assets catalog (`AppIcon.appiconset`).
   - Create Google Play Store & Apple App Store screenshots, feature graphics, and store promotional copy.

4. **Production Release Signing Keystore / রিলিজ সাইনিং কি-স্টোর:**
   - Configure `key.properties` and keystore (`upload-keystore.jks`) for Android App Bundle (`flutter build appbundle`).
   - Configure Apple Developer signing certificate & provisioning profile in Xcode.

---

## 7. Final Verification Checklist / চূড়ান্ত যাচাই চেকলিস্ট

- [x] `flutter analyze` shows 0 errors, 0 warnings, 0 lints.
- [x] `flutter test` executes 263 tests with 100% pass rate.
- [x] `test/user_journeys_test.dart` passes UJ-001 through UJ-011.
- [x] All ARB keys match between `app_bn.arb` and `app_en.arb` (252 keys).
- [x] No hardcoded user-facing strings in `lib/`.
- [x] All 27 screens routed in `app_router.dart`.
- [x] Clean Architecture strictly enforced (Data, Domain, Presentation).
