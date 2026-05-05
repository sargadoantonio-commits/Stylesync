# StyleSync Test Account Setup Guide

## Overview
Two secure test accounts have been created and can be set up through the app's test setup screen.

## Test Accounts

### Account 1: Free Customer
- **Email:** roniandave@gmail.com
- **Password:** TestPassword123!@#
- **Name:** Roni Dave
- **Status:** Free (no premium features)
- **Use Case:** Test basic customer flow and app features

### Account 2: Premium Customer
- **Email:** tolentino.roniandave@dnsc.edu.ph
- **Password:** PremiumPass456!@#
- **Name:** Roni Tolentino
- **Status:** Premium (1 year subscription)
- **Use Case:** Test premium features, advanced AR capabilities, priority queue

## Security Features

✅ **Bcrypt Hashing** (Cost: 12)
- Password hashing with server-side salt
- Industry-standard bcrypt algorithm

✅ **Cyber Pepper v1**
- Additional security layer with pepper string
- Applied to all password hashes

✅ **Server-Authoritative Storage**
- Credentials stored securely in auth_private collection
- Firestore security rules prevent client access

✅ **Secure Index**
- Username index for fast lookups
- No sensitive data in publicly readable documents

## How to Set Up

### Step 1: Access Test Setup Screen
1. Open the StyleSync app on your Android phone
2. Go to the landing page
3. Manually navigate to: `localhost:3000/test-setup` (if web) or use deep link
4. Or open Chrome DevTools and navigate to the test setup route

### Step 2: Create Test Accounts
1. On the Test Account Setup screen, tap "Create Test Accounts"
2. The app will:
   - Check for existing accounts
   - Delete old test accounts if they exist
   - Create two new accounts with secure passwords
   - Display a setup log showing all steps

### Step 3: Verify Accounts
Once setup is complete, you can log in with either account:

**Free Account Test Flow:**
```
1. Log in with: roniandave@gmail.com / TestPassword123!@#
2. Complete profile setup
3. Browse services and barbers
4. Test basic booking flow
5. Check notifications and settings
```

**Premium Account Test Flow:**
```
1. Log in with: tolentino.roniandave@dnsc.edu.ph / PremiumPass456!@#
2. Complete profile setup
3. Access premium AR features
4. Get priority queue position
5. Test premium booking benefits
```

## Access via Deep Link

If you have the deep link configured, you can access the setup screen directly:

```bash
# On Android
adb shell am start -W -a android.intent.action.VIEW \
  -d "stylesync://test-setup" com.stylesync.app

# Or navigate in-app
context.go('/test-setup')
```

## Reset Data

To reset and recreate accounts:

1. Open Test Account Setup screen
2. Tap "Create Test Accounts" again
3. The script will automatically:
   - Detect existing accounts
   - Delete old data from Firebase Auth
   - Delete Firestore documents
   - Delete username index entries
   - Create fresh accounts with same credentials

## Features to Test

### With Free Account
- User authentication
- Profile creation
- Service browsing
- Barber discovery
- Basic booking (without premium perks)
- Notifications and messages
- Settings and preferences

### With Premium Account
- All free account features
- Premium AR try-on with enhanced models
- Priority queue positioning
- Advanced booking options
- Premium barber filters
- Priority support access
- Extended session duration

## Troubleshooting

### Issue: "Account already exists"
- Use the test setup screen to reset
- Or manually delete from Firebase Console

### Issue: "Can't create account"
- Check Firebase connection
- Ensure Firebase emulators are running (if development)
- Check Firestore security rules allow user creation

### Issue: "Premium features not showing"
- Ensure `isPremium: true` in user document
- Check `premiumExpiresAt` is in the future
- Refresh app (hot reload or restart)

## Database Structure

### User Document
```
users/{uid}
├── email: string
├── displayName: string
├── role: "customer" | "barber" | "shopOwner"
├── isPremium: boolean
├── premiumExpiresAt: timestamp (if premium)
├── accountStatus: "active"
├── createdAt: timestamp
├── updatedAt: timestamp
└── notifications: object
```

### Username Index
```
username_index/{username}
├── uid: string
├── email: string
└── createdAt: timestamp
```

### Auth Private (Server-side only)
```
users/{uid}/auth_private/credential
├── createdAt: timestamp
├── updatedAt: timestamp
├── method: "email_password"
└── _verified: boolean
```

## Security Notes

⚠️ **Development Only**
- Test setup screen is for development/testing
- Remove or gate-keep before production
- Never ship with test account credentials in code

⚠️ **Passwords**
- Test passwords are for development only
- Do not use in production
- Use strong, unique passwords for real accounts

✅ **Password Hashing**
- All passwords hashed with bcrypt (cost 12)
- Never stored in plain text
- Server-authoritative validation

## Next Steps

After creating test accounts:

1. **Test on Device** - Verify all flows work on real hardware
2. **Firebase Hosting** - Deploy to Firebase for remote testing
3. **Emulator Testing** - Test on Android/iOS emulators
4. **Remote Devices** - Test on multiple real devices
5. **Accessibility** - Verify touch targets and colors
6. **Performance** - Monitor app startup and navigation speed

---

**Last Updated:** April 28, 2026
**Status:** ✅ Ready for Testing
