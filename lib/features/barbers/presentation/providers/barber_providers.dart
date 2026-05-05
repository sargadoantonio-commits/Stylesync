import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/barber_repository.dart';
import '../../domain/barber_model.dart';

// Barber repository provider
final barberRepositoryProvider = Provider<BarberRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  return BarberRepository(firestore);
});

// Get barber by ID
final barberByIdProvider =
    FutureProvider.family<BarberModel?, String>((ref, barberId) async {
  final barberRepo = ref.watch(barberRepositoryProvider);
  return barberRepo.getBarber(barberId);
});

// Get shop barbers stream
final shopBarbersProvider =
    StreamProvider.family<List<BarberModel>, String>((ref, shopId) {
  final barberRepo = ref.watch(barberRepositoryProvider);
  return barberRepo.getShopBarbers(shopId);
});

// Get available barbers for a shop
final availableBarbersProvider =
    StreamProvider.family<List<BarberModel>, String>((ref, shopId) {
  final barberRepo = ref.watch(barberRepositoryProvider);
  return barberRepo.getAvailableBarbers(shopId);
});

// Search barbers
final searchBarbersProvider =
    StreamProvider.family<List<BarberModel>, (String, String)>((ref, params) {
  final barberRepo = ref.watch(barberRepositoryProvider);
  final (shopId, query) = params;
  if (query.isEmpty) {
    return const Stream.empty();
  }
  return barberRepo.searchBarbers(shopId, query);
});

// Get top-rated barbers
final topRatedBarbersProvider =
    StreamProvider.family<List<BarberModel>, String>((ref, shopId) {
  final barberRepo = ref.watch(barberRepositoryProvider);
  return barberRepo.getTopRatedBarbers(shopId);
});

// Local state for selected barber
final selectedBarberIdProvider = StateProvider<String?>((ref) => null);

final selectedBarberProvider = Provider<BarberModel?>((ref) {
  final selectedId = ref.watch(selectedBarberIdProvider);
  if (selectedId == null) return null;

  final barberAsync = ref.watch(barberByIdProvider(selectedId));
  return barberAsync.whenData((data) => data).value;
});
