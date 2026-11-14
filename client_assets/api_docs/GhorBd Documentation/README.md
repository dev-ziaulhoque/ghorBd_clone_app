# GhorBD API: Integration Guide for the Mobile App

This folder holds the API documentation for building the GhorBD native mobile app. It was generated from the backend source on 2026-10-30. Every route registered in the Express app has a matching entry here, and that was checked automatically.

| File | What it is | How to use it |
| --- | --- | --- |
| `GhorBD.postman_collection.json` | **116 requests** in 15 folders, with headers, bodies, example success and error responses, and token-saving test scripts | Postman → Import |
| `GhorBD.local.postman_environment.json` | `baseUrl = http://localhost:5000/api` | Postman → Import → select environment |
| `GhorBD.staging.postman_environment.json` | `baseUrl` placeholder. **DevOps must fill in the staging host** | same |
| `GhorBD.production.postman_environment.json` | `baseUrl = https://ghorbd.com/api` | same |
| `ghorbd-openapi.json` | OpenAPI 3.0.3 spec: every endpoint, schema, enum and validation rule | Open in [editor.swagger.io](https://editor.swagger.io), Redoc, Stoplight, or a code generator (`openapi-generator` for Kotlin/Swift/Dart) |
| `ghorbd-api-reference.html` | Standalone, searchable HTML reference: guide plus every endpoint with examples | Open it in any browser. Works offline (fonts fall back to system fonts). |
| `tools/` | Generator and route-coverage check | See [Keeping the docs current](#14-keeping-the-docs-current) |

---

## 1. Environments and base URLs

| Environment | Base URL | Notes |
| --- | --- | --- |
| Production | `https://ghorbd.com/api` | Reached through the web server's proxy. Media is served from `https://ghorbd.com/uploads/...` |
| Staging | **TBD** | No staging deployment is defined in the repo. DevOps needs to provide the host. |
| Local (API direct) | `http://localhost:5000/api` | `npm run dev` in `backend/`. Needs MongoDB (see `backend/README.md`). |
| Android emulator → local | `http://10.0.2.2:5000/api` | The emulator's alias for the host machine |
| Physical device → local | `http://<your-LAN-IP>:5000/api` | In development the API listens on `0.0.0.0`. Android needs a cleartext exception for HTTP; iOS needs an ATS exception. |

Configuration that matters to the app:

| Setting | Value | Effect on the app |
| --- | --- | --- |
| Access token lifetime | 15 minutes | Refresh proactively, or when you get a 401 |
| Refresh token lifetime | 30 days | The user must log in again after 30 days of inactivity |
| Email verification at signup | **On** in production | Registration returns no tokens until the email OTP is verified |
| Phone (SMS) OTP | **Off** | `POST /auth/verify` and `/auth/resend-otp` exist but are inactive |
| Max JSON body | 1 MB | |
| Max image upload | 5 MB per file, 20 files per request | |
| Max verification document | 1 MB, 3 per user | |
| CORS | Browser-only check | Native HTTP clients send no `Origin` header and are not affected |

---

## 2. Headers

| Header | When | Value |
| --- | --- | --- |
| `Authorization` | Every endpoint marked **Bearer** or **optional** | `Bearer <accessToken>` |
| `Content-Type` | JSON bodies | `application/json` |
| `Content-Type` | Uploads | `multipart/form-data; boundary=…`. Let your HTTP client set it; don't hard-code it. |
| `Accept` | Recommended | `application/json` |

There are no custom headers and no API key. The server also sets httpOnly cookies (`token`, `refreshToken`) for the website. **Mobile clients should ignore cookies** and use the tokens from the response body. Disable your HTTP client's cookie jar if you can, so cookie auth and header auth don't mix.

Response headers to read:
- `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset` (IETF draft-6 headers) appear on every response.

---

## 3. Response contract

Every endpoint returns one of three shapes:

```jsonc
// Single item
{ "data": { "listing": { … } } }

// List
{ "data": [ … ], "meta": { "page": 1, "perPage": 12, "total": 87, "totalPages": 8 } }

// Error
{ "error": { "code": "VALIDATION_ERROR", "message": "Validation failed",
             "details": [ { "path": "title", "message": "String must contain at least 5 character(s)" } ] } }
```

Rules:
- **Branch on `error.code`, never on `message`.** Messages may change or be localised.
- ids are 24-character hex strings (`"665f1c2e9b1d4a0012ab34cd"`). Responses use `id`, never `_id`.
- Dates are ISO-8601 UTC strings. Display them in `Asia/Dhaka`.
- Money is **whole taka** (`pricePerMonth: 25000`), except fields ending in `Minor`, which are poisha (1/100 taka).
- Phone numbers are stored and returned as `+8801XXXXXXXXX`. Input may be `01XXXXXXXXX`, `+8801…` or `8801…`.
- **A resource you may not see returns 404, not 403.** This applies to another user's listing, a hidden listing, or someone else's file. Don't show a "permission denied" screen for it.
- `204 No Content` (logout) has an empty body.

### HTTP status codes

| Status | Meaning | App behaviour |
| --- | --- | --- |
| 200 / 201 | OK / created | |
| 204 | No content | |
| 400 | Bad request, or a business rule (see `code`) | Show the message |
| 401 | Not signed in, or the token is bad or expired | `TOKEN_EXPIRED`: refresh and retry once. Anything else: go to login. |
| 403 | Signed in, but the role is not allowed, or `EMAIL_NOT_VERIFIED` | |
| 404 | Not found, or not visible to you | |
| 409 | Conflict with the current state (duplicate, invalid transition) | Read `details` |
| 413 | File too large (`FILE_TOO_LARGE`) | |
| 422 | Validation failed. `details[]` has `{ path, message }` for each field. | Highlight the fields |
| 429 | Rate limited | Back off until `RateLimit-Reset` |
| 500 / 502 / 503 | Server, geocoder or database problem | Retry with backoff |

### Error codes to handle

| Code | Status | Where |
| --- | --- | --- |
| `VALIDATION_ERROR` | 422 | Any endpoint with a body or query |
| `UNAUTHORIZED`, `TOKEN_INVALID`, `TOKEN_EXPIRED` | 401 | Any authenticated endpoint |
| `FORBIDDEN` | 403 | Role-restricted endpoints |
| `NOT_FOUND`, `INVALID_ID` | 404 / 400 | |
| `TOO_MANY_REQUESTS` | 429 | |
| `ACCOUNT_EXISTS` | 409 | register (email or phone already used) |
| `INVALID_CREDENTIALS` | 401 | login |
| `EMAIL_NOT_VERIFIED` | 403 | login. A new code was just emailed, so go to the OTP screen. |
| `EMAIL_OTP_INVALID`, `EMAIL_OTP_EXPIRED` | 400 | verify-email-otp |
| `EMAIL_OTP_ATTEMPTS` | 429 | verify-email-otp after 5 wrong codes. Resend a code. |
| `EMAIL_TOKEN_INVALID`, `EMAIL_TOKEN_EXPIRED` | 400 | verify-email (link) |
| `RESET_TOKEN_INVALID`, `RESET_TOKEN_EXPIRED` | 400 | reset |
| `REFRESH_MISSING`, `REFRESH_TOKEN_INVALID`, `ACCOUNT_MISSING`, `PASSWORD_CHANGED` | 401 | refresh. Clear tokens and go to login. |
| `CURRENT_PASSWORD_INVALID` | 401 | change password |
| `GOOGLE_NOT_LINKED`, `PASSWORD_REQUIRED_TO_UNLINK` | 400 | google/unlink |
| `OTP_DISABLED` | 400 | resend-otp (phone OTP is off) |
| `DUPLICATE_LISTING` | 409 | create listing. `details.existing` names the twin. Resend with `allowDuplicate: true`. |
| `INVALID_TRANSITION` | 409 | transition. `details: { from, action, allowed[] }` |
| `UNKNOWN_ACTION` | 400 | transition |
| `NO_CONTACT_PHONE` | 404 | reveal phone |
| `SELF_INQUIRY` | 400 | contact your own listing |
| `OWN_LISTING`, `ALREADY_REPORTED` | 400 / 409 | report |
| `NO_FILE`, `UNSUPPORTED_MEDIA_TYPE`, `IMAGE_PROCESSING_FAILED`, `FILE_TOO_LARGE` | 400 / 413 | uploads |
| `DOCUMENT_LIMIT_REACHED` | 400 | documents (max 3) |
| `NOT_AN_UPLOAD` | 400 | delete media |
| `GEOCODER_UNAVAILABLE` | 502 | geo |
| `COMMENT_NOT_FOUND`, `COMMENT_EMPTY` | 404 / 400 | comments |
| `QUESTION_NOT_FOUND`, `ANSWER_NOT_FOUND`, `QUESTION_TOO_SHORT`, `ANSWER_EMPTY` | 404 / 400 | Q&A |
| `LAST_ADMIN`, `SELF_MANAGEMENT`, `USER_HAS_RECORDS`, `EMAIL_TAKEN` | 400 / 409 | admin user management |
| `AREA_IN_USE` | 409 | admin delete area |
| `DUPLICATE_KEY` | 409 | Any unique constraint (for example, a content slug) |

---

## 4. Authentication and authorization

Stateless JWT. Store both tokens in secure storage: iOS Keychain, Android EncryptedSharedPreferences or Keystore, or `flutter_secure_storage`.

### 4.1 Registration with email OTP (the default)

```
POST /auth/register            { name, email, phone, password, role: "tenant"|"owner" }
  → 201 { data: { user, verification: { email, emailOtpRequired: true, required: false } } }
       (no tokens: a 6-digit code + link are emailed; the code is valid 24 h)

POST /auth/verify-email-otp    { email, otp: "482913" }
  → 200 { data: { user, accessToken, refreshToken, expiresIn: "15m", emailVerified: true } }

POST /auth/resend-email-otp    { email }      // 60 s cooldown, always { sent: true }
```

If `verification.emailOtpRequired` is `false`, the server has email verification turned off. The register response then already includes `accessToken` and `refreshToken`.

Outside production the register response also includes `devEmailOtp`, so QA can finish signup without a mailbox.

Validation rules:
- `name`: 2–120 characters
- `email`: valid address, stored in lower case
- `phone`: BD mobile `01[3-9]XXXXXXXX`, with an optional `+88` prefix
- `password`: 8–128 characters, at least one letter and one digit
- `role`: `tenant` or `owner` only. `admin` and `editor` are assigned by an admin.
- `listerType` / `listerDetail`: optional, owners only

### 4.2 Login

```
POST /auth/login  { email, password }
  → 200 { data: { user, accessToken, refreshToken, expiresIn } }
  → 401 INVALID_CREDENTIALS
  → 403 EMAIL_NOT_VERIFIED   ← a fresh code was emailed; show the OTP screen
```

### 4.3 Token refresh

```
POST /auth/refresh  { refreshToken }
  → 200 { data: { user, accessToken, refreshToken, expiresIn } }   // store BOTH new tokens
  → 401 PASSWORD_CHANGED | REFRESH_TOKEN_INVALID | ACCOUNT_MISSING  // force logout
```

Recommended client strategy:
1. Attach `Authorization: Bearer <accessToken>` to every request.
2. On `401` with `code = TOKEN_EXPIRED`, call `/auth/refresh` **once**. Use a mutex so parallel requests share a single refresh. Then replay the original request.
3. If refresh fails, clear storage and go to login.
4. Optional: refresh proactively at about 13 minutes, or when the app returns to the foreground.

Refresh also re-reads the user, so a role change applies at the next refresh. Changing or resetting the password **revokes every refresh token on every device**.

### 4.4 Other auth endpoints

| Endpoint | Purpose |
| --- | --- |
| `GET /auth/me` | Current user. Returns `{ user: null }` with **200** when signed out, so check for null. Includes `googleLinked` and `hasPassword`. |
| `POST /auth/logout` | 204. JWTs are stateless, so **also delete the stored tokens on the device**. |
| `POST /auth/forgot` `{ email }` | Emails a reset link. The response is always `{ sent: true }`. |
| `POST /auth/reset` `{ token, password }` | Sets a new password and signs out every session |
| `POST /auth/password` `{ currentPassword?, newPassword }` | Change password. Returns **new tokens**, so replace the stored ones. |
| `POST /auth/resend-email` | Resend the verification email (signed-in user) |
| `POST /auth/verify-email` `{ token }` | Verify using the link token (for deep links) |
| `GET /auth/providers` | `{ password: true, google: bool }` |

**Email links (deep linking).** The emails link to the website:
- Verification: `https://ghorbd.com/verify-email?token=…`
- Password reset: `https://ghorbd.com/reset-password?token=…`

To open these in the app, set up Android App Links and iOS Universal Links for those paths, read `token` from the URL, and call `POST /auth/verify-email` or show a new-password form that calls `POST /auth/reset`. Hosting `assetlinks.json` and `apple-app-site-association` on ghorbd.com is a web and DevOps task. Until that exists, the links open in the browser and work there.

### 4.5 Roles and permissions

| Role | Who | Can do |
| --- | --- | --- |
| *(anonymous)* | Visitor | Browse and search listings, listing detail, areas, guides, blog, pages, pricing, read Q&A, place search |
| `tenant` | Default signup | Everything above, plus **post and manage their own listings**, favourites, reveal phone, send inquiries, report, notifications, documents, comment, ask and answer |
| `owner` | Signup with `role: "owner"` | Everything a tenant can, plus `/owner/dashboard` and `/owner/listings` |
| `editor` | Staff, set by an admin | Everything, plus `/admin/*` moderation and content. **Not** user management. |
| `admin` | Staff | Everything, including `/admin/users*` |

Authorization on your own data is by **ownership**: a listing, document, comment or question can be edited or deleted only by its author or by staff. Everyone else gets 404.

---

## 5. Pagination, sorting, filtering

**Page-based** (most lists): `?page=1&perPage=12`. `perPage` is 1–60 (default 12). Read `meta.totalPages` for infinite scroll; stop when `page >= totalPages`.

**Cursor-based** (blog comments only): `?limit=10&before=<meta.nextCursor>`. `nextCursor` is `null` at the end.

**Not paginated** (the whole list comes back): `/areas`, `/content/pricing`, `/content/posts/categories`, `/documents`, `/qa/questions/{id}/answers`.

### Listing filters (`GET /listings` and `GET /search`)

| Param | Type | Notes |
| --- | --- | --- |
| `q` | string | **/search only.** Full text, Bangla or English. Relevance-sorted unless `sort` is given. |
| `type` | `apartment` `room` `house` `hotel` `shop` `office` `land` | |
| `purpose` | `rent` `sale` | Omit for both |
| `division` | `dhaka` `chattogram` `rajshahi` `khulna` `sylhet` `barishal` `rangpur` `mymensingh` | |
| `city`, `area` | slug | For example `city=dhaka&area=uttara`. Get area slugs from `GET /areas`. |
| `minPrice`, `maxPrice` | int (taka) | `minPrice ≤ maxPrice`, otherwise 422 |
| `rooms`, `baths` | int | Minimum count |
| `amenities` | csv or repeated | `amenities=lift,gas`. **All** must match. |
| `verified` | bool | `true`, `1` or `yes` |
| `landType`, `minLandArea`, `maxLandArea` | | Land only. Area is in **katha**. |
| `minStarRating` | 1–5 | Hotel only |
| `lat`, `lng`, `radiusKm` | number | Near-me search. Send `lat` and `lng` together. Radius 0.5–25 km, default 3. |
| `sort` | `newest` `price_asc` `price_desc` `popular` | Featured listings always come first |
| `facets` | bool | **/search only**, default true. `meta.facets` holds the counts for the filter sheet. |

The facets in `meta.facets` are `propertyType[]`, `division[]`, `area[]` (with Bangla `label`), `city[]`, `bedrooms[]`, `landType[]`, `verified[]` and `price{min,max,avg}`. Each facet ignores its own filter, so the other options stay selectable.

---

## 6. File uploads

### Listing photos: `POST /media/upload`

```
POST /api/media/upload
Authorization: Bearer …
Content-Type: multipart/form-data

files=@photo1.jpg
files=@photo2.jpg          (repeat the "files" field, max 20)
```

- JPEG, PNG or WebP. **5 MB per file.** 100 uploads per hour.
- The server fixes EXIF rotation, adds the GhorBD watermark and creates WebP renditions at 400, 800, 1200 and 1600 px.
- Response `201`:
  ```json
  { "data": { "count": 1, "media": [ {
      "url": "https://ghorbd.com/uploads/<userId>/20261001/flat-1-w1200.webp",
      "thumbnailUrl": "https://ghorbd.com/uploads/<userId>/20261001/flat-1-w400.webp",
      "variants": { "w400": {"url":"…","width":400,"height":300,"bytes":21544}, "w800": {…}, "w1200": {…} },
      "srcset": "…", "width": 1280, "height": 960, "bytes": 845112, "mimeType": "image/jpeg" } ] } }
  ```
- Put each `url` into `images[]` when you create or update the listing. Use the `w400` variant for list thumbnails.
- **Compress on the device first** (for example, longest side ≤ 2000 px at 80% JPEG). This keeps uploads well under 5 MB on mobile data.
- Uploads that no listing references are deleted by a nightly job after 24 hours.
- To remove a photo: `DELETE /media` with `{ "url": "<any url of that photo>" }`.

Suggested post-listing flow: pick photos → upload (show progress) → keep the URLs → `POST /listings` with `images: [url, …]`.

### Verification documents: `POST /documents`

- Field **`file`** (single). PDF, JPEG, PNG or WebP. **≤ 1 MB.** At most 3 per user.
- These are private files. View one with `GET /documents/{id}/file` and the Bearer header. Download it to a temp file, then open it in a PDF or image viewer; a plain WebView without the header gets a 404.

---

## 7. Feature to endpoint map

| App screen / feature | Endpoints |
| --- | --- |
| Splash / session restore | `GET /auth/me` (or `POST /auth/refresh` when only a refresh token is stored) |
| Sign up | `POST /auth/register` → `POST /auth/verify-email-otp` (`/auth/resend-email-otp`) |
| Login | `POST /auth/login` |
| Forgot / reset password | `POST /auth/forgot` → (link) → `POST /auth/reset` |
| Home | `GET /listings?sort=newest&perPage=10`, `GET /areas?popular=true`, `GET /content/guides` |
| Search and filters | `GET /search?q=…&…` (use `meta.facets` for the filter sheet), `GET /areas` for area pickers |
| Map / near me | `GET /listings?lat=…&lng=…&radiusKm=3`, place box: `GET /geo/search?q=…` |
| Listing detail | `GET /listings/{id or slug}` |
| Call / show number | `GET /listings/{id}/contact` (only if `listing.hasContactPhone`) |
| Send inquiry | `POST /listings/{id}/contact` |
| Report listing | `POST /listings/{id}/report` |
| Favourites | `POST` / `DELETE /listings/{id}/favorite`, `GET /listings/favorites` |
| Post an ad | `GET /areas`, `GET /geo/search`, `GET /geo/reverse`, `POST /media/upload`, `POST /listings` |
| My listings | `GET /listings/mine?status=…`, `PUT /listings/{id}`, `POST /listings/{id}/transition`, `DELETE /listings/{id}` |
| Owner dashboard | `GET /owner/dashboard` (owner and admin roles) |
| Notifications and badge | `GET /notifications/unread-count`, `GET /notifications`, `POST /notifications/{id}/read`, `POST /notifications/read-all` |
| Profile / account | `GET /auth/me`, `POST /auth/password`, `POST /auth/resend-email`, `POST /auth/google/unlink`. **No profile edit yet**, see §10. |
| Verification documents | `GET` / `POST /documents`, `GET /documents/{id}/file`, `DELETE /documents/{id}` |
| Q&A | `GET /qa/stats`, `GET /qa/questions`, `GET /qa/questions/{slug}`, `POST /qa/questions`, `POST /qa/questions/{id}/answers`, deletes |
| Blog / guides | `GET /content/posts`, `/content/posts/{slug}`, `/content/posts/{id}/comments`, `/content/guides`, `/content/guides/{slug}` |
| Privacy / Terms / About / Help | `GET /content/pages/{privacy|terms|about|help}?locale=bn-BD|en` |
| Pricing (display) | `GET /content/pricing` |
| Admin (if the app includes it) | `/admin/*`, see the Postman folders "Admin — …" |

### Listing lifecycle

```
            create(status: pending, the default)
                 │
 create(draft) ─►draft ──submit──► pending ──admin verify──► active
                   ▲                  │  └──admin reject──► rejected ──submit──► pending
                   └────withdraw──────┘
   draft | pending | active ──archive──► archived ──submit──► pending
```

Owners **cannot** publish directly; only an admin moves a listing to `active`. The transition response includes `available[]`, the actions that are valid now. Use it to decide which buttons to show.

Listing rules worth knowing:
- `propertyType: "land"` requires a `land` object (`landType`, `areaValue`, `areaUnit`) and is always `purpose: "sale"`. `size` is derived from it.
- `propertyType: "hotel"` requires `hotel.totalRooms` and is always `purpose: "rent"`. `pricePerMonth` holds the per-night price.
- `listerType` other than `owner` (`agent`, `developer`, `on_behalf`) requires `listerDetail`.
- `pricePerMonth` is the monthly rent for rentals, the total price for sales, and the per-night price for hotels.
- The contact phone is **never** part of listing payloads. Use `GET /listings/{id}/contact`.
- `displayDuration` (`unlimited`, `1m`, `2m`, `3m`) controls auto-expiry after approval. Editing an expired listing renews it.
- The share link is `https://ghorbd.com` + `listing.path`.

---

## 8. Rate limits

| Scope | Limit |
| --- | --- |
| Whole `/api` | 600 requests / 15 min **per IP** |
| Auth credential endpoints | 20 **failed** attempts / 15 min per IP |
| Reveal phone, inquiries, reports | 30 / hour |
| Uploads (media + documents) | 100 / hour |
| Comments, Q&A posts | 20 / 10 min per account |
| Geo search | 300 / 15 min signed in, 60 / 15 min anonymous. **Debounce typing by 400 ms or more.** |

> ⚠️ **Mobile carrier NAT:** many users on one carrier IP share the per-IP budgets. If this shows up in production, the backend team should consider keying the global limiter by user id for authenticated requests.

---

## 9. Third-party services

| Service | Used for | Mobile app needs to… |
| --- | --- | --- |
| **OpenStreetMap Nominatim** (through the backend) | Place search and reverse geocoding (`/geo/*`) | Nothing. Always call the backend, never Nominatim directly (their usage policy forbids heavy client use). |
| **OpenStreetMap tiles** | Map display on the website (Leaflet) | Pick a map SDK. Options: MapLibre / osmdroid with OSM tiles (show the "© OpenStreetMap contributors" attribution), or Google Maps / Apple MapKit (needs our own API keys; coordinates are plain WGS-84 `lat`/`lng`). **Product decision needed.** |
| **Google OAuth 2.0** | "Continue with Google" on the website | **Not usable natively yet**, see §10 |
| **Email** (SMTP / SendGrid / Mailgun, set on the server) | Verification codes, password reset, inquiry and moderation emails | Nothing |
| **SMS gateway** (Twilio or a local BD HTTP gateway) | Phone OTP, **currently disabled** | Nothing for now |
| MongoDB, Redis | Backend storage and rate-limit store | Nothing |

**Not used anywhere in GhorBD today:** Firebase (Auth, FCM, Analytics, Crashlytics), Socket.IO or WebSockets, payment gateways (SSLCommerz, bKash and so on), booking engines, chat. If the mobile app needs any of these, the backend must build them first (§10).

---

## 10. Gaps: features the mobile app may expect that the API does not have yet

These items came up in the mobile team's requirements but **do not exist in the backend**. Each one needs a product decision and backend work before the app can rely on it.

| # | Feature | Status | What's needed |
| --- | --- | --- | --- |
| 1 | **Edit profile** (name, photo, phone, notification preferences, language) | ❌ No endpoint. `profilePhotoUrl` and `preferences` exist on the user record, but nothing writes them. | `PATCH /auth/me` (or `/users/me`) plus photo upload |
| 2 | **Push notifications** | ❌ No FCM or APNs. Notifications are in-app only. | Device-token registration endpoint (`POST /devices`), an FCM sender in the notification queue, and a Firebase project |
| 3 | **Native Google Sign-In** | ⚠️ Only the web redirect flow exists, and it returns cookies, not tokens | `POST /auth/google/token` that accepts a Google ID token from the native SDK and returns `{ user, accessToken, refreshToken }` |
| 4 | **Booking** | ❌ Not a product feature. GhorBD is a classifieds board: renters contact owners directly. | Product decision |
| 5 | **Payments** | ❌ Billing and invoices were removed (migration 016). `/content/pricing` is display only. | Product decision, then gateway integration (bKash / SSLCommerz) |
| 6 | **In-app chat / real-time** | ❌ Messaging was removed (migration 016) and replaced by the one-off inquiry email. No Socket.IO. | Product decision |
| 7 | **Delete my account** (required by the App Store and Google Play) | ❌ Only an admin can delete a user | `DELETE /auth/me` with password confirmation |
| 8 | **Phone OTP** | ⏸ Built but switched off until an SMS gateway is live | Enable when the SMS gateway is contracted |
| 9 | **Staging environment** | ❓ Not defined in the repo | DevOps to provide the URL and test accounts |
| 10 | **App Links / Universal Links** for email links | ❌ | Host `/.well-known/assetlinks.json` and `apple-app-site-association` on ghorbd.com |
| 11 | **App version check / force update** | ❌ | Optional `GET /app/config` endpoint |

Until 1, 2 and 7 exist, the app can show profile details read-only (from `/auth/me`), poll `GET /notifications/unread-count` on app foreground and on a timer, and link to account deletion on the web or through support.

---

## 11. Enums reference

| Enum | Values |
| --- | --- |
| User role | `tenant` `owner` `editor` `admin` |
| Lister type | `owner` `agent` `developer` `on_behalf` |
| Property type | `apartment` `room` `house` `hotel` `shop` `office` `land` |
| Purpose | `rent` `sale` |
| Division | `dhaka` `chattogram` `rajshahi` `khulna` `sylhet` `barishal` `rangpur` `mymensingh` |
| Listing status | `draft` `pending` `active` `archived` `rejected` |
| Display duration | `unlimited` `1m` `2m` `3m` |
| Sort | `newest` `price_asc` `price_desc` `popular` |
| Land type | `residential` `commercial` `agricultural` `industrial` |
| Land area unit | `katha` (720 ft²) `bigha` (14,400 ft²) `decimal` (435.6 ft²) `acre` (43,560 ft²) `sqft` |
| Land facing | `north` `south` `east` `west` `north_east` `north_west` `south_east` `south_west` |
| Report reason | `fake` `scam` `wrong_info` `unavailable` `duplicate` `offensive` `other` |
| Q&A category | `land` `rent` `buy_sell` `legal` `finance` `expat` `other` |
| Q&A sort | `newest` `active` `popular` `most_answered` `unanswered` |
| Locale | `bn-BD` `en` |
| Notification type | `new_user` `listing_submitted` `listing_reported` `listing_approved` `listing_rejected` `listing_inquiry` `listing_flagged` `report_reviewed` `comment_reply` `comment_submitted` `comment_approved` `comment_rejected` `qa_submitted` `qa_approved` `qa_rejected` `qa_answered` |
| Amenities (UI list, free-form on the API) | `lift` `generator` `security` `parking` `gas` `water` `furnished` `wifi` `garage` `rooftop` `cctv` `balcony`. Land: `road-access` `electricity` `gas-line` `water-line` `boundary-wall` `corner-plot` `pond` `ready-to-build` |

Bangla display labels for these values live in the web app (`frontend/src/i18n/messages/`). Reuse those translations so wording stays consistent.

Notifications carry `deepLink` (a **web path** such as `/listings/<slug>`, `/dashboard` or `/admin/moderation`) and `meta` (for example `{ listingId }`). Map these to app routes on the client.

---

## 12. Credentials and test accounts

- This documentation contains **no secrets**. Production JWT secrets, SMTP passwords and Google OAuth credentials stay on the server.
- Test accounts: ask the backend lead. Locally, `npm run seed` creates demo users, and `npm run user:create -- --email=… --password=… --role=tenant|owner|admin` creates or updates a single account. Never share production passwords in chat or in Postman exports.
- Share credentials through the team password manager, or a Postman **team workspace** where `accessToken` and `refreshToken` are stored as *secret* variables (as in these environment files). Don't commit filled-in environment files.
- Google Sign-In client IDs for Android and iOS (once item 3 in §10 is built) need to be created in the GhorBD Google Cloud project by its owner.

---

## 13. Postman tips

1. Import the collection and all three environments, then pick **GhorBD — Local** (or Production for read-only checks).
2. Run **Auth → Log in**. The tokens are saved automatically.
3. **Listings → Create listing** saves `listingId`. Later requests use `{{listingId}}`. The same goes for `documentId` and `questionId`.
4. Every request has a saved **example response** (success and the usual errors). Use the *Examples* dropdown, or spin up a Postman **mock server** from the collection to build UI before the API is reachable.
5. Optional query parameters are included but **disabled**. Tick them to use them.

---

## 14. Keeping the docs current

The spec and the collection are generated from one table, so they always agree:

```bash
cd backend
node docs/api/tools/build-docs.mjs docs/api          # regenerate all files
node docs/api/tools/check-routes.mjs docs/api/ghorbd-openapi.json   # fails if any route is undocumented
```

When you add or change a route, update `tools/build-docs.mjs` in the same PR.
