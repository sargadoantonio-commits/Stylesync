enum FaceShape {
  oval,
  square,
  round,
}

/// Lightweight geometric classifier for ML Kit [Face] bounding boxes.
abstract final class FaceShapeClassifier {
  static FaceShape classifyBoundingBox({required double width, required double height}) {
    if (height <= 1) return FaceShape.round;
    final ratio = width / height;
    if (ratio >= 0.92) return FaceShape.round;
    if (ratio >= 0.82) return FaceShape.square;
    return FaceShape.oval;
  }
}
