import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/ar_usage_model.dart';

class ArUsageRepository {
  final FirebaseFirestore _firestore;

  ArUsageRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Get or create AR usage doc for current user
  Future<ArUsageDoc> getUsage(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('ar_usage')
          .doc('monthly_stats')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return ArUsageDoc(
          userId: userId,
          usageCount: data['usageCount'] ?? 0,
          lastResetDate: (data['lastResetDate'] as Timestamp).toDate(),
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        );
      }

      // Create new usage doc
      final now = DateTime.now();
      final newUsage = ArUsageDoc(
        userId: userId,
        usageCount: 0,
        lastResetDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('ar_usage')
          .doc('monthly_stats')
          .set({
        'userId': userId,
        'usageCount': 0,
        'lastResetDate': now,
        'createdAt': now,
        'updatedAt': now,
      });

      return newUsage;
    } catch (e) {
      throw Exception('Failed to get AR usage: $e');
    }
  }

  /// Increment usage count (used when free user tries filter)
  Future<void> incrementUsage(String userId) async {
    try {
      final now = DateTime.now();
      final usageRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('ar_usage')
          .doc('monthly_stats');

      // Get current usage
      final doc = await usageRef.get();

      if (doc.exists) {
        final data = doc.data()!;
        final lastReset = (data['lastResetDate'] as Timestamp).toDate();
        final monthsApart =
            (now.year - lastReset.year) * 12 + (now.month - lastReset.month);

        // Reset if new month
        if (monthsApart > 0) {
          await usageRef.update({
            'usageCount': 1,
            'lastResetDate': now,
            'updatedAt': now,
          });
        } else {
          await usageRef.update({
            'usageCount': FieldValue.increment(1),
            'updatedAt': now,
          });
        }
      } else {
        // Create new
        await usageRef.set({
          'userId': userId,
          'usageCount': 1,
          'lastResetDate': now,
          'createdAt': now,
          'updatedAt': now,
        });
      }
    } catch (e) {
      throw Exception('Failed to increment AR usage: $e');
    }
  }

  /// Stream AR usage changes
  Stream<ArUsageDoc> watchUsage(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('ar_usage')
        .doc('monthly_stats')
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        final now = DateTime.now();
        return ArUsageDoc(
          userId: userId,
          usageCount: 0,
          lastResetDate: now,
          createdAt: now,
          updatedAt: now,
        );
      }

      final data = doc.data()!;
      return ArUsageDoc(
        userId: userId,
        usageCount: data['usageCount'] ?? 0,
        lastResetDate: (data['lastResetDate'] as Timestamp).toDate(),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      );
    });
  }
}
