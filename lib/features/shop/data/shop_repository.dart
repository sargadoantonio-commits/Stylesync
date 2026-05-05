import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/shop_model.dart';
import '../domain/barber_in_shop_model.dart';

class ShopRepository {
  final FirebaseFirestore _firestore;

  ShopRepository(this._firestore);

  // Create a new shop
  Future<String> createShop({
    required String ownerId,
    required String name,
    String? address,
    String? phoneNumber,
    double? latitude,
    double? longitude,
    String? photoUrl,
    String? description,
    String? openingHours,
    String? closingHours,
  }) async {
    try {
      final docRef = await _firestore.collection('shops').add({
        'ownerId': ownerId,
        'name': name,
        'address': address,
        'phoneNumber': phoneNumber,
        'latitude': latitude,
        'longitude': longitude,
        'photoUrl': photoUrl,
        'description': description,
        'barbers': [], // Changed from barberIds
        'rating': 0.0,
        'reviewCount': 0,
        'isOpen': true,
        'openingHours': openingHours,
        'closingHours': closingHours,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create shop: $e');
    }
  }

  // Get shop by ID
  Future<ShopModel?> getShop(String shopId) async {
    try {
      final doc = await _firestore.collection('shops').doc(shopId).get();
      if (doc.exists) {
        return ShopModel.fromFirestore(doc.data() ?? {}, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get shop: $e');
    }
  }

  // Get all shops owned by a user
  Stream<List<ShopModel>> getOwnedShops(String ownerId) {
    return _firestore
        .collection('shops')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ShopModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Get all shops
  Stream<List<ShopModel>> getAllShops() {
    return _firestore
        .collection('shops')
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ShopModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Search shops by name
  Stream<List<ShopModel>> searchShops(String query) {
    return _firestore.collection('shops').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ShopModel.fromFirestore(doc.data(), doc.id))
          .where(
              (shop) => shop.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Update shop info
  Future<void> updateShop(String shopId, ShopModel shop) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .update(shop.toFirestore());
    } catch (e) {
      throw Exception('Failed to update shop: $e');
    }
  }

  // Add barber to shop
  Future<void> addBarber({
    required String shopId,
    required String barberId,
    required String barberName,
    required String barberEmail,
  }) async {
    try {
      final newBarber = BarberInShop(
        barberId: barberId,
        name: barberName,
        email: barberEmail,
        assignedAt: DateTime.now(),
      );
      
      await _firestore.collection('shops').doc(shopId).update({
        'barbers': FieldValue.arrayUnion([newBarber.toFirestore()]),
      });
    } catch (e) {
      throw Exception('Failed to add barber: $e');
    }
  }

  // Remove barber from shop
  Future<void> removeBarber(String shopId, String barberId) async {
    try {
      final shopDoc = await _firestore.collection('shops').doc(shopId).get();
      if (shopDoc.exists) {
        final barbers = (shopDoc['barbers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final barberToRemove = barbers
            .firstWhere((b) => b['barberId'] == barberId, orElse: () => {});
        
        if (barberToRemove.isNotEmpty) {
          await _firestore.collection('shops').doc(shopId).update({
            'barbers': FieldValue.arrayRemove([barberToRemove]),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to remove barber: $e');
    }
  }

  // Get shop barbers as a stream
  Stream<List<BarberInShop>> getShopBarbers(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return [];
      
      final barbers = (snapshot['barbers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return barbers
          .map((barber) => BarberInShop.fromFirestore(barber))
          .toList();
    });
  }

  // Toggle admin status for a barber in a shop
  Future<void> toggleBarbersAdmin(String shopId, String barberId, bool isAdmin) async {
    try {
      final shopDoc = await _firestore.collection('shops').doc(shopId).get();
      if (shopDoc.exists) {
        final barbers = (shopDoc['barbers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final barberIndex = barbers.indexWhere((b) => b['barberId'] == barberId);
        
        if (barberIndex != -1) {
          // Remove the old barber entry
          await _firestore.collection('shops').doc(shopId).update({
            'barbers': FieldValue.arrayRemove([barbers[barberIndex]]),
          });
          
          // Update isAdmin and add back
          barbers[barberIndex]['isAdmin'] = isAdmin;
          await _firestore.collection('shops').doc(shopId).update({
            'barbers': FieldValue.arrayUnion([barbers[barberIndex]]),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to toggle barber admin status: $e');
    }
  }

  // Check if a barber is admin in a specific shop
  Future<bool> isUserAdminInShop(String shopId, String barberId) async {
    try {
      final shopDoc = await _firestore.collection('shops').doc(shopId).get();
      if (shopDoc.exists) {
        final barbers = (shopDoc['barbers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final barber = barbers.firstWhere(
          (b) => b['barberId'] == barberId,
          orElse: () => {},
        );
        return barber['isAdmin'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check barber admin status: $e');
    }
  }

  // Deprecated methods - removed admin functionality
  @Deprecated('Use addBarber instead')
  Future<void> addBarberId(String shopId, String barberId) async {
    // Deprecated - do nothing
  }

  @Deprecated('Use removeBarber instead')
  Future<void> removeBarberId(String shopId, String barberId) async {
    // Deprecated - do nothing
  }

  // Update shop rating
  Future<void> updateRating(
      String shopId, double newRating, int newReviewCount) async {
    try {
      await _firestore.collection('shops').doc(shopId).update({
        'rating': newRating,
        'reviewCount': newReviewCount,
      });
    } catch (e) {
      throw Exception('Failed to update rating: $e');
    }
  }

  // Update shop open status
  Future<void> updateOpenStatus(String shopId, bool isOpen) async {
    try {
      await _firestore.collection('shops').doc(shopId).update({
        'isOpen': isOpen,
      });
    } catch (e) {
      throw Exception('Failed to update open status: $e');
    }
  }

  // Delete shop
  Future<void> deleteShop(String shopId) async {
    try {
      await _firestore.collection('shops').doc(shopId).delete();
    } catch (e) {
      throw Exception('Failed to delete shop: $e');
    }
  }

  // Get nearby shops (within radius in km)
  Future<List<ShopModel>> getNearbyShops({
    required double userLat,
    required double userLng,
    required double radiusKm,
  }) async {
    try {
      final allShops = await _firestore.collection('shops').get();
      final nearbyShops = <ShopModel>[];

      for (var doc in allShops.docs) {
        final shop = ShopModel.fromFirestore(doc.data(), doc.id);
        if (shop.latitude != null && shop.longitude != null) {
          final distance = _calculateDistance(
            userLat,
            userLng,
            shop.latitude!,
            shop.longitude!,
          );
          if (distance <= radiusKm) {
            nearbyShops.add(shop);
          }
        }
      }

      return nearbyShops;
    } catch (e) {
      throw Exception('Failed to get nearby shops: $e');
    }
  }

  // Haversine formula to calculate distance
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        (Math.cos(_toRadians(lat1)) *
            Math.cos(_toRadians(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2));

    final c = 2 * Math.asin(Math.sqrt(a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degree) {
    return degree * Math.pi / 180;
  }
}

class Math {
  static const double pi = 3.141592653589793;

  static double sin(double x) => _sin(x);
  static double cos(double x) => _cos(x);
  static double asin(double x) => _asin(x);
  static double sqrt(double x) => _sqrt(x);

  static double _sin(double x) {
    // Simple approximation
    return (x - x * x * x / 6 + x * x * x * x * x / 120);
  }

  static double _cos(double x) {
    return (1 - x * x / 2 + x * x * x * x / 24);
  }

  static double _asin(double x) {
    return x + x * x * x / 6 + 3 * x * x * x * x * x / 40;
  }

  static double _sqrt(double x) {
    if (x < 0) return 0;
    if (x == 0) return 0;
    double r = x;
    for (int i = 0; i < 10; i++) {
      r = (r + x / r) / 2;
    }
    return r;
  }
}
