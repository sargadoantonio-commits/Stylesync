import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:shimmer/shimmer.dart";

import "../../../core/app_strings.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../widgets/queue_card.dart";
import "../../auth/presentation/providers/auth_providers.dart";
import "queue_providers.dart";
import '../../shop/presentation/providers/shop_providers.dart';

/// Displays the live barber queue with premium priority indicators,
/// accessibility semantics, and inline guidance for first-time users.
class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  Future<void> _join() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please sign in to join the queue'),
      ));
      return;
    }

    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profile not loaded yet. Try again shortly.'),
      ));
      return;
    }

    final shopId = ref.read(defaultShopIdProvider);
    if (shopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No shop selected. Please select a shop first.'),
      ));
      return;
    }

    try {
      HapticFeedback.mediumImpact();
      // Debug logging to help diagnose permission failures in emulator.
      // These prints appear in device logcat.
      debugPrint('[Queue] Attempting join: uid=${user.uid}, username=${profile.username}, isPremium=${profile.isPremium}, shopId=$shopId');
      final ticketId = await ref.read(queueRepositoryProvider).joinQueue(
            shopId: shopId,
            userId: user.uid,
            username: profile.username.isNotEmpty ? profile.username : profile.displayName ?? 'Guest',
            isPremium: profile.isPremium,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You have been added to the queue'),
        ));
      }
      // Optionally, we could navigate or update local cached ticket providers here.
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? 'Failed to join queue'),
          backgroundColor: AppColors.kDanger,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: AppColors.kDanger,
        ));
      }
    }
  }

  Future<void> _leave(String shopId, String ticketId) async {
    HapticFeedback.mediumImpact();
    await ref.read(queueRepositoryProvider).leaveQueue(shopId, ticketId);
  }

  @override
  Widget build(BuildContext context) {
    final shopId = ref.watch(defaultShopIdProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final selectedShop = ref.watch(selectedShopProvider);
    final isShopOwner = selectedShop != null && profile != null && (profile.uid == selectedShop.ownerId || profile.isAdmin == true);
    final queueAsync = ref.watch(queueSnapshotProvider);
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.deepNavy,
            elevation: 0,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Live Queue",
                style: AppTypography.orbitronHeading(18)
                    .copyWith(color: AppColors.white),
              ),
              centerTitle: true,
            ),
            leading: Tooltip(
              message: 'Back',
              child: Semantics(
                button: true,
                label: 'Back to previous screen',
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.accentRed),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Your queue updates live while you wait. Premium members keep priority without losing their place.',
                    style: AppTypography.interBody(14)
                        .copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text('Premium priority',
                            style: AppTypography.interBody(12,
                                    weight: FontWeight.w600)
                                .copyWith(color: AppColors.white)),
                        backgroundColor:
                            AppColors.accentRed.withValues(alpha: 0.16),
                        avatar: const Icon(Icons.star_rounded,
                            size: 16, color: AppColors.goldAccent),
                      ),
                      Chip(
                        label: Text('Live now',
                            style: AppTypography.interBody(12,
                                    weight: FontWeight.w600)
                                .copyWith(color: AppColors.white)),
                        backgroundColor:
                            AppColors.accentMagenta.withValues(alpha: 0.16),
                        avatar: const Icon(Icons.flash_on_rounded,
                            size: 16, color: AppColors.accentMagenta),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.deepNavy,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: QueueCard(
                      title: "Live barber queue",
                      subtitle:
                          "Premium people get priority, but you still keep your place inside the same lane.",
                      statusLabel: AppStrings.bookNow,
                      actionLabel: AppStrings.joinQueue,
                      isPremium: false,
                      onAction: _join,
                    ),
                  ),
 
                  // Owner controls: Call Next / Mark Served
                  if (isShopOwner)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final calledId = await ref.read(queueRepositoryProvider).callNext(shopId);
                                if (calledId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No tickets in queue')));
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Called next customer')));
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentMagenta),
                              child: Text('Call Next', style: AppTypography.interBody(14).copyWith(color: AppColors.white)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final shopRef = ref.read(queueRepositoryProvider);
                                final shop = await FirebaseFirestore.instance.collection('shops').doc(shopId).get();
                                final current = shop.data()?['currentServingTicketId'] as String?;
                                if (current == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No customer currently called')));
                                  return;
                                }
                                await shopRef.leaveQueue(shopId, current);
                                await shopRef.clearCurrentServing(shopId);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked served')));
                              },
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.kBorder)),
                              child: Text('Mark Served', style: AppTypography.interBody(14).copyWith(color: AppColors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  queueAsync.when(
                    data: (snap) {
                      final docs = snap.docs;
                      if (docs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              Text('No one is currently in queue',
                                  style: AppTypography.interBody(14)
                                      .copyWith(color: AppColors.textMuted)),
                              const SizedBox(height: 12),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final name = data['username'] as String? ?? 'Guest';
                          final premium = data['isPremium'] as bool? ?? false;
                          final userId = data['userId'] as String? ?? '';
                          final isSelf = userId == uid;
                          final aheadCount = index;

                          return QueueCard(
                            title:
                                '#${index + 1} ${premium ? "Premium" : "Standard"}',
                            subtitle: name,
                            statusLabel: aheadCount == 0
                                ? AppStrings.liveNow
                                : '$aheadCount ahead of this spot',
                            isLive: aheadCount == 0,
                            isPremium: premium,
                            actionLabel: isSelf ? 'Leave queue' : null,
                            onAction: isSelf
                                ? () => _leave(shopId, doc.id)
                                : null,
                          );
                        },
                      );
                    },
                    loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator())),
                    error: (e, st) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Failed to load queue: $e',
                          style: AppTypography.interBody(14)
                              .copyWith(color: AppColors.kMuted)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Semantics(
            label: 'No barbers nearby illustration',
            child: Icon(Icons.storefront_rounded,
                size: 72, color: AppColors.accentRed.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 24),
          Text(AppStrings.noBarbersNearby,
              textAlign: TextAlign.center,
              style:
                  AppTypography.interBody(16).copyWith(color: AppColors.white)),
          const SizedBox(height: 24),
          Tooltip(
            message: 'Join queue',
            child: Semantics(
              button: true,
              label: 'Join the queue',
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _join,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(AppStrings.joinQueue,
                      style:
                          AppTypography.interBody(15, weight: FontWeight.w600)
                              .copyWith(color: AppColors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: AppColors.deepNavy.withValues(alpha: 0.9),
        highlightColor: AppColors.white.withValues(alpha: 0.08),
        child: Column(
          children: [
            Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.deepNavy,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            ...List.generate(
              4,
              (index) => Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
