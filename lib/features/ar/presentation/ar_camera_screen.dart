import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_mlkit_commons/google_mlkit_commons.dart";
import "package:google_mlkit_face_detection/google_mlkit_face_detection.dart";
import "package:permission_handler/permission_handler.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/glass_card.dart";
import "../../../core/router/app_routes.dart";
import "../../auth/presentation/providers/auth_providers.dart";
import "providers/ar_usage_providers.dart";

// Import new AR services
import "../../../services/ar_hairstyle_rendering_engine.dart";
import "../../../services/ml_face_analysis_service.dart";
import "../../../services/global_hairstyle_data_service.dart";
import "../../../services/ar_hairstyle_recommendation_service.dart";
import "../../../services/ar_face_render_context.dart";
import "../../../models/hairstyle_filter.dart";

class ArCameraScreen extends ConsumerStatefulWidget {
  const ArCameraScreen({super.key});

  @override
  ConsumerState<ArCameraScreen> createState() => _ArCameraScreenState();
}

class _ArCameraScreenState extends ConsumerState<ArCameraScreen> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _isInitialized = false;
  bool _permissionGranted = false;
  String? _errorMessage;
  List<Face> _detectedFaces = [];
  String _selectedHairStyle = "fade_classic"; // Updated default
  Size _mlKitImageSize = const Size(720, 1280);
  CameraLensDirection _cameraLensDirection = CameraLensDirection.front;

  static const InputImageRotation _kInputImageRotation =
      InputImageRotation.rotation90deg;

  // New AR features
  FaceAnalysisResult? _faceAnalysis;
  List<HairstyleFilter> _availableStyles = [];
  double _filterIntensity = 1.0;
  bool _enableSmoothing = true;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  List<String> _recommendedStyles = [];
  late GlobalHairstyleDataService _hairstyleService;
  late ARHairstyleRecommendationService _recommendationService;
  String _detectedFaceShape = 'oval';
  final String _detectedHairType = 'Straight';

  @override
  void initState() {
    super.initState();
    _hairstyleService = GlobalHairstyleDataService();
    _recommendationService = ARHairstyleRecommendationService();
    _initialize();
    _loadHairstyleData();
  }

  Future<void> _loadHairstyleData() async {
    try {
      // Initialize both services in parallel
      await Future.wait([
        _hairstyleService.initialize(),
        _recommendationService.initialize(),
      ]);

      // Get trending styles from recommendation service
      final allHairstyles = _recommendationService.getAllHairstylesForTraining();
      
      setState(() {
        // Map training data to display format
        _availableStyles = allHairstyles
            .map((style) {
              // Get face shape compatibility
              final compatibility = (style.characteristics['faceShapeCompatibility'] as Map?) ?? {};
              final compatibleFaceShapes = compatibility.keys.toList().cast<String>();
              
              // Get hair types
              final hairTypes = (style.characteristics['hairType'] as List?) ?? [];
              final compatibleHairTypes = hairTypes.cast<String>();
              
              return HairstyleFilter(
                id: style.id,
                styleCode: style.id,
                name: style.officialName,
                description: style.description,
                imageUrl: style.imageUrl,
                isPremium: false,
                rating: style.getTrendingScore().toDouble(),
                category: 'Professional',
                difficulty: style.characteristics['difficulty'] ?? 'medium',
                compatibleFaceShapes: compatibleFaceShapes,
                compatibleHairTypes: compatibleHairTypes,
                primaryColor: AppColors.accentMagenta,
                accentColor: AppColors.accentCyan,
                createdDate: DateTime.now(),
                trending: style.getTrendingScore() > 80,
              );
            })
            .toList();
        
        // Set default to first style
        if (_availableStyles.isNotEmpty) {
          _selectedHairStyle = _availableStyles.first.styleCode;
        }
      });

      print('✅ Loaded ${_availableStyles.length} hairstyles with real training data');
    } catch (e) {
      debugPrint("[AR Camera] Error loading hairstyle data: $e");
    }
  }

  Future<void> _initialize() async {
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        setState(() {
          _permissionGranted = false;
          _errorMessage =
              "Camera permission denied. Please enable it in settings.";
        });
        return;
      }

      setState(() => _permissionGranted = true);

      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception("No cameras found on device");
      }

      // Initialize camera controller with front camera
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController.initialize();
      _cameraLensDirection = _cameraController.description.lensDirection;

      // Initialize face detector
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
          enableTracking: true,
          enableClassification: true,
          enableLandmarks: true,
        ),
      );

      // Start image stream processing
      await _cameraController.startImageStream(_processCameraImage);

      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _errorMessage = "Error initializing camera: $e");
      debugPrint("[AR Camera] Initialization error: $e");
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    try {
      final w = image.width.toDouble();
      final h = image.height.toDouble();
      if (w > 8 && h > 8) {
        _mlKitImageSize = Size(w, h);
      }

      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      setState(() => _detectedFaces = faces);
      
      // Analyze first detected face with ML and training data
      if (faces.isNotEmpty && mounted) {
        final mlAnalysis = MLFaceAnalysisService.analyzeFace(faces.first);
        
        // Get recommendations from trained data service
        final recommendations = await _recommendationService.getRecommendations(
          mlAnalysis.faceShape,
          _detectedHairType,
        );

        setState(() {
          _faceAnalysis = mlAnalysis;
          _detectedFaceShape = mlAnalysis.faceShape;
          
          // Update recommended styles with official names from training data
          _recommendedStyles = recommendations.topRecommendations
              .take(6)
              .map((style) => style.officialName)
              .toList();
          
          // Auto-select best match with official name
          if (recommendations.topRecommendations.isNotEmpty) {
            final bestMatch = recommendations.topRecommendations.first;
            _selectedHairStyle = bestMatch.id;
          }
        });

        print('🎯 Face shape: $mlAnalysis.faceShape | Top recommendation: ${recommendations.topRecommendations.isNotEmpty ? recommendations.topRecommendations.first.officialName : 'N/A'}');
      }
    } catch (e) {
      debugPrint("[AR Camera] Face detection error: $e");
    }
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    try {
      final inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw);
      if (inputImageFormat == null) return null;

      return InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation90deg,
          format: inputImageFormat,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint("[AR Camera] Image conversion error: $e");
      return null;
    }
  }

  void _switchHairStyle() {
    final styles = _availableStyles.isNotEmpty 
      ? _availableStyles.map((s) => s.styleCode).toList()
      : ["fade_classic", "undercut_modern", "pompadour_classic", "crop_modern"];
    
    final currentIndex = styles.indexOf(_selectedHairStyle);
    final nextIndex = (currentIndex + 1) % styles.length;

    setState(() => _selectedHairStyle = styles[nextIndex]);

    // Get official name from training data
    final officialName = _recommendationService.getOfficialName(_selectedHairStyle);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Switched to $officialName"),
        duration: const Duration(milliseconds: 800),
        backgroundColor: AppColors.accentMagenta,
      ),
    );
  }
  
  /// Get official hairstyle name from training data
  String _getHairstyleName(String styleId) {
    return _recommendationService.getOfficialName(styleId);
  }
  
  /// Get hairstyle description from training data
  String _getHairstyleDescription(String styleId) {
    return _recommendationService.getDescription(styleId);
  }

  void _captureHairStyle() {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final userProfile = ref.read(userProfileProvider).valueOrNull;
    final isPremium = userProfile?.isPremium ?? false;
    final limitReached = ref.read(arLimitReachedProvider);

    // Check if free user has hit limit
    if (!isPremium && limitReached) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Limit Reached",
                style: AppTypography.interBody(14, weight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "You've used all 3 free AR tries this month.",
                style: AppTypography.interBody(12),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.orange.shade700,
          action: SnackBarAction(
            label: "UPGRADE",
            onPressed: () {
              _cameraController.stopImageStream();
              context.push(AppRoutes.premiumUpgrade);
            },
          ),
        ),
      );
      return;
    }

    // Increment usage for free users
    if (!isPremium) {
      ref.read(incrementArUsageProvider(user.uid));
    }

    // Show success
    final remaining = ref.read(arRemainingProvider);
    final remainingText =
        remaining > 0 ? "$remaining tries left" : "Last try this month!";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              "Hair style preview saved",
              style: AppTypography.interBody(14),
            ),
            if (!isPremium) ...[
              const SizedBox(height: 6),
              Text(
                remainingText,
                style:
                    AppTypography.interBody(11).copyWith(color: Colors.amber),
              ),
            ],
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final isPremium = userProfile.valueOrNull?.isPremium ?? false;
    final remaining = ref.watch(arRemainingProvider);
    final usagePercentage = ref.watch(arUsagePercentageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("AR Hair Try-On", style: AppTypography.orbitronHeading(18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.accentMagenta),
          onPressed: () {
            _cameraController.stopImageStream();
            context.pop();
          },
        ),
        actions: [
          if (!isPremium)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: usagePercentage > 0.66
                      ? Colors.orange.withValues(alpha: 0.2)
                      : AppColors.accentMagenta.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: usagePercentage > 0.66
                        ? Colors.orange
                        : AppColors.accentMagenta,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flash_on_rounded,
                      size: 14,
                      color: usagePercentage > 0.66
                          ? Colors.orange
                          : AppColors.accentMagenta,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$remaining/3',
                      style:
                          AppTypography.interBody(12, weight: FontWeight.w600)
                              .copyWith(
                        color: usagePercentage > 0.66
                            ? Colors.orange
                            : AppColors.accentMagenta,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentCyan),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.diamond_rounded,
                      size: 14,
                      color: AppColors.accentCyan,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'PREMIUM',
                      style:
                          AppTypography.interBody(11, weight: FontWeight.w600)
                              .copyWith(color: AppColors.accentCyan),
                    ),
                  ],
                ),
              ),
            ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: !_permissionGranted
          ? _buildPermissionDeniedView()
          : _errorMessage != null
              ? _buildErrorView()
              : !_isInitialized
                  ? _buildLoadingView()
                  : _buildArView(),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: AppColors.accentMagenta.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                "Camera Permission Required",
                style: AppTypography.orbitronHeading(16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "AR hair try-on requires camera access to provide accurate filter previews.",
                style: AppTypography.interBody(14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                    label: const Text("Decline"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => openAppSettings(),
                    icon: const Icon(Icons.settings),
                    label: const Text("Open Settings"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentMagenta,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                "Error Initializing AR",
                style: AppTypography.orbitronHeading(16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? "An unknown error occurred",
                style: AppTypography.interBody(13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _errorMessage = null);
                  _initialize();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentMagenta,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.accentMagenta),
          const SizedBox(height: 16),
          Text(
            "Initializing AR Camera...",
            style: AppTypography.interBody(14),
          ),
        ],
      ),
    );
  }

  Widget _buildArView() {
    return Stack(
      children: [
        // Camera preview
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CameraPreview(_cameraController),
        ),

        // NEW: Advanced hairstyle overlay
        if (_detectedFaces.isNotEmpty)
          Positioned.fill(
            child: CustomPaint(
              painter: _AdvancedARHairstylePainter(
                _detectedFaces.first,
                _selectedHairStyle,
                _filterIntensity,
                _enableSmoothing,
                _faceAnalysis,
                _mlKitImageSize,
                _cameraLensDirection,
                _kInputImageRotation,
              ),
            ),
          ),

        // Basic face overlay (can be removed if advanced overlay is sufficient)
        // if (_detectedFaces.isNotEmpty)
        //   ..._detectedFaces.map((face) => _buildFaceOverlay(face)),

        // Top status bar with ML analysis
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildStatusBar(),
        ),

        // Compatibility info
        if (_faceAnalysis != null)
          Positioned(
            top: 70,
            left: 16,
            right: 16,
            child: _buildFaceAnalysisInfo(),
          ),

        // Side action buttons
        Positioned(
          right: 16,
          bottom: 200,
          child: _buildSideActionButtons(),
        ),

        // Recording indicator
        if (_isRecording)
          Positioned(
            top: 130,
            right: 16,
            child: _buildRecordingIndicator(),
          ),

        // Controls overlay
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: _buildControlsPanel(),
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentMagenta.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.face,
            color: _detectedFaces.isNotEmpty ? Colors.green : Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            _detectedFaces.isNotEmpty ? 'Face detected ✓' : 'Move closer to camera',
            style: AppTypography.interBody(12),
          ),
          const Spacer(),
          if (_faceAnalysis != null)
            Text(
              '${_faceAnalysis!.faceShape} • ${(_faceAnalysis!.confidenceScore * 100).toStringAsFixed(0)}%',
              style: AppTypography.interBody(11).copyWith(color: AppColors.accentMagenta),
            ),
        ],
      ),
    );
  }

  Widget _buildFaceAnalysisInfo() {
    if (_faceAnalysis == null) return const SizedBox.shrink();

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Best Match: ${_selectedHairStyle.replaceAll('_', ' ')}',
              style: AppTypography.interBody(11, weight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '⭐ ${(_faceAnalysis!.compatibilityScores[_selectedHairStyle] ?? 0).toStringAsFixed(0)}% compatible',
              style: AppTypography.interBody(10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Record button
        GestureDetector(
          onTap: () => setState(() {
            _isRecording = !_isRecording;
            if (_isRecording) _recordingSeconds = 0;
          }),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording ? Colors.red : AppColors.accentMagenta,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? Colors.red : AppColors.accentMagenta).withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.circle,
              color: Colors.white,
              size: _isRecording ? 20 : 24,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FloatingActionButton.small(
          onPressed: () => setState(() => _enableSmoothing = !_enableSmoothing),
          backgroundColor: _enableSmoothing ? AppColors.accentMagenta : AppColors.accentCyan,
          child: const Icon(Icons.auto_awesome, size: 20),
        ),
      ],
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.9),
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

  Widget _buildControlsPanel() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Hair Style: ${_selectedHairStyle.replaceAll('_', ' ').toUpperCase()}",
              style: AppTypography.interBody(12, weight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Filter intensity slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Intensity',
                      style: AppTypography.interBody(10),
                    ),
                    Text(
                      '${(_filterIntensity * 100).toStringAsFixed(0)}%',
                      style: AppTypography.interBody(10, weight: FontWeight.bold)
                          .copyWith(color: AppColors.accentMagenta),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 4.0,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                  ),
                  child: Slider(
                    value: _filterIntensity,
                    onChanged: (v) => setState(() => _filterIntensity = v),
                    activeColor: AppColors.accentMagenta,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Recommended styles carousel
            if (_recommendedStyles.isNotEmpty)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recommendedStyles.length,
                  itemBuilder: (context, idx) {
                    final style = _recommendedStyles[idx];
                    final isSelected = _selectedHairStyle == style;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedHairStyle = style),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentMagenta.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.accentMagenta : Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              style.replaceAll('_', ' '),
                              style: AppTypography.interBody(9, weight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _switchHairStyle,
                  icon: const Icon(Icons.style, size: 16),
                  label: const Text("Shuffle"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentMagenta,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _captureHairStyle,
                  icon: const Icon(Icons.camera_alt, size: 16),
                  label: const Text("Capture"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              "Faces: ${_detectedFaces.length} | Confidence: ${_faceAnalysis != null ? '${(_faceAnalysis!.confidenceScore * 100).toStringAsFixed(0)}%' : 'N/A'}",
              style: AppTypography.interBody(10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaceOverlay(Face face) {
    final rect = face.boundingBox;
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.accentMagenta,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.accentMagenta,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
              ),
              child: Text(
                "Face ${_detectedFaces.indexOf(face) + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (face.headEulerAngleY != null)
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  "Angle: ${face.headEulerAngleY!.toStringAsFixed(1)}°",
                  style: const TextStyle(
                    color: AppColors.accentMagenta,
                    fontSize: 9,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// NEW: Advanced AR Hairstyle Painter with ML-based rendering
class _AdvancedARHairstylePainter extends CustomPainter {
  final Face face;
  final String hairstyleId;
  final double intensity;
  final bool enableSmoothing;
  final FaceAnalysisResult? analysis;
  final Size mlKitImageSize;
  final CameraLensDirection lensDirection;
  final InputImageRotation inputRotation;

  _AdvancedARHairstylePainter(
    this.face,
    this.hairstyleId,
    this.intensity,
    this.enableSmoothing,
    this.analysis,
    this.mlKitImageSize,
    this.lensDirection,
    this.inputRotation,
  );

  @override
  void paint(Canvas canvas, Size size) {
    try {
      if (mlKitImageSize.width < 8 || mlKitImageSize.height < 8) return;

      final ctx = ArFaceRenderContext.fromFace(
        face: face,
        canvasSize: size,
        mlKitImageSize: mlKitImageSize,
        rotation: inputRotation,
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

      // Draw optional guides
      _drawOptionalGuides(canvas, size);
    } catch (e) {
      debugPrint("Error painting hairstyle: $e");
    }
  }

  void _drawOptionalGuides(Canvas canvas, Size canvasSize) {
    final ctx = ArFaceRenderContext.fromFace(
      face: face,
      canvasSize: canvasSize,
      mlKitImageSize: mlKitImageSize,
      rotation: inputRotation,
      lensDirection: lensDirection,
    );

    final paint = Paint()
      ..color = AppColors.accentMagenta.withValues(alpha: 0.2)
      ..strokeWidth = 1.5
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
  bool shouldRepaint(_AdvancedARHairstylePainter oldDelegate) {
    return oldDelegate.hairstyleId != hairstyleId ||
        oldDelegate.intensity != intensity ||
        oldDelegate.enableSmoothing != enableSmoothing ||
        oldDelegate.mlKitImageSize != mlKitImageSize ||
        oldDelegate.face.boundingBox != face.boundingBox;
  }
}
