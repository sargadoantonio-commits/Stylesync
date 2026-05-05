import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "package:stylesync/core/theme/app_typography.dart";
import 'package:intl/intl.dart';
import 'package:stylesync/core/theme/app_colors.dart';

class BookingConfirmedScreen extends StatefulWidget {
  final String referenceCode;
  final String barber;
  final String service;
  final double price;
  final DateTime date;
  final String time;

  const BookingConfirmedScreen({
    super.key,
    required this.referenceCode,
    required this.barber,
    required this.service,
    required this.price,
    required this.date,
    required this.time,
  });

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkCtrl;
  late Animation<double> _checkAnim;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkAnim = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
    _checkCtrl.forward();
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              // Animated checkmark
              ScaleTransition(
                scale: _checkAnim,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(44),
                    color: AppColors.kPrimary.withOpacity(0.12),
                    border: Border.all(
                      color: AppColors.kPrimary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kPrimary.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: AppColors.kPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Booking Confirmed!',
                style: AppTypography.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.kText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle with booking details
              Text(
                '${widget.barber} · ${DateFormat('MMM d').format(widget.date)} · ${widget.time}',
                style: AppTypography.inter(
                  fontSize: 13,
                  color: AppColors.kMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Gold reference code card
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.kCard.withOpacity(0.6),
                  border: Border.all(
                    color: AppColors.kGold.withOpacity(0.45),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kGold.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'BOOKING REFERENCE',
                      style: AppTypography.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kMuted,
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.referenceCode,
                      style: AppTypography.orbitron(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.kGold,
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Divider(
                      color: AppColors.kBorder,
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.service} · ₱${widget.price.toStringAsFixed(0)} · Kings Cut Studio, Makati',
                      style: AppTypography.inter(
                        fontSize: 12,
                        color: AppColors.kMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment info
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
                      Icons.payments_outlined,
                      size: 20,
                      color: AppColors.kTeal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pay in person at the barbershop. No online payment.',
                        style: AppTypography.inter(
                          fontSize: 13,
                          color: AppColors.kTeal.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Add to calendar
                      },
                      icon: const Icon(Icons.calendar_month, size: 16),
                      label: const Text('Add to Calendar'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.kBorder),
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Share booking
                      },
                      icon: const Icon(Icons.share_outlined, size: 16),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.kBorder),
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Track queue button
              ElevatedButton(
                onPressed: () => context.go('/queue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPrimary,
                  foregroundColor: AppColors.kBg,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Track Your Queue →',
                  style: AppTypography.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // XP earned
              Text(
                '+10 XP earned! ✨',
                style: AppTypography.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kGold,
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
