import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/offline_connectivity_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Floating badge showing offline status and pending sync items
class OfflineIndicatorWidget extends ConsumerWidget {
  const OfflineIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final connectivityState = ref.watch(offlineConnectivityProvider);

    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 50,
      right: 16,
      child: Material(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.kDanger,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.kDanger.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                connectivityState.message,
                style: AppTypography.interBody(12).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Offline banner for bottom of screen
class OfflineBottomBanner extends ConsumerWidget {
  const OfflineBottomBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Material(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.kDanger.withValues(alpha: 0.9),
          border: Border(
            top: BorderSide(
              color: AppColors.kDanger.withValues(alpha: 1.0),
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Working in offline mode - Data will sync when online',
                style: AppTypography.interBody(12).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.sync,
              color: Colors.white.withValues(alpha: 0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Status indicator for mini display
class OfflineStatusMini extends ConsumerWidget {
  const OfflineStatusMini({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline ? AppColors.kSuccess : AppColors.kDanger,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: AppTypography.interBody(10).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
