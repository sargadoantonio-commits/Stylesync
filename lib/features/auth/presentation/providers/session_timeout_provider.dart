import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// Session timeout provider - auto-logout after 30 minutes of inactivity
final sessionTimeoutProvider =
    StateNotifierProvider<SessionTimeoutNotifier, SessionTimeoutState>((ref) {
  return SessionTimeoutNotifier(FirebaseAuth.instance);
});

class SessionTimeoutState {
  final bool showWarning;
  final Duration timeRemaining;

  SessionTimeoutState({
    required this.showWarning,
    required this.timeRemaining,
  });

  SessionTimeoutState copyWith({
    bool? showWarning,
    Duration? timeRemaining,
  }) {
    return SessionTimeoutState(
      showWarning: showWarning ?? this.showWarning,
      timeRemaining: timeRemaining ?? this.timeRemaining,
    );
  }
}

class SessionTimeoutNotifier extends StateNotifier<SessionTimeoutState> {
  SessionTimeoutNotifier(this._auth)
      : super(SessionTimeoutState(
          showWarning: false,
          timeRemaining: const Duration(minutes: 30),
        )) {
    if (_auth.currentUser != null) {
      _startSessionTimer();
    }
  }

  final FirebaseAuth _auth;
  Timer? _sessionTimer;
  Timer? _countdownTimer;
  late Stopwatch _inactivityStopwatch;

  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration warningBefore = Duration(minutes: 29);
  static const Duration countdownInterval = Duration(seconds: 1);

  void _startSessionTimer() {
    _inactivityStopwatch = Stopwatch()..start();
    _resetSessionTimer();
  }

  void _resetSessionTimer() {
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    _inactivityStopwatch.reset();
    _inactivityStopwatch.start();

    state = SessionTimeoutState(
      showWarning: false,
      timeRemaining: sessionTimeout,
    );

    // Warn user after 29 minutes (1 minute before logout)
    _sessionTimer = Timer(warningBefore, () {
      state = state.copyWith(showWarning: true);
      _startCountdown();
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(countdownInterval, (timer) {
      final elapsed = _inactivityStopwatch.elapsed;
      final remaining = sessionTimeout - elapsed;

      if (remaining.isNegative) {
        _logoutUser();
      } else {
        state = state.copyWith(timeRemaining: remaining);
      }
    });
  }

  Future<void> _logoutUser() async {
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    _inactivityStopwatch.stop();

    try {
      await _auth.signOut();
      state = SessionTimeoutState(
        showWarning: false,
        timeRemaining: const Duration(minutes: 30),
      );
    } catch (e) {
      print('Error during session timeout logout: $e');
    }
  }

  /// Call this whenever user interacts with the app
  void resetInactivityTimer() {
    if (_auth.currentUser != null) {
      _resetSessionTimer();
    }
  }

  /// Manually extend session (user clicks "Stay Logged In")
  void extendSession() {
    resetInactivityTimer();
  }

  /// Manually logout
  Future<void> logout() async {
    await _logoutUser();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    _inactivityStopwatch.stop();
    super.dispose();
  }
}
