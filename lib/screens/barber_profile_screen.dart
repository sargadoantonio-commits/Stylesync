import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "../core/router/app_routes.dart";
import "../core/theme/app_colors.dart";
import "../core/theme/app_typography.dart";
import "../core/theme/glass_card.dart";
import "../core/theme/style_button.dart";

class BarberProfileScreen extends StatelessWidget {
  const BarberProfileScreen(
      {super.key, required this.barberName, required this.specialty});

  final String barberName;
  final String specialty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        title: Text("Barber Profile", style: AppTypography.orbitronHeading(18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.accentMagenta),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(barberName, style: AppTypography.orbitronHeading(20)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text("$specialty • ",
                          style: AppTypography.interBody(14)
                              .copyWith(color: AppColors.textMuted)),
                      const Icon(Icons.star,
                          size: 16, color: AppColors.goldAccent),
                      const SizedBox(width: 4),
                      Text("4.9",
                          style: AppTypography.interBody(14,
                                  weight: FontWeight.w700)
                              .copyWith(color: AppColors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text("Availability",
                      style: AppTypography.orbitronHeading(14)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildAvailabilityChip("Mon 10-6"),
                      _buildAvailabilityChip("Wed 12-8"),
                      _buildAvailabilityChip("Fri 9-5"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("Portfolio", style: AppTypography.orbitronHeading(14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildPortfolioTile("Classic fade"),
                      const SizedBox(width: 12),
                      _buildPortfolioTile("Beard trim"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("What people say",
                      style: AppTypography.orbitronHeading(14)),
                  const SizedBox(height: 12),
                  _buildReview(
                      """Best precision cuts in the city. Super friendly and fast."""),
                  const SizedBox(height: 12),
                  _buildReview(
                      """Always recommend the latest styles. My go-to barber."""),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: StyleButton(
              label: "Book this barber",
              icon: Icons.calendar_today,
              onPressed: () => context.push(AppRoutes.booking),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityChip(String label) {
    return Chip(
      label: Text(label,
          style: AppTypography.interBody(13).copyWith(color: AppColors.white)),
      backgroundColor: AppColors.accentMagenta.withValues(alpha: 0.18),
    );
  }

  Widget _buildPortfolioTile(String title) {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child:
                      Icon(Icons.photo, color: AppColors.accentRed, size: 28),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: AppTypography.interBody(13, weight: FontWeight.w700)
                    .copyWith(color: AppColors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(String text) {
    return Text(text,
        style:
            AppTypography.interBody(13).copyWith(color: AppColors.textMuted));
  }
}
