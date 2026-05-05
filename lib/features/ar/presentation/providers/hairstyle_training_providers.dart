import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/hairstyle_training_data.dart';
import '../../../services/hairstyle_training_data_service.dart';
import '../../../services/ar_hairstyle_recommendation_service.dart';

/// Provider for hairstyle training data service
final hairstyleTrainingDataProvider =
    Provider<HairstyleTrainingDataService>((ref) {
  return HairstyleTrainingDataService();
});

/// Async provider to initialize training data
final trainingDataInitializationProvider =
    FutureProvider<void>((ref) async {
  final service = ref.watch(hairstyleTrainingDataProvider);
  await service.initialize();
});

/// Provider for AR hairstyle recommendation service
final arHairstyleRecommendationProvider =
    Provider<ARHairstyleRecommendationService>((ref) {
  return ARHairstyleRecommendationService();
});

/// Async provider to initialize recommendation service
final recommendationServiceInitializationProvider =
    FutureProvider<void>((ref) async {
  final service = ref.watch(arHairstyleRecommendationProvider);
  await service.initialize();
});

/// Provider for all hairstyles
final allHairstylesProvider = FutureProvider<List<HairstyleTrainingData>>((ref) async {
  await ref.watch(trainingDataInitializationProvider.future);
  final service = ref.watch(hairstyleTrainingDataProvider);
  return service.getAllHairstyles();
});

/// Provider for trending hairstyles
final trendingHairstylesProvider =
    FutureProvider<List<HairstyleTrainingData>>((ref) async {
  await ref.watch(trainingDataInitializationProvider.future);
  final service = ref.watch(hairstyleTrainingDataProvider);
  return service.getTrendingHairstyles(limit: 6);
});

/// Provider for easy maintenance hairstyles
final easyMaintenanceHairstylesProvider =
    FutureProvider<List<HairstyleTrainingData>>((ref) async {
  await ref.watch(trainingDataInitializationProvider.future);
  final service = ref.watch(hairstyleTrainingDataProvider);
  return service.getEasyMaintenance();
});

/// Provider for professional hairstyles
final professionalHairstylesProvider =
    FutureProvider<List<HairstyleTrainingData>>((ref) async {
  await ref.watch(trainingDataInitializationProvider.future);
  final service = ref.watch(hairstyleTrainingDataProvider);
  return service.getProfessionalHairstyles();
});

/// Parameterized provider for hairstyles by face shape
final hairstylesByFaceShapeProvider =
    FutureProvider.family<List<HairstyleTrainingData>, String>((ref, faceShape) async {
  await ref.watch(trainingDataInitializationProvider.future);
  final service = ref.watch(hairstyleTrainingDataProvider);
  return service.getHairstylesForFaceShape(faceShape);
});

/// Parameterized provider for hairstyles by hair type
final hairstylesByHairTypeProvider =
    FutureProvider.family<List<HairstyleTrainingData>, String>((ref, hairType) async {
  await ref.watch(trainingDataInitializationProvider.future);
  final service = ref.watch(hairstyleTrainingDataProvider);
  return service.getHairstylesByHairType(hairType);
});

/// Parameterized provider for hairstyle by ID
final hairstyleByIdProvider =
    FutureProvider.family<HairstyleTrainingData?, String>((ref, id) async {
  await ref.watch(trainingDataInitializationProvider.future);
  final service = ref.watch(hairstyleTrainingDataProvider);
  return service.getHairstyleData(id);
});

/// Parameterized provider for recommendations
final hairstyleRecommendationsProvider = FutureProvider.family<
    HairstyleRecommendations,
    ({String faceShape, String hairType})>((ref, params) async {
  await ref.watch(recommendationServiceInitializationProvider.future);
  final service = ref.watch(arHairstyleRecommendationProvider);
  return service.getRecommendations(params.faceShape, params.hairType);
});

/// Provider for official hairstyle name
final hairstyleOfficialNameProvider =
    FutureProvider.family<String, String>((ref, styleId) async {
  await ref.watch(recommendationServiceInitializationProvider.future);
  final service = ref.watch(arHairstyleRecommendationProvider);
  return service.getOfficialName(styleId);
});

/// Provider for hairstyle description
final hairstyleDescriptionProvider =
    FutureProvider.family<String, String>((ref, styleId) async {
  await ref.watch(recommendationServiceInitializationProvider.future);
  final service = ref.watch(arHairstyleRecommendationProvider);
  return service.getDescription(styleId);
});
