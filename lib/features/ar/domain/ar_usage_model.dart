import 'package:freezed_annotation/freezed_annotation.dart';

part 'ar_usage_model.freezed.dart';

@freezed
class ArUsageDoc with _$ArUsageDoc {
  const factory ArUsageDoc({
    required String userId,
    required int usageCount,
    required DateTime lastResetDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ArUsageDoc;

  const ArUsageDoc._();

  /// Check if usage limit exceeded for free users (3 per month)
  bool isLimitExceeded() {
    final now = DateTime.now();
    final monthsApart = (now.year - lastResetDate.year) * 12 +
        (now.month - lastResetDate.month);

    // If month has changed, reset count
    if (monthsApart > 0) {
      return false; // New month, not exceeded
    }

    return usageCount >= 3; // 3 free attempts per month
  }

  /// Get remaining attempts (for free users)
  int getRemaining() {
    const maxFree = 3;
    final remaining = maxFree - usageCount;
    return remaining > 0 ? remaining : 0;
  }

  /// Get usage percentage for UI display
  double getUsagePercentage() {
    const maxFree = 3;
    return (usageCount / maxFree).clamp(0.0, 1.0);
  }
}
