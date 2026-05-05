import "package:cloud_firestore/cloud_firestore.dart";
import "user_role.dart";

enum LoyaltyRank {
  rookie("rookie"),
  regular("regular"),
  elite("elite"),
  legend("legend");

  const LoyaltyRank(this.firestoreValue);
  final String firestoreValue;

  static LoyaltyRank fromFirestore(String value) {
    return LoyaltyRank.values.firstWhere(
      (rank) => rank.firestoreValue == value,
      orElse: () => LoyaltyRank.rookie,
    );
  }
}

class HairProfile {
  const HairProfile({
    required this.type,
    required this.density,
    required this.scalpSensitivity,
  });

  final String type;
  final String density;
  final String scalpSensitivity;

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "density": density,
      "scalpSensitivity": scalpSensitivity,
    };
  }

  factory HairProfile.fromMap(Map<String, dynamic> map) {
    return HairProfile(
      type: map["type"] ?? "straight",
      density: map["density"] ?? "medium",
      scalpSensitivity: map["scalpSensitivity"] ?? "medium",
    );
  }

  factory HairProfile.baseline() {
    return const HairProfile(
      type: "straight",
      density: "medium",
      scalpSensitivity: "medium",
    );
  }
}

class UserModel {
  const UserModel({
    required this.uid,
    required this.role,
    required this.username,
    required this.displayName,
    required this.photoUrl,
    required this.email,
    required this.phoneNumber,
    required this.providerIds,
    required this.xp,
    required this.loyaltyRank,
    required this.isPremium,
    required this.profileComplete,
    required this.hairProfile,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
    this.isAdmin = false,
  });

  final String uid;
  final UserRole role;
  final String username;
  final String displayName;
  final String photoUrl;
  final String email;
  final String phoneNumber;
  final List<String> providerIds;
  final int xp;
  final LoyaltyRank loyaltyRank;
  final bool isPremium;
  final bool profileComplete;
  final HairProfile hairProfile;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLoginAt;
  final bool isAdmin;

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      role: UserRole.fromFirestore(map["role"] ?? "customer"),
      username: map["username"] ?? "",
      displayName: map["displayName"] ?? "",
      photoUrl: map["photoUrl"] ?? "",
      email: map["email"] ?? "",
      phoneNumber: map["phoneNumber"] ?? "",
      providerIds: List<String>.from(map["providerIds"] ?? []),
      xp: map["xp"] ?? 0,
      loyaltyRank: LoyaltyRank.fromFirestore(map["loyaltyRank"] ?? "rookie"),
      isPremium: map["isPremium"] ?? false,
      profileComplete: map["profileComplete"] as bool? ?? true,
      hairProfile: HairProfile.fromMap(map["hairProfile"] ?? {}),
      createdAt: (map["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map["updatedAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map["lastLoginAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAdmin: map["isAdmin"] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "role": role.firestoreValue,
      "username": username,
      "displayName": displayName,
      "photoUrl": photoUrl,
      "email": email,
      "phoneNumber": phoneNumber,
      "providerIds": providerIds,
      "xp": xp,
      "loyaltyRank": loyaltyRank.firestoreValue,
      "isPremium": isPremium,
      "profileComplete": profileComplete,
      "hairProfile": hairProfile.toMap(),
      "isAdmin": isAdmin,
    };
  }

  /// Masks a phone number for privacy display (e.g., "+63 9XX-XXX-1234").
  static String maskPhone(String phone) {
    if (phone.length < 4) return phone;
    final last4 = phone.substring(phone.length - 4);
    final masked = "X" * (phone.length - 4);
    return masked + last4;
  }
}

/// `users/{uid}/suki_stats/{barberId}`
class SukiStat {
  const SukiStat({
    required this.barberId,
    required this.visitCount,
    required this.lastVisitDate,
  });

  final String barberId;
  final int visitCount;
  final DateTime? lastVisitDate;

  factory SukiStat.fromMap(String barberId, Map<String, dynamic> map) {
    return SukiStat(
      barberId: barberId,
      visitCount: map["visitCount"] ?? 0,
      lastVisitDate: map["lastVisitDate"]?.toDate(),
    );
  }
}