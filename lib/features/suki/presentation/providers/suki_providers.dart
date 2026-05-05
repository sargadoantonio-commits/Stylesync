import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/suki_repository.dart';

// Suki repository provider
final sukiRepositoryProvider = Provider<SukiRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  return SukiRepository(firestore);
});

// Get user's top suki (favorite) barber ID
final topSukiBarberIdProvider = StreamProvider<String?>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  final sukiRepo = ref.watch(sukiRepositoryProvider);

  return userProfile.when(
    data: (profile) {
      if (profile != null) {
        return sukiRepo.getTopSukiBarber(profile.uid);
      }
      return const Stream.empty();
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Get all sukis for user
final userSukisProvider = StreamProvider<List<String>>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  final sukiRepo = ref.watch(sukiRepositoryProvider);

  return userProfile.when(
    data: (profile) {
      if (profile != null) {
        return sukiRepo.getUserSukis(profile.uid);
      }
      return const Stream.empty();
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Add to suki list
final addSukiProvider =
    FutureProvider.family<void, String>((ref, barberId) async {
  final sukiRepo = ref.watch(sukiRepositoryProvider);
  final userProfile = ref.watch(userProfileProvider);

  if (userProfile.valueOrNull != null) {
    await sukiRepo.addSuki(userProfile.valueOrNull!.uid, barberId);
  }
});

// Remove from suki list
final removeSukiProvider =
    FutureProvider.family<void, String>((ref, barberId) async {
  final sukiRepo = ref.watch(sukiRepositoryProvider);
  final userProfile = ref.watch(userProfileProvider);

  if (userProfile.valueOrNull != null) {
    await sukiRepo.removeSuki(userProfile.valueOrNull!.uid, barberId);
  }
});

// Check if barber is a suki
final isSukiProvider =
    FutureProvider.family<bool, String>((ref, barberId) async {
  final sukis = ref.watch(userSukisProvider);

  return sukis.whenData((list) => list.contains(barberId)).value ?? false;
});
