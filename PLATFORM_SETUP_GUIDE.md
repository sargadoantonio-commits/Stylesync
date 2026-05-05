# StyleSync Production Infrastructure Setup Guide

This document provides the complete native platform configuration needed to enable Firebase App Check, Crashlytics, and secure callable auth for StyleSync.

## Prerequisites

- Flutter 3.3+ SDK
- Firebase CLI (`npm install -g firebase-tools`)
- Android SDK (API 26+) and/or Xcode 14+
- A Firebase project configured in the Google Cloud Console

## 1. Native Platform Generation

### Android

If you haven't already scaffolded the Android build system, run:

```bash
flutter create --platforms android .
```

Or, if the `android/` folder is missing:

```bash
flutterfire configure
```

This will generate:
- `android/` folder with Gradle build files
- `android/app/google-services.json` (Firebase project configuration)
- `android/build.gradle` and `android/app/build.gradle` with Firebase dependencies

### iOS

Similarly for iOS:

```bash
flutter create --platforms ios .
```

Or use auto-configuration:

```bash
flutterfire configure
```

This generates:
- `ios/` folder with Xcode project
- `ios/Runner/GoogleService-Info.plist` (Firebase project configuration)
- Podfile with Firebase pods

## 2. Firebase App Check Setup

### Android (Play Integrity Provider)

**In Firebase Console:**

1. Go to **Project Settings** → **App Check**
2. Register your Android app: Select your app and **Manage**
3. Under **Attestation Provider**, select **Play Integrity**
4. For **Debug builds**: Register a **Debug Token**
   - Run your app in debug mode; the token will be logged and printed
   - Copy it and add it to the Firebase Console under **Debug tokens**

**In `android/app/build.gradle`:**

FirebaseAppCheck is already included via flutterfire. Gradle will automatically download the Play Integrity API dependency.

### iOS (App Attest + DeviceCheck)

**In Firebase Console:**

1. Go to **Project Settings** → **App Check**
2. Register your iOS app and select **Manage**
3. Under **Attestation Provider**, select **App Attest**
4. For **Debug builds**: Enable **Debug Token**
   - Run your app in debug mode; the token will be printed to the console
   - Register it in the Firebase Console

**In `ios/Podfile`:**

After running `flutterfire configure`, ensure your Podfile includes:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'FIREBASE_ANALYTICS_COLLECTION_ENABLED=1',
      ]
    end
  end
end
```

### Web (reCAPTCHA v3)

For web deployments, pass the reCAPTCHA v3 site key during build:

```bash
flutter run -d chrome --dart-define=FIREBASE_APP_CHECK_SITE_KEY=YOUR_RECAPTCHA_SITE_KEY
```

Obtain the key from Firebase Console → **App Check** → **reCAPTCHA v3**.

## 3. Firebase Crashlytics Setup

### Android

**In `android/app/build.gradle`:**

After `flutterfire configure`, Crashlytics is auto-included. Verify:

```gradle
dependencies {
  ...
  implementation platform('com.google.firebase:firebase-bom:...')
  implementation 'com.google.firebase:firebase-crashlytics-ktx'
  ...
}

apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'
```

**In `android/build.gradle`:**

```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
    classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
  }
}
```

**Build & Test:**

```bash
flutter build apk --release
# or for testing locally:
flutter run --release
```

Crash logs should appear in Firebase Console → **Crashlytics** within 5 minutes.

### iOS

**In `ios/Podfile`:**

After `flutterfire configure`, ensure FirebaseCrashlytics is included:

```ruby
target 'Runner' do
  ...
  pod 'Firebase/Crashlytics', '~> 10.0'
  ...
end
```

**In Xcode (Runner.xcodeproj):**

1. Open `Runner.xcodeproj` in Xcode
2. Select the **Runner** target
3. Go to **Build Phases** → **+** → **New Run Script Phase**
4. Add:
   ```bash
   "${PODS_ROOT}/FirebaseCrashlytics/run"
   ```
   This strips symbols and uploads them to Firebase automatically during release builds.

**Build & Test:**

```bash
flutter build ios --release
# or for testing:
flutter run --release
```

## 4. Cloud Functions Deployment

### Set the Pepper Secret

For server-side bcrypt credential storage, set the `STYLESYNC_PEPPER` secret:

```bash
printf 'your-long-random-pepper-at-least-16-chars-go-here' | \
  firebase functions:secrets:set STYLESYNC_PEPPER
```

### Deploy Functions & Rules

```bash
firebase deploy --only functions,firestore:rules
```

Verify:
- Cloud Functions console shows the three callables: `registerWithUsernameSecure`, `signInWithUsernameSecure`, `syncServerPasswordCredential`
- Each has `enforceAppCheck: true` in the function metadata
- Firestore rules protect `security_rate_limits/*` and `users/{uid}/auth_private/*`

## 5. Integration Testing

Run the integration tests to verify the setup:

```bash
# On Android emulator
flutter test integration_test/auth_test.dart --target integration_test/auth_test.dart -d emulator-5554

# On iOS simulator
flutter test integration_test/auth_test.dart --target integration_test/auth_test.dart -d <sim-id>
```

Expected behavior:
- Firebase initializes successfully
- App Check tokens are retrieved (or logged as empty in test/debug)
- Callable functions are reachable
- Rate limiting and Firestore rules are confirmed

## 6. Production Checklist

- [ ] Android: Play Integrity enabled in Firebase Console
- [ ] iOS: App Attest enabled in Firebase Console
- [ ] Web: reCAPTCHA v3 site key configured
- [ ] Pepper secret set: `firebase functions:secrets:set STYLESYNC_PEPPER`
- [ ] Functions deployed with `enforceAppCheck: true`
- [ ] Firestore rules deployed (protect rate-limit and auth-private docs)
- [ ] Crashlytics wired in both Android (Gradle plugin) and iOS (Run Script)
- [ ] Integration tests pass
- [ ] Release builds tested on physical devices (not emulators)

## 7. Monitoring & Troubleshooting

### Firebase Console

- **App Check** tab: Verify token rates and provider health
- **Crashlytics** tab: Monitor error trends and new issues
- **Cloud Functions** tab: Check invocation logs for rate-limit errors

### Local Debugging

- **Android**: `flutter run --profile` with logcat filtering
  ```bash
  adb logcat | grep -i "app.check\|Crashlytics"
  ```
- **iOS**: Run in Xcode debugger or check Console.app for crash reports

### Common Issues

1. **App Check token 403**: Debug token not registered; add it in Firebase Console
2. **Crashlytics not collecting**: Ensure `FIREBASE_ANALYTICS_COLLECTION_ENABLED=1` is set and using release build
3. **Function rate-limit errors**: Verify `security_rate_limits` collection exists and rate hashing is working

## References

- [Firebase App Check Docs](https://firebase.google.com/docs/app-check)
- [Firebase Crashlytics Docs](https://firebase.google.com/docs/crashlytics)
- [Cloud Functions Callable with App Check](https://firebase.google.com/docs/functions/callable)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
