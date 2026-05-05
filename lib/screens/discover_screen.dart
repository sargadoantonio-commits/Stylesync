import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../core/app_strings.dart";
import "../core/router/app_routes.dart";
import "../core/theme/app_colors.dart";
import "../core/theme/app_typography.dart";
import "../core/theme/enhanced_design_system.dart";
import "../widgets/bottom_nav_bar.dart";

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      bottomNavigationBar: const BottomNavBar(currentRoute: AppRoutes.discover),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.deepNavy,
            elevation: 0,
            pinned: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: EnhancedGradients.magentaToTransparent,
                ),
              ),
              title: Text(
                AppStrings.discover,
                style: AppTypography.orbitronHeading(24, weight: FontWeight.w700)
                    .copyWith(color: AppColors.white),
              ),
              centerTitle: true,
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: EnhancedSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.accentMagenta.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(EnhancedRadius.md),
                  border: Border.all(
                    color: AppColors.accentMagenta.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search,
                      color: AppColors.accentMagenta, size: 22),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    // TODO: Implement search
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(EnhancedSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Find your perfect barber",
                    style: AppTypography.orbitronHeading(20, weight: FontWeight.w700)
                        .copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: EnhancedSpacing.sm),
                  Text(
                    "Discover top-rated barbershops in your area",
                    style: AppTypography.interBody(14)
                        .copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: EnhancedSpacing.xxl),
                  _buildFeaturedShop(),
                  const SizedBox(height: EnhancedSpacing.section),
                  _buildShopBarbers(),
                  const SizedBox(height: EnhancedSpacing.section),
                  _buildStyleLibraryCard(context),
                  const SizedBox(height: EnhancedSpacing.section),
                  _buildPopularServices(),
                  const SizedBox(height: EnhancedSpacing.section),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedShop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Featured Shop",
              style: AppTypography.orbitronHeading(16, weight: FontWeight.w700)
                  .copyWith(color: AppColors.white),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: EnhancedSpacing.md,
                  vertical: EnhancedSpacing.xs),
              decoration: BoxDecoration(
                gradient: EnhancedGradients.goldAccent,
                borderRadius: BorderRadius.circular(EnhancedRadius.pill),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.accentGold),
                  const SizedBox(width: EnhancedSpacing.xs),
                  Text(
                    "4.9",
                    style:
                        AppTypography.interBody(12, weight: FontWeight.w700)
                            .copyWith(color: AppColors.accentGold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: EnhancedSpacing.lg),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentMagenta.withValues(alpha: 0.12),
                AppColors.accentMagenta.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.accentMagenta.withValues(alpha: 0.25),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(EnhancedRadius.xl),
            boxShadow: EnhancedShadows.lg,
          ),
          padding: const EdgeInsets.all(EnhancedSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentMagenta.withValues(alpha: 0.2),
                      AppColors.accentMagenta.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(EnhancedRadius.lg),
                  border: Border.all(
                    color: AppColors.accentMagenta.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentMagenta.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.accentMagenta.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.storefront_rounded,
                        size: 64,
                        color: AppColors.accentMagenta,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: EnhancedSpacing.xl),
              Text(
                "StyleSync Premium Barbershop",
                style: AppTypography.orbitronHeading(18, weight: FontWeight.w700)
                    .copyWith(color: AppColors.white),
              ),
              const SizedBox(height: EnhancedSpacing.lg),
              _buildShopInfoRow(
                Icons.location_on_rounded,
                "123 Main St, Downtown",
                AppColors.accentCyan,
              ),
              const SizedBox(height: EnhancedSpacing.md),
              _buildShopInfoRow(
                Icons.access_time_rounded,
                "Open • Mon-Sat 9AM-8PM",
                AppColors.accentGold,
              ),
              const SizedBox(height: EnhancedSpacing.md),
              _buildShopInfoRow(
                Icons.phone_rounded,
                "(+63) 912-345-6789",
                AppColors.accentMagenta,
              ),
              const SizedBox(height: EnhancedSpacing.lg),
              Container(
                padding: const EdgeInsets.all(EnhancedSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(EnhancedRadius.md),
                  border: Border.all(
                    color: AppColors.accentMagenta.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.accentMagenta,
                    ),
                    const SizedBox(width: EnhancedSpacing.md),
                    Expanded(
                      child: Text(
                        "Book appointments, join queue, or try AR styling",
                        style: AppTypography.interBody(12)
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShopInfoRow(
      IconData icon, String text, Color accentColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(EnhancedSpacing.sm),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(EnhancedRadius.sm),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
              width: 0.8,
            ),
          ),
          child: Icon(icon, size: 16, color: accentColor),
        ),
        const SizedBox(width: EnhancedSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTypography.interBody(13, weight: FontWeight.w500)
                .copyWith(color: AppColors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleLibraryCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push(AppRoutes.styleLibrary);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accentCyan.withValues(alpha: 0.15),
              AppColors.accentCyan.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(EnhancedRadius.lg),
          border: Border.all(
            color: AppColors.accentCyan.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: EnhancedShadows.lg,
        ),
        padding: const EdgeInsets.all(EnhancedSpacing.xl),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentCyan.withValues(alpha: 0.2),
                    AppColors.accentCyan.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(EnhancedRadius.md),
                border: Border.all(
                  color: AppColors.accentCyan.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.style_rounded,
                  size: 32, color: AppColors.accentCyan),
            ),
            const SizedBox(width: EnhancedSpacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Style Library",
                      style: AppTypography.orbitronHeading(16,
                              weight: FontWeight.w700)
                          .copyWith(color: AppColors.white)),
                  const SizedBox(height: EnhancedSpacing.sm),
                  Text(
                      "Browse curated haircuts and ideas for your next visit.",
                      style: AppTypography.interBody(13)
                          .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.accentCyan, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Popular Services",
          style: AppTypography.orbitronHeading(16, weight: FontWeight.w700)
              .copyWith(color: AppColors.white),
        ),
        const SizedBox(height: EnhancedSpacing.lg),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: EnhancedSpacing.md,
          mainAxisSpacing: EnhancedSpacing.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildServiceCard("Haircut", "₱150", Icons.content_cut,
                AppColors.accentMagenta),
            _buildServiceCard("Shave", "₱80", Icons.iron,
                AppColors.accentCyan),
            _buildServiceCard("Beard Trim", "₱100", Icons.face,
                AppColors.accentGold),
            _buildServiceCard("Hair Wash", "₱50", Icons.shower,
                AppColors.accentMagenta),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceCard(
      String title, String price, IconData icon, Color accentColor) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withValues(alpha: 0.12),
              accentColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(EnhancedRadius.lg),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: EnhancedShadows.md,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(EnhancedSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(EnhancedSpacing.md),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(EnhancedRadius.md),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(icon, size: 28, color: accentColor),
                  ),
                  const SizedBox(height: EnhancedSpacing.lg),
                  Text(
                    title,
                    style: AppTypography.interBody(14, weight: FontWeight.w600)
                        .copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: EnhancedSpacing.sm),
                  Text(
                    price,
                    style: AppTypography.orbitronHeading(16,
                            weight: FontWeight.w700)
                        .copyWith(color: accentColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopBarbers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Our Talented Barbers",
          style: AppTypography.orbitronHeading(16, weight: FontWeight.w700)
              .copyWith(color: AppColors.white),
        ),
        const SizedBox(height: EnhancedSpacing.lg),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            final colors = [
              AppColors.accentMagenta,
              AppColors.accentCyan,
              AppColors.accentGold,
            ];
            final color = colors[index % colors.length];

            return Container(
              margin: const EdgeInsets.only(bottom: EnhancedSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.1),
                    color.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(EnhancedRadius.lg),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 1.2,
                ),
                boxShadow: EnhancedShadows.md,
              ),
              child: Padding(
                padding: const EdgeInsets.all(EnhancedSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.2),
                            color.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(EnhancedRadius.md),
                        border: Border.all(
                          color: color.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 32,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: EnhancedSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Barber ${['Juan', 'Pedro', 'Miguel'][index]}",
                            style: AppTypography.interBody(15,
                                    weight: FontWeight.w600)
                                .copyWith(color: AppColors.white),
                          ),
                          const SizedBox(height: EnhancedSpacing.xs),
                          Text(
                            "Specializes in ${[
                              'Classic Cuts',
                              'Modern Styles',
                              'Beard Grooming'
                            ][index]}",
                            style: AppTypography.interBody(13)
                                .copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: EnhancedSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: EnhancedSpacing.md,
                                vertical: EnhancedSpacing.xs),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(EnhancedRadius.pill),
                              border: Border.all(
                                color: color.withValues(alpha: 0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    size: 13, color: AppColors.accentGold),
                                const SizedBox(width: EnhancedSpacing.xs),
                                Text(
                                  "4.${8 - index}",
                                  style: AppTypography.interBody(12,
                                          weight: FontWeight.w600)
                                      .copyWith(color: color),
                                ),
                                const SizedBox(width: EnhancedSpacing.xs),
                                Text(
                                  "${50 + index * 20}",
                                  style: AppTypography.interBody(11)
                                      .copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: color, size: 18),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
