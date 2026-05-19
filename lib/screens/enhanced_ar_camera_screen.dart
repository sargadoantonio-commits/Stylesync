import 'dart:io' show File, Platform;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stylesync/core/theme/app_colors.dart';

/// Simple camera-only screen replacing the AR try-on.
class EnhancedARCameraScreen extends StatefulWidget {
  const EnhancedARCameraScreen({super.key});

  @override
  State<EnhancedARCameraScreen> createState() => _EnhancedARCameraScreenState();
}

class _EnhancedARCameraScreenState extends State<EnhancedARCameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  XFile? _lastPicture;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        throw Exception('No cameras available on device');
      }

      // Prefer front camera if present
      final frontIndex = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      _selectedCameraIndex = frontIndex >= 0 ? frontIndex : 0;

      await _initializeController(_selectedCameraIndex);
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialization failed: $e'), backgroundColor: AppColors.kDanger),
        );
      }
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _initializeController(int index) async {
    final desc = _cameras[index];
    _controller?.dispose();
    // Try a few safe combinations of resolution and image format to work
    // around devices where CameraX reports an unknown/unsupported pixel
    // format during initialization.
    final presets = [ResolutionPreset.high, ResolutionPreset.medium, ResolutionPreset.low];
    final formats = Platform.isAndroid
      ? <ImageFormatGroup?>[null, ImageFormatGroup.yuv420, ImageFormatGroup.nv21, ImageFormatGroup.unknown]
      : <ImageFormatGroup?>[null, ImageFormatGroup.bgra8888, ImageFormatGroup.unknown];

    Exception? lastError;
    for (final preset in presets) {
        for (final fmt in formats) {
        try {
          if (fmt == null) {
            _controller = CameraController(
              desc,
              preset,
              enableAudio: false,
            );
          } else {
            _controller = CameraController(
              desc,
              preset,
              enableAudio: false,
              imageFormatGroup: fmt,
            );
          }

          await _controller!.initialize();
          // success
          if (mounted) setState(() => _isInitializing = false);
          return;
        } catch (e) {
          lastError = e as Exception? ?? Exception(e.toString());
          debugPrint('Camera init attempt failed (preset=$preset, fmt=$fmt): $e');
          try {
            await _controller?.dispose();
          } catch (_) {}
        }
      }
    }

    debugPrint('All camera init attempts failed: $lastError');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera initialization failed: $lastError'), backgroundColor: AppColors.kDanger),
      );
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() => _isInitializing = true);
    await _initializeController(_selectedCameraIndex);
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final file = await _controller!.takePicture();
      setState(() => _lastPicture = file);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Picture captured'), duration: Duration(seconds: 1)),
      );
    } catch (e) {
      debugPrint('Take picture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture: $e'), backgroundColor: AppColors.kDanger),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: AppBar(
        backgroundColor: AppColors.kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.kAccent),
          onPressed: () => context.pop(),
        ),
        title: const Text('Camera', style: TextStyle(color: AppColors.kText)),
        centerTitle: true,
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.kAccent)))
          : _controller == null || !_controller!.value.isInitialized
              ? Center(child: Text('Camera not available', style: TextStyle(color: AppColors.kMuted)))
              : Stack(
                  children: [
                    Positioned.fill(child: CameraPreview(_controller!)),
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Thumbnail
                          GestureDetector(
                            onTap: () {
                              if (_lastPicture == null) return;
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  child: Image.file(File(_lastPicture!.path)),
                                ),
                              );
                            },
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.kCard2,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.kBorder),
                              ),
                              child: _lastPicture == null
                                  ? const Icon(Icons.photo, color: AppColors.kMuted)
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(File(_lastPicture!.path), fit: BoxFit.cover),
                                    ),
                            ),
                          ),

                          // Capture button
                          GestureDetector(
                            onTap: _takePicture,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.kAccent,
                                boxShadow: [BoxShadow(color: AppColors.kAccent.withOpacity(0.3), blurRadius: 12)],
                              ),
                              child: const Icon(Icons.camera_alt, color: AppColors.kBg, size: 32),
                            ),
                          ),

                          // Switch camera
                          GestureDetector(
                            onTap: _switchCamera,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.kCard2,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.kBorder),
                              ),
                              child: const Icon(Icons.cameraswitch, color: AppColors.kAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
