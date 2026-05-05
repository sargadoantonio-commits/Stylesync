import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/service_models.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore;

  ServiceRepository(this._firestore);

  // Create a new service
  Future<String> createService({
    required String barberId,
    required String customerId,
    required String shopId,
    required String serviceName,
    required double amount,
    required DateTime? scheduledAt,
    String? notes,
  }) async {
    try {
      final docRef = await _firestore.collection('services').add({
        'barberId': barberId,
        'customerId': customerId,
        'shopId': shopId,
        'serviceName': serviceName,
        'amount': amount,
        'createdAt': FieldValue.serverTimestamp(),
        'scheduledAt': scheduledAt,
        'status': ServiceStatus.pending.toString().split('.').last,
        'notes': notes,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create service: $e');
    }
  }

  // Update service status
  Future<void> updateServiceStatus(
    String serviceId,
    ServiceStatus status,
  ) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to update service status: $e');
    }
  }

  // Mark payment as sent by customer
  Future<void> customerPaymentSent(String shopId, String serviceId) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'status': ServiceStatus.paymentSent.toString().split('.').last,
        'paymentSentAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark payment as sent: $e');
    }
  }

  // Barber confirms payment received
  Future<void> barberConfirmReceived(String shopId, String serviceId) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'status': ServiceStatus.paymentConfirmed.toString().split('.').last,
        'paymentConfirmedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to confirm payment: $e');
    }
  }

  // Barber confirms service (marks as started)
  Future<void> barberConfirmService(String serviceId) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'status': ServiceStatus.confirmed.toString().split('.').last,
        'confirmedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to confirm service: $e');
    }
  }

  // Complete service
  Future<void> completeService(String serviceId) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'status': ServiceStatus.completed.toString().split('.').last,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to complete service: $e');
    }
  }

  // Add review and rating
  Future<void> reviewService({
    required String serviceId,
    required int rating,
    required String review,
  }) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'rating': rating,
        'review': review,
        'reviewedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to review service: $e');
    }
  }

  // Get service by ID
  Future<ServiceDoc?> getService(String serviceId) async {
    try {
      final doc = await _firestore.collection('services').doc(serviceId).get();
      if (doc.exists) {
        return ServiceDoc.fromFirestore(doc.data() ?? {}, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get service: $e');
    }
  }

  // Get services for customer
  Stream<List<ServiceDoc>> getCustomerServices(String customerId) {
    return _firestore
        .collection('services')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceDoc.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Get services for barber
  Stream<List<ServiceDoc>> getBarberServices(String barberId) {
    return _firestore
        .collection('services')
        .where('barberId', isEqualTo: barberId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceDoc.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Get pending confirmations for barber
  Stream<List<ServiceDoc>> getBarberPendingConfirmations(String barberId) {
    return _firestore
        .collection('services')
        .where('barberId', isEqualTo: barberId)
        .where('status',
            isEqualTo: ServiceStatus.paymentSent.toString().split('.').last)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceDoc.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Cancel service
  Future<void> cancelService(String serviceId) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'status': ServiceStatus.cancelled.toString().split('.').last,
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel service: $e');
    }
  }
}
