# 🎯 StyleSync Admin Account Setup Guide

## Overview
You now have a **complete admin monitoring system** that uses the Barber role but displays a comprehensive admin dashboard.

---

## ✨ What's New: Admin Monitoring Dashboard

The admin account can monitor:
- 📊 **Real-time Analytics**
  - Total bookings count
  - Active barbers
  - Total customers
  - Active shops

- 📅 **Recent Bookings**
  - Customer names and barber assignments
  - Booking status (pending, confirmed, completed, cancelled)
  - Latest 5 bookings

- ⭐ **Top Barbers**
  - Ranking by rating
  - Star ratings (/5)
  - Number of completed jobs
  - Top 5 performers

- 🏪 **Shop Performance**
  - Shop names and staff count
  - Total revenue per shop
  - Number of completed jobs
  - Performance ranking

---

## 🚀 Setup Instructions

### Step 1: Your Test Accounts (Already Created ✅)

| Email | Password | Role |
|-------|----------|------|
| roniandave@gmail.com | RegularCustomer123!@# | Regular Customer |
| tolentino.roniandave@dnsc.edu.ph | PremiumCustomer456!@# | Premium Customer |
| **sargado.antonioe@dnsc.edu.ph** | **BarberStylist789!@#** | **Admin (via Barber Role)** |
| rato.frankjay@dnsc.edu.ph | ShopOwner000!@# | Shop Owner |

### Step 2: Mark Admin Account (Manual Option - Easiest)

**Option A: Via Firebase Console (Recommended)**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select **style-sync-84923** project
3. Go to **Firestore Database**
4. Navigate to Collection → `users`
5. Find the document with email `sargado.antonioe@dnsc.edu.ph`
6. Click the document to open it
7. Click **Add field**
   - Field: `isAdmin`
   - Type: `Boolean`
   - Value: `true`
8. Click **Save**

**Option B: Via Script (Automated)**

```bash
# Make sure you have firebase-admin SDK installed
npm install firebase-admin

# Then run:
node set-admin-flag.js
```

Or use the web API version (no dependencies):
```bash
node set-admin-flag-web.js
```

---

## 🎮 Testing the Admin Dashboard

1. **Start the app:**
   ```bash
   flutter run
   ```

2. **Login with admin account:**
   - Email: `sargado.antonioe@dnsc.edu.ph`
   - Password: `BarberStylist789!@#`

3. **You should see:**
   - 📊 Admin Monitoring Dashboard (instead of regular barber dashboard)
   - All metrics and stats
   - Real-time data streams

---

## 📚 Architecture

### How It Works:

```
Admin Login
    ↓
Barber Role + isAdmin: true
    ↓
Router checks: if (barber && isAdmin)
    ↓
Shows AdminMonitoringDashboard
    ↓
Displays platform-wide analytics
```

### Updated Files:

1. **User Model** (`lib/features/auth/domain/user_model.dart`)
   - Added `isAdmin` field
   - Updated `fromMap()` and `toMap()` methods

2. **Admin Dashboard** (`lib/screens/admin/admin_monitoring_dashboard.dart`)
   - Real-time booking monitoring
   - Barber performance tracking
   - Shop analytics
   - Revenue tracking

3. **Router** (`lib/core/router/app_router.dart`)
   - Updated to check `isAdmin` flag
   - Routes to appropriate dashboard

---

## 🔐 Account Roles & Capabilities

### 👥 Regular Customer
- Browse barbers
- Book haircuts
- View bookings
- Rate barbers

### ⭐ Premium Customer
- Same as regular +
- VIP booking priority
- Loyalty rewards
- Special discounts

### ✂️ Barber (with Admin)
- **Regular Barber:** Accept bookings, manage schedule
- **Admin Barber:** Monitor entire platform
  - See all bookings
  - View all barbers
  - Track performance
  - View revenue
  - Monitor shops

### 👔 Shop Owner
- Manage staff
- View analytics
- Configure settings
- Manage inventory

---

## 💡 Tips

1. **Default password:** All accounts follow pattern `[Role]...!@#`
2. **Real-time updates:** Dashboard uses Firestore streams for live data
3. **No email verification:** Test accounts skip verification
4. **Complete profiles:** Run the app at least once to create profiles

---

## ❓ Troubleshooting

**Admin dashboard not showing?**
- ✅ Check that `isAdmin: true` is set in Firestore
- ✅ Log out and back in to refresh
- ✅ Check that you're logged in as `sargado.antonioe@dnsc.edu.ph`

**Metrics showing 0?**
- This is normal if you haven't created any bookings yet
- The dashboard will update in real-time as you create bookings

**Can't login as admin?**
- ✅ Make sure account exists: `node setup-stylesync-accounts.js`
- ✅ Use correct password: `BarberStylist789!@#`
- ✅ Check email spelling exactly

---

## 🎯 Next Steps

1. **Setup admin account** (via Firebase Console or script)
2. **Test with regular customer** - Create some bookings
3. **Login as admin** - See monitoring dashboard
4. **Test with barber** - Accept bookings
5. **Test with shop owner** - View shop analytics

---

## 📱 Quick Login Reference

**Start the app and use these credentials:**

```
ADMIN LOGIN (Platform Monitor)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Email:    sargado.antonioe@dnsc.edu.ph
Password: BarberStylist789!@#

CUSTOMER LOGIN (Booking)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Email:    roniandave@gmail.com
Password: RegularCustomer123!@#

SHOP OWNER LOGIN (Management)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Email:    rato.frankjay@dnsc.edu.ph
Password: ShopOwner000!@#
```

---

**Questions? Check the QA_TESTING_CHECKLIST.md for more testing scenarios!**
