import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:shimmer/shimmer.dart";

import "../../core/app_strings.dart";
import "../../core/router/app_routes.dart";
import "../../core/theme/app_colors.dart";
import "../../core/theme/app_typography.dart";
import "../../core/theme/style_button.dart";
import "../../core/theme/enhanced_design_system.dart";
import "../../features/auth/domain/user_role.dart";
import "../../features/auth/presentation/providers/auth_providers.dart";
import "../../features/queue/presentation/queue_providers.dart";
import "../../widgets/bottom_nav_bar.dart";

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final shopId = ref.watch(defaultShopIdProvider);
    final queueAsync = ref.watch(queueSnapshotProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      bottomNavigationBar: const BottomNavBar(currentRoute: AppRoutes.home),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return _buildShimmerBody();
            }

            final isBarber = profile.role == UserRole.barber;
            final queueDocs = queueAsync.maybeWhen(
                data: (snap) => snap.docs, orElse: () => null);
            QueryDocumentSnapshot<Map<String, dynamic>>? currentTicket;
            if (queueDocs != null) {
              for (final doc in queueDocs) {
                if (doc.data()["userId"] == profile.uid) {
                  currentTicket = doc;
                  break;
                }
              }
            }
            final aheadCount = currentTicket == null
                ? 0
                : queueDocs!.where((doc) {
                    final currentIndex =
                        (currentTicket!.data()["queueIndex"] as num?)
                                ?.toInt() ??
                            0;
                    final otherIndex =
                        (doc.data()["queueIndex"] as num?)?.toInt() ?? 0;
                    return otherIndex < currentIndex;
                  }).length;

            return SingleChildScrollView(
              child: Stack(
                children: [
                  // Background gradient accent
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentMagenta.withValues(alpha: 0.08),
                            AppColors.deepNavy.withValues(alpha: 0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: EnhancedSpacing.xl,
                        vertical: EnhancedSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with enhanced design
                        _buildEnhancedHeader(context, profile),
                        const SizedBox(height: EnhancedSpacing.xxxl),

                        // Profile completion alert
                        if (!profile.profileComplete)
                          _buildProfileAlert(context),
                        if (!profile.profileComplete)
                          const SizedBox(height: EnhancedSpacing.xl),

                        // Queue Status with enhanced design
                        if (!isBarber && currentTicket != null)
                          _buildEnhancedQueueCard(
                              context, aheadCount, queueDocs!.length),
                        if (!isBarber && currentTicket != null)
                          const SizedBox(height: EnhancedSpacing.xl),

                        // Quick Actions with enhanced layout
                        _buildQuickActionsSection(context, ref, profile,
                            shopId, isBarber),
                        const SizedBox(height: EnhancedSpacing.xxl),

                        // Premium Status
                        if (!profile.isPremium)
                          _buildPremiumCard(context),
                        if (profile.isPremium)
                          _buildPremiumBadge(),
                        const SizedBox(height: EnhancedSpacing.xxxl),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: _buildShimmerBody,
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.accentRed, size: 48),
                const SizedBox(height: 16),
                Text(AppStrings.networkRetry,
                    style: AppTypography.interBody(14)
                        .copyWith(color: AppColors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, dynamic profile) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.settings),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",
                  style: AppTypography.interBody(13)
                      .copyWith(color: AppColors.textMuted, height: 1.3),
                ),
                const SizedBox(height: EnhancedSpacing.sm),
                Text(
                  profile.displayName.isNotEmpty
                      ? profile.displayName
                      : profile.username,
                  style: AppTypography.orbitronHeading(28, weight: FontWeight.w700)
                      .copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(EnhancedSpacing.xs),
            decoration: BoxDecoration(
              gradient: EnhancedGradients.magentaPrimary,
              borderRadius: BorderRadius.circular(EnhancedRadius.lg),
              border: Border.all(
                color: AppColors.accentMagenta.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: EnhancedShadows.lg,
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.accentMagenta.withValues(alpha: 0.15),
              backgroundImage: profile.photoUrl.isNotEmpty
                  ? NetworkImage(profile.photoUrl)
                  : null,
              child: profile.photoUrl.isEmpty
                  ? Text(
                      profile.displayName.isNotEmpty
                          ? profile.displayName[0].toUpperCase()
                          : profile.username[0].toUpperCase(),
                      style: AppTypography.orbitronHeading(18, weight: FontWeight.w700)
                          .copyWith(color: AppColors.accentMagenta),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAlert(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.profileSetup),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accentMagenta.withValues(alpha: 0.15),
              AppColors.accentMagenta.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(EnhancedRadius.lg),
          border: Border.all(
            color: AppColors.accentMagenta.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: EnhancedShadows.md,
        ),
        padding: const EdgeInsets.all(EnhancedSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.accentMagenta.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(EnhancedRadius.md),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.accentMagenta,
                size: 22,
              ),
            ),
            const SizedBox(width: EnhancedSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Complete your profile",
                    style: AppTypography.interBody(14, weight: FontWeight.w600)
                        .copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: EnhancedSpacing.xs),
                  Text(
                    "Choose a username so barbers can find you.",
                    style: AppTypography.interBody(12)
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.accentMagenta,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedQueueCard(
      BuildContext context, int aheadCount, int totalCount) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.queue),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accentMagenta.withValues(alpha: 0.2),
              AppColors.accentMagenta.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(EnhancedRadius.xl),
          border: Border.all(
            color: AppColors.accentMagenta.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: EnhancedShadows.highlight,
        ),
        padding: const EdgeInsets.all(EnhancedSpacing.xl),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Position",
                        style: AppTypography.interBody(12)
                            .copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: EnhancedSpacing.xs),
                      Row(
                        children: [
                          Text(
                            "#${aheadCount + 1}",
                            style: AppTypography.orbitronHeading(32,
                                    weight: FontWeight.w700)
                                .copyWith(color: AppColors.accentMagenta),
                          ),
                          const SizedBox(width: EnhancedSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$aheadCount ahead",
                                style: AppTypography.interBody(13,
                                        weight: FontWeight.w500)
                                    .copyWith(color: AppColors.white),
                              ),
                              Text(
                                "$totalCount total",
                                style: AppTypography.interBody(12)
                                    .copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(EnhancedSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.accentMagenta.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(EnhancedRadius.md),
                    border: Border.all(
                      color: AppColors.accentMagenta.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: AppColors.accentMagenta,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: EnhancedSpacing.lg),
            Container(
              padding: const EdgeInsets.all(EnhancedSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.deepNavy.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(EnhancedRadius.md),
                border: Border.all(
                  color: AppColors.textMuted.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Est. Wait Time",
                        style: AppTypography.interBody(12)
                            .copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: EnhancedSpacing.xs),
                      Text(
                        "${(aheadCount * 25)} mins",
                        style: AppTypography.orbitronHeading(16,
                                weight: FontWeight.w600)
                            .copyWith(color: AppColors.accentGold),
                      ),
                    ],
                  ),
                  StyleButton(
                    label: "View Queue",
                    onPressed: () => context.push(AppRoutes.queue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref,
      dynamic profile, String shopId, bool isBarber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: EnhancedSpacing.sm),
          child: Text(
            "Quick Actions",
            style: AppTypography.orbitronHeading(16, weight: FontWeight.w700)
                .copyWith(color: AppColors.white),
          ),
        ),
        const SizedBox(height: EnhancedSpacing.lg),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: EnhancedSpacing.md,
          crossAxisSpacing: EnhancedSpacing.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildActionTile(
              icon: Icons.queue_music_rounded,
              label: "Join Queue",
              color: AppColors.accentMagenta,
              onTap: () {
                HapticFeedback.mediumImpact();
                ref.read(queueRepositoryProvider).joinQueue(
                      shopId: shopId,
                      userId: profile.uid,
                      username: profile.username,
                      isPremium: profile.isPremium,
                    );
              },
            ),
            _buildActionTile(
              icon: Icons.calendar_today_rounded,
              label: "Book Now",
              color: AppColors.accentCyan,
              onTap: () {
                HapticFeedback.mediumImpact();
                context.push(AppRoutes.booking);
              },
            ),
            _buildActionTile(
              icon: Icons.camera_alt_rounded,
              label: "AR Try-On",
              color: AppColors.accentGold,
              onTap: () {
                HapticFeedback.mediumImpact();
                context.push(AppRoutes.ar);
              },
            ),
            _buildActionTile(
              icon: Icons.favorite_outline_rounded,
              label: "Favorites",
              color: AppColors.accentMagenta,
              onTap: () {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("View your saved favorite barbers"),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(EnhancedRadius.lg),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: EnhancedShadows.md,
        ),
        child: Stack(
          children: [
            // Background accent
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(EnhancedSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(EnhancedSpacing.md),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(EnhancedRadius.md),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: EnhancedSpacing.md),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.interBody(12, weight: FontWeight.w600)
                        .copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.premiumUpgrade),
      child: Container(
        decoration: EnhancedCardDecoration.createPremiumDecoration(),
        padding: const EdgeInsets.all(EnhancedSpacing.xl),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(EnhancedSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(EnhancedRadius.md),
                        border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        color: AppColors.accentGold,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnhancedSpacing.md,
                          vertical: EnhancedSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(EnhancedRadius.pill),
                        border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Limited Time",
                        style: AppTypography.interBody(10, weight: FontWeight.w700)
                            .copyWith(color: AppColors.accentGold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: EnhancedSpacing.lg),
                Text(
                  "Unlock Premium",
                  style: AppTypography.orbitronHeading(22, weight: FontWeight.w700)
                      .copyWith(color: AppColors.white),
                ),
                const SizedBox(height: EnhancedSpacing.sm),
                Text(
                  "Skip queues • Priority bookings • Exclusive styles",
                  style: AppTypography.interBody(13)
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: EnhancedSpacing.xl),
                StyleButton(
                  label: "Upgrade Now",
                  onPressed: () => context.push(AppRoutes.premiumUpgrade),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentGold.withValues(alpha: 0.15),
            AppColors.accentGold.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(EnhancedRadius.lg),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(EnhancedSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(EnhancedSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(EnhancedRadius.md),
              border: Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.accentGold,
              size: 22,
            ),
          ),
          const SizedBox(width: EnhancedSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Premium Member",
                  style: AppTypography.interBody(14, weight: FontWeight.w600)
                      .copyWith(color: AppColors.white),
                ),
                Text(
                  "Enjoy exclusive benefits",
                  style: AppTypography.interBody(12)
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.stars_rounded,
            color: AppColors.accentGold,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBody([Object? error]) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: AppColors.deepNavy.withValues(alpha: 0.85),
        highlightColor: AppColors.white.withValues(alpha: 0.08),
        child: Column(
          children: List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
