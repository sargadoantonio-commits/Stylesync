/// Represents a barber assigned to a shop
class BarberInShop {
  final String barberId; // Firebase UID
  final String name;
  final String email;
  final String? profilePhoto;
  final double? rating;
  final int? completedJobs;
  final DateTime assignedAt;
  final bool isAdmin; // Whether this barber is also an admin for the shop

  BarberInShop({
    required this.barberId,
    required this.name,
    required this.email,
    this.profilePhoto,
    this.rating,
    this.completedJobs,
    required this.assignedAt,
    this.isAdmin = false,
  });

  factory BarberInShop.fromFirestore(Map<String, dynamic> data) {
    return BarberInShop(
      barberId: data['barberId'] ?? '',
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      profilePhoto: data['profilePhoto'],
      rating: (data['rating'] ?? 0).toDouble(),
      isAdmin: data['isAdmin'] ?? false,
      completedJobs: data['completedJobs'] ?? 0,
      assignedAt: (data['assignedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'barberId': barberId,
      'name': name,
      'email': email,
      'profilePhoto': profilePhoto,
      'rating': rating,
      'completedJobs': completedJobs,
      'isAdmin': isAdmin,
      'assignedAt': assignedAt,
    };
  }

  BarberInShop copyWith({
    String? barberId,
    String? name,
    String? email,
    String? profilePhoto,
    double? rating,
    int? completedJobs,
    DateTime? assignedAt,
    bool? isAdmin,
  }) {
    return BarberInShop(
      barberId: barberId ?? this.barberId,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      assignedAt: assignedAt ?? this.assignedAt,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
