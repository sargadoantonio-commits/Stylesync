import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/offline_sync_queue.dart';
import '../providers/offline_connectivity_provider.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_typography.dart';

/// Test screen for offline mode functionality
class OfflineModeTestScreen extends ConsumerStatefulWidget {
  const OfflineModeTestScreen({super.key});

  @override
  ConsumerState<OfflineModeTestScreen> createState() =>
      _OfflineModeTestScreenState();
}

class _OfflineModeTestScreenState extends ConsumerState<OfflineModeTestScreen> {
  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(offlineConnectivityProvider);
    final pendingItems = ref.watch(pendingOfflineItemsProvider);
    final queueItems = ref.watch(offlineSyncQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mode Test'),
        backgroundColor: AppColors.kPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connectivity Status
            _buildSection(
              title: 'Connectivity Status',
              children: [
                _buildStatusCard(
                  title: 'Status',
                  value: connectivityState.isOnline ? 'Online' : 'Offline',
                  color: connectivityState.isOnline
                      ? AppColors.kSuccess
                      : AppColors.kDanger,
                ),
                _buildStatusCard(
                  title: 'Message',
                  value: connectivityState.message,
                  color: AppColors.kMuted,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sync Queue Status
            _buildSection(
              title: 'Sync Queue',
              children: [
                _buildStatusCard(
                  title: 'Pending Items',
                  value: '$pendingItems',
                  color: pendingItems > 0
                      ? AppColors.accentGold
                      : AppColors.kSuccess,
                ),
                if (queueItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        border: Border.all(color: AppColors.kMuted),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Queued Operations:',
                            style: AppTypography.interBody(12).copyWith(
                              color: AppColors.kMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...queueItems.map((item) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                '• ${item.operationType} - ${item.collection}/${item.documentId} (${item.synced ? 'Synced' : 'Pending'})',
                                style: AppTypography.interBody(11).copyWith(
                                  color: AppColors.kText,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Actions
            _buildSection(
              title: 'Actions',
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final notifier =
                          ref.read(offlineConnectivityProvider.notifier);
                      await notifier.manualConnectivityCheck();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Connectivity check: ${ref.read(offlineConnectivityProvider).message}',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.cloud_queue),
                    label: const Text('Check Connectivity'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: pendingItems == 0
                        ? null
                        : () {
                            ref
                                .read(offlineSyncQueueProvider.notifier)
                                .clearQueue();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sync queue cleared'),
                              ),
                            );
                            setState(() {});
                          },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear Sync Queue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kDanger,
                      disabledBackgroundColor: AppColors.kMuted,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Testing Instructions
            _buildSection(
              title: 'Testing Instructions',
              children: [
                _buildInstructionItem(
                  number: '1',
                  title: 'Enable Airplane Mode',
                  description:
                      'Open Settings → Airplane Mode → Enable\nOr disable WiFi + Mobile Data',
                ),
                _buildInstructionItem(
                  number: '2',
                  title: 'Observe Offline Status',
                  description:
                      'Status should show "Offline"\nRed indicator appears in UI',
                ),
                _buildInstructionItem(
                  number: '3',
                  title: 'View Cached Data',
                  description: 'Browse existing barbers and bookings\n(no new data can be fetched)',
                ),
                _buildInstructionItem(
                  number: '4',
                  title: 'Test Operations',
                  description:
                      'Try creating booking or updating profile\nOperations queued in sync queue',
                ),
                _buildInstructionItem(
                  number: '5',
                  title: 'Restore Connectivity',
                  description:
                      'Turn off Airplane Mode or enable WiFi\nStatus changes to "Online"',
                ),
                _buildInstructionItem(
                  number: '6',
                  title: 'Verify Sync',
                  description:
                      'Queued operations automatically sync\nCheck Firestore for updates',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.interBody(14).copyWith(
            color: AppColors.kText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.interBody(12).copyWith(
              color: AppColors.kMuted,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: AppTypography.interBody(12).copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.kPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppTypography.interBody(11).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.interBody(12).copyWith(
                    color: AppColors.kText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.interBody(11).copyWith(
                    color: AppColors.kMuted,
                    height: 1.5,
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
