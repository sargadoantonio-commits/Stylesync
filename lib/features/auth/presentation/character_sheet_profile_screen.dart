import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:shimmer/shimmer.dart";

import "package:stylesync/core/theme/app_colors.dart";
import "package:stylesync/core/theme/app_typography.dart";
import "package:stylesync/core/theme/style_button.dart";
import "package:stylesync/core/router/app_routes.dart";
import "package:stylesync/features/auth/domain/user_model.dart";
import "package:stylesync/features/auth/domain/user_role.dart";
import "package:stylesync/features/auth/presentation/providers/auth_providers.dart";

/// Post-login **character sheet** profile: RPG-style presentation of the signed-in user.
class CharacterSheetProfileScreen extends ConsumerWidget {
  const CharacterSheetProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => _ShimmerPlaceholder(),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(e.toString(), style: AppTypography.interBody(14).copyWith(color: Colors.redAccent)),
            ),
          ),
          data: (profile) {
            if (profile == null) {
              return _ShimmerPlaceholder();
            }
            return _CharacterSheetBody(profile: profile);
          },
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Shimmer.fromColors(
        baseColor: AppColors.deepNavy,
        highlightColor: AppColors.accentMagenta.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 28, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 20),
            Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 16),
            Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 16),
            Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
          ],
        ),
      ),
    );
  }
}

class _CharacterSheetBody extends StatelessWidget {
  const _CharacterSheetBody({required this.profile});
  final UserModel profile;

  String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.customer:
        return "Patron";
      case UserRole.barber:
        return "Blade Specialist";
      case UserRole.shopOwner:
        return "Shop Captain";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Character Dossier",
            textAlign: TextAlign.center,
            style: AppTypography.orbitronHeading(22).copyWith(color: AppColors.accentMagenta),
          ),
          const SizedBox(height: 8),
          Text(
            "Your StyleSync operative profile",
            textAlign: TextAlign.center,
            style: AppTypography.interBody(13).copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentMagenta.withValues(alpha: 0.45), width: 1.5),
              color: AppColors.deepNavy.withValues(alpha: 0.6),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.accentMagenta.withValues(alpha: 0.2),
                        child: Text(
                          profile.username.isNotEmpty ? profile.username[0].toUpperCase() : "?",
                          style: AppTypography.orbitronHeading(28).copyWith(color: AppColors.accentMagenta),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Codename", style: AppTypography.interBody(11).copyWith(color: AppColors.textMuted)),
                            Text(profile.username, style: AppTypography.orbitronHeading(18)),
                            const SizedBox(height: 6),
                            Text("Class", style: AppTypography.interBody(11).copyWith(color: AppColors.textMuted)),
                            Text(_roleLabel(profile.role), style: AppTypography.interBody(15, weight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28, color: AppColors.textMuted),
                  _StatRow(label: "Style XP", value: "${profile.xp}"),
                  _StatRow(label: "Loyalty Tier", value: profile.loyaltyRank.name.toUpperCase()),
                  _StatRow(label: "Queue Priority", value: profile.isPremium ? "Premium channel" : "Standard"),
                  _StatRow(
                    label: "Hair matrix",
                    value: "${profile.hairProfile.type} · ${profile.hairProfile.density} density",
                  ),
                  if (profile.email.isNotEmpty)
                    _StatRow(
                      label: "Comms (masked)",
                      value: profile.email.length > 4
                          ? "•••@${profile.email.split("@").last}"
                          : profile.email,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          StyleButton(
            label: "Enter StyleSync",
            icon: Icons.play_arrow_rounded,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTypography.interBody(12).copyWith(color: AppColors.textMuted)),
          ),
          Expanded(child: Text(value, style: AppTypography.interBody(14, weight: FontWeight.w600))),
        ],
      ),
    );
  }
}

