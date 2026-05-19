import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stylesync/core/constants.dart' as _flags;
import '../../data/service_repository.dart';
import '../../domain/service_models.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// Service repository provider
final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  return ServiceRepository(firestore);
});

// Review service provider
final reviewServiceProvider = Provider<ReviewService>((ref) {
  final serviceRepo = ref.watch(serviceRepositoryProvider);
  return ReviewService(serviceRepo);
});

// Get service by ID
final getServiceProvider =
    FutureProvider.family<ServiceDoc?, String>((ref, serviceId) async {
  final serviceRepo = ref.watch(serviceRepositoryProvider);
  return serviceRepo.getService(serviceId);
});

// Customer services stream
final customerServicesProvider = StreamProvider<List<ServiceDoc>>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  final serviceRepo = ref.watch(serviceRepositoryProvider);

  return userProfile.when(
    data: (profile) {
      if (profile != null) {
        return serviceRepo.getCustomerServices(profile.uid);
      }
      return const Stream.empty();
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Barber services stream
final barberServicesProvider =
    StreamProvider.family<List<ServiceDoc>, String>((ref, barberId) {
  final serviceRepo = ref.watch(serviceRepositoryProvider);
  return serviceRepo.getBarberServices(barberId);
});

// Barber pending confirmations
final barberConfirmationsProvider = StreamProvider<List<ServiceDoc>>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  final serviceRepo = ref.watch(serviceRepositoryProvider);

  return userProfile.when(
    data: (profile) {
      if (_flags.kUseDemoBarberUI) {
        // Demo mode: disable live confirmations stream to avoid permission errors
        return const Stream.empty();
      }

      if (profile != null) {
        return serviceRepo.getBarberPendingConfirmations(profile.uid);
      }

      return const Stream.empty();
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

class ReviewService {
  final ServiceRepository _serviceRepository;

  ReviewService(this._serviceRepository);

  Future<void> submitReview({
    required String serviceId,
    required int rating,
    required String review,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }
    if (review.isEmpty) {
      throw Exception('Review cannot be empty');
    }
    await _serviceRepository.reviewService(
      serviceId: serviceId,
      rating: rating,
      review: review,
    );
  }
}
