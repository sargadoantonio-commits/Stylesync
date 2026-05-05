import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/theme/app_colors.dart";
import "../../core/theme/app_typography.dart";
import "../../core/theme/glass_card.dart";
import "../../core/theme/style_button.dart";
import "../../features/auth/presentation/providers/auth_providers.dart";
import "../../features/shop/presentation/providers/shop_providers.dart"
    as shop_providers;
import "manage_shop_barbers_screen.dart";

class ShopOwnerDashboardScreen extends ConsumerStatefulWidget {
  const ShopOwnerDashboardScreen({super.key});

  @override
  ConsumerState<ShopOwnerDashboardScreen> createState() =>
      _ShopOwnerDashboardScreenState();
}

class _ShopOwnerDashboardScreenState
    extends ConsumerState<ShopOwnerDashboardScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _err;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _createShop() async {
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (uid == null) return;
    setState(() => _err = null);
    try {
      final name = _nameCtrl.text.trim();
      final address = _addressCtrl.text.trim();
      if (name.isEmpty || address.isEmpty) {
        setState(() => _err = "Shop name and address are required.");
        return;
      }
      await ref
          .read(shop_providers.shopRepositoryProvider)
          .createShop(ownerId: uid, name: name, address: address);
      _nameCtrl.clear();
      _addressCtrl.clear();
    } catch (e) {
      setState(() => _err = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopsAsync = ref.watch(shop_providers.ownedShopsProvider);
    final selectedShopId = ref.watch(shop_providers.selectedShopIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Shop Owner Dashboard",
            style: AppTypography.orbitronHeading(18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Create your shop",
                    style: AppTypography.orbitronHeading(14)),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: "Shop name"),
                  style: AppTypography.interBody(14),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(labelText: "Address"),
                  style: AppTypography.interBody(14),
                ),
                if (_err != null) ...[
                  const SizedBox(height: 10),
                  Text(_err!,
                      style: AppTypography.interBody(12)
                          .copyWith(color: Colors.redAccent)),
                ],
                const SizedBox(height: 12),
                StyleButton(
                    label: "Create shop",
                    icon: Icons.storefront_rounded,
                    onPressed: _createShop),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Active shop", style: AppTypography.orbitronHeading(14)),
                const SizedBox(height: 10),
                Text(
                  selectedShopId ?? "Not selected",
                  style: AppTypography.interBody(14)
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                StyleButton(
                  label: "Manage barbers",
                  icon: Icons.groups_rounded,
                  onPressed: selectedShopId == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ManageShopBarbersScreen(
                                    shopId: selectedShopId,
                                  ),
                            ),
                          );
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text("Your shops", style: AppTypography.orbitronHeading(16)),
          const SizedBox(height: 12),
          shopsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(e.toString(),
                style: AppTypography.interBody(14)
                    .copyWith(color: Colors.redAccent)),
            data: (shops) {
              if (shops.isEmpty) {
                return GlassCard(
                  child: Text(
                    "No shops yet. Create your first one above.",
                    style: AppTypography.interBody(14)
                        .copyWith(color: AppColors.textMuted),
                  ),
                );
              }
              return Column(
                children: [
                  for (final s in shops)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name,
                                style: AppTypography.interBody(16,
                                    weight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(s.address ?? "No address",
                                style: AppTypography.interBody(13)
                                    .copyWith(color: AppColors.textMuted)),
                            const SizedBox(height: 8),
                            Text(
                                "Rating: ${s.rating?.toStringAsFixed(1) ?? '0.0'} ★",
                                style: AppTypography.interBody(13)),
                            const SizedBox(height: 12),
                            StyleButton(
                              label: selectedShopId == s.shopId
                                  ? "Selected"
                                  : "Select shop",
                              icon: Icons.check_circle_rounded,
                              onPressed: () async {
                                await ref
                                    .read(shop_providers.shopRepositoryProvider)
                                    .updateOpenStatus(s.shopId, true);
                                ref
                                    .read(shop_providers
                                        .selectedShopIdProvider.notifier)
                                    .state = s.shopId;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
