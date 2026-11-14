# Phase 7 Implementation Progress / বাস্তবায়ন অগ্রগতি

> Memory & Tracking checklist for Phase 7 implementation.
> Re-read this file and `IMPLEMENTATION_GUIDE.md` section 2 before and after every step.
> Git Note: Commits are skipped in sandbox environment (not permitted).

## Order 1: Core Foundation
- [x] **1a** Add packages to `pubspec.yaml`, check latest stable versions, generate folder structure from Section 5.
- [x] **1b** Implement `core/config/env.dart` (--dart-define), `dio_client.dart`, `api_result.dart`, logging (redacted, debug-only), error, and retry (safe GET only) interceptors. Response parsing and error mapping unit tests.
- [x] **1c** Implement `failures.dart` and `exceptions.dart`, mapping all real error codes from `API_AUDIT.md` (400, 401, 403, 404, 409, 413, 422, 429, 500) to Failure types with localization `messageKey`. Unit tests pass.
- [x] **1d** DI (`get_it`) + router (`go_router`, placeholder routes, auth-guard stub) + `app.dart` + `main.dart`.
- [x] **1e** l10n (`app_bn.arb` default, `app_en.arb`) + Bangla digit and BDT lakh/crore formatters (`7200000` -> `৭২,০০,০০০ ৳`) with unit tests.

## Order 2: Security Foundation
- [x] **2a** `secure_storage` + `session_manager`.
- [x] **2b** `auth_interceptor` with single-flight refresh (tests: concurrent 401s trigger exactly one refresh; refresh failure logs out).
- [x] **2c** log redaction, `input_sanitizer`, `device_integrity`, `certificate_pinning` hook (off in dev).

---
### 🛑 CHECKPOINT A: Stop and wait for developer review.
---

## Order 3: Theme & Shared UI
- [x] **3** Theme tokens + shared widgets (take values from `client_assets/screenshots`; if not visible use `TODO(design)` placeholder).

## Order 4: Authentication Feature
- [x] **4a** Auth data + domain (entities, models, datasources, repository, use cases for register, verify email OTP, login, refresh, logout, password reset).
- [x] **4b** Auth BLoCs (`AuthBloc`, `RegisterBloc`).
- [x] **4c** Auth UI (Login screen, Register screen, OTP verification screen).
- [x] **4d** Router guard + session integration.

---
### 🛑 CHECKPOINT B: Stop and wait for developer review.
---

## Feature Orders (Journey Order)
- [x] **5** Browse & Search: Home, Listings, Filters, Detail (`API-022`, `API-023`, `API-034`, `API-048`).
- [x] **6** Contact (phone reveal, inquiry message), Favorites, Report (`API-028`–`033`).
- [x] **7** Map & Geocoding (`API-022`, `API-049`, `API-050`).
- [x] **8** Land Marketplace (`API-022`).
- [ ] **9** Owner Ad Management: create/edit listing, photo upload, dashboard (`API-024`–`027`, `API-035`–`043`).
- [ ] **10** Content: Blog, Q&A, Help, Guides, Static pages (`API-051`–`060`, `API-062`–`069`).
- [ ] **11** Plans (Display comparison table only, `API-061`).
- [ ] **12** Final Polish: widget tests for key screens, verify no hardcoded strings (all through ARB), verify security checklist table in `IMPLEMENTATION_GUIDE.md` section 6, run final `flutter analyze` + `flutter test`, summary of REQs done / not done.
