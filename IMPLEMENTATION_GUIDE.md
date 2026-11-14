# IMPLEMENTATION GUIDE (instructions for the AI assistant)

Read this file FIRST, every session. Follow it strictly.

## 0. Mission
Build the **Flutter mobile app (app side only)** from the client's materials.
Do not build backend. Do not guess anything the materials do not state.

**Current project: GhorBD** (Bangladesh property marketplace: rent, sale, land). Reference website: https://ghorbd.com/ (Bangla UI). Backend arrives as an API collection in `client_assets/api_docs/`. Full notes: `PROJECT_NOTES.md`. Current gate decision: see `FINAL_AUDIT_REPORT.md` (section 7).

## 1. Source of truth
- Client materials: `client_assets/` (documents, designs, screenshots, icons, fonts, api_docs, other)
- Reference website: https://ghorbd.com/ (for behavior and content only; some pages block automated reading, do not work around that, ask for screenshots)
- Running notes: `PROJECT_NOTES.md` (update after every phase)
- Audit files: `project_management/*.md`
- Priority when conflicting: API collection (for data) > design files (for UI) > documents (for behavior). Log every conflict in `ASSET_ISSUES.md`.

## 2. Working rules
1. Never skip phases. Order: Phase 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> then code.
2. Never write feature code while a Blocker issue affects that feature.
3. Never invent endpoints, fields, colors, text or flows. Unclear -> create ISS entry and ask.
4. IDs (AST, REQ, SCR, API, ISS, UJ) never change once assigned.
5. After each feature, update the traceability matrix in `FINAL_AUDIT_REPORT.md`.
6. Keep replies short. Show what changed and what is next.
7. **Language:** all notes and audit files are written in English + Bangla (বাংলা). App UI is Bangla by default with English as second language; every user-facing string goes through ARB files (`app_bn.arb`, `app_en.arb`), never hardcoded.
8. Numbers: show Bangla digits in the Bangla UI and BDT with lakh/crore grouping (e.g. ৭২,০০,০০০ ৳).
9. The audit files list capabilities (CAP-xx) from the website. Never implement from CAP rows; implement only from real `API-xxx` entries copied from the collection.
10. When new material arrives, re-run the affected phases and add a line to the change log in `PROJECT_NOTES.md`.

## 3. Phase instructions

| Phase | Action | Output file |
|-------|--------|-------------|
| 1 | Scan all of `client_assets/`, list every file | ASSET_INVENTORY.md |
| 2 | Extract requirements and use case journeys from documents | REQUIREMENT_AUDIT.md |
| 3 | Extract screens, theme, missing states from designs | DESIGN_AUDIT.md |
| 4 | Extract endpoints and auth flow from api_docs | API_AUDIT.md |
| 5 | Collect every gap and question | ASSET_ISSUES.md |
| 6 | Summary, order, Go/No-go | FINAL_AUDIT_REPORT.md |
| 7 | Implement | `lib/`, `test/` |

After Phase 6, STOP and wait for the developer's approval before Phase 7.

## 4. Tech stack
- Flutter, Dart (null safety)
- **Dio** for networking
- **flutter_bloc** + **equatable** for state management (no GetX, no setState for business logic)
- **get_it** for dependency injection
- **go_router** for navigation (with auth guard)
- **flutter_secure_storage** for tokens
- **local_auth** (biometric), **flutter_jailbreak_detection** (root check), **connectivity_plus**
- **freezed + json_serializable** for models, **fpdart or dartz** for Either
- **bloc_test + mocktail** for tests

Check each package's latest stable version before adding.

## 5. Architecture (feature-first clean architecture)

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/app_router.dart
│   └── di/injection.dart
├── core/
│   ├── config/env.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── api_endpoints.dart
│   │   ├── api_result.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       ├── logging_interceptor.dart
│   │       ├── retry_interceptor.dart
│   │       └── error_interceptor.dart
│   ├── error/ (failures.dart, exceptions.dart)
│   ├── security/
│   │   ├── secure_storage.dart
│   │   ├── certificate_pinning.dart
│   │   ├── device_integrity.dart
│   │   ├── biometric_service.dart
│   │   ├── session_manager.dart
│   │   └── input_sanitizer.dart
│   └── utils/
├── shared/
│   ├── theme/ (colors, typography, theme)
│   └── widgets/
└── features/
    └── <feature>/
        ├── data/ (datasources, models, repositories_impl)
        ├── domain/ (entities, repositories, usecases)
        └── presentation/ (bloc, pages, widgets)
```

Rules:
- Presentation never calls Dio directly. Flow: Page -> Bloc -> UseCase -> Repository -> DataSource -> Dio.
- Domain layer has no Flutter or Dio imports.
- Every Bloc has Event, State (Equatable), loading / success / failure states.
- Every API call returns `Either<Failure, T>`.

## 6. Security requirements (app side)

| Area | Requirement |
|------|-------------|
| Token storage | flutter_secure_storage only. Never SharedPreferences or plain files |
| Token refresh | Single-flight refresh: on 401, one refresh call, queue other requests, retry. If refresh fails -> logout |
| SSL pinning | Enable in production build (pin config via env) |
| Root / jailbreak | Detect at startup, block or warn on sensitive features (follow client requirement) |
| Screen protection | Block screenshots / recording on sensitive screens, blur in app switcher |
| Biometric lock | Optional app lock, only if required |
| Session timeout | Idle timeout -> clear tokens -> go to login |
| Log redaction | Never log tokens, passwords, OTPs, PII. Logging interceptor only in debug |
| Secrets | No hardcoded keys. Use `--dart-define` / env config |
| Input | Validate and sanitize all user input client-side (server still authoritative) |
| Error messages | Show user-friendly messages. Never show raw server or stack errors |
| Release build | `flutter build --obfuscate --split-debug-info=...` |
| Cache | Do not store sensitive data in cache or local DB unencrypted |
| Deep links | Validate all incoming link parameters |
| Clipboard | Disable copy on sensitive fields |

## 7. Implementation order (Phase 7)

1. **Core:** env config, Dio client, interceptors, failures, DI, router
2. **Security:** secure storage, auth interceptor with refresh, session manager, device integrity, pinning, redaction
3. **Theme + shared widgets** from DESIGN_AUDIT.md (exact values only)
4. **Features in use-case journey order:** Auth -> main flow -> remaining features
5. For each feature: models -> datasource -> repository -> usecases -> bloc -> UI -> tests -> journey checklist

## 8. Per-feature definition of done
- [ ] Linked REQ / SCR / API IDs written at top of the feature (comment) and in traceability matrix
- [ ] All states handled: loading, empty, error, offline, validation, success
- [ ] Models match real API examples
- [ ] Bloc tests and repository tests pass
- [ ] Journey steps (UJ-xxx) manually checked
- [ ] `flutter analyze` clean
- [ ] No secrets or sensitive logs

## 9. Prompt to start (copy-paste to the AI)

> Read `IMPLEMENTATION_GUIDE.md`. Then start Phase 1 using files in `client_assets/`. Fill the `project_management` files in order. Stop after Phase 6 and show me the FINAL_AUDIT_REPORT summary.

After approval:

> Start Phase 7. Begin with Core + Security, then implement features in the order from FINAL_AUDIT_REPORT.md. Update the traceability matrix after each feature.
