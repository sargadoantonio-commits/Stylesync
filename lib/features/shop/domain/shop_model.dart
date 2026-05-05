import 'barber_in_shop_model.dart';

class ShopModel {
  final String shopId;
  final String ownerId;
  final String name;
  final String? address;
  final String? phoneNumber;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final String? description;
  final List<BarberInShop>? barbers; // Changed from barberIds
  final double? rating;
  final int? reviewCount;
  final bool? isOpen;
  final String? openingHours;
  final String? closingHours;
  final DateTime? createdAt;

  ShopModel({
    required this.shopId,
    required this.ownerId,
    required this.name,
    this.address,
    this.phoneNumber,
    this.latitude,
    this.longitude,
    this.photoUrl,
    this.description,
    this.barbers, // Changed from barberIds
    this.rating,
    this.reviewCount,
    this.isOpen,
    this.openingHours,
    this.closingHours,
    this.createdAt,
  });

  factory ShopModel.fromFirestore(Map<String, dynamic> data, String docId) {
    // Convert barbers array
    List<BarberInShop> barbersList = [];
    if (data['barbers'] != null && data['barbers'] is List) {
      barbersList = (data['barbers'] as List)
          .map((barber) => BarberInShop.fromFirestore(barber))
          .toList();
    }

    return ShopModel(
      shopId: docId,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? 'Unknown Shop',
      address: data['address'],
      phoneNumber: data['phoneNumber'],
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      photoUrl: data['photoUrl'],
      description: data['description'],
      barbers: barbersList, // Changed from barberIds
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isOpen: data['isOpen'] ?? true,
      openingHours: data['openingHours'],
      closingHours: data['closingHours'],
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrl': photoUrl,
      'description': description,
      'barbers': barbers?.map((b) => b.toFirestore()).toList() ?? [], // Changed from barberIds
      'rating': rating,
      'reviewCount': reviewCount,
      'isOpen': isOpen,
      'openingHours': openingHours,
      'closingHours': closingHours,
      'createdAt': createdAt,
    };
  }

  ShopModel copyWith({
    String? shopId,
    String? ownerId,
    String? name,
    String? address,
    String? phoneNumber,
    double? latitude,
    double? longitude,
    String? photoUrl,
    String? description,
    List<BarberInShop>? barbers, // Changed from barberIds
    double? rating,
    int? reviewCount,
    bool? isOpen,
    String? openingHours,
    String? closingHours,
    DateTime? createdAt,
  }) {
    return ShopModel(
      shopId: shopId ?? this.shopId,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoUrl: photoUrl ?? this.photoUrl,
      description: description ?? this.description,
      barbers: barbers ?? this.barbers, // Changed from barberIds
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isOpen: isOpen ?? this.isOpen,
      openingHours: openingHours ?? this.openingHours,
      closingHours: closingHours ?? this.closingHours,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
