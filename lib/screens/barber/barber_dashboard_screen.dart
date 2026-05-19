import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:lottie/lottie.dart";

import "package:stylesync/core/theme/app_colors.dart";
import "package:stylesync/core/theme/app_typography.dart";
import "package:stylesync/core/theme/glass_card.dart";
import "package:stylesync/core/theme/style_button.dart";
import "package:stylesync/features/auth/presentation/providers/auth_providers.dart";
import "package:stylesync/core/router/app_routes.dart";
import "package:go_router/go_router.dart";
import "package:stylesync/features/auth/domain/user_model.dart";
import "package:stylesync/features/services/presentation/providers/service_providers.dart";
import "package:stylesync/features/services/domain/service_models.dart";
import "package:stylesync/features/queue/presentation/queue_providers.dart";
import "package:stylesync/core/formatters/ph_formatters.dart";
import "package:stylesync/features/barber/presentation/providers/barber_admin_provider.dart";
import "admin_unlock_modal.dart";
import "admin_unlock_provider.dart";
import "admin_barber_dashboard_screen.dart";

class BarberDashboardScreen extends ConsumerStatefulWidget {
  const BarberDashboardScreen({super.key});

  @override
  ConsumerState<BarberDashboardScreen> createState() =>
      _BarberDashboardScreenState();
}

class _BarberDashboardScreenState extends ConsumerState<BarberDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final profile = ref.watch(userProfileProvider).valueOrNull;

    if (uid == null || profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Check if barber is admin
    final barberAdminAsync = ref.watch(barberAdminStatusProvider(uid));

    return barberAdminAsync.when(
      data: (isAdmin) {
        if (isAdmin) {
          // Route to admin dashboard if barber is admin
          final shopId = ref.watch(defaultShopIdProvider);
          return AdminBarberDashboardScreen(shopId: shopId);
                }
        return _buildBarberDashboard(uid, profile);
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => _buildBarberDashboard(uid, profile),
    );
  }

  Widget _buildBarberDashboard(String uid, UserModel profile) {
    final shopId = ref.watch(defaultShopIdProvider);

    // Static demo data for initial UI preview
    final demoQueue = [
      {
        "userId": "u1",
        "username": "Carlos",
        "isPremium": true,
        "queueIndex": 1,
      },
      {
        "userId": "u2",
        "username": "Jia",
        "isPremium": false,
        "queueIndex": 2,
      },
      {
        "userId": "u3",
        "username": "Omar",
        "isPremium": false,
        "queueIndex": 3,
      }
    ];

    final demoConfirmations = [
      {"id": "s1", "customerId": "Carlos", "amount": 250},
      {"id": "s2", "customerId": "Jia", "amount": 180},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:
            Text("Barber Dashboard", style: AppTypography.orbitronHeading(18)),
        actions: [
          // Admin Access Button (lock icon)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AdminUnlockModal(
                      onAdminUnlocked: () {
                        ref.read(adminUnlockedProvider.notifier).state = true;
                      },
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentMagenta.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.accentMagenta.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text('🔐', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
          // Logout Button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.card,
                      title: Text("Logout?",
                          style: AppTypography.orbitronHeading(16)),
                      content: Text(
                        "Are you sure you want to sign out?",
                        style: AppTypography.interBody(14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel",
                              style: AppTypography.interBody(14)
                                  .copyWith(color: AppColors.textMuted)),
                        ),
                        FilledButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await ref
                                .read(firebaseAuthProvider)
                                .signOut();
                            if (context.mounted) {
                              GoRouter.of(context)
                                  .go(AppRoutes.login);
                            }
                          },
                          child: Text("Logout",
                              style: AppTypography.interBody(14,
                                  weight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.accentRed.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text('🚪', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!profile.profileComplete)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.accentRed.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.accentRed, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Complete your profile",
                            style: AppTypography.interBody(14,
                                    weight: FontWeight.w700)
                                .copyWith(color: AppColors.accentRed)),
                        const SizedBox(height: 6),
                        Text("Set your username and display name.",
                            style: AppTypography.interBody(12)
                                .copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Session", style: AppTypography.orbitronHeading(14)),
                const SizedBox(height: 6),
                Text(
                    profile.displayName.isEmpty
                        ? profile.username
                        : profile.displayName,
                    style:
                        AppTypography.interBody(18, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  profile.phoneNumber.isEmpty
                      ? "Phone hidden"
                      : "Phone: ${UserModel.maskPhone(profile.phoneNumber)}",
                  style: AppTypography.interBody(13)
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),
                Text(
                  "Sensitive contact info is masked until a service is active.",
                  style: AppTypography.interBody(12)
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text("Queue (tap to bill)", style: AppTypography.orbitronHeading(16)),
          const SizedBox(height: 12),
          // Static queue preview
          demoQueue.isEmpty
              ? GlassCard(
                  child: Text(
                    "No one in queue yet.",
                    style: AppTypography.interBody(14)
                        .copyWith(color: AppColors.textMuted),
                  ),
                )
              : Column(
                  children: demoQueue.map((data) {
                    final customerId = data["userId"] as String? ?? "";
                    final username = data["username"] as String? ?? "Guest";
                    final isPremium = data["isPremium"] as bool? ?? false;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              username,
                              style: AppTypography.interBody(16,
                                  weight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isPremium ? "Premium priority" : "Standard",
                              style: AppTypography.interBody(12)
                                  .copyWith(color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 12),
                            StyleButton(
                              label: "Service done ? collect payment",
                              icon: Icons.point_of_sale_rounded,
                              onPressed: () async {
                                final amount = await showDialog<int>(
                                  context: context,
                                  builder: (_) => _AmountDialog(username: username),
                                );
                                // demo: do nothing further
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
          const SizedBox(height: 16),
          Text("Payment confirmations",
              style: AppTypography.orbitronHeading(16)),
          const SizedBox(height: 12),
          // Static confirmations preview
          demoConfirmations.isEmpty
              ? GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      "No pending confirmations.",
                      style: AppTypography.interBody(14)
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ),
                )
              : Column(
                  children: demoConfirmations.map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Confirm ?${PhFormatters.peso((s['amount'] as num?)?.toDouble() ?? 0)} received?",
                              style: AppTypography.interBody(15, weight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Customer: ${s['customerId']}",
                              style: AppTypography.interBody(12)
                                  .copyWith(color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 12),
                            StyleButton(
                              label: "Confirm received",
                              icon: Icons.verified_rounded,
                              onPressed: () {
                                // demo only
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

class _ConfirmCard extends ConsumerStatefulWidget {
  const _ConfirmCard({required this.shopId, required this.service});
  final String shopId;
  final ServiceDoc service;

  @override
  ConsumerState<_ConfirmCard> createState() => _ConfirmCardState();
}

class _ConfirmCardState extends ConsumerState<_ConfirmCard> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Confirm ?${PhFormatters.peso(widget.service.amount)} received?",
              style: AppTypography.interBody(15, weight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              "Customer: ${widget.service.customerId}",
              style: AppTypography.interBody(12)
                  .copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            if (_done) ...[
              Lottie.asset("assets/lottie/sharp_look.json",
                  repeat: false, height: 90),
              const SizedBox(height: 8),
              Text("Sharp Look!",
                  textAlign: TextAlign.center,
                  style: AppTypography.orbitronHeading(16)),
              const SizedBox(height: 10),
            ],
            StyleButton(
              label: _done ? "Confirmed" : "Confirm received",
              icon: _done ? Icons.check_rounded : Icons.verified_rounded,
              onPressed: _done
                  ? null
                  : () async {
                      await ref.read(serviceRepositoryProvider).completeService(
                            widget.service.id,
                          );
                      if (mounted) setState(() => _done = true);
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({required this.username});
  final String username;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _ctrl = TextEditingController(text: "150");
  String? _err;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text("Charge ? amount", style: AppTypography.orbitronHeading(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Customer: ${widget.username}",
            style: AppTypography.interBody(13)
                .copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Amount (?)"),
          ),
          if (_err != null) ...[
            const SizedBox(height: 8),
            Text(_err!,
                style: AppTypography.interBody(12)
                    .copyWith(color: Colors.redAccent)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel",
              style: AppTypography.interBody(14)
                  .copyWith(color: AppColors.textMuted)),
        ),
        FilledButton(
          onPressed: () {
            final amount = int.tryParse(_ctrl.text.trim()) ?? 0;
            if (amount <= 0) {
              setState(() => _err = "Enter a valid amount.");
              return;
            }
            Navigator.pop(context, amount);
          },
          child: Text("Continue",
              style: AppTypography.interBody(14, weight: FontWeight.w700)),
        ),
      ],
    );
  }
}
