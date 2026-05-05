import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_card.dart';

/// Premium upgrade screen shown when users reach AR limit
class PremiumUpgradeScreen extends ConsumerWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Go Premium', style: AppTypography.orbitronHeading(18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.accentMagenta),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentMagenta.withValues(alpha: 0.3),
                          AppColors.accentCyan.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.diamond_rounded,
                      size: 50,
                      color: AppColors.accentMagenta,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'StyleSync Premium',
                    style: AppTypography.orbitronHeading(24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlimited AR Hair Try-Ons + Exclusive Features',
                    style: AppTypography.interBody(14)
                        .copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Pricing Tiers
            Text(
              'Pricing Plans',
              style: AppTypography.orbitronHeading(18),
            ),
            const SizedBox(height: 16),

            // Monthly Plan
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Plan',
                              style: AppTypography.interBody(14,
                                  weight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Perfect for trying styles',
                              style: AppTypography.interBody(12)
                                  .copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                AppColors.accentMagenta.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '₱99',
                            style: AppTypography.interBody(16,
                                    weight: FontWeight.bold)
                                .copyWith(color: AppColors.accentMagenta),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem('Unlimited AR Try-Ons'),
                    const SizedBox(height: 8),
                    _buildFeatureItem('Access to 50+ Styles'),
                    const SizedBox(height: 8),
                    _buildFeatureItem('Save Favorites'),
                    const SizedBox(height: 8),
                    _buildFeatureItem('Ad-Free Experience'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showComingSoonDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentMagenta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Subscribe Monthly'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Yearly Plan
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Yearly Plan',
                                  style: AppTypography.interBody(14,
                                      weight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentCyan
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Save 17%',
                                    style: AppTypography.interBody(10)
                                        .copyWith(color: AppColors.accentCyan),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Best value for style lovers',
                              style: AppTypography.interBody(12)
                                  .copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.accentCyan.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₱988',
                                style: AppTypography.interBody(14,
                                        weight: FontWeight.bold)
                                    .copyWith(color: AppColors.accentCyan),
                              ),
                              Text(
                                '₱82/mo',
                                style: AppTypography.interBody(10)
                                    .copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem('Unlimited AR Try-Ons'),
                    const SizedBox(height: 8),
                    _buildFeatureItem('Access to 50+ Styles'),
                    const SizedBox(height: 8),
                    _buildFeatureItem('Save Favorites'),
                    const SizedBox(height: 8),
                    _buildFeatureItem('Ad-Free Experience'),
                    const SizedBox(height: 8),
                    _buildFeatureItem('Priority Support'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showComingSoonDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentCyan,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Subscribe Yearly'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // FAQ Section
            Text(
              'Frequently Asked',
              style: AppTypography.orbitronHeading(16),
            ),
            const SizedBox(height: 16),
            _buildFaqItem(
              'Can I cancel anytime?',
              'Yes, cancel your subscription at any time. No questions asked.',
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              'What payment methods accepted?',
              'We accept GCash, credit cards, debit cards, and PayPal.',
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              'Is there a free trial?',
              'You already have 3 free tries per month. Upgrade anytime!',
            ),
            const SizedBox(height: 40),

            // Back Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accentMagenta),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Maybe Later',
                  style: AppTypography.interBody(14)
                      .copyWith(color: AppColors.accentMagenta),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: AppColors.accentCyan,
        ),
        const SizedBox(width: 12),
        Text(
          feature,
          style: AppTypography.interBody(13),
        ),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: AppTypography.interBody(13, weight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              answer,
              style: AppTypography.interBody(12)
                  .copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Coming Soon',
          style: AppTypography.orbitronHeading(16),
        ),
        content: Text(
          'Payment processing is coming in the next update. Follow our news for launch date!',
          style: AppTypography.interBody(13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }
}
