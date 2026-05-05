import 'package:flutter/material.dart';

import '../models/hairstyle_filter.dart';
import 'hairstyle_catalog_loader.dart';

/// Service for managing hairstyle filters — catalog-driven names aligned with AR training taxonomy.
class HairstyleFilterService {
  static final HairstyleFilterService _instance = HairstyleFilterService._internal();

  factory HairstyleFilterService() {
    return _instance;
  }

  HairstyleFilterService._internal();

  List<HairstyleFilter>? _catalogBacked;

  /// Legacy defaults if asset catalog fails at runtime (tests / missing asset).
  final List<HairstyleFilter> _defaultFilters = [
    HairstyleFilter(
      id: 'style_fade',
      name: 'Classic Fade',
      description: 'Clean fade with sharp lines and precision edges',
      category: 'fade',
      difficulty: 'easy',
      compatibleFaceShapes: ['oval', 'square', 'diamond'],
      compatibleHairTypes: ['straight', 'wavy'],
      primaryColor: const Color(0xFFD946A6),
      accentColor: const Color(0xFF00F5D4),
      imageUrl: 'assets/haircuts/fade.png',
      isPremium: false,
      usageCount: 5420,
      rating: 4.8,
      trending: true,
      createdDate: DateTime(2024, 1, 15),
      styleCode: 'fade_classic',
    ),
    HairstyleFilter(
      id: 'style_undercut',
      name: 'Modern Undercut',
      description: 'Sharp sides, long top with textured finish',
      category: 'undercut',
      difficulty: 'medium',
      compatibleFaceShapes: ['oval', 'square', 'rectangle'],
      compatibleHairTypes: ['straight', 'wavy', 'curly'],
      primaryColor: const Color(0xFFD946A6),
      accentColor: const Color(0xFFFFD700),
      imageUrl: 'assets/haircuts/undercut.png',
      isPremium: false,
      usageCount: 8932,
      rating: 4.9,
      trending: true,
      createdDate: DateTime(2024, 1, 10),
      styleCode: 'undercut_modern',
    ),
    HairstyleFilter(
      id: 'style_pompadour',
      name: 'Classic Pompadour',
      description: 'Volume and shine with sleek back styling',
      category: 'pompadour',
      difficulty: 'hard',
      compatibleFaceShapes: ['oval', 'rectangle'],
      compatibleHairTypes: ['straight', 'wavy'],
      primaryColor: const Color(0xFFFFD700),
      accentColor: const Color(0xFFD946A6),
      imageUrl: 'assets/haircuts/pompadour.png',
      isPremium: true,
      usageCount: 3210,
      rating: 4.7,
      trending: false,
      createdDate: DateTime(2024, 1, 5),
      styleCode: 'pompadour_classic',
    ),
    HairstyleFilter(
      id: 'style_crop',
      name: 'Textured Crop',
      description: 'Soft fringe with matte textured finish',
      category: 'crop',
      difficulty: 'medium',
      compatibleFaceShapes: ['oval', 'round', 'diamond'],
      compatibleHairTypes: ['wavy', 'curly'],
      primaryColor: const Color(0xFF00F5D4),
      accentColor: const Color(0xFFD946A6),
      imageUrl: 'assets/haircuts/crop.png',
      isPremium: false,
      usageCount: 6543,
      rating: 4.6,
      trending: true,
      createdDate: DateTime(2024, 1, 1),
      styleCode: 'crop_textured',
    ),
    HairstyleFilter(
      id: 'style_beard_blend',
      name: 'Beard Blend',
      description: 'Seamless transition from beard to hair',
      category: 'blend',
      difficulty: 'medium',
      compatibleFaceShapes: ['square', 'rectangle', 'diamond'],
      compatibleHairTypes: ['straight', 'wavy', 'curly'],
      primaryColor: const Color(0xFFD946A6),
      accentColor: const Color(0xFF00F5D4),
      imageUrl: 'assets/haircuts/beard.png',
      isPremium: false,
      usageCount: 4821,
      rating: 4.9,
      trending: true,
      createdDate: DateTime(2024, 2, 1),
      styleCode: 'beard_blend',
    ),
    HairstyleFilter(
      id: 'style_slicked_back',
      name: 'Slicked Back',
      description: 'Wet look with maximum shine and hold',
      category: 'slick',
      difficulty: 'hard',
      compatibleFaceShapes: ['oval', 'rectangle', 'diamond'],
      compatibleHairTypes: ['straight'],
      primaryColor: const Color(0xFFFFD700),
      accentColor: const Color(0xFF00F5D4),
      imageUrl: 'assets/haircuts/slicked_back.png',
      isPremium: true,
      usageCount: 2341,
      rating: 4.8,
      trending: false,
      createdDate: DateTime(2024, 2, 5),
      styleCode: 'slicked_back_premium',
    ),
    HairstyleFilter(
      id: 'style_faux_hawk',
      name: 'Faux Hawk',
      description: 'Edgy mohawk style with defined center ridge',
      category: 'avant-garde',
      difficulty: 'hard',
      compatibleFaceShapes: ['oval', 'square', 'rectangle'],
      compatibleHairTypes: ['curly', 'coily'],
      primaryColor: const Color(0xFFD946A6),
      accentColor: const Color(0xFFFFD700),
      imageUrl: 'assets/haircuts/faux_hawk.png',
      isPremium: true,
      usageCount: 1876,
      rating: 4.5,
      trending: true,
      createdDate: DateTime(2024, 2, 10),
      styleCode: 'faux_hawk_premium',
    ),
  ];

  /// Fetch all hairstyle filters
  Future<List<HairstyleFilter>> getAllFilters() async {
    if (_catalogBacked != null) return _catalogBacked!;
    try {
      final rows = await HairstyleCatalogLoader.loadRawMaps();
      if (rows.isEmpty) throw StateError('empty catalog');
      final list = <HairstyleFilter>[];
      for (final row in rows) {
        final t = HairstyleCatalogLoader.mapToTrainingData(row);
        list.add(HairstyleCatalogLoader.mapToFilter(row, t));
      }
      _catalogBacked = list;
      await Future.delayed(const Duration(milliseconds: 180));
      return list;
    } catch (e) {
      debugPrint('[HairstyleFilterService] Catalog load failed — legacy defaults: $e');
      await Future.delayed(const Duration(milliseconds: 300));
      return _defaultFilters;
    }
  }

  /// Get filters by category
  Future<List<HairstyleFilter>> getFiltersByCategory(String category) async {
    final allFilters = await getAllFilters();
    return allFilters.where((f) => f.category == category).toList();
  }

  /// Get trending filters
  Future<List<HairstyleFilter>> getTrendingFilters() async {
    final allFilters = await getAllFilters();
    return allFilters
        .where((f) => f.trending)
        .toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  /// Get filters compatible with user's profile
  Future<List<HairstyleFilter>> getRecommendedFilters({
    required String faceShape,
    required String hairType,
    bool showPremiumOnly = false,
  }) async {
    final allFilters = await getAllFilters();
    return allFilters
        .where((f) =>
            f.compatibleFaceShapes.contains(faceShape.toLowerCase()) &&
            f.compatibleHairTypes.contains(hairType.toLowerCase()) &&
            (!showPremiumOnly || f.isPremium))
        .toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  /// Get a single filter by ID
  Future<HairstyleFilter?> getFilterById(String id) async {
    final allFilters = await getAllFilters();
    try {
      return allFilters.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search filters by name or description
  Future<List<HairstyleFilter>> searchFilters(String query) async {
    final allFilters = await getAllFilters();
    final lowerQuery = query.toLowerCase();
    return allFilters
        .where((f) =>
            f.name.toLowerCase().contains(lowerQuery) ||
            f.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get premium filters
  Future<List<HairstyleFilter>> getPremiumFilters() async {
    final allFilters = await getAllFilters();
    return allFilters.where((f) => f.isPremium).toList();
  }

  /// Get most popular filters by usage
  Future<List<HairstyleFilter>> getMostPopularFilters({int limit = 6}) async {
    final allFilters = await getAllFilters();
    allFilters.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return allFilters.take(limit).toList();
  }

  /// Get filters by difficulty level
  Future<List<HairstyleFilter>> getFiltersByDifficulty(String difficulty) async {
    final allFilters = await getAllFilters();
    return allFilters.where((f) => f.difficulty == difficulty).toList();
  }

  /// Update filter usage (for analytics)
  Future<void> updateFilterUsage(String filterId) async {
    try {
      // TODO: Send analytics event
      // await analytics.logEvent(
      //   name: 'filter_used',
      //   parameters: {'filter_id': filterId},
      // );
      debugPrint('[HairstyleFilterService] Filter $filterId used');
    } catch (e) {
      debugPrint('[HairstyleFilterService] Error updating filter usage: $e');
    }
  }

  /// Save user's favorite filter
  Future<void> saveFavoriteFilter(String filterId) async {
    try {
      // TODO: Save to Firestore or SharedPreferences
      debugPrint('[HairstyleFilterService] Filter $filterId saved as favorite');
    } catch (e) {
      debugPrint('[HairstyleFilterService] Error saving favorite: $e');
    }
  }

  /// Get user's favorite filters
  Future<List<HairstyleFilter>> getFavoriteFilters() async {
    try {
      // TODO: Load from Firestore or SharedPreferences
      return [];
    } catch (e) {
      debugPrint('[HairstyleFilterService] Error loading favorites: $e');
      return [];
    }
  }
}
