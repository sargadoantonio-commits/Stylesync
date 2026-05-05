import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import "package:stylesync/core/theme/app_typography.dart";
import 'package:stylesync/core/theme/app_colors.dart';

/// Section label with icon prefix
Widget kSectionLabel(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 14, color: AppColors.kMuted),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTypography.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.kMuted,
            letterSpacing: 1.0,
          ),
        ),
      ],
    ),
  );
}

/// Status badge widget
Widget kStatusBadge(String status) {
  final (color, label) = switch (status) {
    'confirmed' => (AppColors.kPrimary, 'Confirmed'),
    'completed' => (AppColors.kSuccess, 'Completed'),
    'cancelled' => (AppColors.kDanger, 'Cancelled'),
    'approved' => (AppColors.kTeal, 'Approved'),
    'pending' => (AppColors.kGold, 'Pending'),
    'rejected' => (AppColors.kDanger, 'Rejected'),
    _ => (AppColors.kMuted, status),
  };

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withAlpha((0.12 * 255).round()),
      border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: AppTypography.inter(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

/// Action tile for quick actions grid
class ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionTile({super.key, 
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.kCard.withAlpha((0.6 * 255).round()),
            border: Border.all(color: AppColors.kBorder, width: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: AppColors.kPrimary),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wait time chip helper
Widget waitChip(int minutes) {
  final (color, label) = switch (minutes) {
    < 15 => (AppColors.kTeal, '~${minutes}min Fast'),
    < 30 => (AppColors.kGold, '~${minutes}min'),
    _ => (AppColors.kDanger, '~${minutes}min'),
  };

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withAlpha((0.12 * 255).round()),
      border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: AppTypography.inter(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}
