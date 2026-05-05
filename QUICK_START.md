# StyleSync - QUICK START TESTING GUIDE

## 🎯 Get Running in 5 Minutes

### Step 1: Prerequisites ✓
- Android device (TNT or similar) connected via USB
- USB debugging enabled on device
- Flutter SDK installed (`flutter doctor` shows all green)

### Step 2: Build & Deploy
```bash
# Navigate to project
cd c:\Users\Nian Dave\Downloads\stylesync

# Get latest dependencies
flutter pub get

# Deploy to device
flutter run --release

# OR build APK manually
flutter build apk --release
# Then: adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Step 3: Test the App Flow

#### 👤 Customer Flow (Fastest Testing)
1. **Landing Page** - See animated background
   - Click "Get Started" → lands on Register
   
2. **Registration** 
   - Email: test@example.com
   - Password: TestPassword123 (with strength meter)
   - Phone: +63912345678
   - Role: Customer
   - Click Register
   
3. **Email Verification (OTP)**
   - 6-digit code entry (auto-focused)
   - Demo: Any 6 digits work (test mode)
   - 10-min countdown timer visible
   
4. **Profile Setup**
   - Pick avatar (photo from device)
   - Enter Display Name & Bio
   - Select Hair Type & Face Shape
   - Submit
   
5. **Customer Dashboard Home**
   - See shop info + live queue
   - 4 Quick Actions grid: Book, Queue, Discover, AR
   - Last booking widget
   
6. **Book a Haircut**
   - Click "Book" → 4-step booking flow
   - Step 1: Choose service (Fade, Crop, etc.)
   - Step 2: Choose barber (Jamie, Noah, Ari)
   - Step 3: Pick date & time
   - Step 4: Confirm booking
   
7. **Booking Confirmation**
   - See gold reference code (SS-12345)
   - "Track Your Queue" button → Queue Tracker
   
8. **Queue Tracker**
   - Big gold position number (#7)
   - Estimated wait time
   - Live updates (demo updates every 5s)

---

#### 💼 Barber Flow (More Complex)
1. **Landing Page** → Register as Barber
   - Select Role: "Barber"
   
2. **Barber ID Upload**
   - Full Name: Johnny Barbero
   - License #: BLic2024-001
   - Shop: StyleSync Default
   - Upload photo (required)
   - Submit
   
3. **Pending Screen**
   - Shows "Application under review"
   - 3-step progress animation
   - Application ID displayed
   - Demo: "Contact Support" button works
   
4. **[After Approval]** Barber Dashboard
   - Queue display (real-time)
   - "Call Next" button (triggers animation)
   - Current customer details
   - Confirmations list
   
5. **Barber Earnings**
   - Gold hero card: Today's earnings
   - ₱2,850 (sample data)
   - Services breakdown
   - Recent completions
   - vs. Yesterday comparison

---

## 🧪 Feature Checklist

### ✅ Working Now
- [x] Landing page with animations (3 orbs, grid, stagger)
- [x] User registration (email, password strength meter, role selection)
- [x] OTP verification (6-digit input, countdown, resend)
- [x] Profile setup (avatar picker, form)
- [x] Customer dashboard (real-time queue, quick actions)
- [x] Booking flow (4-step wizard with date/time pickers)
- [x] Booking confirmation (gold reference code, elastic animations)
- [x] Queue tracker (live position, wait time)
- [x] Barber registration (ID upload with photo)
- [x] Barber pending (status animations, application ID)
- [x] Barber dashboard (queue management)
- [x] Barber earnings (revenue display, breakdown)
- [x] Settings (user profile, toggle notifications)
- [x] Support (contact button, FAQ)
- [x] Style library (filters, try-on buttons)
- [x] Navigation (all routes working)

### 🔄 Partially Working (UI Done, Backend Pending)
- [x] AR Camera (UI complete, ML Kit face detection pending)
- [x] Notifications (settings UI done, Firebase topic setup pending)

### ⏳ Not Yet Implemented
- [ ] ML Kit face detection (requires activation)
- [ ] AR hair overlay rendering (custom painter)
- [ ] Firestore real-time sync (backend config needed)
- [ ] Firebase Authentication integration (backend connection)
- [ ] Cloud Functions for barber approval
- [ ] Profile XP/Level system

---

## 🎨 Visual Testing Checklist

### Colors (Cyber-Mint Theme)
- [x] Magenta buttons (#D946A6) - all CTAs
- [x] Teal accents (#00F5D4) - status badges
- [x] Gold elements (#FFD700) - queue position, earnings
- [x] Dark background (#0A1214) - pages
- [x] Glass cards - 60% opacity + blur effect

### Animations (Should see smooth 60fps)
- [x] Landing page: 3 orbs moving in circles (8s loop)
- [x] Landing page: Staggered content entry (5 animations, 150ms apart)
- [x] Barber pending: Rotating schedule icon (3s)
- [x] Barber pending: Pulsing status icon (2s)
- [x] Booking confirmed: Elastic checkmark (700ms)
- [x] Queue tracker: Smooth number transitions

### Responsive Layout
- [x] Proper padding on all screens (24px sides)
- [x] Content centered on larger screens
- [x] Bottom sheet for modals
- [x] AppBar with proper spacing

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| App won't start | `flutter clean && flutter pub get` |
| Camera crashes | Grant CAMERA permission in system settings |
| Animations lag | Device performance issue; try `--profile` build |
| Colors look wrong | Restart app, check if display is in dark mode |
| Text fuzzy | Try `--release` build for better rendering |
| Routes not found | Check router in app_router.dart, ensure screen imported |

---

## 📊 Performance Targets

- **Launch time**: < 3 seconds
- **Page load**: < 500ms
- **Animation frame rate**: 60 fps
- **Bundle size**: ~50-60 MB (APK)

---

## 🎓 Code Structure Overview

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── router/                  # GoRouter setup
│   ├── theme/                   # Colors, typography, helpers
│   └── formatters/              # Date/money formatting
├── features/
│   ├── auth/                    # Authentication (Riverpod providers)
│   ├── queue/                   # Queue system
│   └── services/                # Service management
├── screens/                     # 20+ screen implementations
│   ├── landing_screen.dart
│   ├── barber/                  # Barber-specific screens
│   ├── customer/                # Customer-specific screens
│   └── ... (14 total screens)
└── widgets/                     # Reusable components
```

---

## 📞 Next Steps After Testing

1. **If all works**: 
   - Continue to Day 4 (AR camera with ML Kit)
   - Implement XP/Level system (Day 5)
   - Connect to real Firebase

2. **If issues found**:
   - Check error message in logcat: `flutter logs`
   - Verify Android minimum SDK version (21+)
   - Clear app data and rebuild

3. **For Firebase integration**:
   - Set up Firestore security rules
   - Create sample data (shops, barbers, services)
   - Configure Cloud Functions
   - Test auth flow with real backend

---

## 🚀 Production Checklist

- [ ] All screens tested on real device
- [ ] Performance profiled (release build)
- [ ] Error handling added (try/catch on network calls)
- [ ] Offline mode considered
- [ ] Analytics events logged
- [ ] Crash reporting enabled
- [ ] Security review (API keys, secrets)
- [ ] Localization considered
- [ ] Accessibility reviewed (contrast, touch targets)
- [ ] Play Store release preparation

---

**Start Testing Now!**  
Run: `flutter run --release -d <device_id>`

Expected result: Full app running with smooth animations and navigation between all 14 completed screens. 🎉
