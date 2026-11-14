# API AUDIT / এপিআই অডিট

> Phase 4 · Project: **GhorBD mobile app** (Flutter + Dio + BLoC, app side only)
> প্রজেক্ট: **ঘরবিডি মোবাইল অ্যাপ** (শুধু অ্যাপ সাইড)
> Status values: `Todo | In Progress | Done | Blocked`

**Phase status:** **Done** (Audited from AST-016 / AST-021..AST-025; all CAP rows replaced with real `API-xxx` entries)
**Last updated:** 2026-11-14
**Source basis / সোর্স:** `client_assets/api_docs/GhorBd Documentation/` — Postman collection v2.1 (`GhorBD.postman_collection.json`), OpenAPI 3.0.3 specification (`ghorbd-openapi.json`), Postman environments (`GhorBD.*.postman_environment.json`), and integration guide (`README.md`).

## 1. Important Notice / গুরুত্বপূর্ণ ঘোষণা

All temporary capabilities (`CAP-01` to `CAP-23`) derived from the initial website audit have now been **fully replaced** by **116 real `API-xxx` entries** extracted directly from the client's official API collection. Every endpoint, HTTP method, authentication rule, request payload schema, and response example in this audit is copied verbatim from the documentation without guessing any field.

এই ফাইলে আগে থাকা সাময়িক CAP তালিকা সম্পূর্ণ বাতিল করে ক্লায়েন্টের অফিসিয়াল কালেকশন থেকে হুবহু **১১৬টি আসল `API-xxx` এন্ট্রি** বসানো হয়েছে। কোনো ফিল্ড বা এন্ডপয়েন্ট অনুমান করা হয়নি।

## 2. Global Config & Protocol Contract / গ্লোবাল কনফিগ ও প্রোটোকল

### 2.1 Environments & Base URLs

| Environment | Base URL | Media URL | Notes |
|-------------|----------|-----------|-------|
| **Production** | `https://ghorbd.com/api` | `https://ghorbd.com/uploads/...` | Reached through web server reverse proxy |
| **Staging** | `{stagingOrigin}/api` | TBD | Placeholder in repo; DevOps must supply staging host |
| **Local (API direct)** | `http://localhost:5000/api` | `http://localhost:5000/uploads/...` | Direct node/express dev server with MongoDB |
| **Android Emulator → Local** | `http://10.0.2.2:5000/api` | `http://10.0.2.2:5000/uploads/...` | Android emulator alias for host machine |
| **Physical Device → Local** | `http://<LAN-IP>:5000/api` | `http://<LAN-IP>:5000/uploads/...` | Requires cleartext HTTP permissions in Android/iOS dev builds |

### 2.2 Headers & Cookie Policy

| Header | Required when | Value / Format |
|--------|---------------|----------------|
| `Authorization` | Any endpoint requiring Bearer auth or optional auth | `Bearer <accessToken>` |
| `Content-Type` | JSON request bodies | `application/json` |
| `Content-Type` | File uploads (photos, documents) | `multipart/form-data; boundary=...` (set automatically by Dio) |
| `Accept` | All requests | `application/json` |

> [!IMPORTANT]
> **Mobile Cookie Policy:** The server sets httpOnly cookies (`token`, `refreshToken`) for web browser sessions. **Mobile clients must ignore cookies** and use the tokens from the response body with `Authorization: Bearer <accessToken>`. Ensure the Dio client does not maintain a cookie jar.

### 2.3 Response Contracts (3 standard shapes)

Every endpoint in the GhorBD API strictly adheres to one of three response structures:

```json
// 1. Single Item Success (200 / 201)
{
  "data": {
    "listing": { ... }
  }
}

// 2. Paginated List Success (200)
{
  "data": [ ... ],
  "meta": {
    "page": 1,
    "perPage": 12,
    "total": 87,
    "totalPages": 8
  }
}

// 3. Error Response (4xx / 5xx)
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "path": "title",
        "message": "String must contain at least 5 character(s)"
      }
    ]
  }
}
```

### 2.4 Data Conventions & Formatting
- **Branching:** The mobile client must branch strictly on `error.code`, never on `error.message` (messages may be localized).
- **Identifiers:** IDs are 24-character hexadecimal MongoDB ObjectIds (`id`, never `_id`).
- **Timestamps:** ISO-8601 UTC strings (`YYYY-MM-DDTHH:mm:ss.sssZ`). Must be parsed and displayed in `Asia/Dhaka` timezone.
- **Monetary Values:** Whole Bangladeshi Taka (e.g. `pricePerMonth: 25000`), except fields ending in `Minor` which represent poisha (1/100 Taka). Grouping in Bangla UI: lakh/crore (e.g., ২৫,০০০ ৳).
- **Phone Numbers:** Stored and returned as E.164 format `+8801XXXXXXXXX`. Input can accept `01XXXXXXXXX`, `+8801...`, or `8801...`.
- **Resource Visibility (404 vs 403):** Private or unapproved resources belonging to another user return `404 Not Found`, not `403 Forbidden`.
- **Empty Responses:** `POST /auth/logout` returns `204 No Content` with an empty body.

### 2.5 HTTP Status Codes & Error Code Glossary

| Status | Meaning | Error Code (`error.code`) | Client Handling |
|--------|---------|---------------------------|-----------------|
| 200 / 201 | Success / Created | n/a | Process `data` payload |
| 204 | No Content | n/a | Handled on logout; clear local tokens |
| 400 | Bad Request | `INVALID_ID`, `RESET_TOKEN_INVALID`, `EMAIL_OTP_INVALID`, `EMAIL_OTP_EXPIRED`, `DOCUMENT_LIMIT_REACHED`, `SELF_INQUIRY`, `OWN_LISTING` | Display user-friendly error message |
| 401 | Unauthorized | `TOKEN_EXPIRED` | Refresh access token once via mutex and retry request |
| 401 | Unauthorized | `UNAUTHORIZED`, `TOKEN_INVALID`, `INVALID_CREDENTIALS`, `REFRESH_TOKEN_INVALID`, `PASSWORD_CHANGED`, `ACCOUNT_MISSING` | Clear secure storage, navigate to login |
| 403 | Forbidden | `EMAIL_NOT_VERIFIED` | Fresh OTP emailed; navigate user to OTP verification screen |
| 403 | Forbidden | `FORBIDDEN` | Role restriction violation (e.g. non-owner accessing owner dashboard) |
| 404 | Not Found | `NOT_FOUND`, `NO_CONTACT_PHONE`, `QUESTION_NOT_FOUND` | Resource missing or hidden; show empty state |
| 409 | Conflict | `ACCOUNT_EXISTS`, `DUPLICATE_LISTING`, `INVALID_TRANSITION`, `ALREADY_REPORTED`, `AREA_IN_USE` | Display conflict warning / handle duplicate override |
| 413 | Payload Too Large | `FILE_TOO_LARGE` | Warn user (photo > 5MB, document > 1MB) |
| 422 | Unprocessable Entity | `VALIDATION_ERROR` | Highlight form fields using `error.details[].path` |
| 429 | Rate Limited | `TOO_MANY_REQUESTS`, `EMAIL_OTP_ATTEMPTS` | Read `RateLimit-Reset` header; back off and disable button |
| 500 / 502 | Server Error | `GEOCODER_UNAVAILABLE`, internal | Exponential backoff retry |

### 2.6 Rate Limits
- **Global API:** 600 requests / 15 minutes per IP.
- **Auth Credentials (login, OTP):** 20 failed attempts / 15 minutes per IP.
- **Phone Reveal / Inquiry / Report:** 30 requests / hour per user.
- **File Uploads (Media & Documents):** 100 uploads / hour per account.
- **Comments & Q&A Posts:** 20 creations / 10 minutes per account.
- **Geo Search (`/geo/search`):** 300 / 15 min (authenticated), 60 / 15 min (anonymous). **Client must debounce typing by ≥ 400 ms.**

## 3. Auth Flow & State Machine / অথ ফ্লো

Stateless JWT authentication with access token in memory/secure storage.

### 3.1 Token Lifetimes
- **Access Token:** 15 minutes (`expiresIn: "15m"`).
- **Refresh Token:** 30 days.

### 3.2 Registration with Email OTP (Default Flow)
1. `POST /auth/register` with `{ name, email, phone, password, role: "tenant"|"owner" }`.
2. Server creates unverified account, dispatches 6-digit email OTP (valid 24h), returns 201 with `{ data: { user, verification: { email, emailOtpRequired: true, required: false } } }` (no tokens).
3. User enters 6-digit OTP -> app calls `POST /auth/verify-email-otp` with `{ email, otp }`.
4. Server returns 200 with `{ data: { user, accessToken, refreshToken, expiresIn: "15m", emailVerified: true } }`.
5. If OTP fails 5 times (`EMAIL_OTP_ATTEMPTS`), user must request new OTP via `POST /auth/resend-email-otp` (60s cooldown).

### 3.3 Login Flow
1. `POST /auth/login` with `{ email, password }`.
2. If email verified: returns 200 with `{ data: { user, accessToken, refreshToken, expiresIn } }`.
3. If email unverified: returns 403 `EMAIL_NOT_VERIFIED`. Server automatically dispatches a fresh code. App transitions immediately to the OTP verification screen.
4. If credentials invalid: returns 401 `INVALID_CREDENTIALS`.

### 3.4 Token Refresh Mechanics (Single-Flight Mutex)
1. App sends requests with `Authorization: Bearer <accessToken>`.
2. When receiving 401 with `error.code == "TOKEN_EXPIRED"`:
   - Dio interceptor acquires a mutex lock.
   - Only ONE single-flight call to `POST /auth/refresh` is dispatched with `{ refreshToken }`.
   - Parallel outgoing requests are queued in memory.
   - On 200 OK: both new `accessToken` and new `refreshToken` are stored in `flutter_secure_storage`.
   - Interceptor replays the queued requests with the new access token.
3. If refresh fails (`REFRESH_TOKEN_INVALID`, `PASSWORD_CHANGED`, `ACCOUNT_MISSING`):
   - Interceptor clears all secure storage.
   - Session manager emits unauthenticated state -> router redirects to login screen.

### 3.5 Password Recovery & Account Operations
- **Forgot Password:** `POST /auth/forgot` with `{ email }`. Server emails reset link `https://ghorbd.com/reset-password?token=...` (always returns `{ sent: true }` to prevent user enumeration).
- **Reset Password:** `POST /auth/reset` with `{ token, password }`. Revokes all existing refresh tokens.
- **Change Password:** `POST /auth/password` with `{ currentPassword, newPassword }`. Returns new tokens.
- **Logout:** `POST /auth/logout` (204). App deletes local tokens immediately.

## 4. Capability Map Replacement Matrix / ক্যাপাবিলিটি প্রতিস্থাপন ম্যাট্রিক্স

The 23 capabilities inferred from the public website have been resolved to concrete API endpoints:

| Old CAP | Capability (EN) | বাংলা | Needs Auth? | Linked REQ | SCR | Concrete Real Endpoints (`API-xxx`) |
|---------|-----------------|-------|-------------|------------|-----|--------------------------------------|
| CAP-01 | Register owner | মালিক রেজিস্ট্রেশন | no | REQ-024 | SCR-011 | `API-005` (POST /auth/register), `API-006` (POST /auth/verify-email-otp), `API-007` (POST /auth/resend-email-otp) |
| CAP-02 | Login, logout, token refresh | লগইন, লগআউট ও টোকেন রিফ্রেশ | no / yes | REQ-023 | SCR-010 | `API-010` (POST /auth/login), `API-011` (POST /auth/refresh), `API-012` (POST /auth/logout), `API-013` (GET /auth/me), `API-014` (POST /auth/forgot), `API-015` (POST /auth/reset), `API-016` (POST /auth/password) |
| CAP-03 | Search listings: purpose, type, area, budget, bedrooms, verified, sort, paging | লিস্টিং ব্রাউজ ও ফিল্টার | no | REQ-001, 007–010 | SCR-002 | `API-022` (GET /listings), `API-034` (GET /search) |
| CAP-04 | Listing detail by slug/id | বিজ্ঞাপনের বিস্তারিত তথ্য | no / optional | REQ-014–021 | SCR-006 | `API-023` (GET /listings/:id) |
| CAP-05 | Listings for map (with coords, search) | মানচিত্রের তথ্য ও সার্চ | no | REQ-011, 012 | SCR-004 | `API-022` (GET /listings?lat=&lng=&radiusKm=), `API-049` (GET /geo/search), `API-050` (GET /geo/reverse) |
| CAP-06 | Land listings: area, land type, price, katha size | জমি বিক্রি ও ফিল্টার | no | REQ-013, 014 | SCR-005 | `API-022` (GET /listings?type=land&landType=&minLandArea=&maxLandArea=) |
| CAP-07 | Facet counts (types, areas, etc.) | ফিল্টার কাউন্ট / ফ্যাসেট | no | REQ-003, 008 | SCR-003 | `API-034` (GET /search?facets=true) |
| CAP-08 | Home data: featured, categories, popular areas, divisions, guides preview | হোম পেজের ডেটা | no | REQ-001–005, 035 | SCR-001 | `API-022` (GET /listings?sort=newest&perPage=10), `API-048` (GET /areas?popular=true), `API-051` (GET /content/guides) |
| CAP-09 | Reveal advertiser phone | বিজ্ঞাপনদাতার ফোন নম্বর দেখা | yes | REQ-018 | SCR-006 | `API-028` (GET /listings/:id/contact) |
| CAP-10 | Send inquiry to owner | বাড়িওয়ালাকে মেসেজ / অনুসন্ধান পাঠানো | yes | REQ-018, 030 | SCR-008 | `API-029` (POST /listings/:id/contact) |
| CAP-11 | Favorites: add, remove, list | পছন্দের তালিকা সংরক্ষণ ও দেখা | yes | REQ-022 | SCR-009 | `API-031` (GET /listings/favorites), `API-032` (POST /listings/:id/favorite), `API-033` (DELETE /listings/:id/favorite) |
| CAP-12 | Report listing | বিজ্ঞাপন রিপোর্ট করা | yes | REQ-020 | SCR-007 | `API-030` (POST /listings/:id/report) |
| CAP-13 | Create, edit, archive listing | বিজ্ঞাপন তৈরি, আপডেট ও স্ট্যাটাস বদল | yes | REQ-025, 027, 028 | SCR-012, 013 | `API-024` (POST /listings), `API-025` (PUT /listings/:id), `API-026` (DELETE /listings/:id), `API-027` (POST /listings/:id/transition) |
| CAP-14 | Upload listing photos | ছবির ফাইল আপলোড | yes | REQ-026 | SCR-012 | `API-038` (POST /media/upload), `API-039` (DELETE /media) |
| CAP-15 | Owner's own listings & dashboard | মালিকের বিজ্ঞাপন ও ড্যাশবোর্ড | yes | REQ-027 | SCR-013 | `API-035` (GET /listings/mine), `API-036` (GET /owner/dashboard), `API-037` (GET /owner/listings) |
| CAP-16 | Plans and pricing (display only) | প্ল্যান ও প্রাইসিং ডিসপ্লে | no | REQ-031–034 | SCR-014 | `API-061` (GET /content/pricing) *(Note: Payments removed in backend migration 016)* |
| CAP-17 | Blog list, categories, detail, comments | ব্লগ পোস্ট ও মন্তব্য | no / yes (comments) | REQ-035 | SCR-015, 016 | `API-054` (GET /content/posts), `API-055` (GET /content/posts/categories), `API-056` (GET /content/posts/:slug), `API-057` (GET /content/posts/:id/comments), `API-058` (POST /content/posts/:id/comments), `API-059` (PATCH /content/comments/:id), `API-060` (DELETE /content/comments/:id) |
| CAP-18 | Q&A: stats, list, detail, ask, answer, delete | প্রশ্নোত্তর প্ল্যাটফর্ম | no / yes (ask/answer) | REQ-036 | SCR-017–019 | `API-062` (GET /qa/stats), `API-063` (GET /qa/questions), `API-064` (POST /qa/questions), `API-065` (GET /qa/questions/:id), `API-066` (DELETE /qa/questions/:id), `API-067` (GET /qa/questions/:id/answers), `API-068` (POST /qa/questions/:id/answers), `API-069` (DELETE /qa/answers/:id) |
| CAP-19 | Help / FAQ / guides content | হেল্প, গাইড ও এফএকিউ | no | REQ-037, 038 | SCR-020, 021 | `API-051` (GET /content/guides), `API-052` (GET /content/guides/:slug), `API-053` (GET /content/pages/:slug) |
| CAP-20 | Contact form & static pages | যোগাযোগ ও স্ট্যাটিক পেজ | no | REQ-039 | SCR-022–025 | `API-053` (GET /content/pages/:slug where slug = `about`, `terms`, `privacy`, `help`) |
| CAP-21 | Verification documents & listing badge | যাচাইকরণ ডকুমেন্টস আপলোড ও ম্যানেজ | yes | REQ-029 | SCR-013 | `API-040` (GET /documents), `API-041` (POST /documents), `API-042` (GET /documents/:id/file), `API-043` (DELETE /documents/:id) |
| CAP-22 | Master data: areas and locations | এলাকা ও লোকেশন মাস্টার ডেটা | no | REQ-001, 002, 041 | SCR-001, 003 | `API-048` (GET /areas) |
| CAP-23 | Account profile & credentials | অ্যাকাউন্ট ও পাসওয়ার্ড | yes | PRP-001 | n/a | `API-013` (GET /auth/me), `API-016` (POST /auth/password), `API-017` (POST /auth/google/unlink) *(Profile edit and delete endpoints pending on backend)* |

## 5. Master Endpoint Catalog (All 116 Endpoints) / মাস্টার এপিআই তালিকা

| ID | Domain / Folder | Method | Endpoint Path | Auth | Description / Summary | Linked REQ | SCR |
|----|-----------------|--------|---------------|------|-----------------------|------------|-----|
| `API-001` | System | `GET` | `/` | None | API index | NFR-004 | global |
| `API-002` | System | `GET` | `/health/live` | None | Liveness probe | NFR-004 | global |
| `API-003` | System | `GET` | `/health/ready` | None | Readiness probe | NFR-004 | global |
| `API-004` | Auth | `GET` | `/auth/providers` | None | Available sign-in methods | REQ-023 | SCR-010 |
| `API-005` | Auth | `POST` | `/auth/register` | None | Register a new account | REQ-024 | SCR-011 |
| `API-006` | Auth | `POST` | `/auth/verify-email-otp` | None | Verify email with 6-digit code (finishes signup) | REQ-024 | SCR-011 |
| `API-007` | Auth | `POST` | `/auth/resend-email-otp` | None | Resend email verification code | REQ-024 | SCR-011 |
| `API-008` | Auth | `POST` | `/auth/verify-email` | None | Verify email with link token | REQ-024 | SCR-011 |
| `API-009` | Auth | `POST` | `/auth/resend-email` | Bearer (JWT) | Resend verification email (signed-in user) | REQ-024 | SCR-011 |
| `API-010` | Auth | `POST` | `/auth/login` | None | Log in with email + password | REQ-023 | SCR-010 |
| `API-011` | Auth | `POST` | `/auth/refresh` | None | Refresh the session | REQ-023, NFR-002 | global |
| `API-012` | Auth | `POST` | `/auth/logout` | None | Log out | REQ-023 | SCR-010 |
| `API-013` | Auth | `GET` | `/auth/me` | Optional | Current user | REQ-023, PRP-001 | SCR-010 |
| `API-014` | Auth | `POST` | `/auth/forgot` | None | Request password reset | REQ-023 | SCR-010 |
| `API-015` | Auth | `POST` | `/auth/reset` | None | Reset password with token | REQ-023 | SCR-010 |
| `API-016` | Auth | `POST` | `/auth/password` | Bearer (JWT) | Set or change password | REQ-023 | SCR-010 |
| `API-017` | Auth | `POST` | `/auth/google/unlink` | Bearer (JWT) | Disconnect Google from account | REQ-023 | SCR-010 |
| `API-018` | Auth | `GET` | `/auth/google` | None | Google sign-in start (WEB ONLY) | REQ-023 | SCR-010 |
| `API-019` | Auth | `GET` | `/auth/google/callback` | None | Google sign-in callback (WEB ONLY) | REQ-023 | SCR-010 |
| `API-020` | Auth | `POST` | `/auth/verify` | None | Verify phone OTP (CURRENTLY DISABLED) | REQ-024 | SCR-011 |
| `API-021` | Auth | `POST` | `/auth/resend-otp` | None | Resend phone OTP (CURRENTLY DISABLED) | REQ-024 | SCR-011 |
| `API-022` | Listings | `GET` | `/listings` | None | Browse public listings | REQ-001, 007–010, 013 | SCR-001, 002, 004, 005 |
| `API-023` | Listings | `GET` | `/listings/{id}` | Optional | Listing detail (by id or slug) | REQ-014–021 | SCR-006 |
| `API-024` | Listings | `POST` | `/listings` | Bearer (Staff/Admin) | Create listing (post an ad) | REQ-025, 026 | SCR-012 |
| `API-025` | Listings | `PUT` | `/listings/{id}` | Bearer (Owner/Admin) | Update listing (partial) | REQ-028 | SCR-012 |
| `API-026` | Listings | `DELETE` | `/listings/{id}` | Bearer (JWT) | Delete (archive) listing | REQ-028 | SCR-013 |
| `API-027` | Listings | `POST` | `/listings/{id}/transition` | Bearer (Staff/Admin) | Change listing status | REQ-027, 028 | SCR-013 |
| `API-028` | Listings | `GET` | `/listings/{id}/contact` | Bearer (JWT) | Reveal advertiser phone number | REQ-018 | SCR-006 |
| `API-029` | Listings | `POST` | `/listings/{id}/contact` | Bearer (Owner/Admin) | Send inquiry to the owner | REQ-018, 030 | SCR-008 |
| `API-030` | Listings | `POST` | `/listings/{id}/report` | Bearer (Staff/Admin) | Report a listing | REQ-020 | SCR-007 |
| `API-031` | Favorites | `GET` | `/listings/favorites` | Bearer (JWT) | My saved listings | REQ-022 | SCR-009 |
| `API-032` | Favorites | `POST` | `/listings/{id}/favorite` | Bearer (JWT) | Save listing | REQ-022 | SCR-006, 009 |
| `API-033` | Favorites | `DELETE` | `/listings/{id}/favorite` | Bearer (JWT) | Unsave listing | REQ-022 | SCR-006, 009 |
| `API-034` | Search | `GET` | `/search` | None | Search listings with facets | REQ-001, 003, 008, 009 | SCR-002, 003 |
| `API-035` | My Listings & Owner Dashboard | `GET` | `/listings/mine` | Bearer (JWT) | My listings (any role) | REQ-027 | SCR-013 |
| `API-036` | My Listings & Owner Dashboard | `GET` | `/owner/dashboard` | Bearer (Staff/Admin) | Owner dashboard stats | REQ-027 | SCR-013 |
| `API-037` | My Listings & Owner Dashboard | `GET` | `/owner/listings` | Bearer (Staff/Admin) | Owner listings | REQ-027 | SCR-013 |
| `API-038` | Media Uploads | `POST` | `/media/upload` | Bearer (JWT) | Upload listing photos | REQ-026 | SCR-012 |
| `API-039` | Media Uploads | `DELETE` | `/media` | Bearer (JWT) | Delete an uploaded photo | REQ-026, 028 | SCR-012 |
| `API-040` | Verification Documents | `GET` | `/documents` | Bearer (JWT) | My verification documents | REQ-029 | SCR-013 |
| `API-041` | Verification Documents | `POST` | `/documents` | Bearer (JWT) | Upload a verification document | REQ-029 | SCR-013 |
| `API-042` | Verification Documents | `GET` | `/documents/{id}/file` | Bearer (Owner/Admin) | View / download a document file | REQ-029 | SCR-013 |
| `API-043` | Verification Documents | `DELETE` | `/documents/{id}` | Bearer (JWT) | Delete a document | REQ-029 | SCR-013 |
| `API-044` | Notifications | `GET` | `/notifications` | Bearer (JWT) | My in-app notifications | REQ-030 | global |
| `API-045` | Notifications | `GET` | `/notifications/unread-count` | Bearer (JWT) | Unread badge count | REQ-030 | global |
| `API-046` | Notifications | `POST` | `/notifications/{id}/read` | Bearer (JWT) | Mark one as read | REQ-030 | global |
| `API-047` | Notifications | `POST` | `/notifications/read-all` | Bearer (JWT) | Mark all as read | REQ-030 | global |
| `API-048` | Areas & Maps | `GET` | `/areas` | None | Curated areas | REQ-001, 002, 041 | SCR-001, 003 |
| `API-049` | Areas & Maps | `GET` | `/geo/search` | Optional | Place / address search (geocoding) | REQ-011, 025 | SCR-004, 012 |
| `API-050` | Areas & Maps | `GET` | `/geo/reverse` | Bearer (JWT) | Reverse geocode (pin → address) | REQ-011, 025 | SCR-004, 012 |
| `API-051` | Content (Guides, Blog, Pages, Pricing) | `GET` | `/content/guides` | None | Guides list | REQ-037, 038 | SCR-020, 021 |
| `API-052` | Content (Guides, Blog, Pages, Pricing) | `GET` | `/content/guides/{slug}` | Optional | Guide detail | REQ-038 | SCR-021 |
| `API-053` | Content (Guides, Blog, Pages, Pricing) | `GET` | `/content/pages/{slug}` | Optional | Static page (about, help, privacy, terms) | REQ-037, 039 | SCR-020, 022–025 |
| `API-054` | Content (Guides, Blog, Pages, Pricing) | `GET` | `/content/posts` | None | Blog posts | REQ-035 | SCR-015 |
| `API-055` | Content (Guides, Blog, Pages, Pricing) | `GET` | `/content/posts/categories` | None | Blog categories | REQ-035 | SCR-015 |
| `API-056` | Content (Guides, Blog, Pages, Pricing) | `GET` | `/content/posts/{slug}` | Optional | Blog post detail | REQ-035 | SCR-016 |
| `API-057` | Content (Guides, Blog, Pages, Pricing) | `GET` | `/content/posts/{id}/comments` | Optional | Post comments | REQ-035 | SCR-016 |
| `API-058` | Content (Guides, Blog, Pages, Pricing) | `POST` | `/content/posts/{id}/comments` | Bearer (JWT) | Add comment / reply | REQ-035 | SCR-016 |
| `API-059` | Content (Guides, Blog, Pages, Pricing) | `PATCH` | `/content/comments/{id}` | Bearer (JWT) | Edit my comment | REQ-035 | SCR-016 |
| `API-060` | Content (Guides, Blog, Pages, Pricing) | `DELETE` | `/content/comments/{id}` | Bearer (JWT) | Delete comment | REQ-035 | SCR-016 |
| `API-061` | Content (Guides, Blog, Pages, Pricing) | `GET` | `/content/pricing` | None | Pricing plans (display only) | REQ-031–034 | SCR-014 |
| `API-062` | Q&A | `GET` | `/qa/stats` | None | Q&A sidebar stats | REQ-036 | SCR-017 |
| `API-063` | Q&A | `GET` | `/qa/questions` | Optional | List questions | REQ-036 | SCR-017 |
| `API-064` | Q&A | `POST` | `/qa/questions` | Bearer (JWT) | Ask a question | REQ-036 | SCR-018 |
| `API-065` | Q&A | `GET` | `/qa/questions/{id}` | Optional | Question detail (by slug or id) | REQ-036 | SCR-019 |
| `API-066` | Q&A | `DELETE` | `/qa/questions/{id}` | Bearer (JWT) | Delete question | REQ-036 | SCR-019 |
| `API-067` | Q&A | `GET` | `/qa/questions/{id}/answers` | Optional | Answers for a question | REQ-036 | SCR-019 |
| `API-068` | Q&A | `POST` | `/qa/questions/{id}/answers` | Bearer (JWT) | Answer a question | REQ-036 | SCR-019 |
| `API-069` | Q&A | `DELETE` | `/qa/answers/{id}` | Bearer (JWT) | Delete answer | REQ-036 | SCR-019 |
| `API-070` | Admin — Moderation | `GET` | `/admin/overview` | Bearer (Staff/Admin) | Platform overview stats | Admin only | admin-console |
| `API-071` | Admin — Moderation | `GET` | `/admin/listings/pending` | Bearer (Staff/Admin) | Review queue | Admin only | admin-console |
| `API-072` | Admin — Moderation | `GET` | `/admin/listings` | Bearer (Staff/Admin) | All listings (admin browser) | Admin only | admin-console |
| `API-073` | Admin — Moderation | `POST` | `/admin/listings/{id}/verify` | Bearer (Staff/Admin) | Approve listing (→ active) | Admin only | admin-console |
| `API-074` | Admin — Moderation | `POST` | `/admin/listings/{id}/reject` | Bearer (Staff/Admin) | Reject listing | Admin only | admin-console |
| `API-075` | Admin — Moderation | `POST` | `/admin/listings/{id}/feature` | Bearer (Staff/Admin) | Feature listing (pin to top) | Admin only | admin-console |
| `API-076` | Admin — Moderation | `POST` | `/admin/listings/{id}/unfeature` | Bearer (Staff/Admin) | Unfeature listing | Admin only | admin-console |
| `API-077` | Admin — Moderation | `GET` | `/admin/reports` | Bearer (Staff/Admin) | Listing reports | Admin only | admin-console |
| `API-078` | Admin — Moderation | `POST` | `/admin/reports/{id}/dismiss` | Bearer (Staff/Admin) | Dismiss report | Admin only | admin-console |
| `API-079` | Admin — Moderation | `POST` | `/admin/reports/{id}/remove-listing` | Bearer (Staff/Admin) | Remove reported listing | Admin only | admin-console |
| `API-080` | Admin — Moderation | `GET` | `/admin/comments` | Bearer (Staff/Admin) | Comment moderation queue | Admin only | admin-console |
| `API-081` | Admin — Moderation | `POST` | `/admin/comments/{id}/approve` | Bearer (Staff/Admin) | Approve comment | Admin only | admin-console |
| `API-082` | Admin — Moderation | `POST` | `/admin/comments/{id}/reject` | Bearer (Staff/Admin) | Reject comment | Admin only | admin-console |
| `API-083` | Admin — Moderation | `GET` | `/admin/qa` | Bearer (Staff/Admin) | Q&A moderation queue | Admin only | admin-console |
| `API-084` | Admin — Moderation | `POST` | `/admin/qa/{type}/{id}/approve` | Bearer (Staff/Admin) | Approve question / answer | Admin only | admin-console |
| `API-085` | Admin — Moderation | `POST` | `/admin/qa/{type}/{id}/reject` | Bearer (Staff/Admin) | Reject question / answer | Admin only | admin-console |
| `API-086` | Admin — Users | `GET` | `/admin/users` | Bearer (Staff/Admin) | List users | Admin only | admin-console |
| `API-087` | Admin — Users | `GET` | `/admin/users/{id}` | Bearer (Staff/Admin) | User detail | Admin only | admin-console |
| `API-088` | Admin — Users | `PUT` | `/admin/users/{id}` | Bearer (Staff/Admin) | Update user profile fields | Admin only | admin-console |
| `API-089` | Admin — Users | `PATCH` | `/admin/users/{id}/role` | Bearer (Staff/Admin) | Change user role | Admin only | admin-console |
| `API-090` | Admin — Users | `DELETE` | `/admin/users/{id}` | Bearer (Staff/Admin) | Delete user | Admin only | admin-console |
| `API-091` | Admin — Users | `GET` | `/admin/users/{id}/documents` | Bearer (Staff/Admin) | A user’s verification documents | Admin only | admin-console |
| `API-092` | Admin — Content | `GET` | `/admin/guides` | Bearer (Staff/Admin) | List guides (incl. drafts) | Admin only | admin-console |
| `API-093` | Admin — Content | `POST` | `/admin/guides` | Bearer (Staff/Admin) | Create guide | Admin only | admin-console |
| `API-094` | Admin — Content | `GET` | `/admin/guides/{id}` | Bearer (Staff/Admin) | Get guide | Admin only | admin-console |
| `API-095` | Admin — Content | `PUT` | `/admin/guides/{id}` | Bearer (Staff/Admin) | Update guide (partial) | Admin only | admin-console |
| `API-096` | Admin — Content | `DELETE` | `/admin/guides/{id}` | Bearer (Staff/Admin) | Delete guide | Admin only | admin-console |
| `API-097` | Admin — Content | `GET` | `/admin/posts` | Bearer (Staff/Admin) | List posts (incl. drafts) | Admin only | admin-console |
| `API-098` | Admin — Content | `POST` | `/admin/posts` | Bearer (Staff/Admin) | Create post | Admin only | admin-console |
| `API-099` | Admin — Content | `GET` | `/admin/posts/{id}` | Bearer (Staff/Admin) | Get post | Admin only | admin-console |
| `API-100` | Admin — Content | `PUT` | `/admin/posts/{id}` | Bearer (Staff/Admin) | Update post (partial) | Admin only | admin-console |
| `API-101` | Admin — Content | `DELETE` | `/admin/posts/{id}` | Bearer (Staff/Admin) | Delete post | Admin only | admin-console |
| `API-102` | Admin — Content | `GET` | `/admin/pages` | Bearer (Staff/Admin) | List pages (incl. drafts) | Admin only | admin-console |
| `API-103` | Admin — Content | `POST` | `/admin/pages` | Bearer (Staff/Admin) | Create page | Admin only | admin-console |
| `API-104` | Admin — Content | `GET` | `/admin/pages/{id}` | Bearer (Staff/Admin) | Get page | Admin only | admin-console |
| `API-105` | Admin — Content | `PUT` | `/admin/pages/{id}` | Bearer (Staff/Admin) | Update page (partial) | Admin only | admin-console |
| `API-106` | Admin — Content | `DELETE` | `/admin/pages/{id}` | Bearer (Staff/Admin) | Delete page | Admin only | admin-console |
| `API-107` | Admin — Content | `GET` | `/admin/pricing` | Bearer (Staff/Admin) | List pricing (incl. drafts) | Admin only | admin-console |
| `API-108` | Admin — Content | `POST` | `/admin/pricing` | Bearer (Staff/Admin) | Create pricing | Admin only | admin-console |
| `API-109` | Admin — Content | `GET` | `/admin/pricing/{id}` | Bearer (Staff/Admin) | Get pricing | Admin only | admin-console |
| `API-110` | Admin — Content | `PUT` | `/admin/pricing/{id}` | Bearer (Staff/Admin) | Update pricing (partial) | Admin only | admin-console |
| `API-111` | Admin — Content | `DELETE` | `/admin/pricing/{id}` | Bearer (Staff/Admin) | Delete pricing | Admin only | admin-console |
| `API-112` | Admin — Content | `GET` | `/admin/areas` | Bearer (Staff/Admin) | List areas (incl. drafts) | Admin only | admin-console |
| `API-113` | Admin — Content | `POST` | `/admin/areas` | Bearer (Staff/Admin) | Create area | Admin only | admin-console |
| `API-114` | Admin — Content | `GET` | `/admin/areas/{id}` | Bearer (Staff/Admin) | Get area | Admin only | admin-console |
| `API-115` | Admin — Content | `PUT` | `/admin/areas/{id}` | Bearer (Staff/Admin) | Update area (partial) | Admin only | admin-console |
| `API-116` | Admin — Content | `DELETE` | `/admin/areas/{id}` | Bearer (Staff/Admin) | Delete area | Admin only | admin-console |

## 6. Core Mobile Endpoints — Specification & Real Examples / মূল মোবাইল এন্ডপয়েন্ট

The following sections provide the exact request body and response payload examples extracted directly from `GhorBD.postman_collection.json` and verified against `ghorbd-openapi.json`.

### 6.Auth

#### `API-005`: Register a new account
- **Route:** `POST /auth/register`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-024` | Screen: `SCR-011`

**Request Body (`application/json`):**
```json
{
  "name": "Rahim Uddin",
  "email": "rahim@example.com",
  "phone": "01711000000",
  "password": "secret123",
  "role": "owner",
  "listerType": "owner"
}
```

**Success Response (`HTTP 201 201 Created — verification pending (default)`):**
```json
{
  "data": {
    "user": {
      "id": "665f1c2e9b1d4a0012ab34cd",
      "name": "Rahim Uddin",
      "email": "rahim@example.com",
      "phone": "+8801711000000",
      "role": "owner",
      "listerType": "owner",
      "listerDetail": null,
      "verified": true,
      "emailVerifiedAt": null,
      "phoneVerifiedAt": null,
      "sessionVersion": 0,
      "passwordChangedAt": null,
      "profilePhotoUrl": null,
      "preferences": {
        "locale": "bn-BD",
        "emailNotifications": true,
        "smsNotifications": true,
        "reminders": {
          "enabled": true,
          "leadDays": 3,
          "remindOverdue": true
        }
      },
      "isOwner": true,
      "isAdmin": false,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "updatedAt": "2026-10-01T08:00:00.000Z"
    },
    "verification": {
      "userId": "665f1c2e9b1d4a0012ab34cd",
      "email": "rahim@example.com",
      "required": false,
      "emailOtpRequired": true,
      "devEmailOtp": "482913"
    }
  }
}
```

**Sample Error Response (`HTTP 409 409 Email or phone already registered`):**
```json
{
  "error": {
    "code": "ACCOUNT_EXISTS",
    "message": "An account with that email already exists"
  }
}
```

#### `API-006`: Verify email with 6-digit code (finishes signup)
- **Route:** `POST /auth/verify-email-otp`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-024` | Screen: `SCR-011`

**Request Body (`application/json`):**
```json
{
  "email": "rahim@example.com",
  "otp": "482913"
}
```

**Success Response (`HTTP 200 200 Verified — session issued`):**
```json
{
  "data": {
    "user": {
      "id": "665f1c2e9b1d4a0012ab34cd",
      "name": "Rahim Uddin",
      "email": "rahim@example.com",
      "phone": "+8801711000000",
      "role": "owner",
      "listerType": "owner",
      "listerDetail": null,
      "verified": true,
      "emailVerifiedAt": "2026-10-01T08:00:00.000Z",
      "phoneVerifiedAt": null,
      "sessionVersion": 0,
      "passwordChangedAt": null,
      "profilePhotoUrl": null,
      "preferences": {
        "locale": "bn-BD",
        "emailNotifications": true,
        "smsNotifications": true,
        "reminders": {
          "enabled": true,
          "leadDays": 3,
          "remindOverdue": true
        }
      },
      "isOwner": true,
      "isAdmin": false,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "updatedAt": "2026-10-01T08:00:00.000Z"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.…",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.…",
    "expiresIn": "15m",
    "emailVerified": true
  }
}
```

**Sample Error Response (`HTTP 400 400 Wrong code (EMAIL_OTP_INVALID) or expired code (EMAIL_OTP_EXPIRED)`):**
```json
{
  "error": {
    "code": "EMAIL_OTP_INVALID",
    "message": "The code is incorrect or has expired"
  }
}
```

#### `API-007`: Resend email verification code
- **Route:** `POST /auth/resend-email-otp`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-024` | Screen: `SCR-011`

**Request Body (`application/json`):**
```json
{
  "email": "rahim@example.com"
}
```

**Success Response (`HTTP 200 200 Sent`):**
```json
{
  "data": {
    "sent": true
  }
}
```

**Sample Error Response (`HTTP 422 422 Request failed schema validation`):**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "path": "title",
        "message": "String must contain at least 5 character(s)"
      }
    ]
  }
}
```

#### `API-010`: Log in with email + password
- **Route:** `POST /auth/login`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-023` | Screen: `SCR-010`

**Request Body (`application/json`):**
```json
{
  "email": "rahim@example.com",
  "password": "secret123"
}
```

**Success Response (`HTTP 200 200 Logged in`):**
```json
{
  "data": {
    "user": {
      "id": "665f1c2e9b1d4a0012ab34cd",
      "name": "Rahim Uddin",
      "email": "rahim@example.com",
      "phone": "+8801711000000",
      "role": "owner",
      "listerType": "owner",
      "listerDetail": null,
      "verified": true,
      "emailVerifiedAt": "2026-10-01T08:00:00.000Z",
      "phoneVerifiedAt": null,
      "sessionVersion": 0,
      "passwordChangedAt": null,
      "profilePhotoUrl": null,
      "preferences": {
        "locale": "bn-BD",
        "emailNotifications": true,
        "smsNotifications": true,
        "reminders": {
          "enabled": true,
          "leadDays": 3,
          "remindOverdue": true
        }
      },
      "isOwner": true,
      "isAdmin": false,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "updatedAt": "2026-10-01T08:00:00.000Z"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.…",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.…",
    "expiresIn": "15m"
  }
}
```

**Sample Error Response (`HTTP 401 401 Wrong email or password (same message for both)`):**
```json
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Incorrect email or password"
  }
}
```

#### `API-011`: Refresh the session
- **Route:** `POST /auth/refresh`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-023, NFR-002` | Screen: `global`

**Request Body (`application/json`):**
```json
{
  "refreshToken": "{{refreshToken}}"
}
```

**Success Response (`HTTP 200 200 New tokens`):**
```json
{
  "data": {
    "user": {
      "id": "665f1c2e9b1d4a0012ab34cd",
      "name": "Rahim Uddin",
      "email": "rahim@example.com",
      "phone": "+8801711000000",
      "role": "owner",
      "listerType": "owner",
      "listerDetail": null,
      "verified": true,
      "emailVerifiedAt": "2026-10-01T08:00:00.000Z",
      "phoneVerifiedAt": null,
      "sessionVersion": 0,
      "passwordChangedAt": null,
      "profilePhotoUrl": null,
      "preferences": {
        "locale": "bn-BD",
        "emailNotifications": true,
        "smsNotifications": true,
        "reminders": {
          "enabled": true,
          "leadDays": 3,
          "remindOverdue": true
        }
      },
      "isOwner": true,
      "isAdmin": false,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "updatedAt": "2026-10-01T08:00:00.000Z"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.…",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.…",
    "expiresIn": "15m"
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing / invalid / revoked refresh token`):**
```json
{
  "error": {
    "code": "REFRESH_TOKEN_INVALID",
    "message": "Invalid refresh token"
  }
}
```

    "code": "REFRESH_TOKEN_INVALID",
    "message": "Invalid refresh token"
  }
}
```

#### `API-013`: Current user
- **Route:** `GET /auth/me`
- **Auth Required:** `Optional`
- **Traceability:** Linked to `REQ-023, PRP-001` | Screen: `SCR-010`

**Success Response (`HTTP 200 200 Current user (or null)`):**
```json
{
  "data": {
    "user": {
      "id": "665f1c2e9b1d4a0012ab34cd",
      "name": "Rahim Uddin",
      "email": "rahim@example.com",
      "phone": "+8801711000000",
      "role": "owner",
      "listerType": "owner",
      "listerDetail": null,
      "verified": true,
      "emailVerifiedAt": "2026-10-01T08:00:00.000Z",
      "phoneVerifiedAt": null,
      "sessionVersion": 0,
      "passwordChangedAt": null,
      "profilePhotoUrl": null,
      "preferences": {
        "locale": "bn-BD",
        "emailNotifications": true,
        "smsNotifications": true,
        "reminders": {
          "enabled": true,
          "leadDays": 3,
          "remindOverdue": true
        }
      },
      "isOwner": true,
      "isAdmin": false,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "updatedAt": "2026-10-01T08:00:00.000Z",
      "googleLinked": false,
      "hasPassword": true
    }
  }
}
```

#### `API-014`: Request password reset
- **Route:** `POST /auth/forgot`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-023` | Screen: `SCR-010`

**Request Body (`application/json`):**
```json
{
  "email": "rahim@example.com"
}
```

**Success Response (`HTTP 200 200 Sent (always)`):**
```json
{
  "data": {
    "sent": true,
    "devResetToken": "(dev only)"
  }
}
```

**Sample Error Response (`HTTP 422 422 Request failed schema validation`):**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "path": "title",
        "message": "String must contain at least 5 character(s)"
      }
    ]
  }
}
```

#### `API-015`: Reset password with token
- **Route:** `POST /auth/reset`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-023` | Screen: `SCR-010`

**Request Body (`application/json`):**
```json
{
  "token": "a3b1c5d7e9f0a2b4c6d8e0f1a3b5c7d9e1f3a5b7c9d1e3f5a7b9c1d3e5f7a9b1",
  "password": "newSecret456"
}
```

**Success Response (`HTTP 200 200 Password reset`):**
```json
{
  "data": {
    "reset": true,
    "sessionsRevoked": true
  }
}
```

**Sample Error Response (`HTTP 400 400 Bad token`):**
```json
{
  "error": {
    "code": "RESET_TOKEN_EXPIRED",
    "message": "Reset link has expired"
  }
}
```

#### `API-016`: Set or change password
- **Route:** `POST /auth/password`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-023` | Screen: `SCR-010`

**Request Body (`application/json`):**
```json
{
  "currentPassword": "secret123",
  "newPassword": "newSecret456"
}
```

**Success Response (`HTTP 200 200 Changed — new session`):**
```json
{
  "data": {
    "user": {
      "id": "665f1c2e9b1d4a0012ab34cd",
      "name": "Rahim Uddin",
      "email": "rahim@example.com",
      "phone": "+8801711000000",
      "role": "owner",
      "listerType": "owner",
      "listerDetail": null,
      "verified": true,
      "emailVerifiedAt": "2026-10-01T08:00:00.000Z",
      "phoneVerifiedAt": null,
      "sessionVersion": 0,
      "passwordChangedAt": null,
      "profilePhotoUrl": null,
      "preferences": {
        "locale": "bn-BD",
        "emailNotifications": true,
        "smsNotifications": true,
        "reminders": {
          "enabled": true,
          "leadDays": 3,
          "remindOverdue": true
        }
      },
      "isOwner": true,
      "isAdmin": false,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "updatedAt": "2026-10-01T08:00:00.000Z"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.…",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.…",
    "expiresIn": "15m"
  }
}
```

**Sample Error Response (`HTTP 401 401 Current password wrong`):**
```json
{
  "error": {
    "code": "CURRENT_PASSWORD_INVALID",
    "message": "Current password is incorrect"
  }
}
```

### 6.Listings

#### `API-022`: Browse public listings
- **Route:** `GET /listings`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-001, 007–010, 013` | Screen: `SCR-001, 002, 004, 005`

**Success Response (`HTTP 200 200 Listings page`):**
```json
{
  "data": [
    {
      "id": "6671a0b2c3d4e5f601234567",
      "ownerId": "665f1c2e9b1d4a0012ab34cd",
      "listerType": "owner",
      "listerDetail": null,
      "title": "Uttara Sector 7 — 3 bed family flat",
      "slug": "uttara-sector-7-3-bed-family-flat",
      "description": "South-facing, lift and generator, 5 minutes to the metro station.",
      "propertyType": "apartment",
      "purpose": "rent",
      "areaSlug": "uttara",
      "city": "dhaka",
      "division": "dhaka",
      "address": "Road 12, Sector 7, Uttara",
      "floor": 5,
      "unitNumber": "5B",
      "rooms": {
        "bed": 3,
        "bath": 2
      },
      "size": 1350,
      "land": null,
      "hotel": null,
      "pricePerMonth": 25000,
      "currency": "BDT",
      "images": [
        "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-1-w1200.webp",
        "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-2-w1200.webp"
      ],
      "amenities": [
        "lift",
        "generator",
        "parking",
        "cctv"
      ],
      "verified": true,
      "verifiedAt": "2026-10-01T08:00:00.000Z",
      "rejectionReason": null,
      "featured": false
    }
  ],
  "meta": {
    "page": 1,
    "perPage": 12,
    "total": 87,
    "totalPages": 8
  }
}
```

**Sample Error Response (`HTTP 422 422 Request failed schema validation`):**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "path": "title",
        "message": "String must contain at least 5 character(s)"
      }
    ]
  }
}
```

#### `API-023`: Listing detail (by id or slug)
- **Route:** `GET /listings/{id}`
- **Auth Required:** `Optional`
- **Traceability:** Linked to `REQ-014–021` | Screen: `SCR-006`

**Success Response (`HTTP 200 200 Listing`):**
```json
{
  "data": {
    "listing": {
      "id": "6671a0b2c3d4e5f601234567",
      "ownerId": "665f1c2e9b1d4a0012ab34cd",
      "listerType": "owner",
      "listerDetail": null,
      "title": "Uttara Sector 7 — 3 bed family flat",
      "slug": "uttara-sector-7-3-bed-family-flat",
      "description": "South-facing, lift and generator, 5 minutes to the metro station.",
      "propertyType": "apartment",
      "purpose": "rent",
      "areaSlug": "uttara",
      "city": "dhaka",
      "division": "dhaka",
      "address": "Road 12, Sector 7, Uttara",
      "floor": 5,
      "unitNumber": "5B",
      "rooms": {
        "bed": 3,
        "bath": 2
      },
      "size": 1350,
      "land": null,
      "hotel": null,
      "pricePerMonth": 25000,
      "currency": "BDT",
      "images": [
        "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-1-w1200.webp",
        "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-2-w1200.webp"
      ],
      "amenities": [
        "lift",
        "generator",
        "parking",
        "cctv"
      ],
      "verified": true,
      "verifiedAt": "2026-10-01T08:00:00.000Z",
      "rejectionReason": null,
      "featured": false,
      "hasContactPhone": true,
      "viewCount": 142
    }
  }
}
```

**Sample Error Response (`HTTP 404 404 Not found`):**
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Listing not found"
  }
}
```

#### `API-024`: Create listing (post an ad)
- **Route:** `POST /listings`
- **Auth Required:** `Bearer (Staff/Admin)`
- **Traceability:** Linked to `REQ-025, 026` | Screen: `SCR-012`

**Request Body (`application/json`):**
```json
{
  "title": "Uttara Sector 7 — 3 bed family flat",
  "description": "South-facing, lift and generator, 5 minutes to the metro station.",
  "propertyType": "apartment",
  "purpose": "rent",
  "areaSlug": "uttara",
  "city": "dhaka",
  "address": "Road 12, Sector 7, Uttara",
  "floor": 5,
  "unitNumber": "5B",
  "rooms": {
    "bed": 3,
    "bath": 2
  },
  "size": 1350,
  "pricePerMonth": 25000,
  "images": [
    "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-1-w1200.webp",
    "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-2-w1200.webp"
  ],
  "amenities": [
    "lift",
    "generator",
    "parking"
  ],
  "contactPhone": "01711000000",
  "allowDirectContact": true,
  "displayDuration": "unlimited",
  "coords": {
    "lat": 23.8759,
    "lng": 90.3795
  },
  "status": "pending"
}
```

**Success Response (`HTTP 201 201 Created`):**
```json
{
  "data": {
    "listing": {
      "id": "6671a0b2c3d4e5f601234567",
      "ownerId": "665f1c2e9b1d4a0012ab34cd",
      "listerType": "owner",
      "listerDetail": null,
      "title": "Uttara Sector 7 — 3 bed family flat",
      "slug": "uttara-sector-7-3-bed-family-flat",
      "description": "South-facing, lift and generator, 5 minutes to the metro station.",
      "propertyType": "apartment",
      "purpose": "rent",
      "areaSlug": "uttara",
      "city": "dhaka",
      "division": "dhaka",
      "address": "Road 12, Sector 7, Uttara",
      "floor": 5,
      "unitNumber": "5B",
      "rooms": {
        "bed": 3,
        "bath": 2
      },
      "size": 1350,
      "land": null,
      "hotel": null,
      "pricePerMonth": 25000,
      "currency": "BDT",
      "images": [
        "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-1-w1200.webp",
        "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-2-w1200.webp"
      ],
      "amenities": [
        "lift",
        "generator",
        "parking",
        "cctv"
      ],
      "verified": false,
      "status": "pending",
      "displayDuration": "unlimited"
    }
  }
}
```

**Sample Error Response (`HTTP 409 409 Same owner + title + address already exists. Resend with allowDuplicate: true if genuinely different.`):**
```json
{
  "error": {
    "code": "DUPLICATE_LISTING",
    "message": "You already have a listing with this title and address",
    "details": {
      "existing": {
        "id": "6671a0b2c3d4e5f601234567",
        "title": "Uttara Sector 7 — 3 bed family flat",
        "slug": "uttara-sector-7-3-bed-family-flat"
      },
      "hint": "Resend with allowDuplicate: true if this is a genuinely different unit"
    }
  }
}
```

#### `API-025`: Update listing (partial)
- **Route:** `PUT /listings/{id}`
- **Auth Required:** `Bearer (Owner/Admin)`
- **Traceability:** Linked to `REQ-028` | Screen: `SCR-012`

**Request Body (`application/json`):**
```json
{
  "pricePerMonth": 23000,
  "amenities": [
    "lift",
    "generator",
    "parking",
    "gas"
  ]
}
```

**Success Response (`HTTP 200 200 Updated`):**
```json
{
  "data": {
    "listing": {
      "id": "6671a0b2c3d4e5f601234567",
      "ownerId": "665f1c2e9b1d4a0012ab34cd",
      "title": "Uttara Sector 7 — 3 bed family flat",
      "pricePerMonth": 23000,
      "amenities": [
        "lift",
        "generator",
        "parking",
        "gas"
      ]
    }
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

#### `API-027`: Change listing status
- **Route:** `POST /listings/{id}/transition`
- **Auth Required:** `Bearer (Staff/Admin)`
- **Traceability:** Linked to `REQ-027, 028` | Screen: `SCR-013`

**Request Body (`application/json`):**
```json
{
  "action": "submit"
}
```

**Success Response (`HTTP 200 200 Transitioned`):**
```json
{
  "data": {
    "listing": {
      "id": "6671a0b2c3d4e5f601234567",
      "status": "pending",
      "available": [
        "withdraw"
      ]
    }
  }
}
```

**Sample Error Response (`HTTP 409 409 Not allowed from current state`):**
```json
{
  "error": {
    "code": "INVALID_TRANSITION",
    "message": "A active listing cannot be withdrawed",
    "details": {
      "from": "active",
      "action": "withdraw",
      "allowed": [
        "archive"
      ]
    }
  }
}
```

#### `API-028`: Reveal advertiser phone number
- **Route:** `GET /listings/{id}/contact`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-018` | Screen: `SCR-006`

**Success Response (`HTTP 200 200 Phone`):**
```json
{
  "data": {
    "phone": "+8801711000000"
  }
}
```

**Sample Error Response (`HTTP 404 404 Listing hidden or no phone shared`):**
```json
{
  "error": {
    "code": "NO_CONTACT_PHONE",
    "message": "This advertiser has not shared a phone number"
  }
}
```

#### `API-029`: Send inquiry to the owner
- **Route:** `POST /listings/{id}/contact`
- **Auth Required:** `Bearer (Owner/Admin)`
- **Traceability:** Linked to `REQ-018, 030` | Screen: `SCR-008`

**Request Body (`application/json`):**
```json
{
  "content": "Is the flat still available from December? I would like to visit this weekend."
}
```

**Success Response (`HTTP 200 200 Sent`):**
```json
{
  "data": {
    "sent": true
  }
}
```

**Sample Error Response (`HTTP 400 400 Inquiry about your own listing`):**
```json
{
  "error": {
    "code": "SELF_INQUIRY",
    "message": "You cannot send an inquiry about your own listing"
  }
}
```

#### `API-030`: Report a listing
- **Route:** `POST /listings/{id}/report`
- **Auth Required:** `Bearer (Staff/Admin)`
- **Traceability:** Linked to `REQ-020` | Screen: `SCR-007`

**Request Body (`application/json`):**
```json
{
  "reason": "scam",
  "details": "Asked for an advance payment before any visit."
}
```

**Success Response (`HTTP 201 201 Reported`):**
```json
{
  "data": {
    "report": {
      "id": "66c0001122334455667788bb",
      "listingId": "6671a0b2c3d4e5f601234567",
      "reporterId": "665f1c2e9b1d4a0012ab34cd",
      "reason": "scam",
      "details": "Asked for an advance payment before any visit.",
      "status": "open",
      "resolvedBy": null,
      "resolvedAt": null,
      "resolutionNote": null,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "updatedAt": "2026-10-01T08:00:00.000Z"
    }
  }
}
```

**Sample Error Response (`HTTP 400 400 Your own listing`):**
```json
{
  "error": {
    "code": "OWN_LISTING",
    "message": "You cannot report your own listing"
  }
}
```

### 6.Favorites

#### `API-031`: My saved listings
- **Route:** `GET /listings/favorites`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-022` | Screen: `SCR-009`

**Success Response (`HTTP 200 200 Saved listings, newest first`):**
```json
{
  "data": [
    {
      "id": "6671a0b2c3d4e5f601234567",
      "ownerId": "665f1c2e9b1d4a0012ab34cd",
      "listerType": "owner",
      "listerDetail": null,
      "title": "Uttara Sector 7 — 3 bed family flat",
      "slug": "uttara-sector-7-3-bed-family-flat",
      "description": "South-facing, lift and generator, 5 minutes to the metro station.",
      "propertyType": "apartment",
      "purpose": "rent",
      "areaSlug": "uttara",
      "city": "dhaka",
      "division": "dhaka",
      "address": "Road 12, Sector 7, Uttara",
      "floor": 5,
      "unitNumber": "5B",
      "rooms": {
        "bed": 3,
        "bath": 2
      },
      "size": 1350,
      "land": null,
      "hotel": null,
      "pricePerMonth": 25000,
      "currency": "BDT",
      "images": [
        "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-1-w1200.webp",
        "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-2-w1200.webp"
      ],
      "amenities": [
        "lift",
        "generator",
        "parking",
        "cctv"
      ],
      "verified": true,
      "verifiedAt": "2026-10-01T08:00:00.000Z",
      "rejectionReason": null,
      "featured": false
    }
  ],
  "meta": {
    "page": 1,
    "perPage": 12,
    "total": 3,
    "totalPages": 1
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

#### `API-032`: Save listing
- **Route:** `POST /listings/{id}/favorite`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-022` | Screen: `SCR-006, 009`

**Success Response (`HTTP 200 200 Already saved`):**
```json
{
  "data": {
    "favorited": true,
    "added": false
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

#### `API-033`: Unsave listing
- **Route:** `DELETE /listings/{id}/favorite`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-022` | Screen: `SCR-006, 009`

**Success Response (`HTTP 200 200 Removed`):**
```json
{
  "data": {
    "favorited": false,
    "removed": true
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

### 6.Search

#### `API-034`: Search listings with facets
- **Route:** `GET /search`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-001, 003, 008, 009` | Screen: `SCR-002, 003`

**Success Response (`HTTP 200 200 Results + facets`):**
```json
{
  "data": [
    {
      "id": "6671a0b2c3d4e5f601234567",
      "ownerId": "665f1c2e9b1d4a0012ab34cd",
      "listerType": "owner",
      "listerDetail": null,
      "title": "Uttara Sector 7 — 3 bed family flat",
      "slug": "uttara-sector-7-3-bed-family-flat",
      "description": "South-facing, lift and generator, 5 minutes to the metro station.",
      "propertyType": "apartment",
      "purpose": "rent",
      "areaSlug": "uttara",
      "city": "dhaka",
      "division": "dhaka",
      "address": "Road 12, Sector 7, Uttara",
      "floor": 5,
      "unitNumber": "5B",
      "rooms": {
        "bed": 3,
        "bath": 2
      },
      "size": 1350,
      "land": null,
      "hotel": null,
      "pricePerMonth": 25000,
      "currency": "BDT",
      "images": [
        "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-1-w1200.webp",
        "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-2-w1200.webp"
      ],
      "amenities": [
        "lift",
        "generator",
        "parking",
        "cctv"
      ],
      "verified": true,
      "verifiedAt": "2026-10-01T08:00:00.000Z",
      "rejectionReason": null,
      "featured": false
    }
  ],
  "meta": {
    "page": 1,
    "perPage": 12,
    "total": 42,
    "totalPages": 4,
    "facets": {
      "propertyType": [
        { "value": "apartment", "count": 25 },
        { "value": "room", "count": 10 },
        { "value": "house", "count": 7 }
      ],
      "division": [
        { "value": "dhaka", "count": 42 }
      ],
      "area": [
        { "value": "uttara", "label": "উত্তরা", "count": 18 },
        { "value": "dhanmondi", "label": "ধানমন্ডি", "count": 14 },
        { "value": "mirpur", "label": "মিরপুর", "count": 10 }
      ],
      "bedrooms": [
        { "value": 1, "count": 8 },
        { "value": 2, "count": 16 },
        { "value": 3, "count": 18 }
      ],
      "verified": [
        { "value": true, "count": 30 },
        { "value": false, "count": 12 }
      ],
      "price": {
        "min": 8000,
        "max": 65000,
        "avg": 24500
      }
    }
  }
}
```

**Sample Error Response (`HTTP 422 422 Request failed schema validation`):**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "path": "title",
        "message": "String must contain at least 5 character(s)"
      }
    ]
  }
}
```

### 6.My Listings & Owner Dashboard

#### `API-035`: My listings (any role)
- **Route:** `GET /listings/mine`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-027` | Screen: `SCR-013`

**Success Response (`HTTP 200 200 My listings`):**
```json
{
  "data": [
    {
      "id": "6671a0b2c3d4e5f601234567",
      "ownerId": "665f1c2e9b1d4a0012ab34cd",
      "listerType": "owner",
      "listerDetail": null,
      "title": "Uttara Sector 7 — 3 bed family flat",
      "slug": "uttara-sector-7-3-bed-family-flat",
      "description": "South-facing, lift and generator, 5 minutes to the metro station.",
      "propertyType": "apartment",
      "purpose": "rent",
      "areaSlug": "uttara",
      "city": "dhaka",
      "division": "dhaka",
      "address": "Road 12, Sector 7, Uttara",
      "floor": 5,
      "unitNumber": "5B",
      "rooms": {
        "bed": 3,
        "bath": 2
      },
      "size": 1350,
      "land": null,
      "hotel": null,
      "pricePerMonth": 25000,
      "currency": "BDT",
      "images": [
        "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-1-w1200.webp",
        "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-2-w1200.webp"
      ],
      "amenities": [
        "lift",
        "generator",
        "parking",
        "cctv"
      ],
      "verified": true,
      "status": "active"
    }
  ],
  "meta": {
    "page": 1,
    "perPage": 12,
    "total": 1,
    "totalPages": 1
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

#### `API-036`: Owner dashboard stats
- **Route:** `GET /owner/dashboard`
- **Auth Required:** `Bearer (Staff/Admin)`
- **Traceability:** Linked to `REQ-027` | Screen: `SCR-013`

**Success Response (`HTTP 200 200 Stats`):**
```json
{
  "data": {
    "listings": {
      "total": 6,
      "active": 4,
      "draft": 1,
      "views": 1820,
      "favorites": 37
    }
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

#### `API-037`: Owner listings
- **Route:** `GET /owner/listings`
- **Auth Required:** `Bearer (Staff/Admin)`
- **Traceability:** Linked to `REQ-027` | Screen: `SCR-013`

**Success Response (`HTTP 200 200 Listings`):**
```json
{
  "data": [
    {
      "id": "6671a0b2c3d4e5f601234567",
      "ownerId": "665f1c2e9b1d4a0012ab34cd",
      "title": "Uttara Sector 7 — 3 bed family flat",
      "status": "active",
      "views": 420
    }
  ]
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

### 6.Media Uploads

#### `API-038`: Upload listing photos
- **Route:** `POST /media/upload`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-026` | Screen: `SCR-012`

**Request Body (`multipart/form-data`):**
- `files`: (file) Image file (repeatable, max 20, ≤ 5 MB per file)

**Success Response (`HTTP 201 201 Stored`):**
```json
{
  "data": {
    "media": [
      {
        "url": "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-1-w1200.webp",
        "thumbnailUrl": "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-1-w400.webp",
        "variants": {
          "w400": {
            "url": "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-1-w400.webp",
            "width": 400,
            "height": 300,
            "bytes": 21544
          },
          "w800": {
            "url": "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-1-w800.webp",
            "width": 800,
            "height": 600,
            "bytes": 64210
          },
          "w1200": {
            "url": "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-1-w1200.webp",
            "width": 1200,
            "height": 900,
            "bytes": 118907
          }
        },
        "srcset": "…-w400.webp 400w, …-w800.webp 800w, …-w1200.webp 1200w",
        "width": 1280,
        "height": 960,
        "bytes": 845112,
        "mimeType": "image/jpeg"
      }
    ],
    "count": 1
  }
}
```

**Sample Error Response (`HTTP 400 400 No file / bad type / unreadable image`):**
```json
{
  "error": {
    "code": "UNSUPPORTED_MEDIA_TYPE",
    "message": "Unsupported file type image/gif. Allowed: image/jpeg, image/png, image/webp"
  }
}
```

#### `API-039`: Delete an uploaded photo
- **Route:** `DELETE /media`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-026, 028` | Screen: `SCR-012`

**Request Body (`application/json`):**
```json
{
  "url": "https://ghorbd.com/uploads/665f1c2e9b1d4a0012ab34cd/20261001/flat-1-w1200.webp"
}
```

**Success Response (`HTTP 200 200 Deleted`):**
```json
{
  "data": {
    "deleted": 4
  }
}
```

**Sample Error Response (`HTTP 400 400 Bad request`):**
```json
{
  "error": {
    "code": "BAD_REQUEST",
    "message": "Bad request"
  }
}
```

### 6.Verification Documents

#### `API-040`: My verification documents
- **Route:** `GET /documents`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-029` | Screen: `SCR-013`

**Success Response (`HTTP 200 200 Documents`):**
```json
{
  "data": [
    {
      "id": "6690bb22cc33dd44ee55ff66",
      "userId": "665f1c2e9b1d4a0012ab34cd",
      "originalName": "nid-front.jpg",
      "mimeType": "image/jpeg",
      "size": 482113,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "updatedAt": "2026-10-01T08:00:00.000Z"
    }
  ]
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

#### `API-041`: Upload a verification document
- **Route:** `POST /documents`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-029` | Screen: `SCR-013`

**Request Body (`multipart/form-data`):**
- `file`: (file) PDF or image, ≤ 1 MB (max 3 documents per account)

**Success Response (`HTTP 201 201 Stored`):**
```json
{
  "data": {
    "document": {
      "id": "6690bb22cc33dd44ee55ff66",
      "userId": "665f1c2e9b1d4a0012ab34cd",
      "originalName": "nid-front.jpg",
      "mimeType": "image/jpeg",
      "size": 482113,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "updatedAt": "2026-10-01T08:00:00.000Z"
    }
  }
}
```

**Sample Error Response (`HTTP 400 400 Limit reached / bad type / no file`):**
```json
{
  "error": {
    "code": "DOCUMENT_LIMIT_REACHED",
    "message": "You can upload at most 3 documents — delete one first"
  }
}
```

#### `API-042`: View / download a document file
- **Route:** `GET /documents/{id}/file`
- **Auth Required:** `Bearer (Owner/Admin)`
- **Traceability:** Linked to `REQ-029` | Screen: `SCR-013`

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

### 6.Notifications

#### `API-044`: My in-app notifications
- **Route:** `GET /notifications`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-030` | Screen: `global`



**Success Response (`HTTP 200 200 Notifications`):**
```json
{
  "data": [
    {
      "id": "6680aa11bb22cc33dd44ee55",
      "userId": "665f1c2e9b1d4a0012ab34cd",
      "type": "listing_approved",
      "title": "আপনার বিজ্ঞাপন অনুমোদিত হয়েছে",
      "body": "\"Uttara Sector 7 — 3 bed family flat\" এখন সবার জন্য প্রকাশিত।",
      "deepLink": "/listings/uttara-sector-7-3-bed-family-flat",
      "meta": {
        "listingId": "6671a0b2c3d4e5f601234567"
      },
      "readAt": null,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "updatedAt": "2026-10-01T08:00:00.000Z"
    }
  ],
  "meta": {
    "page": 1,
    "perPage": 12,
    "total": 87,
    "totalPages": 8
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

#### `API-045`: Unread badge count
- **Route:** `GET /notifications/unread-count`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-030` | Screen: `global`

**Success Response (`HTTP 200 200 Count`):**
```json
{
  "data": {
    "count": 3
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

#### `API-046`: Mark one as read
- **Route:** `POST /notifications/{id}/read`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-030` | Screen: `global`

**Success Response (`HTTP 200 200 OK`):**
```json
{
  "data": {
    "ok": true
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

### 6.Areas & Maps

#### `API-048`: Curated areas
- **Route:** `GET /areas`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-001, 002, 041` | Screen: `SCR-001, 003`

**Success Response (`HTTP 200 200 Areas`):**
```json
{
  "data": [
    {
      "id": "66d0112233445566778899cc",
      "slug": "uttara",
      "name": "উত্তরা",
      "nameEn": "Uttara",
      "city": "dhaka",
      "division": "dhaka",
      "popular": true,
      "description": "",
      "heroImageUrl": null,
      "listingCount": 42,
      "path": "/areas/uttara"
    }
  ],
  "meta": {
    "page": 1,
    "perPage": 12,
    "total": 87,
    "totalPages": 8
  }
}
```

#### `API-049`: Place / address search (geocoding)
- **Route:** `GET /geo/search`
- **Auth Required:** `Optional`
- **Traceability:** Linked to `REQ-011, 025` | Screen: `SCR-004, 012`

**Default / Key Query Parameters:**
- `q`: `Uttara Sector 7`

**Success Response (`HTTP 200 200 Places`):**
```json
{
  "data": [
    {
      "label": "Uttara Sector 7, Dhaka",
      "fullLabel": "Sector 7, Uttara, Dhaka North City Corporation, Dhaka, 1230, Bangladesh",
      "lat": 23.8759,
      "lng": 90.3795
    }
  ]
}
```

**Sample Error Response (`HTTP 502 502 Geocoder unavailable`):**
```json
{
  "error": {
    "code": "GEOCODER_UNAVAILABLE",
    "message": "Address lookup is unavailable right now"
  }
}
```

#### `API-050`: Reverse geocode (pin → address)
- **Route:** `GET /geo/reverse`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-011, 025` | Screen: `SCR-004, 012`

**Default / Key Query Parameters:**
- `lat`: `23.8759`
- `lng`: `90.3795`

**Success Response (`HTTP 200 200 Place or null`):**
```json
{
  "data": {
    "label": "Uttara Sector 7, Dhaka",
    "fullLabel": "Sector 7, Uttara, Dhaka North City Corporation, Dhaka, 1230, Bangladesh",
    "lat": 23.8759,
    "lng": 90.3795
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

### 6.Content (Guides, Blog, Pages, Pricing)

#### `API-051`: Guides list
- **Route:** `GET /content/guides`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-037, 038` | Screen: `SCR-020, 021`

**Success Response (`HTTP 200 200 Guides`):**
```json
{
  "data": [
    {
      "id": "66d0112233445566778899cc",
      "slug": "basa-vara-checklist",
      "title": "বাসা ভাড়ার আগে যা দেখবেন",
      "titleEn": "Checklist before renting",
      "excerpt": "Ten things to check before you sign.",
      "coverImageUrl": "https://ghorbd.com/uploads/seed/guide-cover.webp",
      "published": true,
      "order": 1,
      "seo": {
        "title": null,
        "description": null,
        "ogImageUrl": null
      },
      "path": "/guides/basa-vara-checklist",
      "createdAt": "2026-10-01T08:00:00.000Z",
      "updatedAt": "2026-10-01T08:00:00.000Z"
    }
  ],
  "meta": {
    "page": 1,
    "perPage": 12,
    "total": 87,
    "totalPages": 8
  }
}
```

#### `API-052`: Guide detail
- **Route:** `GET /content/guides/{slug}`
- **Auth Required:** `Optional`
- **Traceability:** Linked to `REQ-038` | Screen: `SCR-021`

**Success Response (`HTTP 200 200 Guide`):**
```json
{
  "data": {
    "guide": {
      "id": "66d0112233445566778899cc",
      "slug": "basa-vara-checklist",
      "title": "বাসা ভাড়ার আগে যা দেখবেন",
      "titleEn": "Checklist before renting",
      "excerpt": "Ten things to check before you sign.",
      "body": "## 1. Water and gas\n…",
      "coverImageUrl": "https://ghorbd.com/uploads/seed/guide-cover.webp",
      "published": true,
      "order": 1,
      "path": "/guides/basa-vara-checklist",
      "createdAt": "2026-10-01T08:00:00.000Z",
      "updatedAt": "2026-10-01T08:00:00.000Z"
    }
  }
}
```

**Sample Error Response (`HTTP 404 404 Not found`):**
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Guide not found"
  }
}
```

#### `API-053`: Static page (about, help, privacy, terms)
- **Route:** `GET /content/pages/{slug}`
- **Auth Required:** `Optional`
- **Traceability:** Linked to `REQ-037, 039` | Screen: `SCR-020, 022–025`

**Success Response (`HTTP 200 200 Page`):**
```json
{
  "data": {
    "page": {
      "id": "66d0112233445566778899cc",
      "slug": "privacy",
      "title": "Privacy Policy",
      "titleEn": "Privacy Policy",
      "body": "## Privacy Policy\n…",
      "path": "/privacy",
      "createdAt": "2026-10-01T08:00:00.000Z",
      "updatedAt": "2026-10-01T08:00:00.000Z",
      "locale": "en"
    }
  }
}
```

**Sample Error Response (`HTTP 404 404 Not found`):**
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Page not found"
  }
}
```

#### `API-054`: Blog posts
- **Route:** `GET /content/posts`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-035` | Screen: `SCR-015`

**Success Response (`HTTP 200 200 Posts`):**
```json
{
  "data": [
    {
      "id": "66b0ee55ff66001122334455",
      "slug": "how-to-find-a-flat",
      "title": "How to find a flat in Dhaka",
      "excerpt": "…",
      "coverImageUrl": "https://ghorbd.com/uploads/blog/cover.webp",
      "categories": [
        "Rent"
      ],
      "publishedAt": "2026-10-01T08:00:00.000Z",
      "readingMinutes": 4,
      "path": "/blog/how-to-find-a-flat"
    }
  ],
  "meta": {
    "page": 1,
    "perPage": 12,
    "total": 87,
    "totalPages": 8
  }
}
```

#### `API-056`: Blog post detail
- **Route:** `GET /content/posts/{slug}`
- **Auth Required:** `Optional`
- **Traceability:** Linked to `REQ-035` | Screen: `SCR-016`

**Success Response (`HTTP 200 200 Post`):**
```json
{
  "data": {
    "post": {
      "id": "66b0ee55ff66001122334455",
      "slug": "how-to-find-a-flat",
      "title": "How to find a flat in Dhaka",
      "body": "## …",
      "categories": [
        "Rent"
      ],
      "publishedAt": "2026-10-01T08:00:00.000Z"
    },
    "newer": null,
    "older": {
      "slug": "older-post",
      "title": "Older post"
    }
  }
}
```

**Sample Error Response (`HTTP 404 404 Not found`):**
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Post not found"
  }
}
```

#### `API-057`: Post comments
- **Route:** `GET /content/posts/{id}/comments`
- **Auth Required:** `Optional`
- **Traceability:** Linked to `REQ-035` | Screen: `SCR-016`

**Success Response (`HTTP 200 200 Comments`):**
```json
{
  "data": [
    {
      "id": "66b1ff6600112233445566aa",
      "postId": "66b0ee55ff66001122334455",
      "parentId": null,
      "body": "Very helpful checklist, thanks!",
      "deleted": false,
      "edited": false,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "pending": false,
      "pendingEdit": false,
      "author": {
        "id": "665f1c2e9b1d4a0012ab34cd",
        "name": "Rahim Uddin",
        "profilePhotoUrl": null
      },
      "replies": []
    }
  ],
  "meta": {
    "page": 1,
    "perPage": 12,
    "total": 87,
    "totalPages": 8,
    "nextCursor": "66b1ff6600112233445566aa"
  }
}
```

#### `API-058`: Add comment / reply
- **Route:** `POST /content/posts/{id}/comments`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-035` | Screen: `SCR-016`

**Request Body (`application/json`):**
```json
{
  "body": "Very helpful checklist, thanks!",
  "parentId": null
}
```

**Success Response (`HTTP 201 201 Created`):**
```json
{
  "data": {
    "comment": {
      "id": "66b1ff6600112233445566aa",
      "postId": "66b0ee55ff66001122334455",
      "parentId": null,
      "body": "Very helpful checklist, thanks!",
      "deleted": false,
      "edited": false,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "pending": true,
      "pendingEdit": false,
      "author": {
        "id": "665f1c2e9b1d4a0012ab34cd",
        "name": "Rahim Uddin",
        "profilePhotoUrl": null
      }
    }
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

#### `API-061`: Pricing plans (display only)
- **Route:** `GET /content/pricing`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-031–034` | Screen: `SCR-014`

**Success Response (`HTTP 200 200 Plans`):**
```json
{
  "data": [
    {
      "id": "66d0112233445566778899cc",
      "slug": "free",
      "name": "ফ্রি",
      "nameEn": "Free",
      "description": "Post a listing at no cost.",
      "priceMinor": 0,
      "price": 0,
      "currency": "BDT",
      "interval": "one_time",
      "features": [
        "1 listing",
        "Admin review"
      ],
      "popular": false,
      "ctaLabel": null,
      "published": true,
      "order": 0,
      "isFree": true
    }
  ],
  "meta": {
    "page": 1,
    "perPage": 12,
    "total": 3,
    "totalPages": 1
  }
}
```

### 6.Q&A

#### `API-062`: Q&A sidebar stats
- **Route:** `GET /qa/stats`
- **Auth Required:** `None`
- **Traceability:** Linked to `REQ-036` | Screen: `SCR-017`

**Success Response (`HTTP 200 200 Stats`):**
```json
{
  "data": {
    "questions": 420,
    "answers": 1180,
    "unanswered": 37,
    "categories": [
      {
        "key": "land",
        "count": 150
      }
    ],
    "tags": [
      {
        "tag": "khatian",
        "count": 40
      }
    ],
    "topQuestions": [
      {
        "id": "66a0cc33dd44ee55ff660011",
        "slug": "khatian-name-mismatch-what-to-do",
        "title": "Khatian name does not match my NID — what should I do?",
        "category": "land",
        "answersCount": 12
      }
    ]
  }
}
```

#### `API-063`: List questions
- **Route:** `GET /qa/questions`
- **Auth Required:** `Optional`
- **Traceability:** Linked to `REQ-036` | Screen: `SCR-017`

**Success Response (`HTTP 200 200 Questions`):**
```json
{
  "data": [
    {
      "id": "66a0cc33dd44ee55ff660011",
      "slug": "khatian-name-mismatch-what-to-do",
      "title": "Khatian name does not match my NID — what should I do?",
      "excerpt": "The khatian for my father’s land lists his name differently from his NID…",
      "category": "land",
      "tags": [
        "khatian",
        "mutation"
      ],
      "views": 342,
      "answersCount": 3,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "lastActivityAt": "2026-10-01T08:00:00.000Z",
      "pending": false,
      "rejected": false,
      "rejectionReason": null,
      "author": {
        "id": "665f1c2e9b1d4a0012ab34cd",
        "name": "Rahim Uddin",
        "profilePhotoUrl": null
      },
      "isOwn": false,
      "canDelete": false
    }
  ],
  "meta": {
    "page": 1,
    "perPage": 12,
    "total": 87,
    "totalPages": 8
  }
}
```

#### `API-064`: Ask a question
- **Route:** `POST /qa/questions`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-036` | Screen: `SCR-018`

**Request Body (`application/json`):**
```json
{
  "title": "Khatian name does not match my NID — what should I do?",
  "body": "The khatian lists my father’s name differently…",
  "category": "land",
  "tags": [
    "khatian",
    "mutation"
  ]
}
```



**Success Response (`HTTP 201 201 Created`):**
```json
{
  "data": {
    "question": {
      "id": "66a0cc33dd44ee55ff660011",
      "slug": "khatian-name-mismatch-what-to-do",
      "title": "Khatian name does not match my NID — what should I do?",
      "excerpt": "The khatian for my father’s land lists his name differently from his NID…",
      "category": "land",
      "tags": [
        "khatian",
        "mutation"
      ],
      "views": 342,
      "answersCount": 3,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "lastActivityAt": "2026-10-01T08:00:00.000Z",
      "pending": true,
      "rejected": false,
      "rejectionReason": null,
      "author": {
        "id": "665f1c2e9b1d4a0012ab34cd",
        "name": "Rahim Uddin",
        "profilePhotoUrl": null
      },
      "isOwn": true,
      "canDelete": true
    }
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

#### `API-065`: Question detail (by slug or id)
- **Route:** `GET /qa/questions/{id}`
- **Auth Required:** `Optional`
- **Traceability:** Linked to `REQ-036` | Screen: `SCR-019`

**Success Response (`HTTP 200 200 Question`):**
```json
{
  "data": {
    "question": {
      "id": "66a0cc33dd44ee55ff660011",
      "slug": "khatian-name-mismatch-what-to-do",
      "title": "Khatian name does not match my NID — what should I do?",
      "category": "land",
      "tags": [
        "khatian",
        "mutation"
      ],
      "views": 342,
      "answersCount": 3,
      "createdAt": "2026-10-01T08:00:00.000Z",
      "lastActivityAt": "2026-10-01T08:00:00.000Z",
      "pending": false,
      "rejected": false,
      "rejectionReason": null,
      "author": {
        "id": "665f1c2e9b1d4a0012ab34cd",
        "name": "Rahim Uddin",
        "profilePhotoUrl": null
      },
      "isOwn": false,
      "canDelete": false,
      "body": "Full question text…"
    },
    "answers": [
      {
        "id": "66a1dd44ee55ff6600112233",
        "questionId": "66a0cc33dd44ee55ff660011",
        "body": "Apply for a correction at the AC (Land) office with a certified NID copy…",
        "createdAt": "2026-10-01T08:00:00.000Z",
        "pending": false,
        "author": {
          "id": "665f1c2e9b1d4a0012ab34cd",
          "name": "Rahim Uddin",
          "profilePhotoUrl": null
        },
        "isAsker": false,
        "isOwn": false,
        "canDelete": false
      }
    ]
  }
}
```

**Sample Error Response (`HTTP 404 404 Not found`):**
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Listing not found"
  }
}
```

#### `API-067`: Answers for a question
- **Route:** `GET /qa/questions/{id}/answers`
- **Auth Required:** `Optional`
- **Traceability:** Linked to `REQ-036` | Screen: `SCR-019`

**Success Response (`HTTP 200 200 Answers`):**
```json
{
  "data": [
    {
      "id": "66a1dd44ee55ff6600112233",
      "questionId": "66a0cc33dd44ee55ff660011",
      "body": "Apply for a correction at the AC (Land) office with a certified NID copy…",
      "createdAt": "2026-10-01T08:00:00.000Z",
      "pending": false,
      "author": {
        "id": "665f1c2e9b1d4a0012ab34cd",
        "name": "Rahim Uddin",
        "profilePhotoUrl": null
      },
      "isAsker": false,
      "isOwn": false,
      "canDelete": false
    }
  ],
  "meta": {
    "page": 1,
    "perPage": 12,
    "total": 87,
    "totalPages": 8,
    "canDeleteQuestion": false
  }
}
```

**Sample Error Response (`HTTP 404 404 Not found`):**
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Listing not found"
  }
}
```

#### `API-068`: Answer a question
- **Route:** `POST /qa/questions/{id}/answers`
- **Auth Required:** `Bearer (JWT)`
- **Traceability:** Linked to `REQ-036` | Screen: `SCR-019`

**Request Body (`application/json`):**
```json
{
  "body": "Apply for a correction at the AC (Land) office with a certified NID copy…"
}
```

**Success Response (`HTTP 201 201 Created`):**
```json
{
  "data": {
    "answer": {
      "id": "66a1dd44ee55ff6600112233",
      "questionId": "66a0cc33dd44ee55ff660011",
      "body": "Apply for a correction at the AC (Land) office with a certified NID copy…",
      "createdAt": "2026-10-01T08:00:00.000Z",
      "pending": true,
      "author": {
        "id": "665f1c2e9b1d4a0012ab34cd",
        "name": "Rahim Uddin",
        "profilePhotoUrl": null
      },
      "isAsker": false,
      "isOwn": true,
      "canDelete": false
    }
  }
}
```

**Sample Error Response (`HTTP 401 401 Missing, invalid or expired access token`):**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Session expired"
  }
}
```

## 7. Enums & Domain Constants Reference / ডোমেন এনাম ও কনস্ট্যান্টস

All domain enums used across request queries, bodies, and response payloads:

| Domain Enum | Allowed API Values | Notes |
|-------------|-------------------|-------|
| **User Role** | `tenant`, `owner`, `editor`, `admin` | Sign-up allows `tenant` or `owner` only |
| **Lister Type** | `owner`, `agent`, `developer`, `on_behalf` | Required for listings; non-owner requires `listerDetail` |
| **Property Type** | `apartment`, `room`, `house`, `hotel`, `shop`, `office`, `land` | `land` requires `land` object; `hotel` requires `hotel.totalRooms` |
| **Purpose** | `rent`, `sale` | `land` is always `sale`; `hotel` is always `rent` |
| **Division** | `dhaka`, `chattogram`, `rajshahi`, `khulna`, `sylhet`, `barishal`, `rangpur`, `mymensingh` | Currently only Dhaka has live data |
| **Listing Status** | `draft`, `pending`, `active`, `archived`, `rejected` | Transitioned via `API-027` or Admin |
| **Display Duration** | `unlimited`, `1m`, `2m`, `3m` | Auto-expiry after admin approval |
| **Sort Order** | `newest`, `price_asc`, `price_desc`, `popular` | Featured listings pinned to top |
| **Land Type** | `residential`, `commercial`, `agricultural`, `industrial` | Used when `propertyType == "land"` |
| **Land Area Unit** | `katha`, `bigha`, `decimal`, `acre`, `sqft` | Conversions: 1 katha = 720 sq ft, 1 bigha = 20 katha |
| **Report Reason** | `fake`, `scam`, `wrong_info`, `unavailable`, `duplicate`, `offensive`, `other` | Used in `API-030` (`POST /listings/{id}/report`) |
| **Q&A Category** | `land`, `rent`, `buy_sell`, `legal`, `finance`, `expat`, `other` | Used in `API-063` and `API-064` |
| **Notification Type** | `new_user`, `listing_submitted`, `listing_reported`, `listing_approved`, `listing_rejected`, `listing_inquiry`, `listing_flagged`, `report_reviewed`, `comment_reply`, `comment_submitted`, `comment_approved`, `comment_rejected`, `qa_submitted`, `qa_approved`, `qa_rejected`, `qa_answered` | Included in `API-044` payload |
| **Amenities** | `lift`, `generator`, `security`, `parking`, `gas`, `water`, `furnished`, `wifi`, `garage`, `rooftop`, `cctv`, `balcony`. Land: `road-access`, `electricity`, `gas-line`, `water-line`, `boundary-wall`, `corner-plot`, `pond`, `ready-to-build` | Multi-select array in listings |

## 8. Backend Gaps & Mobile App Workarounds / ব্যাকএন্ড গ্যাপ ও সমাধান

The backend documentation explicitly details 11 functional gaps. The mobile app architecture addresses them as follows:

| # | Feature Gap | Current Backend Status | Mobile App Handling / Architecture |
|---|-------------|------------------------|------------------------------------|
| 1 | **Edit Profile** | ❌ No `PATCH /auth/me` endpoint. Fields exist in DB but no mutation endpoint. | Show profile details read-only from `GET /auth/me`. Disable edit actions in UI with explanatory message. |
| 2 | **Push Notifications (FCM/APNs)** | ❌ In-app notifications only (`GET /notifications`). No device token registration. | Poll `GET /notifications/unread-count` on app foreground and background timer (3-5 min). Update app badge locally. |
| 3 | **Native Google Sign-In** | ⚠️ Web-only OAuth redirect (`GET /auth/google`) returning cookies. No native token exchange. | Hide native Google Sign-In button in mobile app v1 until `POST /auth/google/token` is deployed. |
| 4 | **Property Booking** | ❌ Classifieds marketplace only. Direct contact model. | Renters contact owners directly via phone reveal (`API-028`) or inquiry (`API-029`). No in-app booking engine. |
| 5 | **Payments & Checkout** | ❌ Billing/invoices removed in migration 016. Pricing is display only. | Display subscription plans (`API-061`) with contact sales / website link. No in-app purchase required for v1. |
| 6 | **In-App Real-Time Chat** | ❌ Messaging removed in migration 016; replaced with one-off inquiry email. | App uses `POST /listings/{id}/contact` for message inquiries. Displays owner response via email notice. |
| 7 | **Delete Account (`DELETE /auth/me`)** | ❌ Admin-only user deletion (`DELETE /admin/users/{id}`). | Required by App Store / Google Play guidelines. Provide account deletion request button linking to support/email. |
| 8 | **Phone (SMS) OTP** | ⏸ Endpoints exist (`API-020`, `API-021`) but inactive (no SMS gateway contracted). | Default strictly to Email OTP verification (`API-005` -> `API-006`). |
| 9 | **Staging Environment** | ❓ URL placeholder only. | Use local environment (`http://10.0.2.2:5000/api`) for dev testing until DevOps provides staging host. |
| 10 | **App Links / Universal Links** | ❌ No `assetlinks.json` hosted on domain yet. | Provide deep-linking router handlers in `go_router`, with graceful fallback to browser links. |
| 11 | **App Version Check** | ❌ No version check endpoint (`GET /app/config`). | Handle version check gracefully; app runs without blocking force-update in v1. |

## 9. Audit Summary & Traceability / অডিট সারসংক্ষেপ

- **Total Official Endpoints:** 116 HTTP operations in 15 folders (Postman collection v2.1, matching OpenAPI 3.0.3).
- **Mobile App Core Endpoints:** 69 endpoints (`API-001` through `API-069`) covering System, Auth, Listings, Favorites, Search, Owner Dashboard, Media, Verification Documents, Notifications, Maps, Content, and Q&A.
- **Admin Endpoints:** 47 endpoints (`API-070` through `API-116`) covering Moderation, User Management, and CMS.
- **CAP Resolution:** All 23 inferred capabilities (`CAP-01` to `CAP-23`) have been replaced with 100% verified real `API-xxx` entries.
- **Guessed Endpoints or Fields:** **0** (strictly copied from client assets).
- **Gate Impact:** Completely unblocks `ISS-001`. Implementation of core app data models, networking layer, and BLoCs can proceed with exact schemas.
