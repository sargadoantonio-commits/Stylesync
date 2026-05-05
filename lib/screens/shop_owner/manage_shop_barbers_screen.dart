import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylesync/core/theme/app_colors.dart';
import 'package:stylesync/core/theme/app_typography.dart';
import 'package:stylesync/core/theme/glass_card.dart';
import 'package:stylesync/core/theme/style_button.dart';
import 'package:stylesync/features/shop/domain/shop_model.dart';
import 'package:stylesync/features/shop/domain/barber_in_shop_model.dart';
import 'package:stylesync/features/shop/presentation/providers/shop_providers.dart' as shop_providers;

/// Screen for shop owner to manage barbers in their shop
class ManageShopBarbersScreen extends ConsumerStatefulWidget {
  final String shopId;

  const ManageShopBarbersScreen({
    required this.shopId,
    super.key,
  });

  @override
  ConsumerState<ManageShopBarbersScreen> createState() =>
      _ManageShopBarbersScreenState();
}

class _ManageShopBarbersScreenState
    extends ConsumerState<ManageShopBarbersScreen> {
  String _selectedBarberId = '';
  String? _error;

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
          'Manage Barbers',
          style: AppTypography.orbitronHeading(18),
        ),
      ),
      body: shopAsync.when(
        data: (shop) {
          if (shop == null) {
            return Center(
              child: Text(
                'Shop not found',
                style: AppTypography.interBody(16),
              ),
            );
          }
          return _buildShopContent(shop);
        },
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

  Widget _buildShopContent(ShopModel shop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAddBarbersSection(),
          const SizedBox(height: 24),
          _buildCurrentBarbersSection(shop),
        ],
      ),
    );
  }

  Widget _buildAddBarbersSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Barber to Shop',
            style: AppTypography.orbitronHeading(16),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Barber Email or ID',
              hintText: 'Enter barber email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _selectedBarberId = value;
              });
            },
            style: AppTypography.interBody(14),
          ),
          const SizedBox(height: 12),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: AppTypography.interBody(12).copyWith(color: AppColors.accentRed),
              ),
            ),
          ],
          const SizedBox(height: 16),
          StyleButton(
            label: 'Add Barber',
            icon: Icons.person_add,
            onPressed: _selectedBarberId.isEmpty ? null : _addBarberToShop,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBarbersSection(ShopModel shop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Barbers in Shop (${shop.barbers?.length ?? 0})',
          style: AppTypography.orbitronHeading(16),
        ),
        const SizedBox(height: 12),
        if (shop.barbers == null || shop.barbers!.isEmpty)
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No barbers yet. Add one above!',
                  style: AppTypography.interBody(14),
                ),
              ),
            ),
          )
        else
          GlassCard(
            child: Column(
              children: shop.barbers!
                  .asMap()
                  .entries
                  .map(
                    (entry) => _buildBarbersListTile(
                      entry.value,
                      shop.shopId,
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildBarbersListTile(BarberInShop barber, String shopId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        barber.name,
                        style: AppTypography.interBody(14, weight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (barber.isAdmin)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentMagenta.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accentMagenta.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text('Admin',
                          style: AppTypography.interBody(10, weight: FontWeight.w600)
                              .copyWith(color: AppColors.accentMagenta),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  barber.email,
                  style: AppTypography.interBody(12),
                ),
                const SizedBox(height: 6),
                if (barber.rating != null)
                  Text(
                    'Rating: ${barber.rating}/5 ⭐',
                    style: AppTypography.interBody(12),
                  ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'toggle_admin') {
                    _toggleBarbersAdmin(shopId, barber.barberId, !barber.isAdmin);
                  } else if (value == 'delete') {
                    _removeBarber(shopId, barber.barberId);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'toggle_admin',
                    child: Row(
                      children: [
                        Icon(barber.isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                            size: 18),
                        const SizedBox(width: 8),
                        Text(barber.isAdmin ? 'Remove Admin' : 'Make Admin'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addBarberToShop() async {
    if (_selectedBarberId.isEmpty) return;

    setState(() => _error = null);

    try {
      await ref
          .read(shop_providers.shopRepositoryProvider)
          .addBarber(
            shopId: widget.shopId,
            barberId: _selectedBarberId,
            barberName: _selectedBarberId,
            barberEmail: _selectedBarberId,
          );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Barber added',
              style: AppTypography.interBody(14),
            ),
          ),
        );
        setState(() {
          _selectedBarberId = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to add barber: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _removeBarber(String shopId, String barberId) async {
    try {
      await ref
          .read(shop_providers.shopRepositoryProvider)
          .removeBarber(shopId, barberId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Barber removed',
              style: AppTypography.interBody(14),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: AppTypography.interBody(14),
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleBarbersAdmin(String shopId, String barberId, bool isAdmin) async {
    try {
      await ref
          .read(shop_providers.shopRepositoryProvider)
          .toggleBarbersAdmin(shopId, barberId, isAdmin);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAdmin ? 'Barber is now admin' : 'Admin status removed',
              style: AppTypography.interBody(14),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: AppTypography.interBody(14),
            ),
          ),
        );
      }
    }
  }
}
