# ASSET ISSUES / সমস্যা ও প্রশ্নের তালিকা

> Phase 5 · Project: **GhorBD mobile app** (Flutter + Dio + BLoC, app side only)
> Issue status: `Open | Asked client | Answered | Resolved | Assumed`
> Severity: `Blocker` (cannot implement) | `Major` (can implement with risk) | `Minor` (small or cosmetic)

**Phase status:** Done (round 2 — updated with official client API collection)
**Last updated:** 2026-11-14

## Issues / সমস্যা

| ID | Severity | Description | Affected | Question (EN) | প্রশ্ন (বাংলা) | Assumption / Resolution | Status |
|----|----------|-------------|----------|---------------|-----------------|-------------------------|--------|
| ISS-001 | Blocker | Backend API collection not received | AST-016, all CAP | Please share the Postman/Insomnia collection with dev/staging/prod environments. | ব্যাকএন্ড কালেকশন (Postman/Insomnia) এবং dev/staging/prod এনভায়রনমেন্ট দিন। | **Resolved:** Received official API collection in `client_assets/api_docs/GhorBd Documentation/` (116 requests across 15 folders, OpenAPI 3.0.3 spec, and environments). | Resolved |
| ISS-002 | Blocker | Login, owner registration and create-listing pages cannot be read on website | AST-009–011, REQ-023–025, SCR-010–012 | Please send screenshots or field lists for login, registration and create-listing (all steps). | লগইন, রেজিস্ট্রেশন ও বিজ্ঞাপন তৈরির সব ধাপের স্ক্রিনশট বা ফিল্ড তালিকা দিন। | **Resolved for data & logic:** Exact fields, validation rules, payloads, and error codes are 100% defined by `API-005`, `API-006`, `API-010`, `API-024`. Visual mobile UI forms follow standard mobile patterns under ISS-003. | Resolved |
| ISS-003 | Major | No mobile design or Figma | AST-017, all SCR | Is there a Figma or mobile design? If not, may we follow the website layout? | মোবাইল ডিজাইন বা Figma আছে? না থাকলে ওয়েবসাইটের লেআউট অনুসরণ করা যাবে? | Follow website structure with responsive mobile clean architecture and theme tokens. | Open |
| ISS-004 | Major | Relationship to ghorbd.com unclear: is this the owner's official app or a custom variant? Affects branding and content rights | AST-015, all | Is this app for the GhorBD owner, or a separate custom product? Who owns brand and content? | এটা কি GhorBD মালিকের অফিসিয়াল অ্যাপ নাকি আলাদা কাস্টম প্রোডাক্ট? ব্র্যান্ড ও কনটেন্টের মালিক কে? | Proceed using GhorBD branding with configurable theme tokens. | Open |
| ISS-005 | Major | Brand originals (logo, icons) and font not provided; only web URLs exist | AST-015, AST-018 | Please send logo (SVG/PNG), app icon, service icons, and the brand font. | লোগো (SVG/PNG), অ্যাপ আইকন, সার্ভিস আইকন ও ব্র্যান্ড ফন্ট দিন। | Temporary Google Font (Hind Siliguri / IBM Plex Sans) and placeholder assets. | Open |
| ISS-006 | Major | Auth method unknown (email, phone+OTP, social), token type, refresh | REQ-023, 024, CAP-01/02 | Which login methods are supported? | কোন কোন লগইন পদ্ধতি আছে (ইমেইল, ফোন+OTP, সোশ্যাল)? | **Resolved:** Stateless JWT. Email+password login (`API-010`), Email OTP verification (`API-005` -> `API-006`), 15m access / 30d refresh tokens (`API-011`). | Resolved |
| ISS-007 | Major | Which actions work as a guest? Favorites tab exists; guest saving unknown | REQ-018, 022 | Can guests save favorites, or is login required? | গেস্ট কি পছন্দের তালিকায় রাখতে পারবে, নাকি লগইন লাগবে? | **Resolved:** Guest browsing permitted. Favorites (`API-031`–`033`), phone reveal (`API-028`), inquiries (`API-029`), and ad creation (`API-024`) strictly require Bearer token. | Resolved |
| ISS-008 | Minor | Only "newest first" sort seen | REQ-009 | What sort options exist (price low/high, etc.)? | সাজানোর আর কী কী অপশন আছে (দাম কম/বেশি ইত্যাদি)? | **Resolved:** API supports `sort=newest|price_asc|price_desc|popular`. Featured listings always pinned to top. | Resolved |
| ISS-009 | Major | Pagination style unknown | REQ-010 | Page-based or cursor-based? Page size? | পেজ-ভিত্তিক না কার্সর-ভিত্তিক? প্রতি পেজে কতটি? | **Resolved:** Page-based (`?page=1&perPage=12`, default 12, max 60). Blog comments use cursor pagination (`?limit=10&before=cursor`). | Resolved |
| ISS-010 | Major | Tenant message: where does the owner read it (in-app inbox, email only)? Any reply flow? | REQ-030, SCR-008 | Is there an in-app inbox, or is the message sent by email only? | মেসেজ কি অ্যাপের ইনবক্সে যাবে নাকি শুধু ইমেইলে? রিপ্লাই কীভাবে হবে? | **Resolved:** In-app chat was removed in backend migration 016. Inquiries (`API-029`) dispatch an email notification to the owner. | Resolved |
| ISS-011 | Major | Verified badge: how does an owner request it, what are the statuses? | REQ-029, CAP-21 | How does an owner get "verified"? Which statuses show in the app? | মালিক কীভাবে "যাচাইকৃত" ব্যাজ পাবে? অ্যাপে কোন কোন স্ট্যাটাস দেখাবে? | **Resolved:** Owner uploads verification documents (`API-041`, max 3). Admin verifies listing via `API-073`, setting `verified = true`. | Resolved |
| ISS-012 | Major | Pro/Business scope and payment: are these in the app? Which payment method? | REQ-031–034 | Should the app include Pro/Business tools and purchase? Which payment gateway? | প্রো/বিজনেস টুল ও কেনা কি অ্যাপে থাকবে? কোন পেমেন্ট গেটওয়ে? | **Resolved:** Invoicing and payments removed in migration 016. Pricing (`API-061`) is display-only with sales link. | Resolved |
| ISS-013 | Major | Land fields (road width, dag/khatian) and units (katha, bigha): input rules and conversion | REQ-014 | Which land fields are required? Is there a katha↔bigha conversion rule? | জমির কোন কোন ফিল্ড বাধ্যতামূলক? কাঠা↔বিঘা রূপান্তরের নিয়ম আছে কি? | **Resolved:** Requires `land` object (`landType`, `areaValue`, `areaUnit`, optional `facing`, `roadWidthFt`). Units: `katha`, `bigha`, `decimal`, `acre`, `sqft`. | Resolved |
| ISS-014 | Minor | Website shows English area slug ("dhanmondi, dhaka") inside Bangla UI | REQ-007, 041, CAP-22 | Will the API return Bangla and English names for areas? | এলাকার নাম কি বাংলা ও ইংরেজি দুই ভাষায় API থেকে আসবে? | **Resolved:** `GET /areas` (`API-048`) returns both Bangla `name` and English `nameEn`. | Resolved |
| ISS-015 | Minor | Data quality in samples: an office listing shows 0 bedrooms and type "flat" | REQ-007 | Is this test data? | এগুলো কি টেস্ট ডেটা? | **Resolved:** Confirmed as dev/seed data. API schema enforces strict enums for `propertyType`. | Resolved |
| ISS-016 | Minor | Placeholder content: phone +880 1700-000000, advertiser "Lorem ispam" | REQ-018, 039 | Which contact details are real? | কোন যোগাযোগের তথ্য আসল? | **Resolved:** Test data in dev database. API requires valid `+8801...` mobile numbers. | Resolved |
| ISS-017 | Minor | "বাড়ি চাই" button opens the map; could be a "wanted ad" feature | REQ-045 | What should "বাড়ি চাই" do? | "বাড়ি চাই" বাটন কী করবে? | **Resolved:** No "wanted ads" entity exists on backend. Navigates to map search (`API-049`). | Resolved |
| ISS-018 | Major | Map provider: site links to OpenStreetMap; app needs a choice (OSM tiles or Google Maps), keys and usage limits | REQ-011, 017 | Which map provider and API key will be used? | কোন ম্যাপ প্রোভাইডার ও API key ব্যবহার হবে? | Wrap map behind an abstract interface; support OSM tiles / MapLibre or Google Maps. | Open |
| ISS-019 | Minor | Detail page shows an unlabeled number after "views" | REQ-015 | What does that counter mean? | ভিউ-এর পরের ওই সংখ্যাটি কী? | **Resolved:** Mapped to `listing.viewCount` (integer). | Resolved |
| ISS-020 | Minor | Deep links: listing URLs use Bangla slugs; app links need control of domain and stable slugs | PRP-004 | Do you control ghorbd.com for app link files? Are slugs stable? | অ্যাপ লিংকের জন্য ডোমেইনে ফাইল রাখা যাবে? slug কি স্থায়ী? | **Resolved:** In-app `go_router` handles `/listings/:id` (by id or slug), `/verify-email`, `/reset-password`. | Resolved |
| ISS-021 | Minor | Dark or light theme not confirmed (browser theme color `#0b1017`) | REQ-043 | Dark only, light only, or both? | ডার্ক, লাইট, নাকি দুটোই? | Support both dark and light modes, defaulting to system. | Open |
| ISS-022 | Major | Not in website but needed on mobile: account deletion, push notifications, share | PRP-001–003 | Approve these additions? | এই সংযোজনগুলো অনুমোদন করবেন? (অ্যাকাউন্ট ডিলিট, পুশ, শেয়ার) | **Resolved:** Handled per README §10: polling unread count (`API-045`), share web URL, support link for account deletion. | Resolved |
| ISS-023 | Minor | Q&A rules: login to ask/answer? moderation? | REQ-036 | Who can ask and answer? | কে প্রশ্ন করতে ও উত্তর দিতে পারবে? | **Resolved:** Reading is public. Asking (`API-064`) and answering (`API-068`) require Bearer JWT; status is `pending: true` until admin approves. | Resolved |
| ISS-024 | Minor | "তথ্য সেবা" tiles open other sites (bhumibd.com, uttoradhikar.org) | REQ-040, AST-020 | Include these in the app? As external links or in-app browser? | এই সার্ভিসগুলো অ্যাপে থাকবে? বাইরের লিংক না ইন-অ্যাপ ব্রাউজার? | External links opening in system browser. | Open |
| ISS-025 | Minor | Only Dhaka has listings; other 7 divisions are "coming soon" | REQ-004 | Show the other divisions as disabled? | বাকি ৭টি বিভাগ কি "শীঘ্রই আসছে" হিসেবে দেখাবে? | **Resolved:** All 8 divisions are valid enum values in API; show available divisions with counts from `meta.facets`. | Resolved |
| ISS-026 | Minor | Phone reveal: limits, logging, abuse rules | REQ-018, NFR-002 | Is there a daily limit for phone reveals? | ফোন নম্বর দেখার কোনো দৈনিক সীমা আছে কি? | **Resolved:** 30 reveals / hour rate limit per user, enforced by backend. Client handles 429 gracefully. | Resolved |
| ISS-027 | Minor | Photo upload limits: count, size, formats | REQ-026, NFR-004 | Max photos, max size, allowed formats? | সর্বোচ্চ কয়টি ছবি, সাইজ ও ফরম্যাট? | **Resolved:** Max 5 MB per file, max 20 files per request. Formats: JPEG, PNG, WebP (`API-038`). | Resolved |
| ISS-028 | Minor | Language: is listing text Bangla only or mixed? Does API serve English labels? | REQ-041 | Which content is available in English? | কোন কনটেন্ট ইংরেজিতে পাওয়া যাবে? | **Resolved:** Static pages support `?locale=bn-BD|en`. Master data provides both `name` (Bangla) and `nameEn`. App UI localized via ARB. | Resolved |
| ISS-029 | Minor | Theme colors #059669 and #0284C7 not confirmed by screenshots | All UI | Please provide official primary and secondary brand hex color codes. | অফিসিয়াল প্রাইমারি ও সেকেন্ডারি ব্র্যান্ড রঙের হেক্স কোড দিন। | Marked TODO(design) in `colors.dart`; emerald/sky used as baseline placeholders. | Open |
| ISS-030 | Major | SSL certificate pinning needs real production SHA-256 pins | Security | Please provide the real production certificate SHA-256 pin for api.ghorbd.com. | api.ghorbd.com এর আসল প্রোডাকশন SSL পিন (SHA-256) প্রদান করুন। | Pinning hook implemented; disabled in dev/staging, awaiting real production pin. | Open |
| ISS-031 | Major | In-app user account deletion endpoint missing from API | REQ-023, PRP-001 | Apple App Store (Guideline 5.1.1(v)) & Google Play Store policies mandate in-app account deletion. Backend only provides admin delete (API-090). Backend must provide DELETE /auth/me or DELETE /account. | অ্যাপল ও গুগল প্লে স্টোর পলিসি অনুযায়ী অ্যাপের ভেতর থেকে অ্যাকাউন্ট ডিলিট করার ব্যবস্থা থাকা বাধ্যতামূলক। ব্যাকএন্ডে অবিলম্বে DELETE /auth/me বা DELETE /account এন্ডপয়েন্ট তৈরি করতে হবে। | Backend team must deploy DELETE /auth/me before store release. In-app settings screen provides confirmation dialog & support ticket routing. | Open |

## Client question list (remaining open items) / ক্লায়েন্টকে পাঠানোর প্রশ্ন

### Blockers / বাধা
*None. All blockers have been resolved by the official API documentation package.*

### Major / গুরুত্বপূর্ণ
1. **Mobile Design:** Is there a Figma file, or should we proceed following the standard mobile responsive layout derived from the website? (ISS-003)
2. **Brand Assets:** Please provide high-resolution SVG/PNG logo, app icon, and brand font files. (ISS-005)
3. **Map Provider:** Should the mobile map use OpenStreetMap tiles (Leaflet/MapLibre, no key required) or Google Maps SDK (requires API key)? (ISS-018)
4. **Brand Ownership:** Please confirm official app status for app store listing metadata. (ISS-004)
5. **Account Deletion Endpoint:** Apple App Store (5.1.1(v)) and Google Play require self-service in-app account deletion. Please provide `DELETE /auth/me` or equivalent. (ISS-031)

### Minor / ছোট
1. Confirm preference for light mode, dark mode, or system default (currently supporting both). (ISS-021)
2. Confirm opening external land service links (bhumibd.com, uttoradhikar.org) in the external browser. (ISS-024)

## Summary / সারসংক্ষেপ
- **Blocker:** open 0 · resolved 2 (ISS-001, ISS-002)
- **Major:** open 6 · resolved 8 (ISS-006, ISS-007, ISS-009, ISS-010, ISS-011, ISS-012, ISS-013, ISS-022)
- **Minor:** open 3 · resolved 12 (ISS-008, ISS-014, ISS-015, ISS-016, ISS-017, ISS-019, ISS-020, ISS-023, ISS-025, ISS-026, ISS-027, ISS-028)
- **Total:** 31 issues (9 open with safe working assumptions, 22 resolved)
