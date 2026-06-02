# Architecture Rules

## 1. No Business Logic in Widgets
Widgets render UI only. All business logic lives in domain use cases or feature-level notifiers/controllers.

## 2. Domain Cannot Import Flutter
The `core/ai/` domain directory and any `domain/` packages must not import `package:flutter/...`. They depend only on Dart stdlib and `equatable`.

## 3. Feature Cannot Depend on Feature
No `import 'package:screenfix_ai/features/overlay/...'` from inside `features/ocr/`. Cross-feature communication goes through `integration/`.

## 4. Main Files Under 100 Lines
`lib/main.dart` and `lib/app.dart` must stay under 100 lines each. They bootstrap the app and configure DI/routing only.

## 5. LoggerService Only
All logging uses `LoggerService` from `infrastructure/logging/`. No `print()`, `debugPrint()`, or direct `log()` calls outside that class.

## 6. No Direct OpenRouter Calls Outside AI Gateway
The `features/ai_gateway/` module is the sole owner of OpenRouter HTTP calls. Other features must go through `ai_gateway` use cases.

## 7. Integration Layer Orchestrates Features
`integration/` holds cross-feature workflows (e.g. "capture → OCR → AI → recommendations"). Features never call each other's notifiers or services directly.

## 8. No Direct SharedPreferences Access Outside Services
Storage access is encapsulated in `core/identity/`, `core/telemetry/`, `core/config/`, and future feature-level services. Widgets and use cases must not import `shared_preferences`.

## 9. No Direct Dio Usage Outside Network Layer
HTTP calls go through `core/network/dio_client.dart` or feature-level repository classes. Raw `Dio` instance must not appear in widgets, notifiers, or use cases.

## 10. All New Services Require Interface-First Design
Every new service gets an abstract interface (in `core/` or feature `domain/`) and an implementation (in `infrastructure/` or feature `data/`). This enables testing via dependency inversion.
