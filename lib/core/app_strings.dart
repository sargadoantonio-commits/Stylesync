abstract final class AppStrings {
  static const String appName = "StyleSync";

  // Core App Strings
  static const String getStarted = "Get Started";
  static const String continueText = "Continue";
  static const String skip = "Skip";
  static const String next = "Next";
  static const String back = "Back";
  static const String done = "Done";
  static const String cancel = "Cancel";
  static const String save = "Save";
  static const String edit = "Edit";
  static const String delete = "Delete";
  static const String confirm = "Confirm";
  static const String ok = "OK";

  // Authentication
  static const String welcomeBack = "Welcome back!";
  static const String signInToAccount = "Sign in to your account";
  static const String createAccount = "Create your account";
  static const String forgotPassword = "Forgot your password?";
  static const String resetPassword = "Reset password";
  static const String enterEmail = "Enter your email";
  static const String enterPassword = "Enter your password";
  static const String confirmPassword = "Confirm your password";
  static const String enterUsername = "Choose a username";
  static const String signIn = "Sign In";
  static const String signUp = "Sign Up";
  static const String signOut = "Sign Out";
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = "Already have an account?";
  static const String checkEmail = "Check your email for reset instructions";

  // Onboarding
  static const String onboardingTitle1 = "Find Great Barbers Near You";
  static const String onboardingDesc1 =
      "Discover top-rated barbershops in your area with real customer reviews.";
  static const String onboardingTitle2 = "Skip the Line with Premium";
  static const String onboardingDesc2 =
      "Get priority service and never wait in line again. Only ₱29/month.";
  static const String onboardingTitle3 = "Try Haircuts Virtually";
  static const String onboardingDesc3 =
      "Use AR to preview hairstyles before booking. See it before you get it.";

  // Home & Navigation
  static const String home = "Home";
  static const String discover = "Discover";
  static const String queue = "Queue";
  static const String profile = "Profile";
  static const String settings = "Settings";
  static const String notifications = "Notifications";

  // Queue & Booking
  static const String noBarbersNearby =
      "No barbers nearby right now. Try checking another area!";
  static const String wantPremium =
      "Want to skip the line? Get Premium for only ₱29.";
  static const String paymentNote =
      "Payment is made in-person at the barbershop after your haircut.";
  static const String networkRetry = "Network is a bit slow. We're retrying!";
  static const String bookNow = "Book Appointment";
  static const String joinQueue = "Get in line for a haircut";
  static const String liveNow = "You're almost up!";
  static const String noQueue =
      "No current tickets yet. Join the queue and get your cut faster.";
  static const String verifyingLicense =
      "We're checking your license! We'll notify you as soon as you're cleared to cut.";
  static const String leaveQueue = "Leave the queue";
  static const String queueFull = "Queue is currently full. Try again later.";
  static const String bookingConfirmed = "Your appointment is confirmed!";
  static const String queueJoined = "You're now in line for service.";

  // Premium Features
  static const String upgradeToPremium = "Upgrade to Premium";
  static const String premiumBenefits =
      "Skip the line • Priority service • Unlimited AR previews";
  static const String premiumPrice = "₱29/month";
  static const String proPrice = "₱79/month";
  static const String premiumActivated =
      "Premium activated! Enjoy priority service.";
  static const String arLimitReached =
      "You've used all your free AR previews. Upgrade to Premium for unlimited access.";

  // AR Features
  static const String tryHaircut = "Try this haircut";
  static const String arPreview = "AR Preview";
  static const String takePhoto = "Take a photo";
  static const String selectHaircut = "Select a haircut style";
  static const String previewComplete =
      "Preview complete! Book now to get this look.";

  // Barber Features
  static const String barberDashboard = "Barber Dashboard";
  static const String manageQueue = "Manage your queue";
  static const String barberProfile = "Your barber profile";
  static const String servicesOffered = "Services you offer";
  static const String workingHours = "Working hours";
  static const String callNextCustomer = "Call next customer";
  static const String markComplete = "Mark service complete";
  static const String addService = "Add a service";
  static const String editService = "Edit service";
  static const String deleteService = "Delete service";

  // Shop Owner Features
  static const String shopDashboard = "Shop Dashboard";
  static const String manageBarbers = "Manage barbers";
  static const String shopSettings = "Shop settings";
  static const String addBarber = "Add barber";
  static const String removeBarber = "Remove barber";
  static const String shopAnalytics = "Shop analytics";
  static const String revenue = "Revenue";
  static const String customerSatisfaction = "Customer satisfaction";

  // Admin Features
  static const String adminDashboard = "Admin Dashboard";
  static const String manageUsers = "Manage users";
  static const String systemSettings = "System settings";
  static const String userReports = "User reports";
  static const String appAnalytics = "App analytics";
  static const String approveBarbers = "Approve barber licenses";
  static const String banUsers = "Ban users";
  static const String systemHealth = "System health";

  // Verification
  static const String verificationPending = "Verification in progress";
  static const String verificationDesc =
      "We're reviewing your barber license. This usually takes 1-2 business days.";
  static const String verificationApproved =
      "License approved! You can now accept customers.";
  static const String verificationRejected =
      "License verification failed. Please check your documents and try again.";

  // Success Messages
  static const String haircutComplete =
      "Haircut complete! Thanks for choosing StyleSync.";
  static const String bookingSuccess =
      "Booking confirmed! See you at the shop.";
  static const String paymentSuccess = "Payment received. Enjoy your new look!";
  static const String profileUpdated = "Profile updated successfully.";

  // Error Messages
  static const String errorGeneric = "Something went wrong. Please try again.";
  static const String errorNetwork =
      "Check your internet connection and try again.";
  static const String errorLocation =
      "We need your location to find nearby barbers.";
  static const String errorCamera = "Camera access is needed for AR previews.";
  static const String errorPermission =
      "Permission denied. Please enable in settings.";

  // Loading States
  static const String loading = "Loading...";
  static const String saving = "Saving...";
  static const String processing = "Processing...";
  static const String connecting = "Connecting...";

  static String queuePosition(int ahead) {
    if (ahead <= 0) return "You're next! Get ready.";
    return "There are $ahead people ahead of you. You're almost up!";
  }

  static String queueCount(int count) {
    if (count == 0) return "No one is waiting. Great time to drop by!";
    return "$count people are waiting right now.";
  }

  static String etaMinutes(int minutes) {
    if (minutes <= 0) return "Ready now";
    if (minutes == 1) return "About 1 minute";
    return "About $minutes minutes";
  }

  static String distanceKm(double km) {
    if (km < 1) return "Less than 1 km away";
    return "${km.toStringAsFixed(1)} km away";
  }
}
