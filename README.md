# GhorBD — ঘর খুঁজুন সহজেই

GhorBD mobile app: find flats, houses, rooms and land for **rent or sale**
across Bangladesh — directly from owners, with verified listings and no
middlemen.

## Features

- Browse/search listings with filters, map view and land section
- Verified listings, favorites, direct owner contact (call/message)
- Owner dashboard: post and manage listings, verification documents
- Blog, guides and Q&A; pricing plans
- Bengali-first UI (Hind Siliguri font, Bengali digits/prices), dark-first
  theme, fully responsive phone/tablet layouts

## Tech

Flutter · clean architecture per feature · flutter_bloc · go_router ·
Dio · get_it · flutter_secure_storage · SharedPreferences

## Run

```bash
flutter pub get
flutter run            # prod API by default: https://ghorbd.com/api
flutter analyze
flutter test
flutter build apk --debug
```

API environment is selected with `--dart-define` (see
`lib/core/config/env.dart` for staging/local variants).

## Release notes

- Release signing is **not** configured yet — see
  `android/key.properties.example` and the signing section in
  `android/app/build.gradle.kts`. Create your own keystore before a
  Play Store release; never commit it.
- Fonts: Hind Siliguri (SIL OFL 1.1, `assets/fonts/OFL.txt`).
