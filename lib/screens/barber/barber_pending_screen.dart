import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "package:stylesync/core/theme/app_typography.dart";
import 'package:stylesync/core/theme/app_colors.dart';
import 'dart:ui' as ui;

class BarberPendingScreen extends StatefulWidget {
  const BarberPendingScreen({super.key});

  @override
  State<BarberPendingScreen> createState() => _BarberPendingScreenState();
}

class _BarberPendingScreenState extends State<BarberPendingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _rotateCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // TODO: Set up real-time Firestore listener
    // _setupRealtimeListener();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: AppBar(
        backgroundColor: AppColors.kBg,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon
              ScaleTransition(
                scale: Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(
                    parent: _pulseCtrl, curve: Curves.easeInOut)),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.kPrimary.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.kPrimary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: RotationTransition(
                      turns: _rotateCtrl,
                      child: const Icon(
                        Icons.schedule_outlined,
                        size: 36,
                        color: AppColors.kPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Verification Pending',
                style: AppTypography.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.kText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Your barber profile is under review.\nUsually within 24 hours.',
                style: AppTypography.inter(
                  fontSize: 14,
                  color: AppColors.kMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Status card
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.kCard.withOpacity(0.6),
                    border: Border.all(
                      color: AppColors.kBorder,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      _StatusRow(
                        icon: Icons.check_circle,
                        label: 'Application submitted',
                        color: AppColors.kTeal,
                      ),
                      SizedBox(height: 16),
                      _StatusRow(
                        icon: Icons.hourglass_top,
                        label: 'Under review by admin',
                        color: AppColors.kGold,
                      ),
                      SizedBox(height: 16),
                      _StatusRow(
                        icon: Icons.lock_outline,
                        label: 'Account activation',
                        color: AppColors.kMuted,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Application ID
              Text(
                'Application ID: ${_generateId()}',
                style: AppTypography.inter(
                  fontSize: 12,
                  color: AppColors.kMuted,
                ).copyWith(fontFamily: 'Courier'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Buttons
              ElevatedButton(
                onPressed: () => context.go('/support'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPrimary,
                  foregroundColor: AppColors.kBg,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Contact support',
                  style: AppTypography.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // TODO: Sign out
                  context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.kBorder),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Sign Out',
                  style: AppTypography.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.kText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateId() =>
      'SS-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8).toUpperCase()}';
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
