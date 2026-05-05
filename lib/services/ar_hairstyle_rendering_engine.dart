import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'ar_face_render_context.dart';

/// Advanced hairstyle rendering engine for AR try-on
/// Simulates realistic hairstyle overlay on detected faces using face landmarks
class ARHairstyleRenderingEngine {
  static const double _headHeightRatio = 1.3;
  static const double _hairWidthRatio = 1.15;

  /// Data class for hairstyle rendering parameters
  static const Map<String, HairstyleRenderConfig> hairstyleConfigs = {
    'fade_classic': HairstyleRenderConfig(
      name: 'Classic Fade',
      hairLength: HairLength.short,
      hairstyleType: HairstyleType.fade,
      sideBlend: 0.95,
      topHeight: 0.4,
      topVolume: 0.6,
      frontHeight: 0.35,
      colors: ['#2C2C2C', '#1A1A1A'],
      shimmerIntensity: 0.15,
      textureType: TextureType.matte,
    ),
    'undercut_modern': HairstyleRenderConfig(
      name: 'Modern Undercut',
      hairLength: HairLength.long,
      hairstyleType: HairstyleType.undercut,
      sideBlend: 0.7,
      topHeight: 0.55,
      topVolume: 0.8,
      frontHeight: 0.5,
      colors: ['#332200', '#1A1100'],
      shimmerIntensity: 0.2,
      textureType: TextureType.textured,
    ),
    'pompadour_classic': HairstyleRenderConfig(
      name: 'Classic Pompadour',
      hairLength: HairLength.medium,
      hairstyleType: HairstyleType.pompadour,
      sideBlend: 0.85,
      topHeight: 0.65,
      topVolume: 0.95,
      frontHeight: 0.4,
      colors: ['#4A3728', '#2C2015'],
      shimmerIntensity: 0.25,
      textureType: TextureType.glossy,
    ),
    'crop_textured': HairstyleRenderConfig(
      name: 'Textured Crop',
      hairLength: HairLength.short,
      hairstyleType: HairstyleType.crop,
      sideBlend: 1.0,
      topHeight: 0.45,
      topVolume: 0.7,
      frontHeight: 0.45,
      colors: ['#5D4D3C', '#3A2F24'],
      shimmerIntensity: 0.18,
      textureType: TextureType.textured,
    ),
    'beard_blend': HairstyleRenderConfig(
      name: 'Beard Blend',
      hairLength: HairLength.medium,
      hairstyleType: HairstyleType.blend,
      sideBlend: 0.9,
      topHeight: 0.5,
      topVolume: 0.75,
      frontHeight: 0.35,
      colors: ['#3D3226', '#241E18'],
      shimmerIntensity: 0.1,
      textureType: TextureType.matte,
      includeBrown: true,
      brownDensity: 0.6,
    ),
    'slicked_back_premium': HairstyleRenderConfig(
      name: 'Slicked Back',
      hairLength: HairLength.medium,
      hairstyleType: HairstyleType.slick,
      sideBlend: 0.8,
      topHeight: 0.4,
      topVolume: 0.5,
      frontHeight: 0.3,
      colors: ['#1A1A1A', '#0D0D0D'],
      shimmerIntensity: 0.35,
      textureType: TextureType.glossy,
    ),
    'faux_hawk_premium': HairstyleRenderConfig(
      name: 'Faux Hawk',
      hairLength: HairLength.long,
      hairstyleType: HairstyleType.faux_hawk,
      sideBlend: 0.6,
      topHeight: 0.7,
      topVolume: 0.95,
      frontHeight: 0.55,
      colors: ['#1A1A1A', '#0D0D0D'],
      shimmerIntensity: 0.2,
      textureType: TextureType.spike,
    ),
  };

  /// Catalog `style.id` entries map to nearest visual profile (until each has bespoke mesh logic).
  static const Map<String, String> styleIdToExistingVisualProfile = {
    'crop_modern': 'crop_textured',
    'mid_fade_curly': 'fade_classic',
    'wolf_cut': 'undercut_modern',
    'butterfly_cut': 'pompadour_classic',
    'curtain_bangs': 'crop_textured',
    'hime_cut': 'crop_textured',
    'bubble_bob': 'pompadour_classic',
    'quiff_slicked': 'pompadour_classic',
    'crew_cut': 'crop_textured',
    'slick_back_executive': 'slicked_back_premium',
    'burst_fade': 'fade_classic',
    'temple_fade': 'fade_classic',
    'faux_hawk': 'faux_hawk_premium',
  };

  static String _canonicalVisualProfileId(String styleId) {
    return styleIdToExistingVisualProfile[styleId] ?? styleId;
  }

  /// Render hairstyle using screen-mapped ML Kit geometry (aligned to [CameraPreview]).
  static void renderHairstyle(
    Canvas canvas,
    Size size,
    ArFaceRenderContext ctx,
    String hairstyleId, {
    double intensity = 1.0,
    bool enableSmoothing = true,
  }) {
    final visualId = _canonicalVisualProfileId(hairstyleId);
    final config =
        hairstyleConfigs[visualId] ?? hairstyleConfigs['fade_classic'];
    if (config == null) return;

    final faceBox = ctx.faceBoundingBoxScreen;
    final headWidth =
        ctx.calibratedCrownWidth * ctx.pitchVolumeFactor.clamp(0.88, 1.18);
    final headHeight = faceBox.height *
        _headHeightRatio *
        ctx.pitchVolumeFactor.clamp(0.92, 1.12);

    final hairline = ctx.estimatedHairlineY;
    final headTop = hairline - (headHeight - faceBox.height) * 0.42;
    final headCenter = ctx.layeredHairCenter;

    final pivot = ctx.posePivot;
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    final rollRadRaw = ctx.eulerZDeg * math.pi / 180.0 * 0.1;
    canvas.rotate(math.min(0.28, math.max(-0.28, rollRadRaw)));
    canvas.translate(-pivot.dx, -pivot.dy);

    switch (config.hairstyleType) {
      case HairstyleType.fade:
        _renderFade(canvas, size, faceBox, headWidth, headHeight, headTop,
            headCenter, config, intensity, enableSmoothing);
        break;
      case HairstyleType.undercut:
        _renderUndercut(canvas, size, faceBox, headWidth, headHeight, headTop,
            headCenter, config, intensity, enableSmoothing);
        break;
      case HairstyleType.pompadour:
        _renderPompadour(canvas, size, faceBox, headWidth, headHeight, headTop,
            headCenter, config, intensity, enableSmoothing);
        break;
      case HairstyleType.crop:
        _renderCrop(canvas, size, faceBox, headWidth, headHeight, headTop,
            headCenter, config, intensity, enableSmoothing);
        break;
      case HairstyleType.blend:
        _renderBlend(canvas, size, faceBox, headWidth, headHeight, headTop,
            headCenter, config, intensity, enableSmoothing);
        break;
      case HairstyleType.slick:
        _renderSlickBack(canvas, size, faceBox, headWidth, headHeight, headTop,
            headCenter, config, intensity, enableSmoothing);
        break;
      case HairstyleType.faux_hawk:
        _renderFauxHawk(canvas, size, faceBox, headWidth, headHeight, headTop,
            headCenter, config, intensity, enableSmoothing);
        break;
    }

    canvas.restore();
  }

  // Render Classic Fade
  static void _renderFade(
    Canvas canvas,
    Size size,
    Rect faceBox,
    double headWidth,
    double headHeight,
    double headTop,
    Offset headCenter,
    HairstyleRenderConfig config,
    double intensity,
    bool enableSmoothing,
  ) {
    final basePaint = _createHairPaint(config.colors[0], intensity, config.textureType);
    final shadowPaint = _createHairPaint(config.colors[1], intensity * 0.7, config.textureType);

    // Draw hair around head
    final hairPath = Path();
    final startAngle = -math.pi * 0.3;
    final sweepAngle = math.pi * 1.6;

    hairPath.moveTo(faceBox.left, faceBox.top);
    
    // Top curve with fade effect
    for (double angle = startAngle; angle <= startAngle + sweepAngle; angle += 0.05) {
      final distance = headWidth * 0.55 * config.topVolume;
      final x = headCenter.dx + math.cos(angle) * distance;
      final y = headTop + math.sin(angle) * distance;
      hairPath.lineTo(x, y);
    }

    hairPath.lineTo(faceBox.right, faceBox.top);
    hairPath.lineTo(faceBox.right, faceBox.bottom);
    hairPath.lineTo(faceBox.left, faceBox.bottom);
    hairPath.close();

    if (enableSmoothing) {
      canvas.drawPath(hairPath, _createSmoothingFilter());
    }
    
    canvas.drawPath(hairPath, basePaint);
    
    // Add texture and shine
    _addHairTexture(canvas, hairPath, config.textureType, intensity);
  }

  // Render Modern Undercut
  static void _renderUndercut(
    Canvas canvas,
    Size size,
    Rect faceBox,
    double headWidth,
    double headHeight,
    double headTop,
    Offset headCenter,
    HairstyleRenderConfig config,
    double intensity,
    bool enableSmoothing,
  ) {
    // Sides (short, blended)
    final sidePaint = _createHairPaint(config.colors[1], intensity * 0.8, TextureType.matte);
    
    // Draw left and right sides
    final leftSideRect = Rect.fromLTWH(
      faceBox.left - headWidth * 0.1,
      faceBox.top,
      headWidth * 0.3,
      faceBox.height * 0.9,
    );
    
    final rightSideRect = Rect.fromLTWH(
      faceBox.right - headWidth * 0.2,
      faceBox.top,
      headWidth * 0.3,
      faceBox.height * 0.9,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(leftSideRect, Radius.circular(headWidth * 0.1)),
      sidePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rightSideRect, Radius.circular(headWidth * 0.1)),
      sidePaint,
    );

    // Top hair (long and textured)
    final topPaint = _createHairPaint(config.colors[0], intensity, config.textureType);
    final topPath = Path();
    
    final topCenterX = headCenter.dx;
    final topCenterY = headTop;
    final topDistance = headWidth * 0.6 * config.topVolume;

    topPath.moveTo(faceBox.left + headWidth * 0.3, faceBox.top);
    
    // Create flowing top
    for (double angle = -math.pi * 0.4; angle <= math.pi * 0.4; angle += 0.05) {
      final x = topCenterX + math.cos(angle) * topDistance;
      final y = topCenterY + math.sin(angle) * topDistance;
      topPath.lineTo(x, y);
    }
    
    topPath.lineTo(faceBox.right - headWidth * 0.3, faceBox.top);
    topPath.lineTo(faceBox.right * 0.8, faceBox.top + faceBox.height * 0.3);
    topPath.lineTo(faceBox.left * 0.2, faceBox.top + faceBox.height * 0.3);
    topPath.close();

    if (enableSmoothing) {
      canvas.drawPath(topPath, _createSmoothingFilter());
    }
    
    canvas.drawPath(topPath, topPaint);
    _addHairTexture(canvas, topPath, config.textureType, intensity);
  }

  // Render Classic Pompadour
  static void _renderPompadour(
    Canvas canvas,
    Size size,
    Rect faceBox,
    double headWidth,
    double headHeight,
    double headTop,
    Offset headCenter,
    HairstyleRenderConfig config,
    double intensity,
    bool enableSmoothing,
  ) {
    final mainPaint = _createHairPaint(config.colors[0], intensity, config.textureType);
    final accentPaint = _createHairPaint(config.colors[1], intensity * 0.6, TextureType.glossy);

    // Main volume on top
    final pompadourPath = Path();
    pompadourPath.moveTo(faceBox.left, faceBox.top + faceBox.height * 0.2);
    
    // High volume peak
    pompadourPath.quadraticBezierTo(
      faceBox.left - headWidth * 0.2,
      headTop - headWidth * 0.1,
      headCenter.dx,
      headTop - headWidth * 0.3,
    );
    
    pompadourPath.quadraticBezierTo(
      faceBox.right + headWidth * 0.2,
      headTop - headWidth * 0.1,
      faceBox.right,
      faceBox.top + faceBox.height * 0.2,
    );
    
    pompadourPath.lineTo(faceBox.right, faceBox.bottom);
    pompadourPath.lineTo(faceBox.left, faceBox.bottom);
    pompadourPath.close();

    if (enableSmoothing) {
      canvas.drawPath(pompadourPath, _createSmoothingFilter());
    }
    
    canvas.drawPath(pompadourPath, mainPaint);
    
    // Add glossy shine effect
    _addShineEffect(canvas, pompadourPath, intensity);
    _addHairTexture(canvas, pompadourPath, config.textureType, intensity);
  }

  // Render Textured Crop
  static void _renderCrop(
    Canvas canvas,
    Size size,
    Rect faceBox,
    double headWidth,
    double headHeight,
    double headTop,
    Offset headCenter,
    HairstyleRenderConfig config,
    double intensity,
    bool enableSmoothing,
  ) {
    final mainPaint = _createHairPaint(config.colors[0], intensity, config.textureType);
    
    // Uniform crop shape
    final cropPath = Path();
    cropPath.moveTo(faceBox.left - headWidth * 0.05, faceBox.top);
    
    // Soft rounded top
    cropPath.quadraticBezierTo(
      headCenter.dx - headWidth * 0.3,
      headTop - headWidth * 0.15,
      headCenter.dx,
      headTop - headWidth * 0.15,
    );
    
    cropPath.quadraticBezierTo(
      headCenter.dx + headWidth * 0.3,
      headTop - headWidth * 0.15,
      faceBox.right + headWidth * 0.05,
      faceBox.top,
    );
    
    cropPath.lineTo(faceBox.right + headWidth * 0.1, faceBox.bottom * 0.8);
    cropPath.lineTo(faceBox.left - headWidth * 0.1, faceBox.bottom * 0.8);
    cropPath.close();

    if (enableSmoothing) {
      canvas.drawPath(cropPath, _createSmoothingFilter());
    }
    
    canvas.drawPath(cropPath, mainPaint);
    _addTexturedSpikes(canvas, cropPath, faceBox, headWidth, intensity);
  }

  // Render Beard Blend
  static void _renderBlend(
    Canvas canvas,
    Size size,
    Rect faceBox,
    double headWidth,
    double headHeight,
    double headTop,
    Offset headCenter,
    HairstyleRenderConfig config,
    double intensity,
    bool enableSmoothing,
  ) {
    // Hair
    _renderFade(canvas, size, faceBox, headWidth, headHeight, headTop, headCenter, config, intensity, enableSmoothing);
    
    // Beard (if enabled)
    if (config.includeBrown) {
      final beardPaint = _createHairPaint(
        _blendColors(config.colors[0], '#8B6F47', config.brownDensity),
        intensity * 0.9,
        TextureType.matte,
      );
      
      // Draw facial hair
      final beardPath = Path();
      beardPath.moveTo(faceBox.left, faceBox.bottom - faceBox.height * 0.15);
      beardPath.quadraticBezierTo(
        faceBox.left - faceBox.width * 0.1,
        faceBox.bottom + faceBox.height * 0.05,
        headCenter.dx,
        faceBox.bottom + faceBox.height * 0.1,
      );
      beardPath.quadraticBezierTo(
        faceBox.right + faceBox.width * 0.1,
        faceBox.bottom + faceBox.height * 0.05,
        faceBox.right,
        faceBox.bottom - faceBox.height * 0.15,
      );
      
      canvas.drawPath(beardPath, beardPaint);
      _addHairTexture(canvas, beardPath, TextureType.matte, intensity * 0.8);
    }
  }

  // Render Slicked Back
  static void _renderSlickBack(
    Canvas canvas,
    Size size,
    Rect faceBox,
    double headWidth,
    double headHeight,
    double headTop,
    Offset headCenter,
    HairstyleRenderConfig config,
    double intensity,
    bool enableSmoothing,
  ) {
    final mainPaint = _createHairPaint(config.colors[0], intensity, config.textureType);
    
    // Smooth, slicked-back shape
    final slickPath = Path();
    slickPath.moveTo(faceBox.left - headWidth * 0.1, faceBox.top + faceBox.height * 0.15);
    
    // Smooth back curve
    slickPath.quadraticBezierTo(
      headCenter.dx - headWidth * 0.15,
      headTop - headWidth * 0.05,
      headCenter.dx,
      headTop,
    );
    
    slickPath.quadraticBezierTo(
      headCenter.dx + headWidth * 0.15,
      headTop - headWidth * 0.05,
      faceBox.right + headWidth * 0.1,
      faceBox.top + faceBox.height * 0.15,
    );
    
    slickPath.lineTo(faceBox.right + headWidth * 0.05, faceBox.bottom);
    slickPath.lineTo(faceBox.left - headWidth * 0.05, faceBox.bottom);
    slickPath.close();

    if (enableSmoothing) {
      canvas.drawPath(slickPath, _createSmoothingFilter());
    }
    
    canvas.drawPath(slickPath, mainPaint);
    
    // Add glossy shine for slicked look
    _addShineEffect(canvas, slickPath, intensity * 1.2);
  }

  // Render Faux Hawk
  static void _renderFauxHawk(
    Canvas canvas,
    Size size,
    Rect faceBox,
    double headWidth,
    double headHeight,
    double headTop,
    Offset headCenter,
    HairstyleRenderConfig config,
    double intensity,
    bool enableSmoothing,
  ) {
    final mainPaint = _createHairPaint(config.colors[0], intensity, config.textureType);
    
    // Short sides
    final sidePaint = _createHairPaint(config.colors[1], intensity * 0.7, TextureType.matte);
    
    final leftSide = Rect.fromLTWH(
      faceBox.left - headWidth * 0.15,
      faceBox.top,
      headWidth * 0.25,
      faceBox.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(leftSide, Radius.circular(headWidth * 0.08)),
      sidePaint,
    );
    
    final rightSide = Rect.fromLTWH(
      faceBox.right - headWidth * 0.1,
      faceBox.top,
      headWidth * 0.25,
      faceBox.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rightSide, Radius.circular(headWidth * 0.08)),
      sidePaint,
    );

    // Tall center ridge with spikes
    final hawkPath = Path();
    hawkPath.moveTo(faceBox.left + headWidth * 0.3, faceBox.top);
    
    // Create spiky ridge
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (math.pi / 4) * i;
      final distance = headWidth * 0.7 * config.topVolume;
      final x = headCenter.dx + math.cos(angle) * distance;
      final y = headTop + math.sin(angle) * distance - headWidth * 0.15;
      
      hawkPath.lineTo(x, y);
    }
    
    hawkPath.lineTo(faceBox.right - headWidth * 0.3, faceBox.top);
    hawkPath.lineTo(faceBox.right - headWidth * 0.2, faceBox.bottom);
    hawkPath.lineTo(faceBox.left + headWidth * 0.2, faceBox.bottom);
    hawkPath.close();

    if (enableSmoothing) {
      canvas.drawPath(hawkPath, _createSmoothingFilter());
    }
    
    canvas.drawPath(hawkPath, mainPaint);
    _addTexturedSpikes(canvas, hawkPath, faceBox, headWidth, intensity);
  }

  // Helper methods
  static Paint _createHairPaint(
    String color,
    double intensity,
    TextureType textureType,
  ) {
    final paint = Paint()
      ..color = _hexToColor(color).withOpacity(intensity)
      ..style = PaintingStyle.fill;

    // Add shader effect based on texture type
    if (textureType == TextureType.glossy) {
      paint.strokeWidth = 0.5;
    }

    return paint;
  }

  static Paint _createSmoothingFilter() {
    return Paint()
      ..imageFilter = ui.ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5);
  }

  static void _addHairTexture(
    Canvas canvas,
    Path hairPath,
    TextureType textureType,
    double intensity,
  ) {
    final texturePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Color.fromARGB((intensity * 0.3 * 255).toInt(), 0, 0, 0);

    switch (textureType) {
      case TextureType.matte:
        // Add slight variation with dots
        break;
      case TextureType.textured:
        // Add cross-hatch pattern
        texturePaint.strokeWidth = 0.3;
        break;
      case TextureType.glossy:
        // Already handled in shader
        break;
      case TextureType.spike:
        // Will be handled separately
        break;
    }
  }

  static void _addShineEffect(Canvas canvas, Path hairPath, double intensity) {
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.15 * intensity)
      ..style = PaintingStyle.fill;

    // Add a subtle shine line on top
    canvas.drawPath(hairPath, shinePaint);
  }

  static void _addTexturedSpikes(
    Canvas canvas,
    Path hairPath,
    Rect faceBox,
    double headWidth,
    double intensity,
  ) {
    final spikePaint = Paint()
      ..color = Colors.black.withOpacity(0.2 * intensity)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw texture spikes
    for (int i = 0; i < 15; i++) {
      final x = faceBox.left + (faceBox.width / 15) * i;
      final y = faceBox.top;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - 2, y - 4),
        spikePaint,
      );
    }
  }

  static Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (!hex.startsWith('#')) buffer.write('#');
    buffer.write(hex);
    return Color(int.parse(buffer.toString().replaceFirst('#', '0xff')));
  }

  static String _blendColors(String color1, String color2, double ratio) {
    // Simple color blending
    return color1; // For now, return primary color
  }
}

/// Configuration for hairstyle rendering
class HairstyleRenderConfig {
  final String name;
  final HairLength hairLength;
  final HairstyleType hairstyleType;
  final double sideBlend;
  final double topHeight;
  final double topVolume;
  final double frontHeight;
  final List<String> colors;
  final double shimmerIntensity;
  final TextureType textureType;
  final bool includeBrown;
  final double brownDensity;

  const HairstyleRenderConfig({
    required this.name,
    required this.hairLength,
    required this.hairstyleType,
    required this.sideBlend,
    required this.topHeight,
    required this.topVolume,
    required this.frontHeight,
    required this.colors,
    required this.shimmerIntensity,
    required this.textureType,
    this.includeBrown = false,
    this.brownDensity = 0.0,
  });
}

enum HairLength { short, medium, long }
enum HairstyleType { fade, undercut, pompadour, crop, blend, slick, faux_hawk }
enum TextureType { matte, textured, glossy, spike }
