import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track if admin monitoring view is unlocked in this session
final adminUnlockedProvider = StateProvider<bool>((ref) {
  return false; // Start as locked
});
