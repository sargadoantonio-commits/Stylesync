import "dart:convert";

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter/foundation.dart';
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
    final ticketRef = shopRef.collection('queue').doc();
    try {
      debugPrint('[Queue] joinQueueSimple: creating ticket ${ticketRef.id} for user=$userId');
      await ticketRef.set({
        'userId': userId,
        'username': username,
        'isPremium': isPremium,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e, st) {
      debugPrint('[Queue] joinQueueSimple: FirebaseException code=${e.code} message=${e.message}');
      debugPrint(st.toString());
      rethrow;
    } catch (e, st) {
      debugPrint('[Queue] joinQueueSimple: unexpected error $e');
      debugPrint(st.toString());
      rethrow;
    }

    // compute position and save cached ticket
    final queueSnap = await shopRef
        .collection('queue')
        .orderBy('isPremium', descending: true)
        .orderBy('joinedAt', descending: false)
        .get();
    final positionInQueue = queueSnap.docs.indexWhere((d) => d.id == ticketRef.id) + 1;
    final shopSnap = await shopRef.get();
    final shopAddress = shopSnap.data()?['address'] as String? ?? 'Shop address saved locally.';

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

  /// Debug helper: create a ticket without running the full transaction.
  /// This performs a simple add and a separate increment update which can
  /// help isolate whether the transaction or rules around `shops/{shopId}`
  /// are causing permission errors.
  Future<String> addDemoTicket({
    required String shopId,
    required String userId,
    required String username,
    required bool isPremium,
  }) async {
    final shopRef = _shopRef(shopId);
    final ticketRef = shopRef.collection('queue').doc();
    try {
      debugPrint('[Queue] addDemoTicket: creating ticket ${ticketRef.id} for user=$userId');
      await ticketRef.set({
        'userId': userId,
        'username': username,
        'isPremium': isPremium,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[Queue] addDemoTicket: updating shop ticketCount via increment');
      await shopRef.set({'ticketCount': FieldValue.increment(1), 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      return ticketRef.id;
    } on FirebaseException catch (e, st) {
      debugPrint('[Queue] addDemoTicket: FirebaseException code=${e.code} message=${e.message}');
      debugPrint(st.toString());
      rethrow;
    }
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
    final ticketRef = shopRef.collection('queue').doc(ticketId);
    final ticketSnap = await ticketRef.get();
    if (!ticketSnap.exists) return;
    try {
      await ticketRef.delete();
    } on FirebaseException catch (e, st) {
      debugPrint('[Queue] leaveQueue: FirebaseException ${e.code} ${e.message}');
      debugPrint(st.toString());
      rethrow;
    }
    await _clearCachedTicket(shopId);
  }

  /// For shop owners/barbers: call the next ticket in line.
  /// Returns the ticketId that was called, or null if none.
  Future<String?> callNext(String shopId) async {
    final shopRef = _shopRef(shopId);
    String? calledId;

    await _db.runTransaction((tx) async {
      final qSnap = await shopRef
          .collection("queue")
          .orderBy("isPremium", descending: true)
          .orderBy("joinedAt", descending: false)
          .limit(1)
          .get();

      if (qSnap.docs.isEmpty) return;
      final doc = qSnap.docs.first;
      calledId = doc.id;

      tx.update(doc.reference, {
        'status': 'called',
        'calledAt': FieldValue.serverTimestamp(),
      });

      tx.set(shopRef, {
        'currentServingTicketId': calledId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });

    return calledId;
  }

  Future<void> clearCurrentServing(String shopId) async {
    final shopRef = _shopRef(shopId);
    await shopRef.update({'currentServingTicketId': FieldValue.delete(), 'updatedAt': FieldValue.serverTimestamp()});
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
