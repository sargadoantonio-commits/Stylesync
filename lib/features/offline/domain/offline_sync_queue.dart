import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a queued operation to be synced when online
class OfflineSyncQueueItem {
  final String id;
  final String operationType; // 'create', 'update', 'delete'
  final String collection;
  final String documentId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  bool synced;

  OfflineSyncQueueItem({
    required this.id,
    required this.operationType,
    required this.collection,
    required this.documentId,
    required this.data,
    required this.timestamp,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'operationType': operationType,
        'collection': collection,
        'documentId': documentId,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'synced': synced,
      };

  factory OfflineSyncQueueItem.fromJson(Map<String, dynamic> json) =>
      OfflineSyncQueueItem(
        id: json['id'] as String,
        operationType: json['operationType'] as String,
        collection: json['collection'] as String,
        documentId: json['documentId'] as String,
        data: Map<String, dynamic>.from(json['data'] as Map),
        timestamp: DateTime.parse(json['timestamp'] as String),
        synced: json['synced'] as bool? ?? false,
      );
}

/// Manages offline sync queue - stores operations when offline
class OfflineSyncQueueNotifier
    extends StateNotifier<List<OfflineSyncQueueItem>> {
  OfflineSyncQueueNotifier() : super([]);

  /// Add operation to sync queue
  void addToQueue(OfflineSyncQueueItem item) {
    state = [...state, item];
  }

  /// Mark item as synced
  void markSynced(String itemId) {
    state = [
      for (final item in state)
        if (item.id == itemId)
          OfflineSyncQueueItem(
            id: item.id,
            operationType: item.operationType,
            collection: item.collection,
            documentId: item.documentId,
            data: item.data,
            timestamp: item.timestamp,
            synced: true,
          )
        else
          item,
    ];
  }

  /// Remove synced items from queue
  void removeSyncedItems() {
    state = [
      for (final item in state)
        if (!item.synced) item,
    ];
  }

  /// Clear all queued items
  void clearQueue() {
    state = [];
  }

  /// Get pending items (not synced)
  List<OfflineSyncQueueItem> getPendingItems() {
    return state.where((item) => !item.synced).toList();
  }
}

/// Provider for offline sync queue
final offlineSyncQueueProvider =
    StateNotifierProvider<OfflineSyncQueueNotifier, List<OfflineSyncQueueItem>>(
  (ref) => OfflineSyncQueueNotifier(),
);

/// Provider for pending items count
final pendingOfflineItemsProvider = Provider<int>((ref) {
  return ref
      .watch(offlineSyncQueueProvider)
      .where((item) => !item.synced)
      .length;
});
