import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../models/hairstyle_training_data.dart';
import 'hairstyle_training_data_service.dart';

/// Enhanced AR hairstyle recommendation service
/// Combines ML face analysis with real training data for accurate recommendations
class ARHairstyleRecommendationService {
  static final ARHairstyleRecommendationService _instance =
      ARHairstyleRecommendationService._internal();

  late HairstyleTrainingDataService _trainingDataService;
  bool _isInitialized = false;

  factory ARHairstyleRecommendationService() {
    return _instance;
  }

  ARHairstyleRecommendationService._internal();

  /// Initialize with training data service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _trainingDataService = HairstyleTrainingDataService();
    await _trainingDataService.initialize();
    _isInitialized = true;

    print('✅ AR Hairstyle Recommendation Service initialized');
  }

  /// Get hairstyle recommendations based on face analysis
  Future<HairstyleRecommendations> getRecommendations(
    String faceShape,
    String hairType,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Get compatible hairstyles for face shape
      final compatibleByFaceShape =
          _trainingDataService.getHairstylesForFaceShape(faceShape);

      // Filter by hair type compatibility
      final needle = hairType.trim().toLowerCase();
      final compatible = compatibleByFaceShape
          .where((style) {
            final hairTypes = style.characteristics['hairType'];
            if (hairTypes is! List) return true;
            return hairTypes.any((t) => t.toString().toLowerCase() == needle);
          })
          .toList();

      // Get trending hairstyles that also match
      final trending =
          _trainingDataService.getTrendingHairstyles(limit: 6);

      // Get easy maintenance options
      final easyMaintenance = _trainingDataService.getEasyMaintenance();

      // Rank recommendations by multiple factors
      final ranked = _rankRecommendations(
        face: null,
        faceShape: faceShape,
        hairType: hairType,
        candidates: compatible,
      );

      return HairstyleRecommendations(
        topRecommendations: ranked.take(6).toList(),
        allCompatible: compatible,
        trending: trending,
        easyMaintenance: easyMaintenance,
        faceShapeMatch: faceShape,
        hairTypeMatch: hairType,
      );
    } catch (e) {
      print('Error getting recommendations: $e');
      return HairstyleRecommendations.empty();
    }
  }

  /// Get specific hairstyle training data
  HairstyleTrainingData? getHairstyleData(String styleId) {
    if (!_isInitialized) {
      return null;
    }
    return _trainingDataService.getHairstyleData(styleId);
  }

  /// Get official hairstyle name from training data
  String getOfficialName(String styleId) {
    if (!_isInitialized) {
      return styleId;
    }
    return _trainingDataService.getOfficialHairstyleName(styleId);
  }

  /// Get hairstyle description for training
  String getDescription(String styleId) {
    if (!_isInitialized) {
      return '';
    }
    return _trainingDataService.getHairstyleDescription(styleId);
  }

  /// Rank hairstyle recommendations
  List<HairstyleTrainingData> _rankRecommendations({
    Face? face,
    required String faceShape,
    required String hairType,
    required List<HairstyleTrainingData> candidates,
  }) {
    return candidates.toList()
      ..sort((a, b) {
        // Score based on multiple factors
        final scoreA = _calculateRecommendationScore(a, faceShape, hairType);
        final scoreB = _calculateRecommendationScore(b, faceShape, hairType);
        return scoreB.compareTo(scoreA);
      });
  }

  /// Calculate recommendation score
  double _calculateRecommendationScore(
    HairstyleTrainingData hairstyle,
    String faceShape,
    String hairType,
  ) {
    double score = 0;

    // Face shape compatibility (weight: 40%)
    final faceCompatibility = hairstyle.getCompatibilityScore(faceShape);
    score += faceCompatibility * 0.4;

    // Trending score (weight: 30%)
    score += hairstyle.getTrendingScore() * 0.3;

    // Easy maintenance bonus (weight: 15%)
    final maintenance =
        hairstyle.characteristics['maintenanceLevel']?.toString().toLowerCase() ?? '';
    if (maintenance.contains('low') && !maintenance.contains('very')) {
      score += 15;
    } else if (maintenance == 'medium') {
      score += 10;
    }

    // Hair type compatibility (weight: 15%)
    final hairTypes = hairstyle.characteristics['hairType'];
    final needle = hairType.trim().toLowerCase();
    if (hairTypes is List &&
        hairTypes.any((t) => t.toString().toLowerCase() == needle)) {
      score += 15;
    }

    return score;
  }

  /// Get all hairstyles for AR training
  List<HairstyleTrainingData> getAllHairstylesForTraining() {
    if (!_isInitialized) {
      return [];
    }
    return _trainingDataService.getAllHairstyles();
  }

  /// Search hairstyles by characteristics
  List<HairstyleTrainingData> searchByTag(String tag) {
    if (!_isInitialized) {
      return [];
    }

    return _trainingDataService.getAllHairstyles()
        .where((style) => style.tags.contains(tag.toLowerCase()))
        .toList();
  }

  /// Get hairstyle by difficulty level
  List<HairstyleTrainingData> getByDifficultyLevel(int maxDifficulty) {
    if (!_isInitialized) {
      return [];
    }

    return _trainingDataService.getAllHairstyles()
        .where((style) => style.barberDifficultyScore <= maxDifficulty)
        .toList();
  }
}

/// Hairstyle recommendations result
class HairstyleRecommendations {
  final List<HairstyleTrainingData> topRecommendations;
  final List<HairstyleTrainingData> allCompatible;
  final List<HairstyleTrainingData> trending;
  final List<HairstyleTrainingData> easyMaintenance;
  final String faceShapeMatch;
  final String hairTypeMatch;

  HairstyleRecommendations({
    required this.topRecommendations,
    required this.allCompatible,
    required this.trending,
    required this.easyMaintenance,
    required this.faceShapeMatch,
    required this.hairTypeMatch,
  });

  factory HairstyleRecommendations.empty() {
    return HairstyleRecommendations(
      topRecommendations: [],
      allCompatible: [],
      trending: [],
      easyMaintenance: [],
      faceShapeMatch: 'unknown',
      hairTypeMatch: 'unknown',
    );
  }

  /// Get top N recommendations
  List<HairstyleTrainingData> getTopN(int n) {
    return topRecommendations.take(n).toList();
  }

  /// Check if empty
  bool get isEmpty => topRecommendations.isEmpty;

  /// Get as JSON
  Map<String, dynamic> toJson() => {
        'topRecommendations':
            topRecommendations.map((s) => s.toJson()).toList(),
        'allCompatibleCount': allCompatible.length,
        'trendingCount': trending.length,
        'easyMaintenanceCount': easyMaintenance.length,
        'faceShapeMatch': faceShapeMatch,
        'hairTypeMatch': hairTypeMatch,
      };
}
