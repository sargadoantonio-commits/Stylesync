import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'ar_coordinates_translator.dart';

/// Screen-space face geometry for AR hair painting (after ML Kit → preview mapping).
class ArFaceRenderContext {
  ArFaceRenderContext({
    required this.faceBoundingBoxScreen,
    required this.landmarksScreen,
    required this.eulerXDeg,
    required this.eulerYDeg,
    required this.eulerZDeg,
  });

  final Rect faceBoundingBoxScreen;
  final Map<FaceLandmarkType, Offset> landmarksScreen;
  final double eulerXDeg;
  final double eulerYDeg;
  final double eulerZDeg;

  static ArFaceRenderContext fromFace({
    required Face face,
    required Size canvasSize,
    required Size mlKitImageSize,
    required InputImageRotation rotation,
    required CameraLensDirection lensDirection,
  }) {
    final box = mlkitTranslateRect(
      face.boundingBox,
      canvasSize,
      mlKitImageSize,
      rotation,
      lensDirection,
    );

    final lm = <FaceLandmarkType, Offset>{};
    for (final t in FaceLandmarkType.values) {
      final l = face.landmarks[t];
      if (l == null) continue;
      lm[t] = mlkitTranslateOffset(
        l.position.x.toDouble(),
        l.position.y.toDouble(),
        canvasSize,
        mlKitImageSize,
        rotation,
        lensDirection,
      );
    }

    return ArFaceRenderContext(
      faceBoundingBoxScreen: box,
      landmarksScreen: lm,
      eulerXDeg: face.headEulerAngleX ?? 0,
      eulerYDeg: face.headEulerAngleY ?? 0,
      eulerZDeg: face.headEulerAngleZ ?? 0,
    );
  }

  /// Crown width from inter-ocular distance when eyes are visible; else face box.
  double get calibratedCrownWidth {
    final le = landmarksScreen[FaceLandmarkType.leftEye];
    final re = landmarksScreen[FaceLandmarkType.rightEye];
    final ew = faceBoundingBoxScreen.width;
    if (le != null && re != null) {
      final iod = (re.dx - le.dx).abs();
      if (iod > 4) return math.max(ew, iod * 2.75);
    }
    return ew * 1.08;
  }

  /// Approximate hairline above eyes (not trichoscopy-accurate; stable for AR overlay).
  double get estimatedHairlineY {
    final le = landmarksScreen[FaceLandmarkType.leftEye];
    final re = landmarksScreen[FaceLandmarkType.rightEye];
    if (le != null && re != null) {
      final eyeMidY = (le.dy + re.dy) / 2;
      final iod = (re.dx - le.dx).abs();
      return eyeMidY - iod * 0.9;
    }
    return faceBoundingBoxScreen.top - faceBoundingBoxScreen.height * 0.04;
  }

  /// Horizontal nudge when user turns head (yaw), keeps mass centered visually.
  double get eulerYawCenterNudge =>
      -(eulerYDeg.clamp(-42.0, 42.0)) * faceBoundingBoxScreen.width * 0.007;

  /// Vertical scaling hint from pitch (looking up/down).
  double get pitchVolumeFactor {
    final x = eulerXDeg.clamp(-35.0, 35.0);
    return 1.0 + x / 180.0;
  }

  Offset get layeredHairCenter {
    final base = faceBoundingBoxScreen.center;
    final nose = landmarksScreen[FaceLandmarkType.noseBase];
    final le = landmarksScreen[FaceLandmarkType.leftEye];
    final re = landmarksScreen[FaceLandmarkType.rightEye];

    var cx = base.dx;
    final hairline = estimatedHairlineY;
    var cy = base.dy * 0.35 + hairline * 0.65;

    if (nose != null) {
      cx = base.dx * 0.45 + nose.dx * 0.55;
    }
    if (le != null && re != null) {
      cx = (le.dx + re.dx) / 2;
    }
    return Offset(cx + eulerYawCenterNudge, cy);
  }

  Offset get posePivot =>
      landmarksScreen[FaceLandmarkType.noseBase] ?? faceBoundingBoxScreen.center;
}
