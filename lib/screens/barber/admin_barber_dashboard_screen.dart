import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/glass_card.dart';
import '../../core/theme/style_button.dart';
import '../../features/shop/presentation/providers/shop_providers.dart' as shop_providers;
import '../shop_owner/manage_shop_barbers_screen.dart';

/// Admin dashboard for barbers who have admin privileges in a shop
class AdminBarberDashboardScreen extends ConsumerStatefulWidget {
  final String shopId;

  const AdminBarberDashboardScreen({
    required this.shopId,
    super.key,
  });

  @override
  ConsumerState<AdminBarberDashboardScreen> createState() =>
      _AdminBarberDashboardScreenState();
}

class _AdminBarberDashboardScreenState
    extends ConsumerState<AdminBarberDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(
      FutureProvider((ref) async {
        final repo = ref.watch(shop_providers.shopRepositoryProvider);
        return await repo.getShop(widget.shopId);
      }),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: AppTypography.orbitronHeading(18),
        ),
      ),
      body: shopAsync.when(
        data: (shop) => _buildShopContent(shop),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: AppTypography.interBody(16),
          ),
        ),
      ),
    );
  }

  Widget _buildShopContent(dynamic shop) {
    if (shop == null) {
      return Center(
        child: Text(
          'Shop not found',
          style: AppTypography.interBody(16),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Shop Information',
                style: AppTypography.orbitronHeading(14),
              ),
              const SizedBox(height: 12),
              Text(
                shop.name,
                style: AppTypography.interBody(16, weight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                shop.address ?? 'No address',
                style: AppTypography.interBody(13)
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              Text(
                'Rating: ${shop.rating?.toStringAsFixed(1) ?? '0.0'} ★',
                style: AppTypography.interBody(13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Barber Management',
                style: AppTypography.orbitronHeading(14),
              ),
              const SizedBox(height: 12),
              StyleButton(
                label: 'Manage Barbers',
                icon: Icons.groups_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ManageShopBarbersScreen(shopId: widget.shopId),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
