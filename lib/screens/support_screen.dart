import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "../core/theme/app_colors.dart";
import "../core/theme/app_typography.dart";
import "../core/theme/glass_card.dart";
import "../core/theme/style_button.dart";
import "../widgets/section_pill_badge.dart";

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        title: Text("Support & Help", style: AppTypography.orbitronHeading(18)),
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
                  const SectionPillBadge(label: "Support"),
                  const SizedBox(height: 10),
                  Text(
                      "Browse the help center or contact your barber shop directly.",
                      style: AppTypography.interBody(14)
                          .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(context, Icons.help_outline, "Help Center",
              "View FAQs and troubleshooting guides."),
          const SizedBox(height: 12),
          _buildCard(context, Icons.phone_in_talk_rounded, "Contact Support",
              "Email or call support for urgent issues."),
          const SizedBox(height: 12),
          _buildCard(context, Icons.handshake_rounded, "Partnership",
              "Learn how barber shops can join StyleSync."),
          const SizedBox(height: 24),
          StyleButton(
            label: "Send support request",
            icon: Icons.mail_outline,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        "Support request submitted. We'll contact you shortly.")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, IconData icon, String title, String subtitle) {
    return GlassCard(
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.kPrimary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.kPrimary),
        ),
        title: Text(title,
            style: AppTypography.interBody(15, weight: FontWeight.w700)),
        subtitle: Text(subtitle,
            style: AppTypography.interBody(13)
                .copyWith(color: AppColors.textMuted)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Opening $title..."),
                backgroundColor: AppColors.kPrimary),
          );
        },
      ),
    );
  }
}
