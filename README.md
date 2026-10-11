<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:0F2027,100:2C5364&height=280&section=header&text=Student%20OS&fontSize=90&fontColor=ffffff&animation=fadeIn&fontAlignY=38&desc=Academics%20%E2%80%A2%20Finances%20%E2%80%A2%20Residency%20%E2%80%A2%20Jobs%20%E2%80%94%20in%20one%20place&descAlignY=55&descSize=18" alt="Student OS header"/>
</p>

<p align="center">
  <a href="https://github.com/dj2313/student_life_manager/releases/tag/v1.0.0"><img src="https://img.shields.io/badge/Download-Android%20APK-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Download Android APK"></a>
  <a href="https://github.com/dj2313/student_life_manager/stargazers"><img src="https://img.shields.io/github/stars/dj2313/student_life_manager?style=for-the-badge&logo=github&label=Stars" alt="GitHub Stars"></a>
  <a href="https://github.com/dj2313/student_life_manager/releases"><img src="https://img.shields.io/github/v/release/dj2313/student_life_manager?style=for-the-badge&label=Latest%20Release" alt="Latest Release"></a>
  <a href="https://github.com/dj2313/student_life_manager/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge" alt="License: MIT"></a>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://firebase.google.com"><img src="https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase" alt="Firebase"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"></a>
  <img src="https://img.shields.io/badge/Hive-local--first-FFC400?style=for-the-badge&logo=database&logoColor=black" alt="Hive">
</p>

<p align="center">
  <strong>Student OS</strong> is an open-source Flutter app for students — especially
  <strong>international students</strong> — that brings academics, finances, residency
  paperwork, jobs, tasks and notes together in one obsidian-styled dashboard,
  with cloud sync via Firebase and offline-first local storage.
</p>

<p align="center">
  <a href="#-getting-started">Getting Started</a> ·
  <a href="#-features">Features</a> ·
  <a href="#%EF%B8%8F-architecture">Architecture</a> ·
  <a href="#%EF%B8%8F-roadmap">Roadmap</a> ·
  <a href="#-contributing">Contributing</a>
</p>

---

## Table of Contents

- [Why Student OS?](#why-student-os)
- [Screenshots](#screenshots)
- [Features](#-features)
- [Tech Stack](#%EF%B8%8F-tech-stack)
- [Getting Started](#-getting-started)
- [Architecture](#%EF%B8%8F-architecture)
- [Project Structure](#project-structure)
- [Roadmap](#%EF%B8%8F-roadmap)
- [Privacy](#-privacy)
- [Contributing](#-contributing)
- [FAQ](#faq)
- [License](#-license)

---

## Why Student OS?

Student life is more than assignments and exams.

As an international student in Germany, you're also juggling things most productivity
apps never think about:

- 🛂 **Residence permit deadlines** — miss one and your visa is at risk
- 🏦 **Blocked account (Sperrkonto)** — prove your finances, track every payout
- 📄 **Anmeldung, health insurance, enrolment certificates** — bureaucracy in a foreign language
- 💸 **Money across two countries** — home currency, euros, remittances
- 💼 **Student job hours** — often legally capped, always worth tracking

Existing tools each handle one piece. Spreadsheets, calendars, notes and banking apps
don't talk to each other — and none of them understand a blocked account or an
Aufenthaltstitel.

**Student OS turns these scattered responsibilities into one organized workspace** —
so you spend less time managing student life and more time living it.

---

## Screenshots

| Landing | Dashboard |
| --- | --- |
| ![Landing](https://raw.githubusercontent.com/dj2313/student_life_manager/main/assets/images/landing.png) | ![Dashboard](https://raw.githubusercontent.com/dj2313/student_life_manager/main/assets/images/landing_hero.png) |

<!-- Record a short GIF walkthrough, save it as assets/demo.gif, and uncomment:
<p align="center">
  <img src="assets/demo.gif" alt="Student OS demo" width="300"/>
</p>
-->

---

## ✨ Features

### 🏠 Smart Dashboard & Home Base
- Personalized greeting that adapts to time of day, plus live weather and location context
- **Bureaucracy tracker** — Anmeldung, health insurance and enrolment checklists
- **Housing tracker** — keep rental and WG details organized
- **Visa reminders** — never miss a residence-permit deadline
- **Focus Zen timer** — distraction-free study sessions with session tracking
- **Travel ticket cards** — keep transport tickets at hand
- Support screen with help resources

### 🎓 Study Hub
- University manager — track institutions, lectures and class progress
- Timetable / schedule view for the week
- **GPA manager** — monitor grades and targets
- Study analytics with charts (weekly goals, ECTS progress)
- **German learning module** — vocab sessions with a timer and daily reminders
- Built-in **study assistant**: German admin-term translator (Anmeldung, Aufenthaltstitel, …),
  note summarizer and flashcard generator — all on-device, no API costs

### 💰 Money Manager
- Multi-account balance overview with expense categories
- **Blocked account (Sperrkonto) tracker** with payout projections
- **India → Germany tracker** — follow money across both countries
- Grocery spending tracker and loan tracker with schedules
- Subscription tracking
- **Student job tracker** — applications, employment info and working hours
- Live currency converter and one-tap CSV export of your data

### ✅ Tasks & Calendar
- To-do lists with a monthly calendar view
- Local notifications for deadlines and reminders

### 📝 Rich Notes
- Full rich-text notes (Flutter Quill) synced to Firestore across devices

### 🧰 Extras
- Scientific calculator
- **OCR document scanner** — extract text from photos of letters and forms (ML Kit, on-device)
- QR code scanning
- Obsidian-style dark theme + clean light theme, Outfit & Inter typography,
  glassmorphism cards, smooth animations and haptic touch feedback

---

## 🛠️ Tech Stack

| Layer | Technology |
| --- | --- |
| Framework | Flutter (Android, iOS, Web, Desktop from one codebase) |
| Language | Dart (SDK ^3.10.4) |
| State management | Provider |
| Auth | Firebase Auth (email/password + Google Sign-In) |
| Cloud database | Cloud Firestore (real-time sync) |
| Push | Firebase Cloud Messaging |
| Local-first storage | Hive + sqflite + SharedPreferences |
| Charts | fl_chart |
| Calendar | table_calendar |
| Notes editor | flutter_quill |
| Weather | Weatherstack API + Open-Meteo |
| Location & maps | Geolocator + google_maps_flutter |
| Notifications | flutter_local_notifications + timezone scheduling |
| OCR | Google ML Kit text recognition (on-device) |
| Currency | Live converter + currency_picker |
| Animations | flutter_animate |
| Networking | Dio |
| Env config | flutter_dotenv |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- Android Studio or VS Code with the Flutter extension
- A [Firebase project](https://console.firebase.google.com) (free Spark plan is enough)
- Android emulator or a physical device

### 1. Clone the repository

```bash
git clone https://github.com/dj2313/student_life_manager.git
cd student_life_manager
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure environment variables

```bash
cp .env.example .env
```

Then add your key to `.env`:

```env
WEATHERSTACK_API_KEY=your_weatherstack_key_here
```

Get a free key at [weatherstack.com](https://weatherstack.com/). Never commit your real `.env`.

### 4. Configure Firebase

This project uses FlutterFire (`firebase_options.dart` is already wired into `main.dart`).
Point it at your own Firebase project:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

In the [Firebase console](https://console.firebase.google.com), enable:
- **Authentication** → Email/Password and Google sign-in methods
- **Cloud Firestore** → create a database (start in production mode)
- **Cloud Messaging** → enabled by default

### 5. Run Student OS

```bash
flutter analyze
flutter test
flutter run
```

---

## 🏗️ Architecture

Feature-first Flutter architecture: each feature owns its screens, widgets and
providers, while `core` holds shared services and `data` holds models and repositories.

```
                        Student OS
                             │
                    ┌────────┴────────┐
                    │  Flutter UI     │  (features/*/screens + widgets)
                    │  Provider state │  (core + feature providers)
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
        Core Services    Local-first    Firebase
        (weather, OCR,   storage        (Auth,
         currency,       (Hive,          Firestore,
         notify, AI)     sqflite)        FCM)
```

Details: [`PROJECT_AUDIT.md`](PROJECT_AUDIT.md).

---

## Project Structure

```
lib/
├── main.dart              # Entry: Hive, dotenv, Firebase, FCM, notifications
├── app.dart               # MaterialApp, theme, routing
├── firebase_options.dart  # FlutterFire config (per platform)
├── core/
│   ├── constants/         # App-wide constants
│   ├── providers/         # Theme, navigation, weather, focus timer, system status
│   ├── services/          # AI, CSV export, currency, notifications, OCR, weather
│   ├── theme/             # Obsidian dark + light themes
│   ├── utils/             # Helpers
│   └── widgets/           # Shared widgets
├── data/
│   ├── models/            # Expense, loan, grocery, subscription, lecture,
│   │                      #   university, note, todo, ticket, blocked account…
│   └── repositories/      # Data access layer
├── features/
│   ├── auth/              # Login + signup
│   ├── onboarding/        # Landing screen
│   ├── home/              # Dashboard, bureaucracy, housing, visa, Focus Zen…
│   ├── study/             # University hub, schedule, GPA, German learning, AI
│   ├── money/             # Dashboard, blocked account, groceries, jobs, loans…
│   ├── tasks/             # To-dos + calendar
│   ├── notes/             # Rich-text notes
│   └── more/              # Calculator, settings
└── widgets/               # App shell (main screen, status indicators)
```

---

## 🗺️ Roadmap

### ✅ v1.0 — Shipped
- [x] Academic hub (universities, schedule, GPA, analytics)
- [x] Focus Zen study timer
- [x] Money manager (blocked account, groceries, loans, subscriptions, jobs)
- [x] India → Germany tracker
- [x] Bureaucracy, housing and visa trackers
- [x] Tasks + calendar, rich-text notes with Firestore sync
- [x] OCR document scanner, calculator, weather + location
- [x] Firebase Auth (email + Google), FCM push
- [x] Dark/light obsidian themes
- [x] Android APK release ([v1.0.0](https://github.com/dj2313/student_life_manager/releases/tag/v1.0.0))

### 🚧 Next — v1.1
- [ ] Google Play Store release
- [ ] Unit + widget test coverage (providers, services, models)
- [ ] Offline-first polish and conflict handling
- [ ] Crash reporting and analytics
- [ ] Accessibility pass (screen readers, large text)
- [ ] Performance pass (list virtualization, image caching)

### 🔮 Future — v2.0
- [ ] Real LLM integration for the study assistant (BYOK: Groq / Gemini)
- [ ] Deadline extraction from scanned documents
- [ ] Calendar sync (Google / Apple)
- [ ] Multi-language UI (DE, ES, FR, HI)
- [ ] Shared household / roommate features
- [ ] iOS App Store release

Have an idea? Open an [issue](https://github.com/dj2313/student_life_manager/issues) or
start a [discussion](https://github.com/dj2313/student_life_manager/discussions).

---

## 🔐 Privacy

Student OS handles personal data — finances, documents, residency status — so privacy
is a design constraint, not an afterthought:

- **Local-first**: your data lives in on-device Hive/sqflite storage and works offline
- **Your cloud**: sync goes to *your own* Firebase project — no third-party analytics
- **On-device AI & OCR**: the study assistant and document scanner run locally, no API calls
- **Minimal permissions**: location, camera and notifications only where the feature needs them
- **You own deletion**: remove your account and data at any time

---

## 🤝 Contributing

Contributions are welcome — bug reports, feature ideas, docs, UI polish and code.
Please see [CONTRIBUTING.md](CONTRIBUTING.md) for the setup guide and conventions.

```bash
git checkout -b feature/my-feature
# make your changes, then:
flutter analyze && flutter test
```

New here? Look for issues labeled
[`good first issue`](https://github.com/dj2313/student_life_manager/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22).

---

## FAQ

**Do I need Firebase to run the app?**
Yes for sign-in and cloud sync — create a free Firebase project and run
`flutterfire configure`. Local features work offline via Hive once you're signed in.

**Does it work offline?**
Yes. Hive + sqflite keep your data on-device; Firestore syncs when you're back online.

**Which platforms are supported?**
Android is the primary target (APK in [Releases](https://github.com/dj2313/student_life_manager/releases)).
iOS, Web and Desktop compile from the same Flutter codebase; store releases are on the roadmap.

**Does the study assistant need API keys?**
No. The current assistant (translator, summarizer, flashcards) runs fully on-device.
Real LLM integration with your own keys is planned for v2.0.

**Is my financial data safe?**
It stays in your local database and your own Firebase project. The app sends
no data to third parties; only the weather feature calls its API.

---

## ⭐ Support the Project

If Student OS helps you — or gives you an idea:

- **Star ⭐ the repo** so other students can find it
- Share it with a fellow (international) student
- [Report a bug](https://github.com/dj2313/student_life_manager/issues) or request a feature
- Contribute code — see [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📝 License

MIT — see [LICENSE](LICENSE).

---

<p align="center">
  <a href="https://star-history.com/#dj2313/student_life_manager&Date">
    <img src="https://api.star-history.com/svg?repos=dj2313/student_life_manager&type=Date&theme=dark" alt="Star History Chart"/>
  </a>
</p>

<p align="center">
  <strong>Built by <a href="https://github.com/dj2313">Dhruv Trivedi</a></strong> — Learn. Organize. Grow. 🦉
</p>
