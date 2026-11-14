# PROJECT NOTES (A–Z) / প্রজেক্ট নোট

> Single place for everything known about the **GhorBD mobile app**. Update after every phase. Language: English + বাংলা.
> এই ফাইলে প্রজেক্টের সব নোট থাকবে। প্রতিটি ফেজের পর আপডেট করো।

**Last updated:** 2026-11-14

## 1. Project overview / প্রজেক্ট পরিচিতি
- **Product:** GhorBD — "আপনার পছন্দের ঘর খুঁজুন সহজেই". Bangladesh property marketplace: rent, sale, land. Direct contact with owner, no broker, free ads. / বাংলাদেশে বাসা, ফ্ল্যাট, রুম, হোটেল, দোকান, অফিস ও জমির বিজ্ঞাপন; দালাল ছাড়া সরাসরি যোগাযোগ।
- **Reference:** https://ghorbd.com/ (Bangla UI, locale `bn_BD`). Website looks like a Next.js site (image paths use `_next/image`).
- **Our scope:** Flutter app, **app side only**. Backend comes as an API collection (not yet received).
- **Stack:** Flutter, Dart, Dio, flutter_bloc, get_it, go_router, flutter_secure_storage; security first (see IMPLEMENTATION_GUIDE.md).
- **Languages:** Bangla (default) and English. All text through ARB files.

## 2. Status board / স্ট্যাটাস
| Phase | File | Status |
|-------|------|--------|
| 1 | ASSET_INVENTORY.md | Done (client assets received) |
| 2 | REQUIREMENT_AUDIT.md | Done (draft) |
| 3 | DESIGN_AUDIT.md | Done (no mobile design yet) |
| 4 | API_AUDIT.md | Done (116 endpoints audited, CAP replaced) |
| 5 | ASSET_ISSUES.md | Done (round 2: 22 resolved, 0 blockers) |
| 6 | FINAL_AUDIT_REPORT.md | Done — decision: GO |
| 7 | Implementation | Order 4 Complete (Auth feature: data, domain, blocs, UI, router guard & session integration; 148 tests pass) |

## 3. Website route map / ওয়েবসাইট রুট
| Route | Purpose | Read? |
|-------|---------|-------|
| `/` | Home | yes |
| `/listings` | Rent list + filters | yes |
| `/listings/sale` | Sale list | linked |
| `/listings/<type>` | Type: flat, house, room, hotel, shop, office | linked |
| `/listings/verified` | Verified only | linked |
| `/listings/division/<slug>` | By division | linked |
| `/listings/<slug>` | Listing detail (Bangla unicode slug) | yes (1 sample) |
| `/listings/new` | Create listing | blocked |
| `/rent/dhaka/<area>` | Area page | linked |
| `/map` | Map search | yes |
| `/land` | Land for sale | yes |
| `/pricing` | Plans | yes |
| `/blog`, `/blog/<slug>` | Blog | preview only |
| `/qa`, `/qa/<slug>`, `?category=`, `?mine=1` | Q&A | list only |
| `/guides`, `/help`, `/about`, `/contact`, `/privacy`, `/terms` | Content | help read; others linked |
| `/login`, `/owner/register` | Auth | blocked |
| `/dashboard`, `/favorites` | Owner dashboard, saved | linked |

## 4. Facts worth remembering / জরুরি তথ্য
- Phone number and messaging need login; guests see "login to view number". / নম্বর ও মেসেজের জন্য লগইন লাগে।
- Safety notice on every detail page: see the property first, never send advance money. / অগ্রিম টাকা পাঠাবেন না।
- "Verified" means the team checked info and photos; it is **not** a guarantee of rental terms (Help Center). / যাচাইকৃত মানে তথ্য ও ছবি যাচাই, ভাড়ার শর্তের নিশ্চয়তা নয়।
- Plans: Free (3 ads, direct message, basic dashboard, photo upload) · Pro ৳499/mo · Business ৳1,499/mo, prices exclude VAT. / সব দাম ভ্যাট ছাড়া।
- Rent filter defaults: max budget ৳50,000; bedroom options any,1+,2+,3+,4+; sort "newest first".
- Land filter: katha 1+, 2+, 3+, 5+, 10+; land types residential, commercial (agricultural in meta text).
- Number format uses Bangla digits and lakh/crore grouping (৭২,০০,০০০ ৳).
- Dhaka is the only active division (others "coming soon").
- Map on detail page uses OpenStreetMap link; coordinates can be missing (those listings are not on the map).
- Theme color meta: `#0b1017`.
- Some sample data looks like test data (placeholder phone and name) — see ISS-015, ISS-016.
- Three pages block automated reading (`/login`, `/owner/register`, `/listings/new`). We did not work around this; ask for screenshots instead.

## 5. Glossary EN ↔ বাংলা (for ARB keys) / শব্দকোষ
| English | বাংলা | | English | বাংলা |
|---------|-------|-|---------|-------|
| Flat | ফ্ল্যাট | | Verified | যাচাইকৃত |
| Room | রুম | | Bedroom | বেডরুম |
| House | বাড়ি | | Bathroom | বাথরুম |
| Hotel | হোটেল | | Area (size) | আয়তন |
| Shop | দোকান | | Floor | তলা |
| Office | অফিস | | Unit | ইউনিট |
| Land | জমি | | Amenities | সুযোগ-সুবিধা |
| For rent | ভাড়ার জন্য | | Location | অবস্থান |
| For sale | বিক্রির জন্য | | Monthly rent | মাসিক ভাড়া |
| Residential | আবাসিক | | Advertiser | বিজ্ঞাপনদাতা |
| Commercial | বাণিজ্যিক | | Listing / ad | বিজ্ঞাপন |
| Agricultural | কৃষি | | Tenant | ভাড়াটিয়া |
| Katha | কাঠা | | Landlord / owner | বাড়িওয়ালা |
| Bigha | বিঘা | | Map | মানচিত্র |
| Dag (plot no.) | দাগ | | Favorites / saved | সেভ / পছন্দের তালিকা |
| Khatian (land record) | খতিয়ান | | Login | লগইন |
| Namjari (mutation) | নামজারি | | Dashboard | ড্যাশবোর্ড |
| Khajna (land tax) | খাজনা | | My listings | আমার বিজ্ঞাপন |
| Deed | দলিল | | Report | রিপোর্ট |
| Inheritance | উত্তরাধিকার | | Search | খুঁজুন |
| Q&A | প্রশ্নোত্তর | | Apply | প্রয়োগ করুন |
| Guide | গাইড | | Sort / newest first | সাজান / নতুন আগে |
| Pricing | প্রাইসিং | | Coming soon | শীঘ্রই আসছে |

**Areas / এলাকা:** Dhanmondi ধানমন্ডি · Uttara উত্তরা · Bashundhara বসুন্ধরা · Mirpur মিরপুর · Gulshan গুলশান · Banani বনানী · Khilgaon খিলগাঁও · Mohammadpur মোহাম্মদপুর · Savar সাভার · Noakhali নোয়াখালী
**Divisions / বিভাগ:** Dhaka ঢাকা · Chattogram চট্টগ্রাম · Rajshahi রাজশাহী · Khulna খুলনা · Sylhet সিলেট · Barishal বরিশাল · Rangpur রংপুর · Mymensingh ময়মনসিংহ

## 6. Key UI strings seen (seed for ARB) / ইউআই টেক্সট
- Hero: "আপনার পছন্দের ঘর খুঁজুন সহজেই"
- Search hint: "এলাকা, ধরন বা বাজেট দিয়ে খুঁজুন"
- Guest on detail: "নম্বর দেখতে লগইন করুন" · "মেসেজ পাঠাতে লগইন করুন"
- Safety: "যোগাযোগের আগে বাসাটি সরাসরি দেখে নিন। অগ্রিম টাকা পাঠাবেন না।"
- Report: "বিজ্ঞাপনটি রিপোর্ট করুন" · "ভুয়া, প্রতারণা বা ভুল তথ্য? আমাদের জানান।"
- Map without location: "এই বিজ্ঞাপনের অবস্থান দেওয়া নেই, তাই এটি মানচিত্রে নেই।"

## 7. Decisions log / সিদ্ধান্ত
| Date | Decision | Reason |
|------|----------|--------|
| 2026-11-14 | State management: BLoC (not GetX) | User request |
| 2026-11-14 | Audit-first workflow with ID traceability | User request |
| 2026-11-14 | No implementation from CAP rows; wait for real collection | Avoid guessing |
| 2026-11-14 | Blocked pages not bypassed; ask for screenshots | Site disallows automated reading |
| 2026-11-14 | Bangla default, English secondary | User request: notes in both languages |

## 8. Change log / পরিবর্তনের তালিকা
| Date | Change |
|------|--------|
| 2026-11-14 | Created from website analysis; all audit files filled (round 1) |
| 2026-11-14 | Re-ran Phase 1 & 4 with client API docs: ASSET_INVENTORY & API_AUDIT filled with 116 real endpoints (CAP replaced) |
| 2026-11-14 | Re-ran Phase 5 & 6: ASSET_ISSUES updated (22 closed, 0 blockers); FINAL_AUDIT_REPORT decision upgraded to GO |
| 2026-11-14 | Phase 7, Order 1, step 1a: added latest compatible packages to pubspec.yaml, generated clean architecture folder skeleton per section 5; flutter pub get and flutter analyze pass |
| 2026-11-14 | Phase 7, Order 1, step 1b: implemented env.dart, dio_client.dart, api_result.dart, logging/error/retry interceptors; response contract & error mapping unit tests passed (34 tests) |
| 2026-11-14 | Phase 7, Order 1, step 1c: implemented failures.dart and exceptions.dart, mapped real error codes from API_AUDIT.md to Failure types with localization messageKeys; all 56 unit tests passed |
| 2026-11-14 | Phase 7, Order 1, step 1d: implemented DI (get_it), GoRouter with auth guard & routes, app.dart, main.dart; 63 tests passed |
| 2026-11-14 | Phase 7, Order 1, step 1e: configured l10n (app_bn.arb default, app_en.arb), implemented South Asian lakh/crore & Bangla digit formatters; 74 tests passed |
| 2026-11-14 | Phase 7, Order 2, step 2a: implemented secure_storage & session_manager with idle timeout lifecycle; 84 tests passed |
| 2026-11-14 | Phase 7, Order 2, step 2b: implemented auth_interceptor with single-flight mutex token refresh, request retries on 401, and logout cascade; 89 tests passed |
| 2026-11-14 | Phase 7, Order 2, step 2c: implemented log redaction, input_sanitizer, device_integrity, certificate_pinning hook, biometric_service; all 107 tests passed (Reached Checkpoint A) |
| 2026-11-14 | Phase 7, Order 3, step 3: implemented Theme tokens (colors, typography, spacing, Material 3 light/dark) and shared state widgets (loading, error, empty, offline, card, button, text field, filter chip); 120 tests passed |
| 2026-11-14 | Phase 7, Order 4, steps 4a-4d: implemented complete Auth feature (data, domain, usecases, AuthBloc, RegisterBloc, UI screens, router guard, session integration); all 148 tests passed (Reached Checkpoint B) |
| 2026-11-14 | Android platform setup: generated Android platform files, configured permissions (INTERNET, USE_BIOMETRIC, allowBackup=false), FlutterFragmentActivity, minSdk 23, applicationId com.ghorbd.ghorbad_clone_app, and build configurations; 148 tests and analyze passed |
