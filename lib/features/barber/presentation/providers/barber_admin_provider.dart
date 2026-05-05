import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylesync/features/shop/data/shop_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider for checking if a barber is admin in their shop
final barberAdminStatusProvider = FutureProvider.family<bool, String>((ref, barberId) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final shopRepo = ShopRepository(firestore);
    
    // Get all shops and check if this barber is admin in any
    final shopsSnapshot = await firestore.collection('shops').get();
    
    for (final shopDoc in shopsSnapshot.docs) {
      final barbers = (shopDoc['barbers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final barber = barbers.firstWhere(
        (b) => b['barberId'] == barberId,
        orElse: () => {},
      );
      
      if (barber.isNotEmpty && barber['isAdmin'] == true) {
        return true;
      }
    }
    
    return false;
  } catch (e) {
    return false;
  }
});

// Provider to get the shop ID where the barber is admin
final currentBarberShopProvider = FutureProvider.family<String?, String>((ref, barberId) async {
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Get all shops and find which one has this barber as admin
    final shopsSnapshot = await firestore.collection('shops').get();
    
    for (final shopDoc in shopsSnapshot.docs) {
      final barbers = (shopDoc['barbers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final barber = barbers.firstWhere(
        (b) => b['barberId'] == barberId,
        orElse: () => {},
      );
      
      if (barber.isNotEmpty && barber['isAdmin'] == true) {
        return shopDoc.id;
      }
    }
    
    return null;
  } catch (e) {
    return null;
  }
});
