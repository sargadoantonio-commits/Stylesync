class BarberModel {
  final String barberId;
  final String name;
  final String? photoUrl;
  final String? bio;
  final double? rating;
  final int? reviewCount;
  final String? shopId;
  final double? yearsExperience;
  final List<String>? specialties;
  final String? gcashQrUrl;
  final bool? isAvailable;
  final int? totalBookings;
  final int? completedBookings;

  BarberModel({
    required this.barberId,
    required this.name,
    this.photoUrl,
    this.bio,
    this.rating,
    this.reviewCount,
    this.shopId,
    this.yearsExperience,
    this.specialties,
    this.gcashQrUrl,
    this.isAvailable,
    this.totalBookings,
    this.completedBookings,
  });

  factory BarberModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return BarberModel(
      barberId: docId,
      name: data['name'] ?? 'Unknown Barber',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      shopId: data['shopId'],
      yearsExperience: (data['yearsExperience'] ?? 0).toDouble(),
      specialties: List<String>.from(data['specialties'] ?? []),
      gcashQrUrl: data['gcashQrUrl'],
      isAvailable: data['isAvailable'] ?? true,
      totalBookings: data['totalBookings'] ?? 0,
      completedBookings: data['completedBookings'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'bio': bio,
      'rating': rating,
      'reviewCount': reviewCount,
      'shopId': shopId,
      'yearsExperience': yearsExperience,
      'specialties': specialties,
      'gcashQrUrl': gcashQrUrl,
      'isAvailable': isAvailable,
      'totalBookings': totalBookings,
      'completedBookings': completedBookings,
    };
  }

  BarberModel copyWith({
    String? barberId,
    String? name,
    String? photoUrl,
    String? bio,
    double? rating,
    int? reviewCount,
    String? shopId,
    double? yearsExperience,
    List<String>? specialties,
    String? gcashQrUrl,
    bool? isAvailable,
    int? totalBookings,
    int? completedBookings,
  }) {
    return BarberModel(
      barberId: barberId ?? this.barberId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      shopId: shopId ?? this.shopId,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      specialties: specialties ?? this.specialties,
      gcashQrUrl: gcashQrUrl ?? this.gcashQrUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      totalBookings: totalBookings ?? this.totalBookings,
      completedBookings: completedBookings ?? this.completedBookings,
    );
  }
}
