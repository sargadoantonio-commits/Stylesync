import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:stylesync/core/theme/app_colors.dart';

class BarberPendingScreen extends StatefulWidget {
  const BarberPendingScreen({super.key});

  @override
  State<BarberPendingScreen> createState() => _BarberPendingScreenState();
}

class _BarberPendingScreenState extends State<BarberPendingScreen> {
  late String _uid;
  late StreamSubscription<DocumentSnapshot> _subscription;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _listenToApplicationStatus();
  }

  void _listenToApplicationStatus() {
    _subscription = FirebaseFirestore.instance
        .collection('barberApplications')
        .doc(_uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final status = snapshot['status'] ?? 'pending';

        if (status == 'approved' && mounted) {
          // Auto-navigate to barber dashboard
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Congratulations! You\'ve been approved! 🎉'),
              backgroundColor: Color(0xFF00B894),
              duration: Duration(seconds: 2),
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) context.go('/barber/dashboard');
          });
        } else if (status == 'rejected' && mounted) {
          _showRejectedDialog();
        }
      }
    });
  }

  void _showRejectedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.kCard,
        icon:
            const Icon(Icons.info_outline, color: AppColors.kDanger, size: 32),
        title: const Text(
          'Application Rejected',
          style: TextStyle(
            color: AppColors.kText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Unfortunately, your application was not approved at this time. Please review the requirements and try again.',
          style: TextStyle(color: AppColors.kMuted),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ctx.pop();
              context.go('/barber/apply');
            },
            child: const Text(
              'Reapply',
              style: TextStyle(color: AppColors.kAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: AppBar(
        backgroundColor: AppColors.kBg,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // Animated loader
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.kAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (value * 0.2),
                            child: const Icon(
                              Icons.hourglass_empty,
                              size: 56,
                              color: AppColors.kAccent,
                            ),
                          );
                        },
                        onEnd: () {
                          // Loop animation
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Status text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Verification in Progress',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We\'re reviewing your application. This usually takes 24-48 hours.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.kMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Status card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.kAccent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline,
                            color: AppColors.kAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Application Submitted',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kText,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Your documents have been received',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.kMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.kBorder, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.kCard2,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.hourglass_empty,
                            color: AppColors.kMuted, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Under Review',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kText,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'We\'re verifying your documents',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.kMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.kBorder, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.kCard2,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_outline,
                            color: AppColors.kMuted, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Approval',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kMuted,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Coming soon',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.kMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Info box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.kAccent.withOpacity(0.3),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.kAccent, size: 18),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'While You Wait',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.kAccent,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Complete your profile setup to be ready to book appointments once approved.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Call to action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => context.push('/profile-setup'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: const Text('Complete Profile Setup'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: AppColors.kAccent),
                    ),
                    child: const Text(
                      'Contact Support',
                      style: TextStyle(color: AppColors.kAccent),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
