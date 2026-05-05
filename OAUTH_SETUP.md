# OAuth Configuration Guide for StyleSync

## 🚨 IMPORTANT: OAuth is currently NOT functional because it needs proper configuration

Your OAuth buttons will show errors until you complete the setup below. This is expected behavior.

## Step 1: Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Enable Authentication and add Google/Facebook sign-in providers
4. Get your Firebase config values

Update `lib/firebase_options.dart` with your actual Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: "your_actual_web_api_key",
  appId: "your_actual_web_app_id",
  messagingSenderId: "your_messaging_sender_id",
  projectId: "your_project_id",
  authDomain: "your_project_id.firebaseapp.com",
  storageBucket: "your_project_id.appspot.com",
  measurementId: "your_measurement_id",
);
```

## Step 2: Google Sign-In Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create/select project
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs for web and mobile

Update `lib/core/oauth_config.dart`:
```dart
static const String googleClientId = 'your_google_client_id';
static const String googleClientSecret = 'your_google_client_secret';
```

Update `web/index.html`:
```html
<script src="https://accounts.google.com/gsi/client" async defer></script>
```

Update `android/app/src/main/res/values/strings.xml`:
```xml
<string name="default_web_client_id">your_google_client_id</string>
```

## Step 3: Facebook Login Setup

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or use existing
3. Add Facebook Login product
4. Configure OAuth redirect URIs
5. Get App ID and Client Token

Update `lib/core/oauth_config.dart`:
```dart
static const String facebookAppId = 'your_facebook_app_id';
static const String facebookClientToken = 'your_facebook_client_token';
```

Update `web/index.html`:
```html
<script>
  window.fbAsyncInit = function() {
    FB.init({
      appId: 'your_facebook_app_id',
      cookie: true,
      xfbml: true,
      version: 'v18.0'
    });
  };
</script>
```

Update `android/app/src/main/res/values/strings.xml`:
```xml
<string name="facebook_app_id">your_facebook_app_id</string>
<string name="facebook_client_token">your_facebook_client_token</string>
```

Update `android/app/build.gradle.kts`:
```kotlin
defaultConfig {
    manifestPlaceholders["facebookAppId"] = "your_facebook_app_id"
    manifestPlaceholders["facebookClientToken"] = "your_facebook_client_token"
}
```

## Step 4: Instagram Setup (Optional)

Instagram uses Facebook's OAuth system. If you want Instagram login:
1. Use the same Facebook App ID and Client Token
2. Enable Instagram Basic Display in Facebook Developer Console
3. Note: Full Instagram integration requires backend implementation

## Step 5: Testing

After configuration:
1. Run `flutter clean && flutter pub get`
2. Test on web: `flutter run -d chrome`
3. Test on Android: `flutter run -d android_device_id`

## Current Status

- ✅ Code structure is ready
- ✅ Error handling implemented
- ✅ Configuration validation added
- ❌ Needs actual OAuth credentials to function
- ❌ Firebase project must be configured

## Troubleshooting

If you see "OAuth not configured" errors:
- Check that you've replaced all placeholder values
- Ensure Firebase Authentication is enabled
- Verify OAuth provider settings in Firebase Console
- Make sure redirect URIs are correctly configured

## Need Help?

The OAuth implementation is now properly structured and will work once you add your actual credentials. Each provider has clear error messages to guide you through setup.