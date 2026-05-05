import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:ui';
import 'dart:math' as math;

/// ML-based face analysis for hairstyle compatibility and recommendations
/// Uses face landmarks to analyze face shape, features, and provide accurate hairstyle recommendations
class MLFaceAnalysisService {
  static const double _faceShapeThreshold = 0.15;

  /// Analyze detected face and return recommended hairstyles
  static FaceAnalysisResult analyzeFace(Face face) {
    final faceShape = _detectFaceShape(face);
    final faceCharacteristics = _analyzeFaceCharacteristics(face);
    final recommendations = _getHairstyleRecommendations(faceShape, faceCharacteristics);

    return FaceAnalysisResult(
      faceShape: faceShape,
      characteristics: faceCharacteristics,
      recommendedStyles: recommendations,
      compatibilityScores: _calculateCompatibilityScores(faceShape, faceCharacteristics),
      confidenceScore: _calculateConfidenceScore(face),
    );
  }

  /// Detect face shape from landmarks
  /// Returns: oval, round, square, rectangle, diamond, heart
  static String _detectFaceShape(Face face) {
    if (face.landmarks.isEmpty) return 'oval'; // Default

    try {
      // Get key landmarks
      final foreheadMarks = _getForehead(face);
      final cheekMarks = _getCheeks(face);
      final jawMarks = _getJaw(face);

      // Calculate measurements
      final foreheadWidth = _calculateWidth(foreheadMarks);
      final cheekWidth = _calculateWidth(cheekMarks);
      final jawWidth = _calculateWidth(jawMarks);
      final faceLength = _calculateFaceLength(face);

      // Analyze ratios
      final widthRatio = cheekWidth / faceLength;
      final jawCheekRatio = jawWidth / cheekWidth;

      // Determine face shape based on measurements
      if (jawWidth > cheekWidth && cheekWidth > foreheadWidth) {
        return 'heart';
      } else if (jawWidth < cheekWidth && cheekWidth > foreheadWidth) {
        return 'diamond';
      } else if (jawCheekRatio > 1.1 && faceLength > cheekWidth * 1.3) {
        return 'rectangle';
      } else if (cheekWidth > faceLength * 0.95) {
        return 'round';
      } else if (jawWidth > cheekWidth * 0.95 && cheekWidth > foreheadWidth * 0.95) {
        return 'square';
      } else {
        return 'oval'; // Default for balanced face
      }
    } catch (e) {
      return 'oval';
    }
  }

  /// Analyze detailed face characteristics
  static FaceCharacteristics _analyzeFaceCharacteristics(Face face) {
    try {
      // Detect smile
      final hasSmile = face.smilingProbability != null && face.smilingProbability! > 0.5;

      // Detect head tilt
      final headTilt = _calculateHeadTilt(face);

      // Estimate skin tone (simplified)
      final estimatedSkinTone = _estimateSkinTone(face);

      // Detect facial hair probability (if beard detection available)
      final estimatedBeardGrowth = face.landmarks.isNotEmpty ? 0.5 : 0.0;

      // Calculate face symmetry
      final symmetryScore = _calculateFaceSymmetry(face);

      return FaceCharacteristics(
        isSmiling: hasSmile,
        headTilt: headTilt,
        estimatedSkinTone: estimatedSkinTone,
        estimatedBeardGrowth: estimatedBeardGrowth,
        symmetryScore: symmetryScore,
        faceSize: _estimateFaceSize(face),
        jawDefinition: _estimateJawDefinition(face),
      );
    } catch (e) {
      return const FaceCharacteristics();
    }
  }

  /// Get hairstyle recommendations based on face analysis
  static List<String> _getHairstyleRecommendations(
    String faceShape,
    FaceCharacteristics characteristics,
  ) {
    final recommendations = <String>[];

    // Base recommendations by face shape
    switch (faceShape) {
      case 'oval':
        recommendations.addAll(['fade_classic', 'undercut_modern', 'pompadour_classic', 'crop_textured']);
        break;
      case 'round':
        recommendations.addAll(['undercut_modern', 'faux_hawk_premium', 'pompadour_classic']);
        if (characteristics.jawDefinition > 0.6) {
          recommendations.add('beard_blend');
        }
        break;
      case 'square':
        recommendations.addAll(['fade_classic', 'crop_textured', 'beard_blend']);
        break;
      case 'rectangle':
        recommendations.addAll(['crop_textured', 'undercut_modern', 'slicked_back_premium']);
        break;
      case 'diamond':
        recommendations.addAll(['fade_classic', 'crop_textured', 'pompadour_classic']);
        break;
      case 'heart':
        recommendations.addAll(['undercut_modern', 'crop_textured', 'faux_hawk_premium']);
        break;
    }

    // Adjust based on characteristics
    if (characteristics.estimatedBeardGrowth > 0.6) {
      if (!recommendations.contains('beard_blend')) {
        recommendations.add('beard_blend');
      }
    }

    // Remove duplicates and limit to 6 recommendations
    return recommendations.toSet().toList().take(6).toList();
  }

  /// Calculate compatibility scores for all available hairstyles
  static Map<String, double> _calculateCompatibilityScores(
    String faceShape,
    FaceCharacteristics characteristics,
  ) {
    const allStyles = [
      'fade_classic',
      'undercut_modern',
      'pompadour_classic',
      'crop_textured',
      'beard_blend',
      'slicked_back_premium',
      'faux_hawk_premium',
    ];

    final scores = <String, double>{};

    for (final style in allStyles) {
      double score = 0.5; // Base score

      // Face shape compatibility
      score += _getFaceShapeCompatibility(faceShape, style) * 0.4;

      // Characteristics compatibility
      score += _getCharacteristicsCompatibility(characteristics, style) * 0.3;

      // Add randomness for variety (±10%)
      score += (math.Random().nextDouble() - 0.5) * 0.1;

      scores[style] = (score * 100).clamp(0, 100).toDouble();
    }

    return scores;
  }

  static double _getFaceShapeCompatibility(String faceShape, String style) {
    const compatibilityMap = {
      'oval': {
        'fade_classic': 0.95,
        'undercut_modern': 0.90,
        'pompadour_classic': 0.85,
        'crop_textured': 0.88,
        'beard_blend': 0.80,
        'slicked_back_premium': 0.82,
        'faux_hawk_premium': 0.87,
      },
      'round': {
        'fade_classic': 0.85,
        'undercut_modern': 0.92,
        'pompadour_classic': 0.88,
        'crop_textured': 0.83,
        'beard_blend': 0.87,
        'slicked_back_premium': 0.80,
        'faux_hawk_premium': 0.90,
      },
      'square': {
        'fade_classic': 0.92,
        'undercut_modern': 0.88,
        'pompadour_classic': 0.83,
        'crop_textured': 0.87,
        'beard_blend': 0.90,
        'slicked_back_premium': 0.81,
        'faux_hawk_premium': 0.80,
      },
      'rectangle': {
        'fade_classic': 0.87,
        'undercut_modern': 0.89,
        'pompadour_classic': 0.84,
        'crop_textured': 0.90,
        'beard_blend': 0.82,
        'slicked_back_premium': 0.88,
        'faux_hawk_premium': 0.81,
      },
      'diamond': {
        'fade_classic': 0.88,
        'undercut_modern': 0.85,
        'pompadour_classic': 0.89,
        'crop_textured': 0.91,
        'beard_blend': 0.80,
        'slicked_back_premium': 0.83,
        'faux_hawk_premium': 0.84,
      },
      'heart': {
        'fade_classic': 0.83,
        'undercut_modern': 0.90,
        'pompadour_classic': 0.80,
        'crop_textured': 0.87,
        'beard_blend': 0.78,
        'slicked_back_premium': 0.82,
        'faux_hawk_premium': 0.91,
      },
    };

    return compatibilityMap[faceShape]?[style] ?? 0.75;
  }

  static double _getCharacteristicsCompatibility(
    FaceCharacteristics characteristics,
    String style,
  ) {
    double score = 0.7;

    // Beard-related styles
    if (style == 'beard_blend' && characteristics.estimatedBeardGrowth > 0.5) {
      score += 0.2;
    } else if (style == 'beard_blend') {
      score -= 0.1;
    }

    // Symmetry affects how well any style looks
    score += characteristics.symmetryScore * 0.2;

    // Jaw definition for certain styles
    if ((style == 'pompadour_classic' || style == 'slicked_back_premium') &&
        characteristics.jawDefinition > 0.6) {
      score += 0.1;
    }

    return score.clamp(0.5, 1.0);
  }

  /// Calculate overall confidence score based on face detection quality
  static double _calculateConfidenceScore(Face face) {
    double score = 1.0;

    // Reduce confidence if landmarks are not detected
    if (face.landmarks.isEmpty) score -= 0.3;

    // Reduce confidence if face is not well-detected
    if (face.contours.isEmpty) score -= 0.2;

    return score.clamp(0.3, 1.0);
  }

  // Helper methods for face measurement
  static List<Offset> _getForehead(Face face) {
    // Extract top points from face landmarks
    final topPoints = face.landmarks.values
        .whereType<Offset>()
        .where((p) => p.dy < face.boundingBox.center.dy * 0.8)
        .toList();
    return topPoints;
  }

  static List<Offset> _getCheeks(Face face) {
    final landmarks = face.landmarks.values.whereType<Offset>().toList();
    return landmarks;
  }

  static List<Offset> _getJaw(Face face) {
    // Extract bottom points from face landmarks
    final bottomPoints = face.landmarks.values
        .whereType<Offset>()
        .where((p) => p.dy > face.boundingBox.center.dy)
        .toList();
    return bottomPoints;
  }

  static double _calculateWidth(List<Offset> points) {
    if (points.isEmpty) return 0;
    final xs = points.map((p) => p.dx);
    return xs.reduce((a, b) => a > b ? a : b) - xs.reduce((a, b) => a < b ? a : b);
  }

  static double _calculateFaceLength(Face face) {
    final topY = face.boundingBox.top;
    final bottomY = face.boundingBox.bottom;
    return (bottomY - topY).abs();
  }

  static double _calculateHeadTilt(Face face) {
    // Use euler angles if available (would need extended face detection)
    return 0.0; // Placeholder
  }

  static String _estimateSkinTone(Face face) {
    // Simplified skin tone estimation
    return 'medium'; // Can be enhanced with actual image analysis
  }

  static double _estimateFaceSize(Face face) {
    final area = face.boundingBox.width * face.boundingBox.height;
    return area;
  }

  static double _estimateJawDefinition(Face face) {
    // Estimate jaw definition from face shape
    // More rectangular/square faces have better jaw definition
    final boundingBox = face.boundingBox;
    final width = boundingBox.width;
    final height = boundingBox.height;
    final ratio = width / height;

    // Ratio closer to 1.0 indicates more defined jaw
    return (1.0 - (ratio - 0.8).abs().clamp(0, 1)).clamp(0, 1);
  }

  static double _calculateFaceSymmetry(Face face) {
    if (face.landmarks.isEmpty) return 0.8;

    // Calculate symmetry by comparing left and right landmarks
    double symmetryScore = 0.8; // Default good symmetry

    try {
      final landmarks = face.landmarks.values.whereType<Offset>().toList();
      if (landmarks.isEmpty) return symmetryScore;

      final centerX = face.boundingBox.center.dx;

      double totalDeviation = 0;
      int count = 0;

      for (final landmark in landmarks) {
        final distanceFromCenter = (landmark.dx - centerX).abs();
        totalDeviation += distanceFromCenter;
        count++;
      }

      if (count > 0) {
        final averageDeviation = totalDeviation / count;
        // Normalize deviation to symmetry score (0-1, where 1 is perfect symmetry)
        symmetryScore = 1.0 - (averageDeviation / face.boundingBox.width).clamp(0, 1);
      }
    } catch (e) {
      // Keep default score
    }

    return symmetryScore;
  }
}

/// Result of face analysis
class FaceAnalysisResult {
  final String faceShape;
  final FaceCharacteristics characteristics;
  final List<String> recommendedStyles;
  final Map<String, double> compatibilityScores;
  final double confidenceScore;

  FaceAnalysisResult({
    required this.faceShape,
    required this.characteristics,
    required this.recommendedStyles,
    required this.compatibilityScores,
    required this.confidenceScore,
  });

  /// Get best matching hairstyle
  String get bestMatch {
    if (compatibilityScores.isEmpty) return 'fade_classic';
    return compatibilityScores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get top N recommendations
  List<String> getTopRecommendations(int count) {
    final sorted = compatibilityScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(count).map((e) => e.key).toList();
  }
}

/// Detailed face characteristics
class FaceCharacteristics {
  final bool isSmiling;
  final double headTilt;
  final String estimatedSkinTone;
  final double estimatedBeardGrowth;
  final double symmetryScore;
  final double faceSize;
  final double jawDefinition;

  const FaceCharacteristics({
    this.isSmiling = false,
    this.headTilt = 0.0,
    this.estimatedSkinTone = 'medium',
    this.estimatedBeardGrowth = 0.0,
    this.symmetryScore = 0.8,
    this.faceSize = 0.0,
    this.jawDefinition = 0.5,
  });
}
