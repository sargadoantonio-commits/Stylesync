import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_card.dart';

class PricingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final List<String> features;
  final String buttonText;
  final VoidCallback? onPressed;
  final Color accentColor;
  final bool loading;

  const PricingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.features,
    required this.buttonText,
    required this.onPressed,
    this.accentColor = AppColors.accentMagenta,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
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
                    Text(title, style: AppTypography.interBody(14, weight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTypography.interBody(12).copyWith(color: AppColors.textMuted)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(price, style: AppTypography.interBody(16, weight: FontWeight.bold).copyWith(color: accentColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((f) => Padding(padding: const EdgeInsets.only(bottom:8), child: _featureItem(f))).toList(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: loading
                    ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white))
                    : Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.accentCyan),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppTypography.interBody(13))),
      ],
    );
  }
}
