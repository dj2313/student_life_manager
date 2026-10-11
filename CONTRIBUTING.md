# Contributing to Student OS

Thanks for your interest in contributing! Every contribution helps — bug reports,
feature ideas, documentation, UI polish and code.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Android Studio or VS Code with the Flutter extension
- A [Firebase project](https://console.firebase.google.com) (free Spark plan works)
- Android emulator or a physical device

### Setup

1. **Fork** the repository on GitHub.

2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/student_life_manager.git
   cd student_life_manager
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env and add your Weatherstack API key:
   # WEATHERSTACK_API_KEY=your_key_here
   ```

5. **Configure Firebase:**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Then enable **Authentication** (Email/Password + Google) and **Cloud Firestore**
   in the Firebase console.

6. **Run the app:**
   ```bash
   flutter run
   ```

## How to Contribute

### Reporting bugs

Check [existing issues](https://github.com/dj2313/student_life_manager/issues) first,
then open a new one with:
- Device & OS (e.g. "Pixel 7, Android 14")
- `flutter --version` output
- Steps to reproduce, expected vs. actual behavior
- Screenshots or a screen recording if it's a UI bug

### Suggesting features

Open an issue with the `enhancement` label describing the problem, your proposed
solution, and any reference apps. Keep the international-student use case in mind.

### Code contributions

1. Find an issue — [`good first issue`](https://github.com/dj2313/student_life_manager/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
   is a great place to start — and comment that you're working on it.
2. Create a branch:
   ```bash
   git checkout -b feature/your-feature-name
   # or: git checkout -b fix/what-you-fix
   ```
3. Make your changes (see conventions below).
4. Verify:
   ```bash
   flutter analyze
   flutter test
   ```
5. Commit with a clear message (`feat:`, `fix:`, `docs:`, `style:`, `refactor:` …).
6. Push and open a Pull Request against `main`. Reference the issue (`Fixes #123`)
   and attach screenshots for UI changes.

## Project Conventions

```
lib/
├── core/       # Shared: constants, providers, services, theme, utils, widgets
├── data/       # Models + repositories (data access layer)
├── features/   # auth, onboarding, home, study, money, tasks, notes, more
└── widgets/    # App shell
```

- **Services** (`core/services`) own all external calls — Firebase, weather, OCR, notifications.
- **Providers** hold app state and call services. New state → new `ChangeNotifier` provider, registered in `app.dart`.
- **Screens** render UI from providers. Keep them thin; push logic into providers/services.
- **Models** live in `data/models` with `fromJson`/`toJson` for Firestore + Hive support.
- State management is **Provider** — please don't introduce other frameworks.

## Code Style

- `dart format .` before committing; `flutter analyze` must pass with zero issues.
- Follow [Effective Dart](https://dart.dev/effective-dart/style).
- Break complex UI into small, reusable widgets.
- Comment the *why*, not the *what*.

## Design Guidelines

Obsidian-inspired aesthetic:
- Dark backgrounds (`#0F2027` → `#2C5364` range), white text, calm blue accents
- **Outfit** for headings, **Inter** for body (via `google_fonts`)
- 8px spacing grid, glassmorphism cards, 200–300ms subtle animations (`flutter_animate`)
- `HapticFeedback` on primary interactions; keep light theme equally usable

## Release Process

1. Changes merge to `main` via reviewed PRs.
2. Maintainer tags a release (`v1.0.0`, …) and attaches the built APK.
3. `CHANGELOG.md` is updated for every release.

## Questions?

- [Discussions](https://github.com/dj2313/student_life_manager/discussions) for general questions
- [Issues](https://github.com/dj2313/student_life_manager/issues) for bugs and features

Thank you for helping make student life a little easier! 🎓
