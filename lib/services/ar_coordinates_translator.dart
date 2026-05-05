import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// Maps ML Kit coordinates onto the [CustomPaint] that covers [CameraPreview].
/// Source: flutter-ml/google_ml_kit_flutter `coordinates_translator.dart`.
double mlkitTranslateX(
  double x,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x *
          canvasSize.width /
          (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation270deg:
      return canvasSize.width -
          x *
              canvasSize.width /
              (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      switch (cameraLensDirection) {
        case CameraLensDirection.back:
          return x * canvasSize.width / imageSize.width;
        default:
          return canvasSize.width - x * canvasSize.width / imageSize.width;
      }
    default:
      return x * canvasSize.width / imageSize.width;
  }
}

double mlkitTranslateY(
  double y,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y *
          canvasSize.height /
          (Platform.isIOS ? imageSize.height : imageSize.width);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return y * canvasSize.height / imageSize.height;
    default:
      return y * canvasSize.height / imageSize.height;
  }
}

Rect mlkitTranslateRect(
  Rect box,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection lens,
) {
  final left = mlkitTranslateX(box.left, canvasSize, imageSize, rotation, lens);
  final top = mlkitTranslateY(box.top, canvasSize, imageSize, rotation, lens);
  final right = mlkitTranslateX(box.right, canvasSize, imageSize, rotation, lens);
  final bottom = mlkitTranslateY(box.bottom, canvasSize, imageSize, rotation, lens);

  final l = math.min(left, right);
  final r = math.max(left, right);
  final t = math.min(top, bottom);
  final b = math.max(top, bottom);
  return Rect.fromLTRB(l, t, r, b);
}

Offset mlkitTranslateOffset(
  double x,
  double y,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection lens,
) {
  return Offset(
    mlkitTranslateX(x, canvasSize, imageSize, rotation, lens),
    mlkitTranslateY(y, canvasSize, imageSize, rotation, lens),
  );
}
