import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_card.dart';
import 'pricing_card.dart';

/// Premium upgrade screen shown when users reach AR limit
class PremiumUpgradeScreen extends ConsumerStatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  ConsumerState<PremiumUpgradeScreen> createState() =>
      _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends ConsumerState<PremiumUpgradeScreen> {
  String? _loadingTier;

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 8),
            const SizedBox(height: 16),

            PricingCard(
              title: 'Monthly Plan',
              subtitle: 'Perfect for trying styles',
              price: '₱99',
              features: const [
                'Unlimited AR Try-Ons',
                'Access to 50+ Styles',
                'Save Favorites',
                'Ad-Free Experience',
              ],
              buttonText: 'Subscribe Monthly',
              accentColor: AppColors.accentMagenta,
              loading: _loadingTier == 'monthly',
              onPressed: () => _startSubscription(context, tier: 'monthly'),
            ),
            const SizedBox(height: 16),

            PricingCard(
              title: 'Yearly Plan',
              subtitle: 'Best value for style lovers',
              price: '₱988\n₱82/mo',
              features: const [
                'Unlimited AR Try-Ons',
                'Access to 50+ Styles',
                'Save Favorites',
                'Ad-Free Experience',
                'Priority Support',
              ],
              buttonText: 'Subscribe Yearly',
              accentColor: AppColors.accentCyan,
              loading: _loadingTier == 'yearly',
              onPressed: () => _startSubscription(context, tier: 'yearly'),
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
              'Stripe Checkout shows the payment methods available for your region and card network.',
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

  Future<void> _startSubscription(
    BuildContext context, {
    required String tier,
  }) async {
    setState(() {
      _loadingTier = tier;
    });

    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('createPremiumSubscription');
      final response = await callable.call(<String, dynamic>{'tier': tier});
      final data = Map<String, dynamic>.from(response.data as Map);
      final redirectUrl = data['redirectUrl'] as String?;
      final status = data['status'] as String? ?? 'unknown';

      if (!context.mounted) return;

      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        final uri = Uri.parse(redirectUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            status == 'active' ? 'Premium Activated' : 'Complete Payment',
            style: AppTypography.orbitronHeading(16),
          ),
          content: Text(
            status == 'active'
                ? 'Your subscription is active. Premium access is ready now.'
                : 'Finish the checkout in your browser, then tap Check Status so the app can unlock premium features.',
            style: AppTypography.interBody(13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Later'),
            ),
            if (status != 'active')
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _refreshSubscriptionStatus(context);
                },
                child: const Text('Check Status'),
              ),
          ],
        ),
      );
    } on FirebaseFunctionsException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Checkout failed.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Checkout failed. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingTier = null;
        });
      }
    }
  }

  Future<void> _refreshSubscriptionStatus(BuildContext context) async {
    try {
      final callable = FirebaseFunctions.instance
          .httpsCallable('refreshPremiumSubscription');
      final response = await callable.call();
      final data = Map<String, dynamic>.from(response.data as Map);
      final status = data['status'] as String? ?? 'unknown';

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'active'
                ? 'Premium is now active.'
                : 'Subscription status is $status. Try again after completing payment.',
          ),
        ),
      );
    } on FirebaseFunctionsException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(error.message ?? 'Unable to check subscription status.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to check subscription status.')),
      );
    }
  }

}
