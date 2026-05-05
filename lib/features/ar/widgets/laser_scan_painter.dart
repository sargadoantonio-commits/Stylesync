import "package:flutter/material.dart";

import "../../../core/theme/app_colors.dart";

/// Vertical AR-style scan line driven by [animation] in the 0–1 range.
class LaserScanPainter extends CustomPainter {
  LaserScanPainter({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value.clamp(0.0, 1.0);
    final y = size.height * t;

    final core = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.accentMagenta.withValues(alpha: 0.05),
          AppColors.accentMagenta.withValues(alpha: 0.85),
          AppColors.accentMagenta.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 0.5, 0.58, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, y - 40, size.width, 80));

    canvas.drawRect(Rect.fromLTWH(0, y - 40, size.width, 80), core);

    final line = Paint()
      ..color = AppColors.accentMagenta
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
  }

  @override
  bool shouldRepaint(covariant LaserScanPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
