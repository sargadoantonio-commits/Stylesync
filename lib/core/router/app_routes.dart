abstract final class AppRoutes {
  AppRoutes._();

  static const String landing = "/";
  static const String login = "/login";
  static const String roleSelection = "/role-selection";
  static const String register = "/register";
  static const String forgotPassword = "/forgot-password";
  static const String characterSheet = "/character-sheet";
  static const String profileSetup = "/profile-setup";
  static const String home = "/home";
  static const String customerHome = "/customer-home";
  static const String barberHome = "/barber-home";
  static const String shopOwnerHome = "/shop-owner-home";
  static const String discover = "/discover";
  static const String booking = "/booking";
  static const String styleLibrary = "/style-library";
  static const String hairstyleFilters = "/hairstyle-filters";
  static const String myBookings = "/my-bookings";
  static const String notifications = "/notifications";
  static const String support = "/support";
  static const String barberProfile = "/barber-profile";
  static const String settings = "/settings";
  static const String queue = "/queue";
  static const String ar = "/ar";
  static const String premiumUpgrade = "/premium-upgrade";
  static const String profileXP = "/profile-xp";

  static const List<String> authRoutes = [
    login,
    roleSelection,
    register,
    forgotPassword,
    characterSheet,
  ];

  static bool isAuthRoute(String location) => authRoutes.contains(location);
}
