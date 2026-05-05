import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stylesync/core/theme/app_colors.dart';

class BarberIdUploadScreen extends StatefulWidget {
  const BarberIdUploadScreen({super.key});

  @override
  State<BarberIdUploadScreen> createState() => _BarberIdUploadScreenState();
}

class _BarberIdUploadScreenState extends State<BarberIdUploadScreen> {
  bool _idUploaded = false;
  bool _licenseUploaded = false;
  String? _selectedIdType;
  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  final _shopController = TextEditingController();

  final List<String> _idTypes = [
    'National ID',
    'Driver\'s License',
    'Passport',
    'UMID',
  ];

  void _simulateIdUpload() {
    setState(() => _idUploaded = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Government ID uploaded ✓'),
        backgroundColor: Color(0xFF00B894),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _simulateLicenseUpload() {
    setState(() => _licenseUploaded = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('License photo uploaded ✓'),
        backgroundColor: Color(0xFF00B894),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_idUploaded || !_licenseUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both ID and license photos'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('barberApplications')
          .doc(uid)
          .set({
        'uid': uid,
        'name': FirebaseAuth.instance.currentUser!.displayName ?? 'Unknown',
        'govIdType': _selectedIdType,
        'licenseNumber': _licenseController.text.trim(),
        'shopAffiliation': _shopController.text.trim(),
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully! ✓'),
            backgroundColor: Color(0xFF00B894),
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) context.go('/barber/pending');
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: $e'),
          backgroundColor: AppColors.kDanger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _shopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: AppBar(
        backgroundColor: AppColors.kBg,
        title: const Text('Barber Verification',
            style: TextStyle(color: AppColors.kText)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Upload Your Documents',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Help us verify you\'re a licensed barber',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.kMuted,
                ),
              ),
              const SizedBox(height: 32),

              // ID Type selector
              const Text(
                'ID Type',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kText,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedIdType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.kCard2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.kBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.kAccent, width: 1.5),
                  ),
                ),
                items: _idTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type,
                        style: const TextStyle(color: AppColors.kText)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedIdType = value),
                validator: (v) => v == null ? 'Please select ID type' : null,
                style: const TextStyle(color: AppColors.kText),
                dropdownColor: AppColors.kCard,
                isExpanded: true,
              ),
              const SizedBox(height: 24),

              // ID Photo
              const Text(
                'Government ID Photo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kText,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _simulateIdUpload,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.kCard2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _idUploaded ? AppColors.kAccent : AppColors.kBorder,
                      width: 2,
                    ),
                  ),
                  child: _idUploaded
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle,
                                size: 56, color: AppColors.kSuccess),
                            SizedBox(height: 8),
                            Text(
                              'ID photo uploaded',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kSuccess,
                              ),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 40, color: AppColors.kAccent),
                            SizedBox(height: 8),
                            Text(
                              'Tap to upload ID photo',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kMuted,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // License Photo
              const Text(
                'Barber License/Certificate Photo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kText,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _simulateLicenseUpload,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.kCard2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _licenseUploaded
                          ? AppColors.kAccent
                          : AppColors.kBorder,
                      width: 2,
                    ),
                  ),
                  child: _licenseUploaded
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle,
                                size: 56, color: AppColors.kSuccess),
                            SizedBox(height: 8),
                            Text(
                              'License photo uploaded',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kSuccess,
                              ),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 40, color: AppColors.kAccent),
                            SizedBox(height: 8),
                            Text(
                              'Tap to upload license photo',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kMuted,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // License Number
              TextFormField(
                controller: _licenseController,
                decoration: InputDecoration(
                  labelText: 'License Number',
                  filled: true,
                  fillColor: AppColors.kCard2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.kBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.kAccent, width: 1.5),
                  ),
                  labelStyle: const TextStyle(color: AppColors.kMuted),
                ),
                style: const TextStyle(color: AppColors.kText),
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'License number required' : null,
              ),
              const SizedBox(height: 16),

              // Shop Affiliation
              TextFormField(
                controller: _shopController,
                decoration: InputDecoration(
                  labelText: 'Shop Affiliation (optional)',
                  filled: true,
                  fillColor: AppColors.kCard2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.kBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.kAccent, width: 1.5),
                  ),
                  labelStyle: const TextStyle(color: AppColors.kMuted),
                ),
                style: const TextStyle(color: AppColors.kText),
              ),
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.kBg),
                        ),
                      )
                    : const Text('Submit Application',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
