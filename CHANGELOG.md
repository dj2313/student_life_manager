# Changelog

All notable changes to Student OS are documented here, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[Semantic Versioning](https://semver.org/).

---

## [v1.0.0] — 2026-03-01

First public release. Built over Jan–Mar 2026: project setup and core dashboards
(Phase 1–5), Money/Study/Home premium overhauls, Residence Permit system,
Weatherstack + location integration, and the Android release build.

### Added

**Study**
- University manager, lecture schedule and class-progress tracking
- GPA manager and study dashboard with analytics charts
- German learning module with vocab timer + daily reminders
- On-device study assistant: admin-term translator, note summarizer, flashcards

**Money**
- Multi-account dashboard with expense categories and CSV export
- Blocked account (Sperrkonto) tracker with payout projections
- India → Germany money tracker, grocery tracker, loan tracker, subscriptions
- Student job tracker (applications, hours)
- Live currency converter

**Home & daily life**
- Smart dashboard with greeting, weather and location
- Bureaucracy, housing and visa-reminder trackers
- Focus Zen study timer, travel ticket cards, support screen

**Productivity**
- Tasks with calendar view and deadline notifications
- Rich-text notes with Firestore sync
- Scientific calculator, OCR document scanner, QR scanning

**Platform**
- Firebase Auth (email/password + Google), Firestore sync, FCM push
- Offline-first local storage (Hive, sqflite)
- Obsidian dark + light themes, animations, haptics
- Android APK release

---

## [Unreleased]

### Planned — v1.1
- Google Play Store release
- Unit + widget test coverage
- Offline-first polish, crash reporting, accessibility pass

### Planned — v2.0
- Real LLM integration for the study assistant (BYOK)
- Deadline extraction from scanned documents
- Calendar sync, multi-language UI, shared household features
- iOS App Store release
