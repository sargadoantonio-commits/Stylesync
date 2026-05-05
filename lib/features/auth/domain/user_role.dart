enum UserRole {
  barber,
  shopOwner,
  customer;

  String get firestoreValue => name;

  static UserRole fromFirestore(String? value) {
    switch (value) {
      case "barber":
        return UserRole.barber;
      case "shopOwner":
        return UserRole.shopOwner;
      case "customer":
      default:
        return UserRole.customer;
    }
  }
}
