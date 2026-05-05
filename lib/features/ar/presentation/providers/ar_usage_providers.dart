import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ar_usage_repository.dart';
import '../../domain/ar_usage_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// AR Usage Repository Provider
final arUsageRepositoryProvider = Provider((ref) {
  return ArUsageRepository(firestore: FirebaseFirestore.instance);
});

// Watch current user's AR usage
final arUsageProvider = StreamProvider<ArUsageDoc?>((ref) async* {
  final auth = ref.watch(authStateProvider);
  final repository = ref.watch(arUsageRepositoryProvider);

  if (auth.isLoading) {
    yield null;
    return;
  }

  final user = auth.valueOrNull;
  if (user == null) {
    yield null;
    return;
  }

  yield* repository.watchUsage(user.uid);
});

// Get remaining AR attempts
final arRemainingProvider = Provider<int>((ref) {
  final usageAsync = ref.watch(arUsageProvider);

  return usageAsync.when(
    loading: () => 3, // Default for loading
    error: (_, __) => 3, // Default on error
    data: (usage) {
      if (usage == null) return 3;

      final now = DateTime.now();
      final monthsApart = (now.year - usage.lastResetDate.year) * 12 +
          (now.month - usage.lastResetDate.month);

      // If month has changed, reset
      if (monthsApart > 0) {
        return 3;
      }

      return usage.getRemaining();
    },
  );
});

// Check if user has reached limit
final arLimitReachedProvider = Provider<bool>((ref) {
  final usageAsync = ref.watch(arUsageProvider);

  return usageAsync.when(
    loading: () => false,
    error: (_, __) => false,
    data: (usage) {
      if (usage == null) return false;
      return usage.isLimitExceeded();
    },
  );
});

// Get usage percentage (0.0 to 1.0)
final arUsagePercentageProvider = Provider<double>((ref) {
  final usageAsync = ref.watch(arUsageProvider);

  return usageAsync.when(
    loading: () => 0.0,
    error: (_, __) => 0.0,
    data: (usage) {
      if (usage == null) return 0.0;
      return usage.getUsagePercentage();
    },
  );
});

// Increment usage count
final incrementArUsageProvider =
    FutureProvider.family<void, String>((ref, userId) async {
  final repository = ref.watch(arUsageRepositoryProvider);
  await repository.incrementUsage(userId);

  // Refresh usage data
  ref.refresh(arUsageProvider);
});
