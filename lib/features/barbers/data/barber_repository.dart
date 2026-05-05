import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/barber_model.dart';

class BarberRepository {
  final FirebaseFirestore _firestore;

  BarberRepository(this._firestore);

  // Get barber by ID
  Future<BarberModel?> getBarber(String barberId) async {
    try {
      final doc = await _firestore.collection('barbers').doc(barberId).get();
      if (doc.exists) {
        return BarberModel.fromFirestore(doc.data() ?? {}, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get barber: $e');
    }
  }

  // Get all barbers for a shop
  Stream<List<BarberModel>> getShopBarbers(String shopId) {
    return _firestore
        .collection('barbers')
        .where('shopId', isEqualTo: shopId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BarberModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Get all available barbers for a shop
  Stream<List<BarberModel>> getAvailableBarbers(String shopId) {
    return _firestore
        .collection('barbers')
        .where('shopId', isEqualTo: shopId)
        .where('isAvailable', isEqualTo: true)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BarberModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Search barbers by name
  Stream<List<BarberModel>> searchBarbers(String shopId, String query) {
    return _firestore
        .collection('barbers')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BarberModel.fromFirestore(doc.data(), doc.id))
          .where((barber) =>
              barber.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Get top-rated barbers
  Stream<List<BarberModel>> getTopRatedBarbers(String shopId,
      {int limit = 10}) {
    return _firestore
        .collection('barbers')
        .where('shopId', isEqualTo: shopId)
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BarberModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Create a new barber (for admin/shop owner)
  Future<String> createBarber({
    required String name,
    required String shopId,
    String? photoUrl,
    String? bio,
    double? yearsExperience,
    List<String>? specialties,
    String? gcashQrUrl,
  }) async {
    try {
      final docRef = await _firestore.collection('barbers').add({
        'name': name,
        'shopId': shopId,
        'photoUrl': photoUrl,
        'bio': bio,
        'yearsExperience': yearsExperience ?? 0,
        'specialties': specialties ?? [],
        'gcashQrUrl': gcashQrUrl,
        'rating': 0.0,
        'reviewCount': 0,
        'isAvailable': true,
        'totalBookings': 0,
        'completedBookings': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create barber: $e');
    }
  }

  // Update barber info
  Future<void> updateBarber(String barberId, BarberModel barber) async {
    try {
      await _firestore
          .collection('barbers')
          .doc(barberId)
          .update(barber.toFirestore());
    } catch (e) {
      throw Exception('Failed to update barber: $e');
    }
  }

  // Update barber availability
  Future<void> updateAvailability(String barberId, bool isAvailable) async {
    try {
      await _firestore.collection('barbers').doc(barberId).update({
        'isAvailable': isAvailable,
      });
    } catch (e) {
      throw Exception('Failed to update availability: $e');
    }
  }

  // Update barber rating
  Future<void> updateRating(
      String barberId, double newRating, int newReviewCount) async {
    try {
      await _firestore.collection('barbers').doc(barberId).update({
        'rating': newRating,
        'reviewCount': newReviewCount,
      });
    } catch (e) {
      throw Exception('Failed to update rating: $e');
    }
  }

  // Increment completed bookings
  Future<void> incrementCompletedBookings(String barberId) async {
    try {
      await _firestore.collection('barbers').doc(barberId).update({
        'completedBookings': FieldValue.increment(1),
        'totalBookings': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment bookings: $e');
    }
  }

  // Delete barber
  Future<void> deleteBarber(String barberId) async {
    try {
      await _firestore.collection('barbers').doc(barberId).delete();
    } catch (e) {
      throw Exception('Failed to delete barber: $e');
    }
  }
}
