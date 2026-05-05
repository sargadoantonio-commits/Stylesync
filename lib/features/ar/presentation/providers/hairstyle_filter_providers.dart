import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/hairstyle_filter.dart';
import '../../../../services/hairstyle_filter_service.dart';

/// Provider for HairstyleFilterService
final hairstyleFilterServiceProvider = Provider<HairstyleFilterService>((ref) {
  return HairstyleFilterService();
});

/// Provider for all hairstyle filters
final allHairstyleFiltersProvider = FutureProvider<List<HairstyleFilter>>((ref) async {
  final service = ref.watch(hairstyleFilterServiceProvider);
  return service.getAllFilters();
});

/// Provider for trending filters
final trendingHairstyleFiltersProvider = FutureProvider<List<HairstyleFilter>>((ref) async {
  final service = ref.watch(hairstyleFilterServiceProvider);
  return service.getTrendingFilters();
});

/// Provider for most popular filters
final popularHairstyleFiltersProvider = FutureProvider<List<HairstyleFilter>>((ref) async {
  final service = ref.watch(hairstyleFilterServiceProvider);
  return service.getMostPopularFilters();
});

/// Provider for filters by category
final hairstyleFiltersByCategoryProvider = FutureProvider.family<List<HairstyleFilter>, String>((ref, category) async {
  final service = ref.watch(hairstyleFilterServiceProvider);
  return service.getFiltersByCategory(category);
});

/// Provider for filter search
final searchHairstyleFiltersProvider = FutureProvider.family<List<HairstyleFilter>, String>((ref, query) async {
  final service = ref.watch(hairstyleFilterServiceProvider);
  return service.searchFilters(query);
});

/// Provider for premium filters
final premiumHairstyleFiltersProvider = FutureProvider<List<HairstyleFilter>>((ref) async {
  final service = ref.watch(hairstyleFilterServiceProvider);
  return service.getPremiumFilters();
});

/// State notifier for currently selected filter
class SelectedFilterNotifier extends StateNotifier<HairstyleFilter?> {
  SelectedFilterNotifier() : super(null);

  void selectFilter(HairstyleFilter? filter) {
    state = filter;
  }

  void clearSelection() {
    state = null;
  }
}

final selectedHairstyleFilterProvider = StateNotifierProvider<SelectedFilterNotifier, HairstyleFilter?>((ref) {
  return SelectedFilterNotifier();
});

/// State notifier for filter application settings
class FilterApplicationNotifier extends StateNotifier<FilterApplicationState> {
  FilterApplicationNotifier() : super(const FilterApplicationState());

  void setIntensity(double intensity) {
    state = state.copyWith(intensity: intensity.clamp(0.0, 1.0));
  }

  void setSmoothing(bool enabled) {
    state = state.copyWith(enableSmoothing: enabled);
  }

  void setStyleCode(String code) {
    state = state.copyWith(selectedStyleCode: code);
  }

  void setApplying(bool applying) {
    state = state.copyWith(isApplying: applying);
  }

  void reset() {
    state = const FilterApplicationState();
  }
}

final filterApplicationStateProvider = StateNotifierProvider<FilterApplicationNotifier, FilterApplicationState>((ref) {
  return FilterApplicationNotifier();
});

/// Provider for favorite filters
final favoriteHairstyleFiltersProvider = FutureProvider<List<HairstyleFilter>>((ref) async {
  final service = ref.watch(hairstyleFilterServiceProvider);
  return service.getFavoriteFilters();
});

/// Provider for recommended filters based on user profile
final recommendedHairstyleFiltersProvider = FutureProvider.family<List<HairstyleFilter>, ({String faceShape, String hairType})>((ref, params) async {
  final service = ref.watch(hairstyleFilterServiceProvider);
  return service.getRecommendedFilters(
    faceShape: params.faceShape,
    hairType: params.hairType,
  );
});
