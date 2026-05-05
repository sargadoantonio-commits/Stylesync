/// OAuth configuration for StyleSync social authentication
/// Configure these values in your Firebase Console and respective OAuth provider dashboards
library;

class OAuthConfig {
  // Google Sign-In Configuration
  // Android-specific Google Sign-In client ID (from google-services.json - client_type 1)
  // This is the primary client ID used for Google Sign-In on Android
  static const String googleAndroidClientId =
      '669385709309-aholsdvmci52m8gs1a7h947tdqoadkoi.apps.googleusercontent.com';

  // Web/other OAuth client ID (for web and backend use)
  static const String googleWebClientId =
      '669385709309-ju38fpd1ar5qe5tpobngi9bbkj192ltn.apps.googleusercontent.com';

  // Fallback to Android client ID for general use
  static const String googleClientId = googleAndroidClientId;

  static const String googleClientSecret = '';

  // Validation helpers
  static bool get isGoogleConfigured =>
      googleClientId.isNotEmpty && googleAndroidClientId.isNotEmpty;

  // Error messages
  static const String googleNotConfiguredError =
      'Google Sign-In is not configured. Please set up Google OAuth in Firebase Console.';
}
