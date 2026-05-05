import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:stylesync/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ar_face_render_context.dart';
import '../services/ar_hairstyle_rendering_engine.dart';
import '../services/ml_face_analysis_service.dart';
import '../services/global_hairstyle_data_service.dart';
import '../models/hairstyle_filter.dart';

/// Enhanced AR Camera Screen with TikTok-like filter experience
class EnhancedARCameraScreen extends ConsumerStatefulWidget {
  const EnhancedARCameraScreen({super.key});

  @override
  ConsumerState<EnhancedARCameraScreen> createState() => _EnhancedARCameraScreenState();
}

class _EnhancedARCameraScreenState extends ConsumerState<EnhancedARCameraScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isFaceDetected = false;
  Face? _detectedFace;
  FaceAnalysisResult? _faceAnalysis;
  String _selectedStyle = 'fade_classic';
  bool _isProcessing = false;
  double _filterIntensity = 1.0;
  bool _enableSmoothing = true;
  List<HairstyleFilter> _filteredStyles = [];
  List<String> _recommendedStyles = [];
  int _currentFilterIndex = 0;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Size _captureImageSize = const Size(720, 1280);
  CameraLensDirection _lensDirection = CameraLensDirection.front;

  final List<String> _allStyles = [
    'fade_classic',
    'undercut_modern',
    'pompadour_classic',
    'crop_textured',
    'beard_blend',
    'slicked_back_premium',
    'faux_hawk_premium',
  ];

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        enableClassification: true,
        enableTracking: true,
      ),
    );
    _initializeCamera();
    _loadHairstyleData();
  }

  Future<void> _loadHairstyleData() async {
    try {
      final service = GlobalHairstyleDataService();
      await service.initialize();
      _filteredStyles = service.getTrendingStyles(limit: 20);
    } catch (e) {
      print('Error loading hairstyle data: $e');
    }
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
      _lensDirection = _cameraController!.description.lensDirection;
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

        try {
          final image = await _cameraController!.takePicture();

          var nextCaptureSize = _captureImageSize;
          try {
            final raw = await image.readAsBytes();
            final codec = await ui.instantiateImageCodec(raw);
            final frame = await codec.getNextFrame();
            final i = frame.image;
            if (i.width > 0 && i.height > 0) {
              nextCaptureSize = Size(i.width.toDouble(), i.height.toDouble());
            }
            i.dispose();
          } catch (_) {
            /* decoded size optional */
          }

          final inputImage = InputImage.fromFilePath(image.path);

          final faces = await _faceDetector!.processImage(inputImage);

          if (mounted) {
            setState(() {
              _captureImageSize = nextCaptureSize;

              if (faces.isNotEmpty) {
                _detectedFace = faces.first;
                _isFaceDetected = true;
                
                // Analyze face and get recommendations
                _faceAnalysis = MLFaceAnalysisService.analyzeFace(_detectedFace!);
                _recommendedStyles = _faceAnalysis!.getTopRecommendations(6);
                
                if (!_recommendedStyles.contains(_selectedStyle)) {
                  _selectedStyle = _recommendedStyles.isNotEmpty 
                    ? _recommendedStyles.first 
                    : 'fade_classic';
                }
              } else {
                _isFaceDetected = false;
                _detectedFace = null;
                _faceAnalysis = null;
              }
            });
          }
        } catch (e) {
          print('Face detection error: $e');
        }

        _isProcessing = false;
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Face detection loop error: $e');
      _isProcessing = false;
    }
  }

  void _cycleToNextStyle() {
    setState(() {
      _currentFilterIndex = (_currentFilterIndex + 1) % _allStyles.length;
      _selectedStyle = _allStyles[_currentFilterIndex];
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      _recordingSeconds = 0;
    });

    if (_isRecording) {
      _startRecordingTimer();
    }
  }

  void _startRecordingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() => _recordingSeconds++);
        if (_recordingSeconds < 60) {
          _startRecordingTimer();
        } else {
          _stopRecording();
        }
      }
    });
  }

  void _stopRecording() {
    setState(() => _isRecording = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Recording saved!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveStyle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('💾 Saved: $_selectedStyle'),
        backgroundColor: AppColors.kSuccess,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareStyle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📤 Shared to friends!'),
        backgroundColor: AppColors.kAccent,
        duration: Duration(seconds: 2),
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
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

          // Hairstyle overlay (custom paint)
          if (_detectedFace != null)
            Positioned.fill(
              child: CustomPaint(
                painter: _ARHairstyleOverlayPainter(
                  _detectedFace!,
                  _selectedStyle,
                  _filterIntensity,
                  _enableSmoothing,
                  _captureImageSize,
                  _lensDirection,
                ),
              ),
            ),

          // Top status bar with face detection info
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _buildTopStatusBar(),
          ),

          // Bottom TikTok-like controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),

          // Side action buttons (TikTok style)
          Positioned(
            right: 12,
            bottom: 200,
            child: _buildSideActionButtons(),
          ),

          // Recording indicator
          if (_isRecording)
            Positioned(
              top: 60,
              right: 12,
              child: _buildRecordingIndicator(),
            ),

          // Face analysis info
          if (_faceAnalysis != null)
            Positioned(
              top: 90,
              left: 12,
              right: 12,
              child: _buildFaceAnalysisInfo(),
            ),
        ],
      ),
    );
  }

  Widget _buildTopStatusBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kBg.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kAccent.withOpacity(0.3)),
        backdropFilter: const ui.BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.face,
            color: _isFaceDetected ? AppColors.kSuccess : AppColors.kMuted,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            _isFaceDetected ? 'Face detected ✓' : 'Move closer to camera',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.kText,
            ),
          ),
          const Spacer(),
          if (_faceAnalysis != null) ...[
            Text(
              'Shape: ${_faceAnalysis!.faceShape}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.kMuted,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(_faceAnalysis!.confidenceScore * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.kAccent,
              ),
            ),
          ],
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isFaceDetected ? AppColors.kSuccess : AppColors.kMuted,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceAnalysisInfo() {
    if (_faceAnalysis == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.kCard.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Best Match: ${_selectedStyle.replaceAll('_', ' ')}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.kAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '⭐ Compatibility: ${(_faceAnalysis!.compatibilityScores[_selectedStyle] ?? 0).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.kMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.kBorder),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          
          // Filter intensity slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Intensity',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.kMuted,
                      ),
                    ),
                    Text(
                      '${(_filterIntensity * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 4.0,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
                  ),
                  child: Slider(
                    value: _filterIntensity,
                    min: 0.0,
                    max: 1.0,
                    activeColor: AppColors.kAccent,
                    inactiveColor: AppColors.kBorder,
                    onChanged: (value) => setState(() => _filterIntensity = value),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Style selector carousel
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _recommendedStyles.isEmpty ? _allStyles.length : _recommendedStyles.length,
              itemBuilder: (context, idx) {
                final style = _recommendedStyles.isEmpty 
                  ? _allStyles[idx] 
                  : _recommendedStyles[idx];
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
                          Icons.content_cut,
                          color: AppColors.kAccent,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            style.replaceAll('_', ' '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: AppColors.kMuted,
                            ),
                          ),
                        ),
                        if (_faceAnalysis != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${(_faceAnalysis!.compatibilityScores[style] ?? 0).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 8,
                              color: AppColors.kAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Cycle styles button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _cycleToNextStyle,
                    icon: const Icon(Icons.shuffle, size: 18),
                    label: const Text('Shuffle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.kAccent,
                      side: const BorderSide(color: AppColors.kAccent),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Share button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareStyle,
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.kAccent,
                      side: const BorderSide(color: AppColors.kAccent),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Save button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveStyle,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSideActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Record button (large center button)
        GestureDetector(
          onTap: _toggleRecording,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording ? AppColors.kDanger : AppColors.kAccent,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? AppColors.kDanger : AppColors.kAccent).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.circle,
              color: AppColors.kBg,
              size: _isRecording ? 20 : 24,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Beauty effects button
        FloatingActionButton.small(
          onPressed: () {
            setState(() => _enableSmoothing = !_enableSmoothing);
          },
          backgroundColor: _enableSmoothing ? AppColors.kAccent : AppColors.kCard2,
          child: const Icon(Icons.sparkles, size: 20),
        ),

        const SizedBox(height: 12),

        // Close button
        FloatingActionButton.small(
          onPressed: () => context.pop(),
          backgroundColor: AppColors.kCard2,
          child: const Icon(Icons.close, size: 20),
        ),
      ],
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.kDanger.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${_recordingSeconds ~/ 60}:${(_recordingSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for AR hairstyle overlay
class _ARHairstyleOverlayPainter extends CustomPainter {
  final Face face;
  final String hairstyleId;
  final double intensity;
  final bool enableSmoothing;
  final Size mlKitImageSize;
  final CameraLensDirection lensDirection;

  _ARHairstyleOverlayPainter(
    this.face,
    this.hairstyleId,
    this.intensity,
    this.enableSmoothing,
    this.mlKitImageSize,
    this.lensDirection,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (mlKitImageSize.width < 8 || mlKitImageSize.height < 8) return;

    final ctx = ArFaceRenderContext.fromFace(
      face: face,
      canvasSize: size,
      mlKitImageSize: mlKitImageSize,
      rotation: InputImageRotation.rotation0deg,
      lensDirection: lensDirection,
    );

    ARHairstyleRenderingEngine.renderHairstyle(
      canvas,
      size,
      ctx,
      hairstyleId,
      intensity: intensity,
      enableSmoothing: enableSmoothing,
    );

    _drawFaceGuides(canvas, ctx);
  }

  void _drawFaceGuides(Canvas canvas, ArFaceRenderContext ctx) {
    final paint = Paint()
      ..color = AppColors.kAccent.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final mapped = ctx.faceBoundingBoxScreen;
    canvas.drawRect(mapped, paint);

    final centerX = mapped.center.dx;
    canvas.drawLine(
      Offset(centerX, mapped.top),
      Offset(centerX, mapped.bottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ARHairstyleOverlayPainter oldDelegate) {
    return oldDelegate.hairstyleId != hairstyleId ||
        oldDelegate.intensity != intensity ||
        oldDelegate.enableSmoothing != enableSmoothing ||
        oldDelegate.mlKitImageSize != mlKitImageSize ||
        oldDelegate.face.boundingBox != face.boundingBox;
  }
}

import 'dart:ui' as ui;
