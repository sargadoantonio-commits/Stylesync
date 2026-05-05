# StyleSync Firebase Users - Quick Setup Guide

## 📋 What You Need to Do

### Step 1: Create Email/Password Users in Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com)
2. Select StyleSync project
3. Go to **Authentication** → **Users** tab
4. Click **"Add user"** and create these users:

| Email | Password | Purpose |
|-------|----------|---------|
| `roniandave@gmail.com` | `SecurePass123!` | Premium Customer |
| `customer.test@gmail.com` | `TestPass123!` | Test Customer |
| `barber.test@gmail.com` | `TestPass123!` | Test Barber |

### Step 2: Create Firestore Profiles

Use the script in `FIREBASE_BATCH_SETUP.js` to quickly create all profiles.

**OR** manually create each:

1. Go to **Firestore** → **Data**
2. Go to `users` collection
3. Click **"Create document"**
4. Use **Custom ID** = user's UID from Firebase Auth
5. Paste the data from the script below

---

## 🚀 Google Sign-In Premium Barber Setup

**Important:** Google users auto-create profiles on first login.

### Steps:

1. **Open StyleSync app**
2. **Tap "Sign in with Google"**
3. **Select: `tolentino.roniandave@dnsc.edu.ph`**
4. **Complete profile setup** (enter username: `barber_tolentino`)
5. **App auto-creates:**
   - ✅ Firebase Auth user
   - ✅ Firestore user document
   - ✅ Username index

6. **Then in Firebase Console**, upgrade to Premium:
   - Go to `users` collection
   - Find the Google user document
   - Update: `isPremium: true`, `loyaltyRank: "legend"`, `role: "barber"`
   - Create `barbers/{uid}` document (see script below)

---

## 📝 Copy-Paste Ready Data

### User 1: Premium Customer (Email/Password)

**Firebase Auth:**
- Email: `roniandave@gmail.com`
- Password: `SecurePass123!`

**Firestore (`users/{uid}`):**
```json
{
  "username": "roniandave",
  "displayName": "Roni Dave",
  "email": "roniandave@gmail.com",
  "role": "customer",
  "isPremium": true,
  "photoUrl": "",
  "phoneNumber": "",
  "providerIds": ["password"],
  "xp": 500,
  "loyaltyRank": "elite",
  "profileComplete": true,
  "hairProfile": {
    "type": "straight",
    "density": "medium",
    "scalpSensitivity": "medium"
  },
  "createdAt": "(server timestamp)",
  "updatedAt": "(server timestamp)",
  "lastLoginAt": "(server timestamp)"
}
```

**Username Index (`username_index/roniandave`):**
```json
{
  "uid": "(UID from Firebase Auth)",
  "email": "roniandave@gmail.com"
}
```

---

### User 2: Test Customer (Email/Password)

**Firebase Auth:**
- Email: `customer.test@gmail.com`
- Password: `TestPass123!`

**Firestore (`users/{uid}`):**
```json
{
  "username": "customer_john",
  "displayName": "John Customer",
  "email": "customer.test@gmail.com",
  "role": "customer",
  "isPremium": false,
  "photoUrl": "",
  "phoneNumber": "",
  "providerIds": ["password"],
  "xp": 100,
  "loyaltyRank": "rookie",
  "profileComplete": true,
  "hairProfile": {
    "type": "wavy",
    "density": "medium",
    "scalpSensitivity": "low"
  },
  "createdAt": "(server timestamp)",
  "updatedAt": "(server timestamp)",
  "lastLoginAt": "(server timestamp)"
}
```

**Username Index (`username_index/customer_john`):**
```json
{
  "uid": "(UID from Firebase Auth)",
  "email": "customer.test@gmail.com"
}
```

---

### User 3: Test Barber (Email/Password)

**Firebase Auth:**
- Email: `barber.test@gmail.com`
- Password: `TestPass123!`

**Firestore (`users/{uid}`):**
```json
{
  "username": "barber_johnny",
  "displayName": "Johnny Barber",
  "email": "barber.test@gmail.com",
  "role": "barber",
  "isPremium": false,
  "photoUrl": "",
  "phoneNumber": "+639111111111",
  "providerIds": ["password"],
  "xp": 300,
  "loyaltyRank": "regular",
  "profileComplete": true,
  "hairProfile": {
    "type": "straight",
    "density": "medium",
    "scalpSensitivity": "medium"
  },
  "createdAt": "(server timestamp)",
  "updatedAt": "(server timestamp)",
  "lastLoginAt": "(server timestamp)"
}
```

**Firestore (`barbers/{uid}`):**
```json
{
  "username": "barber_johnny",
  "displayName": "Johnny Barber",
  "email": "barber.test@gmail.com",
  "phoneNumber": "+639111111111",
  "isPremium": false,
  "verificationStatus": "pending",
  "rating": 4.2,
  "totalRatings": 45,
  "yearsExperience": 3,
  "specializations": ["fade", "buzz"],
  "location": {
    "address": "456 Haircut Ave, Quezon City",
    "city": "Quezon City",
    "province": "NCR",
    "coordinates": {
      "latitude": 14.6349,
      "longitude": 121.0388
    }
  },
  "availability": {
    "monday": {"start": "10:00", "end": "19:00"},
    "tuesday": {"start": "10:00", "end": "19:00"},
    "wednesday": {"start": "10:00", "end": "19:00"},
    "thursday": {"start": "10:00", "end": "19:00"},
    "friday": {"start": "10:00", "end": "21:00"},
    "saturday": {"start": "09:00", "end": "17:00"},
    "sunday": {"start": "closed", "end": "closed"}
  },
  "createdAt": "(server timestamp)",
  "updatedAt": "(server timestamp)"
}
```

**Username Index (`username_index/barber_johnny`):**
```json
{
  "uid": "(UID from Firebase Auth)",
  "email": "barber.test@gmail.com"
}
```

---

### User 4: Premium Barber (Google Sign-In)

**Important:** This user logs in via Google first, then you manually upgrade in Firebase.

**Step 1 - Login in app:**
- Tap "Sign in with Google"
- Select: `tolentino.roniandave@dnsc.edu.ph`
- Complete profile setup
- Get UID from Firebase Console

**Step 2 - Update Firestore (`users/{uid}`):**
```json
{
  "username": "barber_tolentino",
  "displayName": "Tolentino Barber",
  "email": "tolentino.roniandave@dnsc.edu.ph",
  "role": "barber",
  "isPremium": true,
  "phoneNumber": "+639123456789",
  "providerIds": ["google.com"],
  "xp": 1000,
  "loyaltyRank": "legend",
  "profileComplete": true,
  "hairProfile": {
    "type": "straight",
    "density": "medium",
    "scalpSensitivity": "medium"
  },
  "createdAt": "(server timestamp)",
  "updatedAt": "(server timestamp)",
  "lastLoginAt": "(server timestamp)"
}
```

**Step 3 - Create Firestore (`barbers/{uid}`):**
```json
{
  "username": "barber_tolentino",
  "displayName": "Tolentino Barber",
  "email": "tolentino.roniandave@dnsc.edu.ph",
  "phoneNumber": "+639123456789",
  "isPremium": true,
  "verificationStatus": "approved",
  "rating": 4.8,
  "totalRatings": 250,
  "yearsExperience": 8,
  "specializations": ["fade", "undercut", "design"],
  "location": {
    "address": "123 Barbershop St, Metro Manila",
    "city": "Manila",
    "province": "NCR",
    "coordinates": {
      "latitude": 14.5995,
      "longitude": 120.9842
    }
  },
  "availability": {
    "monday": {"start": "09:00", "end": "20:00"},
    "tuesday": {"start": "09:00", "end": "20:00"},
    "wednesday": {"start": "09:00", "end": "20:00"},
    "thursday": {"start": "09:00", "end": "20:00"},
    "friday": {"start": "09:00", "end": "20:00"},
    "saturday": {"start": "09:00", "end": "18:00"},
    "sunday": {"start": "10:00", "end": "18:00"}
  },
  "createdAt": "(server timestamp)",
  "updatedAt": "(server timestamp)"
}
```

**Step 4 - Create Username Index (`username_index/barber_tolentino`):**
```json
{
  "uid": "(UID from Google login)",
  "email": "tolentino.roniandave@dnsc.edu.ph"
}
```

---

## ✅ Verification Checklist

After setup, test each user:

- [ ] **roniandave@gmail.com** 
  - ✅ Can login with email/password
  - ✅ Shows as Premium
  - ✅ Role is "customer"
  - ✅ Loyalty rank is "elite"

- [ ] **customer.test@gmail.com**
  - ✅ Can login with email/password
  - ✅ Shows as regular (not premium)
  - ✅ Role is "customer"

- [ ] **barber.test@gmail.com**
  - ✅ Can login with email/password
  - ✅ Role is "barber"
  - ✅ Appears in barber discovery
  - ✅ Verification status shows

- [ ] **tolentino.roniandave@dnsc.edu.ph**
  - ✅ Can login with Google
  - ✅ Shows as Premium
  - ✅ Role is "barber"
  - ✅ Shows approved verification status
  - ✅ Appears in premium barber list

---

## 🔧 If Google Sign-In Has Issues

Check these in order:

1. **SHA-1 Fingerprint:**
   ```bash
   cd c:\Users\Nian Dave\Downloads\stylesync\android
   ./gradlew.bat signingReport
   ```
   - Copy SHA1 value
   - Go to Firebase Console → Settings → Add SHA-1

2. **Google Provider Enabled:**
   - Firebase Console → Authentication → Sign-in method
   - ✅ Check Google is enabled

3. **Clear Cache & Rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run --release
   ```

4. **Test on Real Device:**
   - Don't use emulator for Google Sign-In
   - Use real Android phone with Google Play Services

---

## 📱 Login Test Sequence

1. **Test Email/Password First:**
   ```
   Login as roniandave@gmail.com → SecurePass123!
   Should go directly to home
   ```

2. **Test Google Sign-In:**
   ```
   Logout
   Tap "Sign in with Google"
   Select tolentino.roniandave@dnsc.edu.ph
   Should show profile setup if first time
   ```

3. **Test Multiple Users:**
   ```
   Logout
   Login as customer.test@gmail.com
   Verify customer interface shows
   ```

4. **Verify Premium Features:**
   ```
   Login as roniandave@gmail.com
   Go to home
   Check queue display → Should say "Premium priority"
   ```

---

## 🎯 Summary

| User | Email | Auth Type | Role | Premium |
|------|-------|-----------|------|---------|
| Roni | roniandave@gmail.com | Email/Pass | Customer | ✅ Yes |
| John | customer.test@gmail.com | Email/Pass | Customer | ❌ No |
| Johnny | barber.test@gmail.com | Email/Pass | Barber | ❌ No |
| Tolentino | tolentino.roniandave@dnsc.edu.ph | Google | Barber | ✅ Yes |

All setup! You're ready to test 🚀
