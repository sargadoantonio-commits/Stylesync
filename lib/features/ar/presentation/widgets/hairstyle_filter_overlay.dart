import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../models/hairstyle_filter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/enhanced_design_system.dart';

/// Widget for rendering hairstyle filters on detected faces
class HairstyleFilterOverlay extends StatelessWidget {
  final List<Face> detectedFaces;
  final HairstyleFilter? selectedFilter;
  final FilterApplicationState? filterState;

  const HairstyleFilterOverlay({
    super.key,
    required this.detectedFaces,
    this.selectedFilter,
    this.filterState,
  });

  @override
  Widget build(BuildContext context) {
    if (detectedFaces.isEmpty || selectedFilter == null) {
      return const SizedBox.expand();
    }

    return CustomPaint(
      painter: HairstyleFilterPainter(
        faces: detectedFaces,
        filter: selectedFilter!,
        filterState: filterState ?? const FilterApplicationState(),
      ),
      child: const SizedBox.expand(),
    );
  }
}

/// Custom painter for rendering hairstyle filters
class HairstyleFilterPainter extends CustomPainter {
  final List<Face> faces;
  final HairstyleFilter filter;
  final FilterApplicationState filterState;

  HairstyleFilterPainter({
    required this.faces,
    required this.filter,
    required this.filterState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final face in faces) {
      _drawHairstyleFilter(canvas, size, face);
    }
  }

  void _drawHairstyleFilter(Canvas canvas, Size size, Face face) {
    final bounds = face.boundingBox;
    
    // Calculate hairstyle position (above head)
    final centerX = bounds.center.dx;
    final topY = bounds.top - 20;
    final width = bounds.width;
    final height = bounds.height * 0.8;

    // Draw filter based on style code
    switch (filter.styleCode) {
      case 'fade_classic':
        _drawFadeHairstyle(canvas, centerX, topY, width, height);
        break;
      case 'undercut_modern':
        _drawUndercutHairstyle(canvas, centerX, topY, width, height);
        break;
      case 'pompadour_classic':
        _drawPompadourHairstyle(canvas, centerX, topY, width, height);
        break;
      case 'crop_textured':
        _drawCropHairstyle(canvas, centerX, topY, width, height);
        break;
      case 'beard_blend':
        _drawBeardBlend(canvas, face.boundingBox);
        break;
      case 'slicked_back_premium':
        _drawSlickedBackHairstyle(canvas, centerX, topY, width, height);
        break;
      case 'faux_hawk_premium':
        _drawFauxHawkHairstyle(canvas, centerX, topY, width, height);
        break;
      default:
        _drawDefaultHairstyle(canvas, centerX, topY, width, height);
    }

    // Draw filter info badge
    _drawFilterBadge(canvas, size);
  }

  void _drawFadeHairstyle(Canvas canvas, double cx, double cy, double w, double h) {
    final paint = Paint()
      ..color = filter.primaryColor.withValues(alpha: filterState.intensity)
      ..style = PaintingStyle.fill;

    // Draw hair outline (oval shape)
    final path = Path();
    path.moveTo(cx - w / 2, cy);
    path.quadraticBezierTo(cx - w / 2.5, cy - h, cx, cy - h * 1.2);
    path.quadraticBezierTo(cx + w / 2.5, cy - h, cx + w / 2, cy);
    path.lineTo(cx + w / 2, cy + h * 0.3);
    path.quadraticBezierTo(cx, cy + h * 0.4, cx - w / 2, cy + h * 0.3);
    path.close();

    canvas.drawPath(path, paint);

    // Draw fade lines (vertical lines for fade effect)
    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3 * filterState.intensity)
      ..strokeWidth = 2;

    for (int i = 0; i < 4; i++) {
      final xOffset = (i - 1.5) * (w / 5);
      canvas.drawLine(
        Offset(cx + xOffset, cy + h * 0.1),
        Offset(cx + xOffset, cy + h * 0.35),
        linePaint,
      );
    }
  }

  void _drawUndercutHairstyle(Canvas canvas, double cx, double cy, double w, double h) {
    final paint = Paint()
      ..color = filter.primaryColor.withValues(alpha: filterState.intensity)
      ..style = PaintingStyle.fill;

    // Draw undercut (two parts: long top + short sides)
    final topPath = Path();
    topPath.moveTo(cx - w / 3, cy);
    topPath.quadraticBezierTo(cx - w / 4, cy - h * 0.8, cx, cy - h * 1.3);
    topPath.quadraticBezierTo(cx + w / 4, cy - h * 0.8, cx + w / 3, cy);
    topPath.lineTo(cx + w / 3, cy + h * 0.2);
    topPath.lineTo(cx - w / 3, cy + h * 0.2);
    topPath.close();

    canvas.drawPath(topPath, paint);

    // Draw sides (darker shade)
    final sidePaint = Paint()
      ..color = filter.accentColor.withValues(alpha: filterState.intensity * 0.7)
      ..style = PaintingStyle.fill;

    final leftSidePath = Path();
    leftSidePath.moveTo(cx - w / 3, cy);
    leftSidePath.lineTo(cx - w / 2, cy);
    leftSidePath.lineTo(cx - w / 2, cy + h * 0.35);
    leftSidePath.lineTo(cx - w / 3, cy + h * 0.2);
    leftSidePath.close();

    final rightSidePath = Path();
    rightSidePath.moveTo(cx + w / 3, cy);
    rightSidePath.lineTo(cx + w / 2, cy);
    rightSidePath.lineTo(cx + w / 2, cy + h * 0.35);
    rightSidePath.lineTo(cx + w / 3, cy + h * 0.2);
    rightSidePath.close();

    canvas.drawPath(leftSidePath, sidePaint);
    canvas.drawPath(rightSidePath, sidePaint);
  }

  void _drawPompadourHairstyle(Canvas canvas, double cx, double cy, double w, double h) {
    final paint = Paint()
      ..color = filter.primaryColor.withValues(alpha: filterState.intensity)
      ..style = PaintingStyle.fill;

    // Draw pompadour (high volume on top)
    final path = Path();
    path.moveTo(cx - w / 2.5, cy);
    path.quadraticBezierTo(cx - w / 3, cy - h * 1.5, cx, cy - h * 1.8);
    path.quadraticBezierTo(cx + w / 3, cy - h * 1.5, cx + w / 2.5, cy);
    path.lineTo(cx + w / 2.5, cy + h * 0.25);
    path.lineTo(cx - w / 2.5, cy + h * 0.25);
    path.close();

    canvas.drawPath(path, paint);

    // Add glossy shine effect
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2 * filterState.intensity)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - w / 6, cy - h * 1.2),
        width: w / 4,
        height: h / 3,
      ),
      shinePaint,
    );
  }

  void _drawCropHairstyle(Canvas canvas, double cx, double cy, double w, double h) {
    final paint = Paint()
      ..color = filter.primaryColor.withValues(alpha: filterState.intensity)
      ..style = PaintingStyle.fill;

    // Draw crop (shorter, textured)
    final path = Path();
    path.moveTo(cx - w / 2.2, cy);
    path.quadraticBezierTo(cx - w / 2.5, cy - h * 0.7, cx, cy - h * 0.9);
    path.quadraticBezierTo(cx + w / 2.5, cy - h * 0.7, cx + w / 2.2, cy);
    path.lineTo(cx + w / 2.2, cy + h * 0.3);
    path.lineTo(cx - w / 2.2, cy + h * 0.3);
    path.close();

    canvas.drawPath(path, paint);

    // Add texture dots
    final texturePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3 * filterState.intensity);

    for (int i = -2; i <= 2; i++) {
      for (int j = 0; j < 2; j++) {
        canvas.drawCircle(
          Offset(cx + i * w / 6, cy - h * (0.3 + j * 0.25)),
          2,
          texturePaint,
        );
      }
    }
  }

  void _drawBeardBlend(Canvas canvas, Rect faceBounds) {
    final paint = Paint()
      ..color = filter.primaryColor.withValues(alpha: filterState.intensity * 0.6)
      ..style = PaintingStyle.fill;

    // Draw beard outline
    final beardPath = Path();
    beardPath.moveTo(faceBounds.bottomLeft.dx, faceBounds.bottomLeft.dy - 20);
    beardPath.quadraticBezierTo(
      faceBounds.left,
      faceBounds.bottomLeft.dy + 15,
      faceBounds.center.dx,
      faceBounds.bottomRight.dy + 20,
    );
    beardPath.quadraticBezierTo(
      faceBounds.right,
      faceBounds.bottomRight.dy + 15,
      faceBounds.bottomRight.dx,
      faceBounds.bottomRight.dy - 20,
    );
    beardPath.close();

    canvas.drawPath(beardPath, paint);
  }

  void _drawSlickedBackHairstyle(Canvas canvas, double cx, double cy, double w, double h) {
    final paint = Paint()
      ..color = filter.primaryColor.withValues(alpha: filterState.intensity)
      ..style = PaintingStyle.fill;

    // Draw slicked back (smooth, angled back)
    final path = Path();
    path.moveTo(cx - w / 2, cy);
    path.lineTo(cx - w / 2.5, cy - h * 0.6);
    path.quadraticBezierTo(cx, cy - h * 1.1, cx + w / 3, cy - h * 1.2);
    path.lineTo(cx + w / 2, cy - h * 0.3);
    path.lineTo(cx + w / 2, cy + h * 0.25);
    path.close();

    canvas.drawPath(path, paint);

    // Add shine for slicked look
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3 * filterState.intensity);

    canvas.drawLine(
      Offset(cx - w / 3, cy - h * 0.7),
      Offset(cx + w / 4, cy - h * 1.0),
      shinePaint..strokeWidth = 3,
    );
  }

  void _drawFauxHawkHairstyle(Canvas canvas, double cx, double cy, double w, double h) {
    final paint = Paint()
      ..color = filter.primaryColor.withValues(alpha: filterState.intensity)
      ..style = PaintingStyle.fill;

    // Draw faux hawk (ridge in center, short sides)
    final centerPath = Path();
    centerPath.moveTo(cx - w / 6, cy);
    centerPath.lineTo(cx - w / 5, cy - h * 1.2);
    centerPath.quadraticBezierTo(cx, cy - h * 1.6, cx + w / 5, cy - h * 1.2);
    centerPath.lineTo(cx + w / 6, cy);
    centerPath.lineTo(cx + w / 6, cy + h * 0.25);
    centerPath.lineTo(cx - w / 6, cy + h * 0.25);
    centerPath.close();

    canvas.drawPath(centerPath, paint);

    // Draw sides
    final sidePaint = Paint()
      ..color = filter.accentColor.withValues(alpha: filterState.intensity * 0.6);

    for (final side in [-1, 1]) {
      final sidePath = Path();
      sidePath.moveTo(cx + side * w / 6, cy);
      sidePath.lineTo(cx + side * w / 2.5, cy);
      sidePath.lineTo(cx + side * w / 2.5, cy + h * 0.3);
      sidePath.lineTo(cx + side * w / 6, cy + h * 0.25);
      sidePath.close();
      canvas.drawPath(sidePath, sidePaint);
    }
  }

  void _drawDefaultHairstyle(Canvas canvas, double cx, double cy, double w, double h) {
    final paint = Paint()
      ..color = filter.primaryColor.withValues(alpha: filterState.intensity)
      ..style = PaintingStyle.fill;

    // Draw basic hairstyle
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - h * 0.5),
        width: w,
        height: h * 1.2,
      ),
      paint,
    );
  }

  void _drawFilterBadge(Canvas canvas, Size size) {
    const badgeHeight = 40.0;
    const badgeWidth = 120.0;

    // Badge background
    final badgePaint = Paint()
      ..color = filter.primaryColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width - badgeWidth - 16,
          size.height - badgeHeight - 16,
          badgeWidth,
          badgeHeight,
        ),
        const Radius.circular(12),
      ),
      badgePaint,
    );

    // Badge border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width - badgeWidth - 16,
          size.height - badgeHeight - 16,
          badgeWidth,
          badgeHeight,
        ),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    // Badge text
    final textPainter = TextPainter(
      text: TextSpan(
        text: filter.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width - badgeWidth - 8,
        size.height - badgeHeight + (badgeHeight - textPainter.height) / 2 - 16,
      ),
    );
  }

  @override
  bool shouldRepaint(HairstyleFilterPainter oldDelegate) =>
      oldDelegate.faces != faces ||
      oldDelegate.filter != filter ||
      oldDelegate.filterState != filterState;
}

/// Widget for displaying filter controls
class FilterControlPanel extends StatelessWidget {
  final HairstyleFilter selectedFilter;
  final FilterApplicationState filterState;
  final VoidCallback onDismiss;
  final Function(double) onIntensityChange;

  const FilterControlPanel({
    super.key,
    required this.selectedFilter,
    required this.filterState,
    required this.onDismiss,
    required this.onIntensityChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EnhancedSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.deepNavy.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(EnhancedRadius.lg),
        border: Border.all(
          color: selectedFilter.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedFilter.name,
                style: AppTypography.orbitronHeading(14, weight: FontWeight.w700)
                    .copyWith(color: selectedFilter.primaryColor),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                onPressed: onDismiss,
              ),
            ],
          ),
          const SizedBox(height: EnhancedSpacing.md),

          // Filter description
          Text(
            selectedFilter.description,
            style: AppTypography.interBody(11).copyWith(color: AppColors.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: EnhancedSpacing.lg),

          // Intensity slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Intensity',
                style: AppTypography.interBody(11, weight: FontWeight.w600)
                    .copyWith(color: AppColors.white),
              ),
              const SizedBox(height: EnhancedSpacing.sm),
              SliderTheme(
                data: const SliderThemeData(
                  trackHeight: 4,
                  thumbShape: RoundSliderThumbShape(
                    elevation: 4.0,
                    enabledThumbRadius: 8.0,
                    disabledThumbRadius: 4.0,
                  ),
                ),
                child: Slider(
                  value: filterState.intensity,
                  onChanged: onIntensityChange,
                  min: 0.0,
                  max: 1.0,
                  activeColor: selectedFilter.primaryColor,
                  inactiveColor: AppColors.textMuted.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),

          const SizedBox(height: EnhancedSpacing.lg),

          // Filter info badges
          Row(
            children: [
              _buildBadge(selectedFilter.difficulty, selectedFilter.accentColor),
              const SizedBox(width: EnhancedSpacing.sm),
              _buildBadge('${selectedFilter.rating}⭐', selectedFilter.primaryColor),
              const SizedBox(width: EnhancedSpacing.sm),
              if (selectedFilter.isPremium)
                _buildBadge('Premium', const Color(0xFFFFD700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: EnhancedSpacing.md,
        vertical: EnhancedSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(EnhancedRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: AppTypography.interBody(9, weight: FontWeight.w600)
            .copyWith(color: color),
      ),
    );
  }
}
