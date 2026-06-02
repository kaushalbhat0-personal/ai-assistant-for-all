# ScreenFix AI

AI assistant that analyzes any Android screen and provides actionable recommendations.

Tap the floating overlay → screen is captured → text is extracted → AI analyzes context → recommendations appear.

## Architecture

Clean Architecture with feature-first structure.

**Architecture Version: v1.0 (Frozen)**

```
lib/
├── core/              Shared kernel (errors, network, config, ai entities)
├── common/            Reusable widgets
├── features/          Vertical slices (overlay, ocr, ai_gateway, ...)
├── integration/       Cross-feature orchestration
├── infrastructure/    External service implementations
└── routing/           GoRouter configuration
```

See `docs/architecture_rules.md` for detailed rules.

## Prerequisites

- Flutter SDK ^3.29.0
- Android SDK 24+
- OpenRouter API key

## Setup

```bash
git clone <repo-url>
cd screenfix_ai
flutter pub get
```

## Environment Variables

Configuration is provided at build time via `--dart-define`.

### Development

```bash
flutter run --dart-define=ENVIRONMENT=development
```

### With API Key

```bash
flutter run \
  --dart-define=ENVIRONMENT=development \
  --dart-define=OPENROUTER_API_KEY=sk-or-v1-xxx
```

### Production Build

```bash
flutter build appbundle --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=OPENROUTER_API_KEY=$OPENROUTER_API_KEY
```

## Build Commands

| Command | Purpose |
|---|---|
| `flutter pub get` | Install dependencies |
| `flutter analyze` | Static analysis |
| `dart format lib/` | Format code |
| `flutter test` | Run tests |
| `flutter test --coverage` | Run tests with coverage |
| `flutter build apk --debug` | Debug APK |
| `flutter build appbundle --release` | Release AAB |

## Folder Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── ai/              Domain entities for AI pipeline
│   ├── config/          Environment & app configuration
│   ├── constants/       App-wide constants
│   ├── di/              Dependency injection setup
│   ├── errors/          Failure & exception hierarchy
│   ├── feature_flags/   Runtime feature toggles
│   ├── identity/        Anonymous device identity
│   ├── network/         Dio client & interceptors
│   └── telemetry/       Event tracking system
├── common/widgets/       Reusable UI components
├── features/             Feature modules (vertical slices)
│   ├── overlay/          Floating overlay subsystem
│   ├── screen_capture/   Screen & metadata capture
│   ├── ocr/              Text extraction
│   ├── local_analysis/   Pattern matching pre-filter
│   ├── prompt_engine/    Structured prompt builder
│   ├── ai_gateway/       OpenRouter AI provider
│   └── settings/         User preferences
├── integration/          Cross-feature orchestration
├── infrastructure/       External service adapters
└── routing/              GoRouter configuration

test/
├── unit/                 Unit tests (mirrors lib/ structure)
├── widget/               Widget tests
├── integration/          Integration tests
└── helpers/              Test utilities
```

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `get_it` | Dependency injection |
| `go_router` | Declarative routing |
| `dio` | HTTP client |
| `shared_preferences` | Key-value storage |
| `drift` | SQLite ORM |
| `uuid` | Anonymous identity |
| `equatable` | Value equality |
| `mocktail` | Test mocking |

## License

Proprietary — all rights reserved.
