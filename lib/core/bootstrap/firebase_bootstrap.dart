import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_app_check/firebase_app_check.dart";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";

import "package:stylesync/firebase_options.dart";

/// Production-style Firebase boot: App Check (abuse resistance) + Crashlytics (stability signal).
///
/// **App Check**
/// - Android / iOS: Play Integrity / App Attest in release; debug providers in debug/profile.
/// - Web: set `--dart-define=FIREBASE_APP_CHECK_SITE_KEY=<reCAPTCHA v3 site key>` from the Firebase
///   console (App Check → Web), or auth callables with `enforceAppCheck: true` will reject requests.
Future<void> bootstrapFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Enable Firestore offline persistence for offline mode support
  try {
    // Settings for offline persistence must be set before any database operations
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    debugPrint('[StyleSync] Offline persistence enabled with unlimited cache');
  } catch (e) {
    debugPrint('[StyleSync] Error enabling offline persistence: $e');
  }

  // Connect to emulators in debug mode ONLY if they're available
  // Skip emulator connections in profile/release modes
  if (kDebugMode) {
    try {
      // DISABLED - Using real Firebase project for now
      // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
      // debugPrint("[StyleSync] Connected to Firebase emulators");
      debugPrint("[StyleSync] Using production Firebase");
    } catch (e) {
      debugPrint("[StyleSync] Firebase emulators not available (connecting to production): $e");
      // If emulators aren't running, it will just use production Firebase
    }
  }

  await _activateAppCheck();
  await _activateCrashlytics();
}

Future<void> _activateAppCheck() async {
  try {
    if (kIsWeb) {
      const webKey = String.fromEnvironment("FIREBASE_APP_CHECK_SITE_KEY");
      if (webKey.isEmpty) {
        debugPrint(
          "[StyleSync] Web App Check: set --dart-define=FIREBASE_APP_CHECK_SITE_KEY=... "
          "(Firebase Console → App Check → reCAPTCHA v3) so Cloud Functions can enforce tokens.",
        );
        return;
      }
      await FirebaseAppCheck.instance.activate(webProvider: ReCaptchaV3Provider(webKey));
      return;
    }

    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
  } catch (e, st) {
    debugPrint("[StyleSync] App Check activation failed (non-fatal): $e\n$st");
  }
}

Future<void> _activateCrashlytics() async {
  if (kIsWeb || kDebugMode) {
    debugPrint('[StyleSync] Crashlytics disabled in debug mode or web.');
    return;
  }

  try {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  } catch (e, st) {
    debugPrint('[StyleSync] Crashlytics initialization failed: $e\n$st');
    return;
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    unawaited(
      FirebaseCrashlytics.instance.recordError(
        details.exception,
        details.stack ?? StackTrace.current,
        fatal: true,
      ).catchError((error) {
        debugPrint('[StyleSync] Crashlytics recordError failed: $error');
      }),
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    unawaited(
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true).catchError((e) {
        debugPrint('[StyleSync] Crashlytics recordError failed: $e');
      }),
    );
    return true;
  };
}
