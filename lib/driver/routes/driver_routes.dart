import 'package:flutter/material.dart';
import '../screens/app_startup_gate.dart';
import '../screens/driver_screens.dart';

class DriverRoutes {
  static Map<String, WidgetBuilder> get routes {
    return {
      '/': (context) => const AppStartupGate(),
      '/login': (context) => const DriverOnboardingScreen(),
      '/kyc': (context) => const DriverOnboardingScreen(),
      '/vehicle_details': (context) => const DriverOnboardingScreen(),
      '/home': (context) => const DriverHomeScreen(),
      '/dashboard_male': (context) => const DriverHomeScreen(),
      '/dashboard_female': (context) => const DriverHomeScreen(),
      '/requests': (context) => const DriverRequestsScreen(),
      '/navigation': (context) => const DriverNavigationScreen(),
      '/earnings': (context) => const DriverEarningsScreen(),
      '/wallet': (context) => const DriverWalletScreen(),
      '/trips': (context) => const DriverTripsScreen(),
      '/history': (context) => const DriverHistoryScreen(),
      '/support': (context) => const DriverSupportScreen(),
      '/profile': (context) => const DriverProfileScreen(),
      '/notifications': (context) => const DriverNotificationsScreen(),
    };
  }
}
