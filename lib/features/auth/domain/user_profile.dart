import "user_role.dart";

/// Firestore mirror of identity + StyleSync fields (Laravel had username + auth; roles added for StyleSync).
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
    required this.isPremium,
    required this.createdAt,
  });

  final String uid;
  final String username;
  final String email;
  final UserRole role;
  final bool isPremium;
  final DateTime? createdAt;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      username: map["username"] as String? ?? "",
      email: map["email"] as String? ?? "",
      role: UserRole.fromFirestore(map["role"] as String?),
      isPremium: map["isPremium"] as bool? ?? false,
      createdAt: (map["createdAt"] as dynamic)?.toDate() as DateTime?,
    );
  }

  Map<String, dynamic> toWriteMap() {
    return {
      "username": username,
      "email": email,
      "role": role.firestoreValue,
      "isPremium": isPremium,
    };
  }
}
