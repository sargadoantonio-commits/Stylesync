import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:stylesync/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class ARCameraScreen extends StatefulWidget {
  const ARCameraScreen({super.key});

  @override
  State<ARCameraScreen> createState() => _ARCameraScreenState();
}

class _ARCameraScreenState extends State<ARCameraScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isFaceDetected = false;
  Face? _detectedFace;
  String _selectedStyle = 'fade_design';
  bool _isProcessing = false;
  final List<String> _freeStyles = [
    'fade_design',
    'clean_fade',
    'beard_trim',
    'classic_cut',
    'textured_crop',
    'undercut',
    'pompadour',
    'faux_hawk'
  ];

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        enableTracking: true,
      ),
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _startFaceDetection();

      if (mounted) setState(() {});
    } catch (e) {
      print('Camera init error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: $e'),
            backgroundColor: AppColors.kDanger,
          ),
        );
      }
    }
  }

  Future<void> _startFaceDetection() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      while (mounted) {
        if (_isProcessing) {
          await Future.delayed(const Duration(milliseconds: 100));
          continue;
        }

        _isProcessing = true;

        final image = await _cameraController!.takePicture();
        final inputImage = InputImage.fromFilePath(image.path);

        final faces = await _faceDetector!.processImage(inputImage);

        if (mounted) {
          setState(() {
            if (faces.isNotEmpty) {
              _detectedFace = faces.first;
              _isFaceDetected = true;
            } else {
              _isFaceDetected = false;
              _detectedFace = null;
            }
          });
        }

        _isProcessing = false;
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Face detection error: $e');
      _isProcessing = false;
    }
  }

  void _saveStyle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_selectedStyle saved! 📸'),
        backgroundColor: AppColors.kSuccess,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.kBg,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.kAccent),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: AppBar(
        backgroundColor: AppColors.kBg,
        title:
            const Text('AR Try-On', style: TextStyle(color: AppColors.kText)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.kAccent),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

          // Face detection overlay (bounding box)
          if (_detectedFace != null)
            Positioned.fill(
              child: CustomPaint(
                painter: _FaceBoundingBoxPainter(_detectedFace!),
              ),
            ),

          // Style selector bottom sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.kCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  top: BorderSide(color: AppColors.kBorder),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Try-On Styles',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _freeStyles.length,
                      itemBuilder: (context, idx) {
                        final style = _freeStyles[idx];
                        final isSelected = _selectedStyle == style;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedStyle = style),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.kAccent.withOpacity(0.2)
                                  : AppColors.kCard2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.kAccent
                                    : AppColors.kBorder,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: AppColors.kAccent,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    style.replaceAll('_', ' '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.kMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Share'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.kAccent,
                              side: const BorderSide(color: AppColors.kAccent),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveStyle,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Save Style'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Top info bar
          Positioned(
            top: 12,
            right: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kBg.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.kAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.face, color: AppColors.kAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _isFaceDetected
                        ? 'Face detected ✓'
                        : 'Move closer to camera',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.kText,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isFaceDetected
                          ? AppColors.kSuccess
                          : AppColors.kMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for face bounding box
class _FaceBoundingBoxPainter extends CustomPainter {
  final Face face;

  _FaceBoundingBoxPainter(this.face);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.kAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = AppColors.kAccent.withOpacity(0.2)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    // Draw glow
    canvas.drawRect(
      Rect.fromLTWH(
        face.boundingBox.left,
        face.boundingBox.top,
        face.boundingBox.width,
        face.boundingBox.height,
      ),
      glowPaint,
    );

    // Draw bounding box
    canvas.drawRect(
      Rect.fromLTWH(
        face.boundingBox.left,
        face.boundingBox.top,
        face.boundingBox.width,
        face.boundingBox.height,
      ),
      paint,
    );

    // Draw corner indicators
    final rect = Rect.fromLTWH(
      face.boundingBox.left,
      face.boundingBox.top,
      face.boundingBox.width,
      face.boundingBox.height,
    );

    // Draw corners
    final corners = [
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.left, rect.bottom),
      Offset(rect.right, rect.bottom),
    ];

    for (final corner in corners) {
      canvas.drawCircle(corner, 4, paint);
    }

    // Draw face landmarks if available
    if (face.contours.isNotEmpty) {
      final landmarkPaint = Paint()
        ..color = AppColors.kTeal
        ..strokeWidth = 2
        ..style = PaintingStyle.fill;

      for (final contour in face.contours.values) {
        if (contour != null) {
          for (final point in contour.points) {
            canvas.drawCircle(
              Offset(point.x.toDouble(), point.y.toDouble()),
              2,
              landmarkPaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_FaceBoundingBoxPainter oldDelegate) => true;
}
