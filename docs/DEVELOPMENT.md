# Development & Run Guide

This document explains how to install, configure, and run StyleSync locally (Android) including the Firebase Emulator Suite and Cloud Functions. It focuses on reproducing the developer environment on another PC or device.

## Prerequisites
- Flutter SDK (stable, tested with Flutter 3.x+)
- Android SDK & Android Studio (for emulator or device builds)
- Node.js (16+) and npm (for functions and emulator tooling)
- Firebase CLI (`npm install -g firebase-tools`) and `npx` available
- Java JDK (required for Android Gradle builds)
- Optional: VS Code or Android Studio for editing

## Repo setup
1. Clone the repo:

```bash
git clone <repo-url> stylesync
cd stylesync
```

2. Install Dart/Flutter packages:

```bash
flutter pub get
```

3. Generate code (if using `freezed` or codegen):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

If you see generated-file related errors during the build, run the above. If build fails with stale artifacts, run `flutter clean` then retry.

## Firebase emulator (local dev)
The project uses Firestore, Auth, and Functions in the emulator for safe local testing.

1. Install dependencies for functions:

```bash
cd functions
npm install
cd ..
```

2. Start the emulators in the project root:

```bash
npx firebase emulators:start --only auth,firestore,functions --project stylesync
```

Watch the terminal output. The Firestore emulator prints rule rejections and helpful diagnostics when clients attempt denied writes.

## Seed data (optional)
There are admin/seed scripts to create test shops and tickets in `tools/` and `functions/`:

```bash
# Node scripts that use firebase-admin (run from project root)
node tools/create_elcorte.js
node tools/add_ticket.js
```

These assume you have set the emulator `FIREBASE_CONFIG` or are running emulators locally.

## Running the Flutter app (Android)
The app connects to emulators using a `--dart-define` key. You must point the app to the host running the emulators.

1. Determine the host IP reachable from the Android device/emulator. For a physical device on the same LAN use the machine LAN IP (e.g. `192.168.1.42`). Android Emulator often uses `10.0.2.2` for the host machine; if using a separate VM (BlueStacks) you may need the host LAN IP (e.g. `192.168.254.102`).

2. (Optional) If building for Android debug and your app blocks cleartext, update `android/app/src/debug/res/xml/network_security_config_debug.xml` to allow your emulator host IP.

3. Run the app pointing to the emulator host:

```bash
flutter run --dart-define=EMULATOR_HOST=192.168.254.102
```

Replace `192.168.254.102` with your host IP. The app prints a log like: `[StyleSync] Connected to Firebase emulators at <IP>` when configured properly.

Notes:
- If Flutter build fails with `assembleDebug` errors, run:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter clean
flutter run --dart-define=EMULATOR_HOST=<IP>
```

- If you run on the Android emulator (not BlueStacks), try `10.0.2.2` as the host.
- Use `adb logcat -v time *:E` to capture errors and debugPrint output from the app.

## Firestore rules & testing
- Emulator uses `firestore.rules` in the repo. If you change rules for local testing remember to revert them before production.
- The emulator prints rule evaluation logs to the terminal where `firebase emulators:start` runs. Use those logs to debug `permission-denied` issues.

## Common tasks
- Rebuild after editing generated models: `flutter pub run build_runner build --delete-conflicting-outputs`
- Clear Flutter build cache: `flutter clean`
- Start emulators: `npx firebase emulators:start --only auth,firestore,functions --project stylesync`
- Seed test shop: `node tools/create_elcorte.js`

## Troubleshooting
- Permission denied during client writes: (1) inspect emulator terminal for rule rejections; (2) ensure your `request.auth.uid` is set (Sign in using emulator Auth), (3) make rule changes conservative — prefer server-side function for authoritative operations.
- App cannot reach emulators: confirm `EMULATOR_HOST` value, ensure firewall allows connections, and if using Android emulator prefer `10.0.2.2`.
- Gradle errors on Windows: run `flutter doctor` and ensure Android SDK/NDK/Java versions are healthy.

---
If you'd like, I can also add a small `scripts/` helper (PowerShell + bash) to start emulators and run the app with the correct `EMULATOR_HOST` automatically. Want that added?