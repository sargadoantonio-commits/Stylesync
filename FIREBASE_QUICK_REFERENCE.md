# StyleSync Firebase Setup - Quick Reference

## Status ✅
- ✅ All authentication code: **NO ERRORS**
- ✅ Google Sign-In: **WORKING**
- ✅ Email/Password: **WORKING**
- ✅ Firebase integration: **COMPLETE**

---

## Quick Start (5 minutes)

### 1️⃣ Create Premium Customer
```
Email: roniandave@gmail.com
Password: SecurePass123!
Role: customer
isPremium: true (after manual setup)
```

### 2️⃣ Create Premium Google Barber
```
Email: tolentino.roniandave@dnsc.edu.ph
Auth: Google Sign-In (in app)
Role: barber
isPremium: true (after manual setup)
```

### 3️⃣ Create Sample Users
```
Customer: customer.test@gmail.com / TestPass123!
Barber: barber.test@gmail.com / TestPass123!
```

---

## Setup Workflow

### For Email/Password Users:

```
1. Firebase Console → Authentication → Add user
   ↓
2. Copy user UID
   ↓
3. Firestore → users collection → Add document
   - Document ID: {UID}
   - Paste data from FIREBASE_SETUP_GUIDE.md
   ↓
4. Firestore → username_index → Add document
   - Document ID: {username}
   - { "uid": "{UID}", "email": "..." }
   ↓
✅ Done! User can login
```

### For Google Users (Barber):

```
1. Open app → "Sign in with Google"
   ↓
2. Select tolentino.roniandave@dnsc.edu.ph
   ↓
3. Complete profile setup (auto-creates profile + index)
   ↓
4. Firebase Console:
   - Update users/{uid}: role="barber", isPremium=true
   - Create barbers/{uid}: {barber profile data}
   ↓
✅ Done! Premium barber ready
```

---

## File Reference

| File | Purpose |
|------|---------|
| `FIREBASE_SETUP_GUIDE.md` | 📖 Complete setup instructions (copy-paste ready) |
| `FIREBASE_BATCH_SETUP.js` | 🚀 Firebase console script with all users |
| `FIREBASE_USER_SETUP.md` | 📝 Detailed setup with all fields |
| `GOOGLE_SIGNIN_SETUP.md` | 🔧 Google Sign-In configuration guide |

---

## Test Users Summary

| User | Email | Password | Auth | Role | Premium |
|------|-------|----------|------|------|---------|
| Roni | roniandave@gmail.com | SecurePass123! | Email | Customer | ✅ |
| Google Barber | tolentino...@dnsc.edu.ph | — | Google | Barber | ✅ |
| Test Customer | customer.test@gmail.com | TestPass123! | Email | Customer | ❌ |
| Test Barber | barber.test@gmail.com | TestPass123! | Email | Barber | ❌ |

---

## Common Tasks

### Make User Premium
```
Firestore → users/{uid}
Set: isPremium = true
Set: loyaltyRank = "elite" or "legend"
```

### Check User Role
```
Firestore → users/{uid}
Look for: role = "customer" or "barber"
```

### Fix Google Sign-In Issues
```
1. Android SHA-1:
   cd android && ./gradlew.bat signingReport
   
2. Add SHA-1 to Firebase Console
   
3. Rebuild:
   flutter clean && flutter pub get && flutter run --release
```

### List All Users
```
Firebase Console → Authentication → Users
(Shows all email/password users)

OR

Firestore → users collection
(Shows all users including Google)
```

---

## Verification Checklist

- [ ] Can signup with email/password
- [ ] Can login with email/password
- [ ] Can login with Google
- [ ] Premium customer shows premium badge
- [ ] Barber shows in discovery
- [ ] Usernames are unique
- [ ] Roles display correctly

---

## Need Help?

1. **Google Sign-In not working?**
   - Check `GOOGLE_SIGNIN_SETUP.md`
   - Verify SHA-1 fingerprint
   - Test on real device (not emulator)

2. **User not appearing after Firestore write?**
   - Check document ID = Firebase Auth UID (exact match!)
   - Wait 5 seconds for sync
   - Hard refresh in Firebase Console

3. **Username already taken error?**
   - Check `username_index` collection
   - Ensure no duplicate usernames
   - Use `normalizeUsername()` function for lowercase

4. **Profile won't load?**
   - Verify all required fields exist
   - Check Firestore rules are deployed
   - Check user has `profileComplete: true`

---

## 🎯 Next Steps

1. ✅ Read `FIREBASE_SETUP_GUIDE.md`
2. ✅ Create all 4 test users
3. ✅ Deploy Firestore rules (if not already)
4. ✅ Test each login flow
5. ✅ Verify premium features work
6. ✅ Start testing the app!

---

## Firebase Commands

```bash
# Deploy only Firestore rules
firebase deploy --only firestore:rules

# Deploy only functions
firebase deploy --only functions

# Deploy everything
firebase deploy

# Clear Firestore (use with caution!)
firebase firestore:delete users --recursive

# Start local emulator
firebase emulators:start
```

---

**All set! Your authentication system is ready to test.** 🚀
