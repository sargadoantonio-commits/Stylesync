import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:stylesync/core/constants.dart' as _flags;

import "../../../core/shop_selection/shop_selection_providers.dart";
import "../../auth/presentation/providers/auth_providers.dart";
import "../data/queue_repository.dart";

final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  return QueueRepository(ref.watch(firestoreProvider));
});

final defaultShopIdProvider = Provider<String>((ref) {
  final selected = ref.watch(selectedShopIdProvider);
  return selected ?? "main";
});

final queueSnapshotProvider = StreamProvider<QuerySnapshot<Map<String, dynamic>>>((ref) {
  if (_flags.kUseDemoBarberUI) {
    return const Stream.empty();
  }

  final shopId = ref.watch(defaultShopIdProvider);
  return ref.watch(queueRepositoryProvider).watchQueue(shopId);
});

final cachedQueueTicketProvider = FutureProvider.family<QueueTicketCache?, String>((ref, shopId) {
  return ref.watch(queueRepositoryProvider).getLastKnownTicket(shopId);
});
