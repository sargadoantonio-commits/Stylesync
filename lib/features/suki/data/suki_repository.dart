import 'package:cloud_firestore/cloud_firestore.dart';

class SukiRepository {
  final FirebaseFirestore _firestore;

  SukiRepository(this._firestore);

  // Add barber to suki list
  Future<void> addSuki(String userId, String barberId) async {
    try {
      final sukiRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('sukis')
          .doc(barberId);

      await sukiRef.set({
        'barberId': barberId,
        'addedAt': FieldValue.serverTimestamp(),
        'bookingCount': 0,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add suki: $e');
    }
  }

  // Remove barber from suki list
  Future<void> removeSuki(String userId, String barberId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sukis')
          .doc(barberId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove suki: $e');
    }
  }

  // Get user's suki list
  Stream<List<String>> getUserSukis(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('sukis')
        .orderBy('bookingCount', descending: true)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  // Get top suki barber ID
  Stream<String?> getTopSukiBarber(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('sukis')
        .orderBy('bookingCount', descending: true)
        .orderBy('addedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.id;
    });
  }

  // Check if is suki
  Future<bool> isSuki(String userId, String barberId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sukis')
          .doc(barberId)
          .get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check suki status: $e');
    }
  }

  // Increment booking count for suki
  Future<void> incrementSukiBooking(String userId, String barberId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sukis')
          .doc(barberId)
          .update({
        'bookingCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment booking count: $e');
    }
  }

  // Get suki count for a barber
  Future<int> getSukiCount(String barberId) async {
    try {
      // Count how many users have this barber as suki
      // This would require a more complex query in a real implementation
      // For now, return 0 as a placeholder
      return 0;
    } catch (e) {
      throw Exception('Failed to get suki count: $e');
    }
  }
}
