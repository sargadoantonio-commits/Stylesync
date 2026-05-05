import "dart:convert";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Priority queue under `shops/{shopId}/queue/{ticketId}`.
/// Sorting rule (HCI-efficient): premium first, then earliest join time.
class QueueRepository {
  QueueRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _shopRef(String shopId) => _db.collection("shops").doc(shopId);

  Stream<QuerySnapshot<Map<String, dynamic>>> watchQueue(String shopId) {
    return _shopRef(shopId)
        .collection("queue")
        .orderBy("isPremium", descending: true)
        .orderBy("joinedAt", descending: false)
        .snapshots();
  }

  Future<String> joinQueue({
    required String shopId,
    required String userId,
    required String username,
    required bool isPremium,
  }) async {
    final shopRef = _shopRef(shopId);
    final ticketRef = shopRef.collection("queue").doc();
    String shopAddress = "Shop address saved locally.";
    int positionInQueue = 0;

    await _db.runTransaction((tx) async {
      final shopSnap = await tx.get(shopRef);
      final shopData = shopSnap.data();
      shopAddress = shopData?['address'] as String? ?? shopAddress;

      final queueSnapshot = await shopRef
          .collection("queue")
          .orderBy("isPremium", descending: true)
          .orderBy("joinedAt", descending: false)
          .get();
      final docs = queueSnapshot.docs;
      final ticketCount = docs.length;
      positionInQueue = docs.length + 1;

      tx.set(
        shopRef,
        {
          "ticketCount": ticketCount + 1,
          "updatedAt": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      tx.set(ticketRef, {
        "userId": userId,
        "username": username,
        "isPremium": isPremium,
        "joinedAt": FieldValue.serverTimestamp(),
      });
    });

    await _saveCachedTicket(
      shopId,
      QueueTicketCache(
        ticketId: ticketRef.id,
        shopId: shopId,
        username: username,
        position: positionInQueue,
        shopAddress: shopAddress,
        isPremium: isPremium,
        updatedAt: DateTime.now(),
      ),
    );

    return ticketRef.id;
  }

  Future<void> _saveCachedTicket(String shopId, QueueTicketCache ticket) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("stylesync_cached_ticket_$shopId", jsonEncode(ticket.toJson()));
  }

  Future<QueueTicketCache?> getLastKnownTicket(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("stylesync_cached_ticket_$shopId");
    if (raw == null) return null;
    try {
      return QueueTicketCache.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> leaveQueue(String shopId, String ticketId) async {
    final shopRef = _shopRef(shopId);
    final ticketRef = shopRef.collection("queue").doc(ticketId);
    await _db.runTransaction((tx) async {
      final ticketSnap = await tx.get(ticketRef);
      if (!ticketSnap.exists) return;
      tx.delete(ticketRef);
      final shopSnap = await tx.get(shopRef);
      if (shopSnap.exists) {
        tx.update(shopRef, {
          "ticketCount": FieldValue.increment(-1),
          "updatedAt": FieldValue.serverTimestamp(),
        });
      }
    });
    await _clearCachedTicket(shopId);
  }

  Future<void> _clearCachedTicket(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("stylesync_cached_ticket_$shopId");
  }
}

class QueueTicketCache {
  QueueTicketCache({
    required this.ticketId,
    required this.shopId,
    required this.username,
    required this.position,
    required this.shopAddress,
    required this.isPremium,
    required this.updatedAt,
  });

  final String ticketId;
  final String shopId;
  final String username;
  final int position;
  final String shopAddress;
  final bool isPremium;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      "ticketId": ticketId,
      "shopId": shopId,
      "username": username,
      "position": position,
      "shopAddress": shopAddress,
      "isPremium": isPremium,
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  factory QueueTicketCache.fromJson(Map<String, dynamic> map) {
    return QueueTicketCache(
      ticketId: map["ticketId"] as String? ?? "",
      shopId: map["shopId"] as String? ?? "main",
      username: map["username"] as String? ?? "Guest",
      position: (map["position"] as num?)?.toInt() ?? 0,
      shopAddress: map["shopAddress"] as String? ?? "",
      isPremium: map["isPremium"] as bool? ?? false,
      updatedAt: DateTime.parse(map["updatedAt"] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}
