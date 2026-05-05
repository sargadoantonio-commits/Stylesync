import "package:flutter_riverpod/flutter_riverpod.dart";

import "shop_selection_repository.dart";

final shopSelectionRepositoryProvider = Provider<ShopSelectionRepository>((ref) {
  return ShopSelectionRepository();
});

final selectedShopIdProvider = StateProvider<String?>((ref) => null);

final selectedShopIdLoaderProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(shopSelectionRepositoryProvider);
  final shopId = await repo.getSelectedShopId();
  ref.read(selectedShopIdProvider.notifier).state = shopId;
});
