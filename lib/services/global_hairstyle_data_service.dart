import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/hairstyle_filter.dart';
import 'hairstyle_catalog_loader.dart';

/// Service for hairstyle filters backed by bundled taxonomy (+ optional HTTPS host you control).
/// TikTok/Instagram do not expose global filter-training APIs; realism comes from proprietary ML/SDKs.
class GlobalHairstyleDataService {
  static final GlobalHairstyleDataService _instance = GlobalHairstyleDataService._internal();
  
  final Map<String, HairstyleFilter> _cache = {};
  bool _isInitialized = false;

  factory GlobalHairstyleDataService() {
    return _instance;
  }

  GlobalHairstyleDataService._internal();

  /// Initialize and fetch hairstyle data from global sources
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Future.wait([
        _loadBundledCatalogFilters(),
        _fetchFromConfigurableRemoteCatalog(),
        _fetchTrendingStyles(),
        _fetchCommunityStyles(),
      ]);

      // Load fallback data if needed
      if (_cache.isEmpty) {
        _loadFallbackData();
      }

      _isInitialized = true;
      print('✅ Global hairstyle data initialized: ${_cache.length} styles');
    } catch (e) {
      print('⚠️ Error initializing hairstyle data: $e');
      _loadFallbackData();
      _isInitialized = true;
    }
  }

  /// Same JSON schema as bundled asset; compile with `--dart-define=HAIRSTYLE_CATALOG_URL=https://…/catalog.json` to refresh over the air.
  static const String remoteCatalogJsonUrl =
      String.fromEnvironment('HAIRSTYLE_CATALOG_URL', defaultValue: '');

  Future<void> _loadBundledCatalogFilters() async {
    try {
      final rows = await HairstyleCatalogLoader.loadRawMaps();
      for (final row in rows) {
        final training = HairstyleCatalogLoader.mapToTrainingData(row);
        final filter = HairstyleCatalogLoader.mapToFilter(row, training);
        _cache[filter.id] = filter;
      }
    } catch (e) {
      print('Bundled filter catalog failed: $e');
    }
  }

  /// Optional HTTPS JSON array (same shape as `assets/data/hairstyle_catalog.json`).
  Future<void> _fetchFromConfigurableRemoteCatalog() async {
    final url = remoteCatalogJsonUrl.trim();
    if (url.isEmpty) return;
    try {
      final response =
          await http.get(Uri.parse(url), headers: {'Accept': 'application/json'}).timeout(
                const Duration(seconds: 8),
              );
      if (response.statusCode == 200) {
        _processAPIResponse(jsonDecode(response.body));
      }
    } catch (e) {
      print('Remote hairstyle catalog unavailable: $e');
    }
  }

  /// Process API response and cache data
  void _processAPIResponse(dynamic data) {
    try {
      if (data is List) {
        for (final item in data) {
          final filter = _parseHairstyleFromAPI(item);
          if (filter != null) {
            _cache[filter.id] = filter;
          }
        }
      } else if (data is Map) {
        final items = data['styles'] ?? data['hairstyles'] ?? data['data'] ?? [];
        if (items is List) {
          for (final item in items) {
            final filter = _parseHairstyleFromAPI(item);
            if (filter != null) {
              _cache[filter.id] = filter;
            }
          }
        }
      }
    } catch (e) {
      print('Error processing API response: $e');
    }
  }

  /// Parse hairstyle from API response
  HairstyleFilter? _parseHairstyleFromAPI(dynamic data) {
    try {
      if (data is! Map) return null;

      return HairstyleFilter(
        id: data['id'] ?? data['code'] ?? 'style_${DateTime.now().millisecondsSinceEpoch}',
        name: data['name'] ?? data['title'] ?? 'Unknown Style',
        description: data['description'] ?? data['desc'] ?? 'Professional hairstyle',
        category: data['category'] ?? data['type'] ?? 'modern',
        difficulty: data['difficulty'] ?? 'medium',
        compatibleFaceShapes: List<String>.from(data['compatibleFaceShapes'] ?? 
            data['faceShapes'] ?? 
            ['oval', 'square', 'round']),
        compatibleHairTypes: List<String>.from(data['compatibleHairTypes'] ?? 
            data['hairTypes'] ?? 
            ['straight', 'wavy', 'curly']),
        primaryColor: _parseColor(data['primaryColor'] ?? data['color1'] ?? '0xFFD946A6'),
        accentColor: _parseColor(data['accentColor'] ?? data['color2'] ?? '0xFF00F5D4'),
        imageUrl: data['imageUrl'] ?? data['image'] ?? data['photo'] ?? 'assets/haircuts/default.png',
        isPremium: data['isPremium'] ?? data['premium'] ?? false,
        usageCount: data['usageCount'] ?? data['uses'] ?? 0,
        rating: (data['rating'] ?? 0.0).toDouble(),
        trending: data['trending'] ?? data['isTrending'] ?? false,
        createdDate: _parseDate(data['createdDate'] ?? data['date']),
        styleCode: data['styleCode'] ?? data['code'] ?? 'default',
      );
    } catch (e) {
      print('Error parsing hairstyle: $e');
      return null;
    }
  }

  Color _parseColor(dynamic colorData) {
    try {
      if (colorData is String) {
        return Color(int.parse(colorData.replaceFirst('#', '0x')));
      } else if (colorData is int) {
        return Color(colorData);
      }
    } catch (e) {
      print('Color parsing error: $e');
    }
    return const Color(0xFFD946A6); // Default pink
  }

  DateTime _parseDate(dynamic dateData) {
    try {
      if (dateData is String) {
        return DateTime.parse(dateData);
      } else if (dateData is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateData);
      }
    } catch (e) {
      print('Date parsing error: $e');
    }
    return DateTime.now();
  }

  /// Fetch trending hairstyles from social media APIs
  Future<void> _fetchTrendingStyles() async {
    try {
      // TikTok-like trend data (would need API keys in production)
      final trendingData = _generateTrendingStylesFromCache();
      
      for (final style in trendingData) {
        _cache[style.id] = style;
      }
    } catch (e) {
      print('Error fetching trending styles: $e');
    }
  }

  /// Fetch community-submitted styles
  Future<void> _fetchCommunityStyles() async {
    try {
      // This could connect to Firebase or a community API
      // For now, generate synthetic community styles
      final communityStyles = _generateCommunityStyles();
      
      for (final style in communityStyles) {
        _cache[style.id] = style;
      }
    } catch (e) {
      print('Error fetching community styles: $e');
    }
  }

  /// Load fallback data if no internet available
  void _loadFallbackData() {
    final fallbackStyles = [
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

    for (final style in fallbackStyles) {
      _cache[style.id] = style;
    }
  }

  /// Generate trending styles from existing cache
  List<HairstyleFilter> _generateTrendingStylesFromCache() {
    final ranked = [..._cache.values];
    ranked.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return ranked.take(5).toList();
  }

  /// Generate synthetic community styles
  List<HairstyleFilter> _generateCommunityStyles() {
    return [
      HairstyleFilter(
        id: 'community_burst_fade',
        name: 'Burst Fade',
        description: 'Curved fade that follows head shape',
        category: 'fade',
        difficulty: 'hard',
        compatibleFaceShapes: ['oval', 'round'],
        compatibleHairTypes: ['straight', 'wavy', 'curly'],
        primaryColor: const Color(0xFF6366F1),
        accentColor: const Color(0xFF00F5D4),
        imageUrl: 'assets/haircuts/burst_fade.png',
        isPremium: false,
        usageCount: 2150,
        rating: 4.7,
        trending: true,
        createdDate: DateTime(2024, 3, 1),
        styleCode: 'burst_fade',
      ),
      HairstyleFilter(
        id: 'community_temp_fade',
        name: 'Temple Fade',
        description: 'Modern temple line with precise angles',
        category: 'fade',
        difficulty: 'medium',
        compatibleFaceShapes: ['square', 'diamond'],
        compatibleHairTypes: ['straight', 'wavy'],
        primaryColor: const Color(0xFFF43F5E),
        accentColor: const Color(0xFF00F5D4),
        imageUrl: 'assets/haircuts/temple_fade.png',
        isPremium: false,
        usageCount: 1890,
        rating: 4.6,
        trending: true,
        createdDate: DateTime(2024, 3, 5),
        styleCode: 'temple_fade',
      ),
      HairstyleFilter(
        id: 'community_wave_check',
        name: 'Wave Check',
        description: 'Brushed waves with sharp definition',
        category: 'waves',
        difficulty: 'medium',
        compatibleFaceShapes: ['oval', 'round', 'square'],
        compatibleHairTypes: ['wavy', 'curly'],
        primaryColor: const Color(0xFF14B8A6),
        accentColor: const Color(0xFFFFD700),
        imageUrl: 'assets/haircuts/wave_check.png',
        isPremium: true,
        usageCount: 3420,
        rating: 4.8,
        trending: true,
        createdDate: DateTime(2024, 3, 10),
        styleCode: 'wave_check',
      ),
    ];
  }

  /// Get all available hairstyles
  List<HairstyleFilter> getAllStyles() {
    return _cache.values.toList();
  }

  /// Get trending hairstyles
  List<HairstyleFilter> getTrendingStyles({int limit = 10}) {
    final ranked = [..._cache.values];
    ranked.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return ranked.take(limit).toList();
  }

  /// Get styles by category
  List<HairstyleFilter> getStylesByCategory(String category) {
    return _cache.values.where((s) => s.category == category).toList();
  }

  /// Get styles compatible with face shape
  List<HairstyleFilter> getCompatibleStyles(String faceShape) {
    return _cache.values
        .where((s) => s.compatibleFaceShapes.contains(faceShape))
        .toList();
  }

  /// Search hairstyles
  List<HairstyleFilter> searchStyles(String query) {
    final lowerQuery = query.toLowerCase();
    return _cache.values
        .where((s) =>
            s.name.toLowerCase().contains(lowerQuery) ||
            s.description.toLowerCase().contains(lowerQuery) ||
            s.category.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get hairstyle by ID
  HairstyleFilter? getStyleById(String id) {
    return _cache[id];
  }

  /// Get top-rated styles
  List<HairstyleFilter> getTopRatedStyles({int limit = 10}) {
    final ranked = [..._cache.values];
    ranked.sort((a, b) => b.rating.compareTo(a.rating));
    return ranked.take(limit).toList();
  }

  /// Get styles for premium users
  List<HairstyleFilter> getPremiumStyles() {
    return _cache.values.where((s) => s.isPremium).toList();
  }

  /// Get styles for free users
  List<HairstyleFilter> getFreeStyles() {
    return _cache.values.where((s) => !s.isPremium).toList();
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
    _isInitialized = false;
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'totalStyles': _cache.length,
      'premiumStyles': _cache.values.where((s) => s.isPremium).length,
      'freeStyles': _cache.values.where((s) => !s.isPremium).length,
      'trendingStyles': _cache.values.where((s) => s.trending).length,
      'categories': _cache.values.map((s) => s.category).toSet().length,
      'isInitialized': _isInitialized,
    };
  }
}

/// Riverpod provider for global hairstyle data
final globalHairstyleDataProvider = FutureProvider((ref) async {
  final service = GlobalHairstyleDataService();
  await service.initialize();
  return service;
});

/// Provider for getting all available styles
final availableHairstylesProvider = FutureProvider((ref) async {
  final service = await ref.watch(globalHairstyleDataProvider.future);
  return service.getAllStyles();
});

/// Provider for trending styles
final trendingStylesProvider = FutureProvider((ref) async {
  final service = await ref.watch(globalHairstyleDataProvider.future);
  return service.getTrendingStyles();
});
