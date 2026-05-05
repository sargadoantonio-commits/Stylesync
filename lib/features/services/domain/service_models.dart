enum ServiceStatus {
  pending,
  paymentSent,
  paymentConfirmed,
  confirmed,
  completed,
  cancelled,
}

class ServiceDoc {
  final String id;
  final String barberId;
  final String customerId;
  final String shopId;
  final String serviceName;
  final double amount;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final ServiceStatus status;
  final String? paymentMethod;
  final String? notes;
  final int? rating;
  final String? review;

  ServiceDoc({
    required this.id,
    required this.barberId,
    required this.customerId,
    required this.shopId,
    required this.serviceName,
    required this.amount,
    required this.createdAt,
    this.scheduledAt,
    required this.status,
    this.paymentMethod,
    this.notes,
    this.rating,
    this.review,
  });

  // Convert to/from Firestore
  factory ServiceDoc.fromFirestore(Map<String, dynamic> data, String docId) {
    return ServiceDoc(
      id: docId,
      barberId: data['barberId'] ?? '',
      customerId: data['customerId'] ?? '',
      shopId: data['shopId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      scheduledAt: (data['scheduledAt'] as dynamic)?.toDate(),
      status: ServiceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => ServiceStatus.pending,
      ),
      paymentMethod: data['paymentMethod'],
      notes: data['notes'],
      rating: data['rating'],
      review: data['review'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'barberId': barberId,
      'customerId': customerId,
      'shopId': shopId,
      'serviceName': serviceName,
      'amount': amount,
      'createdAt': createdAt,
      'scheduledAt': scheduledAt,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'rating': rating,
      'review': review,
    };
  }
}
