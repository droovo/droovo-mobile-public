# Contributing to Droovo — Public Helpers

Thanks for helping improve Droovo's shared business logic! This repo only
contains pure helper classes and their tests — no backend, no UI screens, no
secrets — so it's safe to fork, run, and send PRs against.

## What you can work on

* Bug fixes or improvements to any class in `lib/helpers/`.
* New or expanded test cases in `test/`.
* More realistic fake data in `test/fixtures/sample_data.json`.
* Documentation (this file, the README, code comments).

Please don't try to wire Firebase, HTTP calls, or platform plugins into
`lib/helpers/` — that's the point of the helper code staying
dependency-free. If a helper needs data it doesn't have, add a field to
the plain models in `lib/models/` rather than reaching for the private
app's real entities. (`dashboard/` is a separate, static, read-only site —
see below — and isn't held to this rule.)

## Branch naming

* Feature: `feat/description`
* Bug fix: `fix/description`
* Chore/docs: `chore/description`

## Running locally

```bash
flutter pub get

# whole suite
flutter test

# a single helper's tests
flutter test test/seat_helper_test.dart

# the screen-less demo app (proves the helpers run as real Flutter code)
flutter run -t lib/main_public.dart
```

## Before opening a PR

* [ ] `dart format .` — no pending changes (CI fails the build otherwise)
* [ ] `flutter analyze` — no issues
* [ ] `flutter test` — all green
* [ ] Added or changed a helper? Add/update its test file in `test/`
* [ ] Needed new test data? Add it to `test/fixtures/sample_data.json`
  instead of hand-rolling ad-hoc objects inside a test
* [ ] No TODOs left referencing private-app-only concerns (Firebase, auth
  tokens, payment, etc.)

## What CI does automatically

Every push and pull request runs
[`.github/workflows/flutter-ci.yml`](.github/workflows/flutter-ci.yml):

1. `dart format --output=none --set-exit-if-changed .`
2. `flutter analyze`
3. `flutter test`
4. Builds a release APK, AAB, and web bundle, uploaded as downloadable
   artifacts on the workflow run's **Summary** page (kept for 30 days).

A maintainer tagging a release (e.g. `v1.0.0`) additionally publishes a
[GitHub Release](../../releases) with those same build files attached —
you don't need to create a tag yourself as a contributor.

## Project dashboard

**[droovo-flutter-public.web.app](https://droovo-flutter-public.web.app)**
is a live, read-only view of this repo — activity, open PRs, branches, CI
build status, and release downloads — useful for checking whether your PR
has been picked up or whether a build is green before asking. It's a
static site under `dashboard/` that just calls the public GitHub API; it
redeploys automatically on push to `main` via
[`firebase-hosting-merge.yml`](.github/workflows/firebase-hosting-merge.yml),
and your own PRs get a live preview URL via
[`firebase-hosting-pull-request.yml`](.github/workflows/firebase-hosting-pull-request.yml).
You're welcome to improve it too (it's plain HTML/CSS/JS, no build step).

## Merging into the private app

Approved changes to `lib/helpers/` are manually ported into the private
GitLab repository by the Droovo team after review and testing here.
`lib/main_public.dart` is for this repo only and is never merged upstream.
