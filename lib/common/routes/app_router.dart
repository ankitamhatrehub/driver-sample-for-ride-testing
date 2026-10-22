import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../driver_features/earnings/screens/driver_earnings_screen.dart';
import '../../driver_features/home/screens/driver_home_screen.dart';
import '../../driver_features/notifications/screens/driver_notifications_screen.dart';
import '../../driver_features/onboarding/language_page.dart';
import '../../driver_features/onboarding/onboarding_pages.dart';
import '../../driver_features/onboarding/welcome_page.dart';
import '../../driver_features/profile/screens/profile_screen.dart';
import '../../driver_features/rides/screens/driver_navigation_screen.dart';
import '../../driver_features/rides/screens/driver_requests_screen.dart';
import '../../driver_features/settings/screens/driver_settings_screen.dart';
import '../../driver_features/profile/screens/driver_support_screen.dart';
import '../../driver_features/trips/screens/driver_history_screen.dart';
import '../../driver_features/trips/screens/driver_trips_screen.dart';
import '../../driver_features/wallet/wallet_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = _create();

  static GoRouter _create() {
    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      observers: [_RouteDebugObserver()],
      redirect: (context, state) {
        if (state.uri.path == '/vehicle_details') {
          return AppRoutes.vehicleDetails;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.language,
          name: 'language',
          builder: (context, state) => const LanguagePage(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          name: 'welcome',
          builder: (context, state) => const WelcomePage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const WelcomePage(),
        ),
        GoRoute(
          path: AppRoutes.otp,
          name: 'otp',
          builder: (context, state) => const OtpPage(),
        ),
        GoRoute(
          path: AppRoutes.vehicleDetails,
          name: 'vehicleDetails',
          builder: (context, state) => const VehiclePage(),
        ),
        GoRoute(
          path: AppRoutes.kyc,
          name: 'kyc',
          builder: (context, state) => const KycPage(),
        ),
        GoRoute(
          path: AppRoutes.kycAadhaar,
          name: 'kycAadhaar',
          builder: (context, state) => const AadhaarPage(),
        ),
        GoRoute(
          path: AppRoutes.kycDrivingLicence,
          name: 'kycDrivingLicence',
          builder: (context, state) => const DrivingLicencePage(),
        ),
        GoRoute(
          path: AppRoutes.kycRc,
          name: 'kycRc',
          builder: (context, state) => const VehicleRcPage(),
        ),
        GoRoute(
          path: AppRoutes.kycPhotos,
          name: 'kycPhotos',
          builder: (context, state) => const VehiclePhotosPage(),
        ),
        GoRoute(
          path: AppRoutes.kycInsurance,
          name: 'kycInsurance',
          builder: (context, state) => const VehicleInsurancePage(),
        ),
        GoRoute(
          path: AppRoutes.kycFace,
          name: 'kycFace',
          builder: (context, state) => const FacePage(),
        ),
        GoRoute(
          path: AppRoutes.kycBank,
          name: 'kycBank',
          builder: (context, state) => const BankPage(),
        ),
        GoRoute(
          path: AppRoutes.driverDetails,
          name: 'driverDetails',
          builder: (context, state) => const DriverDetailsPage(),
        ),
        GoRoute(
          path: AppRoutes.review,
          name: 'review',
          builder: (context, state) => const ReviewPage(),
        ),
        GoRoute(
          path: AppRoutes.applicationStatus,
          name: 'applicationStatus',
          builder: (context, state) => const ApplicationStatusPage(),
        ),
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const DriverHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.dashboardMale,
          name: 'dashboardMale',
          builder: (context, state) => const DriverHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.dashboardFemale,
          name: 'dashboardFemale',
          builder: (context, state) => const DriverHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.requests,
          name: 'requests',
          builder: (context, state) => const DriverRequestsScreen(),
        ),
        GoRoute(
          path: AppRoutes.navigation,
          name: 'navigation',
          builder: (context, state) => const DriverNavigationScreen(),
        ),
        GoRoute(
          path: AppRoutes.earnings,
          name: 'earnings',
          builder: (context, state) => const DriverEarningsScreen(),
        ),
        GoRoute(
          path: AppRoutes.wallet,
          name: 'wallet',
          builder: (context, state) => const WalletScreen(),
        ),
        GoRoute(
          path: AppRoutes.trips,
          name: 'trips',
          builder: (context, state) => const DriverTripsScreen(),
        ),
        GoRoute(
          path: AppRoutes.history,
          name: 'history',
          builder: (context, state) => const DriverHistoryScreen(),
        ),
        GoRoute(
          path: AppRoutes.support,
          name: 'support',
          builder: (context, state) => const DriverSupportScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const DriverSettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          name: 'notifications',
          builder: (context, state) => const DriverNotificationsScreen(),
        ),
      ],
    );

    router.routerDelegate.addListener(() => _logLocation(router));
    return router;
  }

  static void _logLocation(GoRouter router) {
    final config = router.routerDelegate.currentConfiguration;
    final matched = config.matches
        .map((match) => match.matchedLocation)
        .join(' > ');
    debugPrint('[Route] ${config.uri}  matched: $matched');
  }
}

class _RouteDebugObserver extends NavigatorObserver {
  void _log(String action, Route<dynamic>? route, Route<dynamic>? previous) {
    debugPrint(
      '[Route] $action ${route?.settings.name ?? route?.settings.arguments} '
      'from ${previous?.settings.name}',
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('pop', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _log('replace', newRoute, oldRoute);
  }
}
