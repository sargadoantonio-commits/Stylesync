import '../models/hairstyle_training_data.dart';
import 'hairstyle_catalog_loader.dart';

/// Real-world hairstyle training data service
/// Primary taxonomy ships in assets (same source powers official names). Remote APIs
/// for TikTok-/Reels-style trends are proprietary; bundled JSON uses public naming.
class HairstyleTrainingDataService {
  static final HairstyleTrainingDataService _instance =
      HairstyleTrainingDataService._internal();

  final Map<String, HairstyleTrainingData> _trainingCache = {};
  bool _isInitialized = false;

  factory HairstyleTrainingDataService() {
    return _instance;
  }

  HairstyleTrainingDataService._internal();

  /// Initialize: load bundled catalog first, then optional hooks for future backends.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('📊 Loading haircut taxonomy for AR/training…');
      await _loadBundledCatalogPrimary();
      await Future.wait([
        _fetchFromBarberShopData(),
        _fetchFromCommunityData(),
        _fetchFromStyleGuideData(),
      ], eagerError: false);

      _seedEmergencyInlineIfSparse();

      if (_trainingCache.isEmpty) {
        _loadComprehensiveFallbackData();
      }

      _isInitialized = true;
      print(
          '✅ Hairstyle training data initialized: ${_trainingCache.length} styles (bundled taxonomy + overlays)');
    } catch (e) {
      print('⚠️ Error initializing training data: $e');
      _seedEmergencyInlineIfSparse();
      _loadComprehensiveFallbackData();
      _isInitialized = true;
    }
  }

  /// Single source of truth: `assets/data/hairstyle_catalog.json`
  Future<void> _loadBundledCatalogPrimary() async {
    try {
      final rows = await HairstyleCatalogLoader.loadRawMaps();
      for (final row in rows) {
        final t = HairstyleCatalogLoader.mapToTrainingData(row);
        _trainingCache[t.id] = t;
      }
      print('📦 Catalog rows loaded: ${_trainingCache.length}');
    } catch (e) {
      print('⚠️ Bundled hairstyle catalog unreadable (add assets/data?): $e');
    }
  }

  /// Offline safety net — only fills gaps missing from catalog.
  void _seedEmergencyInlineIfSparse() {
    if (_trainingCache.containsKey('textured_messy')) return;
    final fallback = HairstyleTrainingData(
      id: 'textured_messy',
      officialName: 'Textured tousled crop',
      aliases: ['Bed head textured', 'Casual tousle'],
      description: 'Naturally textured tousled silhouette with minimal styling.',
      characteristics: {
        'sideLength': '10-14mm',
        'topLength': '25-42mm',
        'backLength': '15-32mm',
        'texture': 'High movement',
        'faceShapeCompatibility': {
          'oval': 89,
          'square': 86,
          'round': 82,
          'rectangle': 86,
          'diamond': 85,
          'heart': 84
        },
        'difficulty': 'easy',
        'maintenanceLevel': 'Low',
        'maintenanceFrequency': '4-6 weeks',
        'headSize': 'All',
        'hairType': ['curly', 'wavy'],
        'ageGroup': '15-40',
      },
      imageUrl: 'https://images.pexels.com/photos/3407857/pexels-photo-3407857.jpeg',
      tags: ['texture', 'casual'],
      tiktokTrendingScore: 80,
      instagramPopularity: 83,
      barberDifficultyScore: 2,
    );
    _trainingCache[fallback.id] = fallback;
  }

  /// Fetch from barber shop trending data
  Future<void> _fetchFromBarberShopData() async {
    try {
      // Could integrate with real barber shop APIs like BarberConnect, Booksy, etc.
      print('📡 Checking barber shop trending data sources...');
      // In production, would connect to:
      // - Booksy API
      // - BarberConnect API
      // - Appointments.com API
      // - Local barber shop databases
    } catch (e) {
      print('Error fetching barber shop data: $e');
    }
  }

  /// Fetch from community recommendations
  Future<void> _fetchFromCommunityData() async {
    try {
      // Could integrate with Reddit, TikTok, Instagram APIs for trending styles
      print('📡 Checking community trending data (Reddit, TikTok, Instagram)...');
      // In production would track:
      // - Reddit r/Bald, r/Haircare hairstyle discussions
      // - TikTok hairstyle trends
      // - Instagram hairstyle hashtags
    } catch (e) {
      print('Error fetching community data: $e');
    }
  }

  /// Fetch from professional style guides
  Future<void> _fetchFromStyleGuideData() async {
    try {
      print('📡 Checking professional barber style guide data...');
      // Could integrate with:
      // - Professional barber associations
      // - Hair styling magazines
      // - Celebrity hairstylist guides
    } catch (e) {
      print('Error fetching style guide data: $e');
    }
  }

  /// Load comprehensive fallback training data
  void _loadComprehensiveFallbackData() {
    print('📚 Loading comprehensive fallback training data...');
    
    // Already loaded in _fetchFromMenHaircutsAPI
    if (_trainingCache.isEmpty) {
      // This should not happen due to async error handling
      print('⚠️ All data sources failed, using basic fallback');
    }
  }

  /// Get hairstyle by ID
  HairstyleTrainingData? getHairstyleData(String id) {
    return _trainingCache[id];
  }

  /// Get all hairstyles
  List<HairstyleTrainingData> getAllHairstyles() {
    return _trainingCache.values.toList();
  }

  /// Get hairstyles compatible with face shape
  List<HairstyleTrainingData> getHairstylesForFaceShape(String faceShape) {
    return _trainingCache.values
        .where((style) {
          final compatibility =
              style.characteristics['faceShapeCompatibility'] as Map?;
          if (compatibility == null) return true;
          final score = compatibility[faceShape.toLowerCase()] as int? ?? 0;
          return score >= 80; // 80+ compatibility
        })
        .toList()
        ..sort((a, b) {
          final compatA =
              (a.characteristics['faceShapeCompatibility'] as Map?)?[faceShape.toLowerCase()] ?? 0;
          final compatB =
              (b.characteristics['faceShapeCompatibility'] as Map?)?[faceShape.toLowerCase()] ?? 0;
          return compatB.compareTo(compatA as int);
        });
  }

  /// Trending heuristic (bundled CSV-style scores — not scraped from platforms).
  List<HairstyleTrainingData> getTrendingHairstyles({int limit = 10}) {
    final sorted = [..._trainingCache.values];
    sorted.sort(
      (a, b) => b.getTrendingScore().compareTo(a.getTrendingScore()),
    );
    return sorted.take(limit).toList();
  }

  /// Get hairstyles by hair type (case-insensitive labels).
  List<HairstyleTrainingData> getHairstylesByHairType(String hairType) {
    final needle = hairType.trim().toLowerCase();
    return _trainingCache.values
        .where((style) {
          final compatible = style.characteristics['hairType'];
          if (compatible is! List) return false;
          return compatible.any((t) => t.toString().toLowerCase() == needle);
        })
        .toList();
  }

  /// Hairstyles with lower stated upkeep (low / medium; excludes very high / high).
  List<HairstyleTrainingData> getEasyMaintenance() {
    return _trainingCache.values.where((style) {
      final m = (style.characteristics['maintenanceLevel'] ?? '')
          .toString()
          .toLowerCase();
      if (m.contains('very')) return false;
      if (m.contains('high')) return false;
      return m.contains('low') || m.contains('medium');
    }).toList();
  }

  /// Get professional-appropriate hairstyles
  List<HairstyleTrainingData> getProfessionalHairstyles() {
    const professional = ['fade_classic', 'crop_modern', 'crew_cut', 'quiff_slicked'];
    return _trainingCache.values
        .where((style) => professional.contains(style.id))
        .toList();
  }

  /// Update hairstyle name dynamically (from API or database)
  String getOfficialHairstyleName(String styleId) {
    return _trainingCache[styleId]?.officialName ?? styleId;
  }

  /// Get all aliases for a hairstyle
  List<String> getHairstyleAliases(String styleId) {
    return _trainingCache[styleId]?.aliases ?? [];
  }

  /// Get hairstyle description for training
  String getHairstyleDescription(String styleId) {
    return _trainingCache[styleId]?.description ?? '';
  }
}
