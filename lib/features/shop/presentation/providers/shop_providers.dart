import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/shop_repository.dart';
import '../../domain/shop_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// Shop repository provider
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  return ShopRepository(firestore);
});

// Get shop by ID
final getShopProvider =
    FutureProvider.family<ShopModel?, String>((ref, shopId) async {
  final shopRepo = ref.watch(shopRepositoryProvider);
  return shopRepo.getShop(shopId);
});

// Get all shops owned by user
final ownedShopsProvider = StreamProvider<List<ShopModel>>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  final shopRepo = ref.watch(shopRepositoryProvider);

  return userProfile.when(
    data: (profile) {
      if (profile != null) {
        return shopRepo.getOwnedShops(profile.uid);
      }
      return const Stream.empty();
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Get all shops
final allShopsProvider = StreamProvider<List<ShopModel>>((ref) {
  final shopRepo = ref.watch(shopRepositoryProvider);
  return shopRepo.getAllShops();
});

// Search shops
final searchShopsProvider =
    StreamProvider.family<List<ShopModel>, String>((ref, query) {
  final shopRepo = ref.watch(shopRepositoryProvider);
  if (query.isEmpty) {
    return const Stream.empty();
  }
  return shopRepo.searchShops(query);
});

// Selected shop ID state
final selectedShopIdProvider = StateProvider<String?>((ref) => null);

// Get selected shop
final selectedShopProvider = Provider<ShopModel?>((ref) {
  final selectedId = ref.watch(selectedShopIdProvider);
  if (selectedId == null) return null;

  final shopAsync = ref.watch(getShopProvider(selectedId));
  return shopAsync.whenData((data) => data).value;
});

// Get nearby shops
final nearbyShopsProvider =
    FutureProvider.family<List<ShopModel>, (double, double, double)>(
        (ref, params) async {
  final shopRepo = ref.watch(shopRepositoryProvider);
  final (lat, lng, radius) = params;
  return shopRepo.getNearbyShops(userLat: lat, userLng: lng, radiusKm: radius);
});
