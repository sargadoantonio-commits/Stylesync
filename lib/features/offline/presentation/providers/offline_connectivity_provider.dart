import 'dart:async';
import 'dart:io' show InternetAddress;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the connectivity state of the app
class ConnectivityState {
  final bool isOnline;
  final String message;

  ConnectivityState({
    required this.isOnline,
    this.message = '',
  });

  factory ConnectivityState.online() {
    return ConnectivityState(isOnline: true, message: 'Connected to internet');
  }

  factory ConnectivityState.offline() {
    return ConnectivityState(isOnline: false, message: 'Offline - Using cached data');
  }
}

/// Monitors network connectivity and provides offline/online state
class OfflineConnectivityNotifier extends StateNotifier<ConnectivityState> {
  late Timer _connectivityCheckTimer;
  bool _wasOnline = true;

  OfflineConnectivityNotifier() : super(ConnectivityState.online()) {
    _initializeConnectivityCheck();
  }

  void _initializeConnectivityCheck() {
    // Check connectivity every 5 seconds
    _connectivityCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkConnectivity(),
    );
    
    // Initial check
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    try {
      // Simple connectivity check by attempting to resolve a DNS name
      final result = await InternetAddress.lookup('8.8.8.8').timeout(
        const Duration(seconds: 3),
      );
      
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (isConnected != _wasOnline) {
        _wasOnline = isConnected;
        state = isConnected
            ? ConnectivityState.online()
            : ConnectivityState.offline();
      }
    } catch (e) {
      // If DNS lookup fails, assume offline
      if (_wasOnline) {
        _wasOnline = false;
        state = ConnectivityState.offline();
      }
    }
  }

  /// Manual check for connectivity
  Future<void> manualConnectivityCheck() async {
    await _checkConnectivity();
  }

  @override
  void dispose() {
    _connectivityCheckTimer.cancel();
    super.dispose();
  }
}

/// Provider for offline connectivity state
final offlineConnectivityProvider =
    StateNotifierProvider<OfflineConnectivityNotifier, ConnectivityState>(
  (ref) => OfflineConnectivityNotifier(),
);

/// Convenience provider to check if app is online
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(offlineConnectivityProvider).isOnline;
});

/// Convenience provider to check if app is offline
final isOfflineProvider = Provider<bool>((ref) {
  return !ref.watch(offlineConnectivityProvider).isOnline;
});
