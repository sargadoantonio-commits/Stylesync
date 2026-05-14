# 🔧 Google Sign-In Api10 Error - Quick Fix Guide

## 🚨 Current Error
```
PlatformException(sign_in_failed, com.google.android.gms.common.api.Api10, null)
```

**What this means:** Google Play Services error code 10 = **DEVELOPER_ERROR**  
**Why it happens:** Configuration mismatch between your app and Firebase Console

---

## ✅ Immediate Actions (Do These Now)

### 1️⃣ Verify SHA-1 Fingerprint

Your debug SHA-1 must be registered in Firebase Console. Get it with:

```bash
cd "E:\Stylesync\android"
./gradlew.bat signingReport
```

**Look for:**
```
Variant: debug
Config: debug
SHA1: b70c44711e263dd9f938ee3d0d0b0e5bc0e1d0ef  ← COPY THIS
```

### 2️⃣ Add to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select **style-sync-84923** project
3. Settings (⚙️) → **Your apps** → Select Android app
4. Scroll to **"SHA certificate fingerprints"**
5. Click **"Add fingerprint"**
6. Paste your SHA1: `b70c44711e263dd9f938ee3d0d0b0e5bc0e1d0ef`
7. **Save**

### 3️⃣ Download Fresh google-services.json

After adding SHA-1:
1. Go to Firebase Console → Android app settings
2. Scroll to **"google-services.json"**
3. Click **"Download google-services.json"**
4. Replace `android/app/google-services.json` with this new file

### 4️⃣ Rebuild App

```bash
cd E:\Stylesync
flutter clean
flutter pub get
flutter run
```

### 5️⃣ Test on Device

- **Uninstall old app** from your phone/emulator
- App reinstalls automatically during `flutter run`
- Tap "Sign in with Google"
- **✅ Should work now!**

---

## 🔍 Verification Checklist

Before testing, verify ALL of these:

- [ ] SHA-1 fingerprint added to Firebase Console
- [ ] Fresh `google-services.json` downloaded and placed at `android/app/google-services.json`
- [ ] App package name is `com.stylesync.app` (check AndroidManifest.xml)
- [ ] Google Play Services enabled in Firebase Authentication
- [ ] Device has Google Play Services installed (or emulator with Google APIs)
- [ ] Internet connection working on test device
- [ ] App rebuilt and reinstalled (not just hot reload)

---

## 🆘 Still Getting Api10 Error?

Try these next steps:

### Step A: Enable Google Sign-In in Firebase
1. Firebase Console → **Authentication** → **Sign-in method**
2. Find **"Google"**
3. If **not enabled**, click it and toggle **Enable**
4. Click **Save**

### Step B: Clear App Cache
```bash
# On device via adb
adb shell pm clear com.stylesync.app

# Then reinstall
flutter run
```

### Step C: Use Android Release Signing Key
If you plan to publish to Google Play, add the **release SHA-1** to Firebase too:

```bash
# Get release SHA-1 (same command as debug)
cd "E:\Stylesync\android"
./gradlew.bat signingReport

# Look for "Variant: release" section
# Copy the SHA1 value
# Add to Firebase Console same as Step 2 above
```

### Step D: Check OAuth Client Configuration
Verify in `lib/core/oauth_config.dart`:

```dart
static const String googleAndroidClientId =
    '669385709309-aholsdvmci52m8gs1a7h947tdqoadkoi.apps.googleusercontent.com';

static const String googleWebClientId =
    '669385709309-ju38fpd1ar5qe5tpobngi9bbkj192ltn.apps.googleusercontent.com';
```

These must match the values in `android/app/google-services.json`:
- `googleAndroidClientId` → `client_id` where `client_type` is 1
- `googleWebClientId` → `client_id` where `client_type` is 3

---

## 🎯 Why This Fixes Api10

| Error | Root Cause | Fix |
|-------|-----------|-----|
| Api10 | SHA-1 not in Firebase | Add SHA-1 → Download google-services.json → Rebuild |
| Api10 | Stale google-services.json | Download fresh file from Firebase |
| Api10 | App not reinstalled | `flutter clean` → `flutter run` |
| Api10 | Wrong package name | Verify `com.stylesync.app` in AndroidManifest.xml |
| Api10 | Play Services not updated | Update Google Play Services on device |

---

## 📊 Code Changes Made

Your `lib/features/auth/data/auth_repository.dart` has been updated:

```dart
// ✅ BEFORE (caused Api10):
googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  serverClientId: OAuthConfig.googleAndroidClientId,  // ❌ Wrong!
  forceCodeForRefreshToken: true,
);

// ✅ AFTER (fixed):
googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // Let Play Services handle auth automatically
);
```

**Why:** Using `serverClientId` with the Android OAuth client ID (client_type 1) causes Play Services to reject the request. Removing it lets Play Services use automatic configuration from `google-services.json`.

---

## 🚀 Quick Command Summary

Run these in order:

```bash
# 1. Get SHA-1
cd "E:\Stylesync\android"
./gradlew.bat signingReport

# 2. Copy SHA1 to Firebase Console (steps above)

# 3. Download fresh google-services.json from Firebase

# 4. Place it here: android/app/google-services.json

# 5. Clean and rebuild
cd E:\Stylesync
flutter clean
flutter pub get

# 6. Run on device
flutter run
```

---

## ✨ Success Indicators

When fixed, you'll see:
- ✅ Google Sign-In dialog appears (no crash)
- ✅ Select your Google account
- ✅ App logs in successfully
- ✅ Redirected to home screen
- ✅ Email appears in profile

---

## 📞 Firebase Console Links

- [Firebase Console](https://console.firebase.google.com/)
- [StyleSync Project](https://console.firebase.google.com/project/style-sync-84923)
- [Android App Settings](https://console.firebase.google.com/project/style-sync-84923/settings/general/android:com.stylesync.app)

---

## 📝 Notes

- **SHA-1 fingerprint** is unique per signing key (debug vs release)
- **google-services.json** must match the SHA-1 you registered
- Always **rebuild** after updating google-services.json
- **Test on device** with internet connection
- This error is **NOT** a code bug—it's a **configuration mismatch**

**If still stuck:** Check Firebase Console for any error messages in the Authentication logs.
