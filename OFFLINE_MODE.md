# Offline Mode - StyleSync

## Overview

StyleSync now supports **offline mode** for testing and enhanced user experience. The app can operate without internet connectivity and automatically sync data when back online.

## Features

### ✅ What Works Offline

1. **View Cached Data**
   - Browse previously loaded barbers
   - View shop information
   - Access bookings and history

2. **Local Caching**
   - Automatic Firestore offline persistence
   - Cache size: Unlimited (configurable)
   - All read operations use cache when offline

3. **Offline Indicators**
   - Red "Offline" badge at top-right
   - Bottom banner showing sync status
   - Real-time online/offline detection

4. **Operation Queuing**
   - Failed operations queued for sync
   - Auto-syncs when connectivity restored
   - Prevents data loss

### ⚠️ Limited Functionality Offline

- **Authentication**: Cannot login offline (requires Firebase Auth)
- **New Bookings**: Cannot create bookings (requires Cloud Functions)
- **Payments**: Cannot process payments (requires Stripe)
- **Real-time Updates**: Limited to cached data

## Testing Offline Mode

### Method 1: Airplane Mode
1. Open Settings on Android phone
2. Enable Airplane Mode
3. App will detect offline status

### Method 2: Disable WiFi & Mobile Data
1. Settings → Network → WiFi (off)
2. Settings → Network → Mobile Data (off)
3. App will work with cached data

### Method 3: Developer Mode (Recommended)
If you want to test without losing network:
- Modify `offline_connectivity_provider.dart`
- Change DNS check from `8.8.8.8` to a local test method
- Force offline state manually

## How It Works

### 1. Firestore Offline Persistence

Enabled in `firebase_bootstrap.dart`:
```dart
await FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### 2. Connectivity Detection

Checks network every 5 seconds:
```dart
// In offline_connectivity_provider.dart
InternetAddress.lookup('8.8.8.8').timeout(Duration(seconds: 3))
```

### 3. Offline UI Indicators

Three widgets available:
- `OfflineIndicatorWidget`: Top-right badge
- `OfflineBottomBanner`: Bottom status banner  
- `OfflineStatusMini`: Compact status chip

### 4. Sync Queue

Tracks pending operations:
- Stored in `offlineSyncQueueProvider`
- Auto-syncs when online
- Prevents duplicate submissions

## Implementation in Screens

To add offline indicator to a screen:

```dart
import 'package:stylesync/features/offline/presentation/widgets/offline_indicator_widget.dart';

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Your screen content
        Scaffold(
          body: MyContent(),
        ),
        // Add offline indicator
        const OfflineIndicatorWidget(),
      ],
    );
  }
}
```

## Adding to Root Navigation

Best practice: Add to main app router:

```dart
// In app_router.dart or main navigation
Stack(
  children: [
    Navigator(), // or router
    const OfflineBottomBanner(),
  ],
)
```

## Testing Checklist

- [ ] Turn off WiFi → See "Offline" badge
- [ ] Browse cached barbers → Data displays
- [ ] Try to book → Error message shown gracefully
- [ ] Turn WiFi back on → "Online" status appears
- [ ] Check pending operations sync
- [ ] Verify no data loss occurred

## Cache Performance

- **Cache Size**: Unlimited (can be changed in Settings)
- **Read Speed**: Fast (local disk)
- **Write Speed**: Queued when offline
- **Battery Impact**: Minimal (periodic 5-sec check)

## Troubleshooting

### Offline indicator always shows "Offline"

1. Check internet connectivity on phone
2. Verify WiFi/mobile data is enabled
3. Restart the app
4. Check DNS settings

### Data not syncing after going online

1. Check Firestore rules permit updates
2. Verify pending items in sync queue
3. Check Cloud Firestore logs
4. Manually trigger sync check

### Cache getting too large

Modify in `firebase_bootstrap.dart`:
```dart
cacheSizeBytes: 100 * 1024 * 1024, // 100 MB instead of unlimited
```

## Future Enhancements

- [ ] SQLite for larger local storage
- [ ] Background sync with WorkManager
- [ ] Conflict resolution for concurrent edits
- [ ] Biometric auth for offline access
- [ ] Progressive sync prioritization
- [ ] Custom sync error handling

## File Structure

```
lib/features/offline/
├── domain/
│   └── offline_sync_queue.dart          # Sync queue logic
├── presentation/
│   ├── providers/
│   │   └── offline_connectivity_provider.dart  # Connectivity state
│   └── widgets/
│       └── offline_indicator_widget.dart       # UI indicators
```

## Provider Documentation

### `offlineConnectivityProvider`
- Type: `StateNotifierProvider<OfflineConnectivityNotifier, ConnectivityState>`
- Returns: Current online/offline state
- Usage: `ref.watch(offlineConnectivityProvider)`

### `isOnlineProvider`
- Type: `Provider<bool>`
- Returns: `true` if online, `false` if offline
- Usage: `ref.watch(isOnlineProvider)`

### `isOfflineProvider`
- Type: `Provider<bool>`
- Returns: `true` if offline, `false` if online
- Usage: `ref.watch(isOfflineProvider)`

### `offlineSyncQueueProvider`
- Type: `StateNotifierProvider<OfflineSyncQueueNotifier, List<OfflineSyncQueueItem>>`
- Returns: List of queued operations
- Usage: `ref.watch(offlineSyncQueueProvider)`

### `pendingOfflineItemsProvider`
- Type: `Provider<int>`
- Returns: Count of pending sync items
- Usage: `ref.watch(pendingOfflineItemsProvider)`

## Android Manifest Requirements

Already configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## Testing Offline Mode

### Quick Test Steps

1. **Enable offline mode:**
   - Airplane Mode (quickest)
   - Or disable WiFi + mobile data

2. **Observe behavior:**
   - Red "Offline" indicator appears
   - Existing bookings/data visible
   - New operations show error

3. **Test reconnect:**
   - Re-enable connectivity
   - App returns to "Online" mode
   - Pending operations synced

## Support

For offline mode issues:
1. Check connectivity status
2. Review sync queue for pending items
3. Check Firestore offline cache
4. Review error logs in Logcat
