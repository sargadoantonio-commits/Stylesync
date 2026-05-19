import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "app_routes.dart";
import "../../features/ar/presentation/ar_camera_screen.dart";
import "../../screens/enhanced_ar_camera_screen.dart";
import "../../features/ar/presentation/premium_upgrade_screen.dart";
import "../../features/ar/presentation/screens/hairstyle_filter_gallery_screen.dart";
import "../../features/auth/presentation/auth_screen.dart";
import "../../features/auth/presentation/character_sheet_profile_screen.dart";
import "../../features/auth/presentation/forgot_password_screen.dart";
import "../../features/auth/presentation/providers/auth_providers.dart";
import "../../features/auth/presentation/settings_screen.dart";
import "../../features/auth/presentation/role_selection_screen.dart";
import "../../features/auth/domain/user_role.dart";
import "../../features/queue/presentation/queue_screen.dart";
import "../../screens/booking_screen.dart";
import "../../screens/booking_confirmed_screen.dart";
import "../../screens/barber_profile_screen.dart";
import "../../screens/profile_setup_screen.dart";
import "../../screens/landing_screen.dart";
import "../../screens/customer/home_screen.dart";
import "../../screens/barber/barber_dashboard_screen.dart";
import "../../screens/barber/barber_id_upload_screen.dart";
import "../../screens/barber/barber_pending_screen.dart";
import "../../screens/barber/barber_earnings_screen.dart";
import "../../screens/admin/admin_monitoring_dashboard.dart";
import "../../screens/shop_owner/shop_owner_dashboard_screen.dart";
import "../../screens/discover_screen.dart";
import "../../screens/notifications_screen.dart";
import "../../screens/style_library_screen.dart";
import "../../screens/support_screen.dart";
import "../../screens/email_otp_verify_screen.dart";
import "../../screens/my_bookings_screen.dart";
import "../../screens/profile_xp_screen.dart";

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}

CustomTransitionPage<void> _fadePage(
    {required LocalKey key, required Widget child}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, c) {
      return FadeTransition(opacity: animation, child: c);
    },
  );
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh =
      _AuthRefresh(ref.watch(authRepositoryProvider).authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.landing,
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final auth = ref.read(authStateProvider);
      final isAuthRoute = AppRoutes.isAuthRoute(loc);

      if (auth.isLoading) return null;

      final user = auth.valueOrNull;
      // If not signed in and not on landing/auth route, go to landing
      if (user == null) {
        if (loc == AppRoutes.landing) return null; // Allow landing
        return isAuthRoute ? null : AppRoutes.landing;
      }

      // User is signed in, redirect from auth routes
      if (isAuthRoute || loc == AppRoutes.landing) {
        // Get user profile to determine role
        final profileAsync = ref.read(userProfileProvider);
        if (profileAsync.isLoading) return null;

        final profile = profileAsync.valueOrNull;
        if (profile == null) {
          return AppRoutes.roleSelection;
        }

        // Route to role-specific home
        switch (profile.role) {
          case UserRole.barber:
            return AppRoutes.barberHome;
          case UserRole.shopOwner:
            return AppRoutes.shopOwnerHome;
          case UserRole.customer:
            return AppRoutes.customerHome;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.landing,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const LandingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const AuthScreen(mode: AuthMode.login),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const AuthScreen(mode: AuthMode.register),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.characterSheet,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const CharacterSheetProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const RoleSelectionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const ProfileSetupScreen(),
        ),
      ),
      GoRoute(
        path: '/verify-email',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const EmailOtpVerifyScreen(
            email: 'user@example.com',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.myBookings,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const MyBookingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerHome,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.barberHome,
        pageBuilder: (context, state) {
          // Check if this is an admin barber
          final profileAsync = ref.read(userProfileProvider);
          final profile = profileAsync.valueOrNull;
          
          final isAdmin = profile?.isAdmin ?? false;
          
          return _fadePage(
            key: state.pageKey,
            child: isAdmin
                ? const AdminMonitoringDashboard()
                : const BarberDashboardScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.shopOwnerHome,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const ShopOwnerDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.discover,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const DiscoverScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.queue,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const QueueScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.ar,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          // Route `/ar` now opens the simplified camera-only screen to
          // avoid initialization issues on devices where the AR pipeline
          // may fail. The original `ArCameraScreen` remains in the codebase
          // for future restoration.
          child: const EnhancedARCameraScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.premiumUpgrade,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const PremiumUpgradeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.booking,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const BookingScreen(),
        ),
      ),
      GoRoute(
        path: '/booking/confirmed',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _fadePage(
            key: state.pageKey,
            child: BookingConfirmedScreen(
              referenceCode: extra?['referenceCode'] ?? 'SS-00000',
              barber: extra?['barber'] ?? 'Your Barber',
              service: extra?['service'] ?? 'Service',
              price: extra?['price'] ?? 0.0,
              date: extra?['date'] ?? DateTime.now(),
              time: extra?['time'] ?? '00:00',
              shopName: extra?['shopName'] ?? 'Shop',
              shopAddr: extra?['shopAddr'] ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: '/barber/apply',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const BarberIdUploadScreen(),
        ),
      ),
      GoRoute(
        path: '/barber/pending',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const BarberPendingScreen(),
        ),
      ),
      GoRoute(
        path: '/barber/earnings',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const BarberEarningsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.styleLibrary,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const StyleLibraryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.hairstyleFilters,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const HairstyleFilterGalleryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.support,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const SupportScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.barberProfile,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final barberName = extra?['barberName'] as String? ?? 'Your Barber';
          final specialty = extra?['specialty'] as String? ?? 'Skilled styling';
          return _fadePage(
            key: state.pageKey,
            child: BarberProfileScreen(
                barberName: barberName, specialty: specialty),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profileXP,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const ProfileXPScreen(),
        ),
      ),
    ],
  );
});
