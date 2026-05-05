import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylesync/core/theme/app_colors.dart';
import 'package:stylesync/core/theme/app_typography.dart';
import 'package:stylesync/features/auth/presentation/providers/session_timeout_provider.dart';

/// Session timeout warning dialog - displayed 1 minute before automatic logout
class SessionTimeoutWarningDialog extends ConsumerWidget {
  const SessionTimeoutWarningDialog({super.key});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionTimeoutProvider);

    if (!sessionState.showWarning) {
      return const SizedBox.shrink();
    }

    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_rounded,
              color: AppColors.accentGold,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Session Expiring Soon',
                style: AppTypography.orbitronHeading(16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your session will expire in:',
              style: AppTypography.interBody(14),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _formatDuration(sessionState.timeRemaining),
                style: AppTypography.orbitronHeading(32).copyWith(
                  color: AppColors.accentGold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'For security purposes, your session automatically expires after 30 minutes of inactivity to protect your account.',
              style: AppTypography.interBody(12).copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final notifier = ref.read(sessionTimeoutProvider.notifier);
              await notifier.logout();
            },
            child: Text(
              'Logout',
              style: AppTypography.interBody(14).copyWith(
                color: AppColors.accentRed,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentCyan,
            ),
            onPressed: () {
              final notifier = ref.read(sessionTimeoutProvider.notifier);
              notifier.extendSession();
              Navigator.pop(context);
            },
            child: Text(
              'Stay Logged In',
              style: AppTypography.interBody(14).copyWith(
                color: AppColors.background,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
