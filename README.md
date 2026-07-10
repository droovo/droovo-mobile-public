# Droovo Mobile App (Public)

[![Flutter CI](https://github.com/droovo/droovo-mobile-public/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/droovo/droovo-mobile-public/actions/workflows/flutter-ci.yml)

Welcome to the **public Droovo Flutter app repository**! This repo contains only a subset of the Flutter app: helper classes and testable code that external contributors can work on and improve.

📊 **[Live project dashboard](https://public.droovo.tn/)** — branches, recent activity, pull requests, CI builds, and downloads at a glance.

🌐 [droovo.tn](https://droovo.tn/) • 📱 [Get it on Google Play](https://play.google.com/store/apps/details?id=tn.droovo.droovo_app) • ✉️ [Contact us](https://droovo.tn/contact)

> ⚠️ **Note:** Sensitive code and the full app are maintained in the private Droovo GitLab repository.

---

## Table of Contents

* [Project Overview](#project-overview)
* [Dashboard](#dashboard)
* [Getting Started](#getting-started)
* [Contributing](#contributing)
* [CI/CD & Testing](#cicd--testing)
* [Downloads](#downloads)
* [Workflow for Updates](#workflow-for-updates)
* [Reporting Issues](#reporting-issues)
* [License](#license)

---

## Project Overview

This is a real, runnable Flutter project — it has no product screens, only the pure business-logic helpers and their tests. It contains:

* `lib/helpers/`: pure-logic helper classes ported from the private app (pricing, distance/geolocation math, seat assignment, ride validation & filtering, form validation, auth rules, chat utilities). None of them touch Firebase, HTTP, or platform plugins, so they run anywhere `flutter test` runs.
* `lib/models/`: plain Dart data classes (`Ride`, `Car`, `Seat`, `User`, `Message`...) that mirror the shape of the private app's entities without any of the Firestore/Hive wiring.
* `lib/main_public.dart`: a screen-less demo entry point that just proves the helpers run as a real Flutter app — see [Getting Started](#getting-started).
* `test/`: one test file per helper, plus `test/fixtures/sample_data.json` — fake rides, cars, users and chat messages that every test exercises against, and `test/helpers/test_data.dart` which loads it into the typed models above.

The full app, including sensitive business logic, payment, and backend integrations, is in the private GitLab repository.

---

## Dashboard

**[public.droovo.tn](https://public.droovo.tn/)** is a live, read-only project dashboard — a plain static site (`dashboard/`) that reads public data straight from the GitHub API and shows:

* **Activity** — recent commits on `main`, so you can see what changed and who changed it.
* **Pull Requests** — open and recently updated PRs from contributors.
* **Branches** — every branch and its latest commit.
* **Builds** — recent CI runs with pass/fail status, linking to each run on GitHub (downloading that run's artifact still requires a GitHub login — that's GitHub's own policy, not something this dashboard can bypass).
* **Downloads** — tagged releases with the APK/AAB/web build attached, which download directly with **no GitHub login needed**.

It's hosted on Firebase Hosting and redeploys automatically via
[`.github/workflows/firebase-hosting-merge.yml`](.github/workflows/firebase-hosting-merge.yml)
on every push to `main`; pull requests also get their own live preview
URL via [`firebase-hosting-pull-request.yml`](.github/workflows/firebase-hosting-pull-request.yml)
(posted as a PR comment). It ships no backend and stores no data of its
own — everything shown is fetched live from `api.github.com` in the
visitor's browser.

---

## Getting Started

### Prerequisites

* [Flutter](https://flutter.dev/docs/get-started/install) ≥ 3.x
* Android Studio / Xcode (for device builds)
* Git

### Clone the repository

```bash
git clone https://github.com/droovo/droovo-mobile-public.git
cd droovo-mobile-public
```

### Install dependencies

```bash
flutter pub get
```

### Run the testable app

```bash
flutter run -t lib/main_public.dart
```

This launches the app with the public helper code, allowing you to test changes safely.

---

## Contributing

We welcome contributions! Full guidelines, the pre-PR checklist, and what
you can/can't touch live in [CONTRIBUTING.md](CONTRIBUTING.md). Short version:

1. **Fork the repository**.
2. **Create a feature branch** for your changes:

```bash
git checkout -b feat/my-feature
```

3. **Modify or add helper classes** only. Do not attempt to access sensitive or private logic.
4. **Run tests locally**:

```bash
dart format .
flutter analyze
flutter test
```

5. **Submit a pull request (PR)**. GitHub Actions will automatically analyze, test, and build it.

---

## CI/CD & Testing

Every push and pull request runs [`.github/workflows/flutter-ci.yml`](.github/workflows/flutter-ci.yml) on GitHub Actions:

1. **Verify** — `dart format --set-exit-if-changed .` and `flutter analyze`.
2. **Test** — `flutter test` (the full suite under `test/`).
3. **Build** — release **APK**, **AAB** (Android App Bundle), and a **web** build, uploaded as downloadable artifacts on the workflow run's *Summary* page (kept for 30 days).

Android release builds are signed with Flutter's default debug keystore (see `android/app/build.gradle.kts`) since this is a community demo app, not a Play Store release — no signing secrets are needed to build them.

Pushing a tag like `v1.0.0` runs the same pipeline and additionally publishes a **GitHub Release** with the APK/AAB/web zip attached — see [Downloads](#downloads).

---

## Downloads

There are two ways to grab a build without compiling it yourself:

* **Latest tagged release** (recommended, permanent link, no GitHub login needed): see the [Releases page](../../releases) for the newest `app-release.apk`, `app-release.aab`, and `droovo-public-helpers-web.zip`.
* **Any individual commit/PR build**: open the corresponding run under the [Actions tab](../../actions/workflows/flutter-ci.yml), scroll to *Artifacts*, and download the APK/AAB/web zip generated for that push (requires being signed in to GitHub; artifacts expire after 30 days).

These builds only contain the screen-less demo app from `lib/main_public.dart` — there is no product UI to install here, they mainly exist to prove the pipeline (and the helpers) actually build and run.

---

## Workflow for Updates

1. Contributors submit PRs to the public repo.
2. After review and testing, approved changes to helper classes are manually merged into the private GitLab repository.
3. `main_public.dart` is for testing purposes and **is not merged** into the private repo.

This workflow ensures contributors can safely improve shared code without exposing the full app.

---

## Reporting Issues

* Submit an issue if you find bugs or have improvement suggestions in this repo's helper logic.
* Provide a detailed description, steps to reproduce, and screenshots if possible.
* For anything about the live app itself (account/billing/ride issues), use [droovo.tn/contact](https://droovo.tn/contact) instead — this repo's maintainers can't act on those from a GitHub issue.

---

## License

This project is maintained by **Droovo**. Contributions are governed by the terms in the [LICENSE](LICENSE) file.

---

Thank you for helping make Droovo better! 🚀
