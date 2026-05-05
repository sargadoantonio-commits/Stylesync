import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "package:stylesync/core/theme/app_typography.dart";
import 'package:stylesync/core/theme/app_colors.dart';
import 'package:stylesync/core/theme/theme_helpers.dart';
import 'dart:ui' as ui;

class BarberEarningsScreen extends StatelessWidget {
  const BarberEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - replace with Firestore
    final revenue = 2850;
    final cutsCount = 12;
    final avgRating = 4.8;
    final previousRevenue = 2150;

    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: AppBar(
        backgroundColor: AppColors.kBg,
        elevation: 0,
        title: Text(
          'Today\'s Earnings',
          style: AppTypography.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.kText,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kText),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card with gold border
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.kCard.withOpacity(0.6),
                  border: Border.all(
                    color: AppColors.kGold.withOpacity(0.45),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kGold.withOpacity(0.15),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'TODAY\'S EARNINGS',
                      style: AppTypography.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '₱$revenue',
                      style: AppTypography.orbitron(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.kGold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              '$cutsCount',
                              style: AppTypography.orbitron(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.kText,
                              ),
                            ),
                            Text(
                              'cuts',
                              style: AppTypography.inter(
                                fontSize: 9,
                                color: AppColors.kMuted,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: AppColors.kBorder,
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$avgRating',
                                  style: AppTypography.orbitron(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.kGold,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.star,
                                    size: 14, color: AppColors.kGold),
                              ],
                            ),
                            Text(
                              'avg',
                              style: AppTypography.inter(
                                fontSize: 9,
                                color: AppColors.kMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Services breakdown
            kSectionLabel(Icons.cut_outlined, 'SERVICES BREAKDOWN'),
            ...[
              ('Fade Cut', 5, 1250),
              ('Textured Crop', 4, 900),
              ('Beard Blend', 3, 700),
            ].map((svc) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.kCard2,
                    border: Border.all(color: AppColors.kBorder, width: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              svc.$1,
                              style: AppTypography.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kText,
                              ),
                            ),
                            Text(
                              '${svc.$2} services',
                              style: AppTypography.inter(
                                fontSize: 11,
                                color: AppColors.kMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₱${svc.$3}',
                        style: AppTypography.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.kPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Recent completions
            kSectionLabel(Icons.check_circle_outline, 'RECENT COMPLETIONS'),
            ...[
              ('Juan Cruz', 'Fade Cut', '₱250', '2h ago'),
              ('Marco Santos', 'Textured Crop', '₱300', '4h ago'),
              ('Alex Rodriguez', 'Beard Blend', '₱200', '6h ago'),
            ].map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.kPrimary.withOpacity(0.15),
                      child: Text(
                        item.$1[0],
                        style: AppTypography.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.kPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: AppTypography.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.kText,
                            ),
                          ),
                          Text(
                            item.$2,
                            style: AppTypography.inter(
                              fontSize: 11,
                              color: AppColors.kMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.$3,
                          style: AppTypography.orbitron(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.kPrimary,
                          ),
                        ),
                        Text(
                          item.$4,
                          style: AppTypography.inter(
                            fontSize: 9,
                            color: AppColors.kMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Comparison
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.kTeal.withOpacity(0.08),
                border: Border.all(color: AppColors.kBorderTeal, width: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    previousRevenue < revenue
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: 20,
                    color: previousRevenue < revenue
                        ? AppColors.kSuccess
                        : AppColors.kDanger,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'vs Yesterday: ₱$previousRevenue — ${((revenue - previousRevenue) / previousRevenue * 100).toStringAsFixed(1)}% ${previousRevenue < revenue ? 'up' : 'down'}',
                      style: AppTypography.inter(
                        fontSize: 13,
                        color: AppColors.kText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
