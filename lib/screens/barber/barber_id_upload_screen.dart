import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "package:stylesync/core/theme/app_typography.dart";
import 'package:stylesync/core/theme/app_colors.dart';
import 'package:stylesync/core/theme/theme_helpers.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BarberIdUploadScreen extends StatefulWidget {
  const BarberIdUploadScreen({super.key});

  @override
  State<BarberIdUploadScreen> createState() => _BarberIdUploadScreenState();
}

class _BarberIdUploadScreenState extends State<BarberIdUploadScreen> {
  final _nameCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _shopCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _govIdFile;
  bool _isUploading = false;
  final double _uploadProgress = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _licenseCtrl.dispose();
    _shopCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 95,
    );
    if (image != null) {
      setState(() => _govIdFile = File(image.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_govIdFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your Gov ID photo'),
          backgroundColor: AppColors.kDanger,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      // TODO: Implement Firebase Storage upload
      // For now, simulate upload
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        context.go('/barber/pending');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.kDanger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: AppBar(
        backgroundColor: AppColors.kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kText),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 36,
                    color: AppColors.kPrimary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verify Your Identity',
                          style: AppTypography.orbitron(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.kText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Submit your Gov ID to get verified',
                          style: AppTypography.inter(
                            fontSize: 13,
                            color: AppColors.kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Info banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.kTeal.withOpacity(0.08),
                  border: Border.all(
                    color: AppColors.kBorderTeal,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outlined,
                      size: 20,
                      color: AppColors.kTeal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verification takes 24-48 hours. You will be notified once approved.',
                        style: AppTypography.inter(
                          fontSize: 13,
                          color: AppColors.kTeal.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form fields
              kSectionLabel(Icons.person_outline, 'FULL NAME'),
              TextFormField(
                controller: _nameCtrl,
                style: AppTypography.inter(color: AppColors.kText),
                decoration: InputDecoration(
                  hintText: 'Your full name',
                  hintStyle: AppTypography.inter(color: AppColors.kMuted),
                  filled: true,
                  fillColor: AppColors.kCard2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.kBorder),
                  ),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              kSectionLabel(Icons.badge_outlined, 'LICENSE/BARBER ID NUMBER'),
              TextFormField(
                controller: _licenseCtrl,
                style: AppTypography.inter(color: AppColors.kText),
                decoration: InputDecoration(
                  hintText: 'Your license number',
                  hintStyle: AppTypography.inter(color: AppColors.kMuted),
                  filled: true,
                  fillColor: AppColors.kCard2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.kBorder),
                  ),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              kSectionLabel(Icons.store_outlined, 'SHOP AFFILIATION'),
              TextFormField(
                controller: _shopCtrl,
                style: AppTypography.inter(color: AppColors.kText),
                decoration: InputDecoration(
                  hintText: 'Your barbershop name',
                  hintStyle: AppTypography.inter(color: AppColors.kMuted),
                  filled: true,
                  fillColor: AppColors.kCard2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.kBorder),
                  ),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 28),

              // Image picker
              kSectionLabel(Icons.upload_file_outlined, 'GOVERNMENT ID PHOTO'),
              GestureDetector(
                onTap: _isUploading ? null : _pickImage,
                child: _govIdFile == null
                    ? Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.kCard2,
                          border: Border.all(
                            color: AppColors.kPrimary.withOpacity(0.3),
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignOutside,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: AppColors.kMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to upload Gov ID',
                              style: AppTypography.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Accepted: UMID, PhilSys, Driver\'s License, Passport',
                              style: AppTypography.inter(
                                fontSize: 10,
                                color: AppColors.kMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _govIdFile!,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: TextButton(
                              onPressed: _isUploading ? null : _pickImage,
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.kBg.withOpacity(0.8),
                              ),
                              child: Text(
                                'Change photo',
                                style: AppTypography.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.kPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              if (_isUploading) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _uploadProgress,
                  minHeight: 4,
                  backgroundColor: AppColors.kCard2,
                  valueColor: const AlwaysStoppedAnimation(AppColors.kPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Uploading...${(_uploadProgress * 100).toStringAsFixed(0)}%',
                  style: AppTypography.inter(
                    fontSize: 11,
                    color: AppColors.kMuted,
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isUploading ||
                        _nameCtrl.text.isEmpty ||
                        _licenseCtrl.text.isEmpty ||
                        _govIdFile == null
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPrimary,
                  foregroundColor: AppColors.kBg,
                  minimumSize: const Size(double.infinity, 52),
                  disabledBackgroundColor: AppColors.kBorder,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isUploading ? 'Uploading...' : 'Submit Verification',
                  style: AppTypography.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
