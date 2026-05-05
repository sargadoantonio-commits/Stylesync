// AR feature temporarily disabled due to camera dependency
// This file contains AR camera integration code that requires the camera package
// which was removed to allow building for Android without iOS native asset build issues

/*
import "dart:io" show Platform;
import "dart:typed_data";

import "package:camera/camera.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:google_mlkit_commons/google_mlkit_commons.dart";

/// Builds an [InputImage] from a live [CameraImage] for ML Kit pipelines.
InputImage? inputImageFromCameraImage(
  CameraImage image,
  CameraDescription camera, {
  required DeviceOrientation deviceOrientation,
}) {
  final rotation = _rotationFor(camera, deviceOrientation);
  final format = Platform.isAndroid
      ? InputImageFormat.nv21
      : (Platform.isIOS ? InputImageFormat.bgra8888 : InputImageFormat.nv21);

  final bytes = _mergePlanes(image);

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    ),
  );
}

Uint8List _mergePlanes(CameraImage image) {
  final buffer = WriteBuffer();
  for (final plane in image.planes) {
    buffer.putUint8List(plane.bytes);
  }
  return buffer.done().buffer.asUint8List();
}

InputImageRotation _rotationFor(CameraDescription camera, DeviceOrientation orientation) {
  var rotation = camera.sensorOrientation;
  if (camera.lensDirection == CameraLensDirection.front) {
    rotation = (rotation + 360) % 360;
  }
  switch (orientation) {
    case DeviceOrientation.portraitUp:
      break;
    case DeviceOrientation.landscapeLeft:
      rotation += 90;
      break;
    case DeviceOrientation.portraitDown:
      rotation += 180;
      break;
    case DeviceOrientation.landscapeRight:
      rotation += 270;
      break;
  }
  final normalized = (rotation + 360) % 360;
  return InputImageRotationValue.fromRawValue(normalized) ?? InputImageRotation.rotation0deg;
}
*/
