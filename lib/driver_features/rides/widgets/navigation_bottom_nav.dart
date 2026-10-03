import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/earnings/screens/driver_earnings_screen.dart';
import 'package:rider_app/driver_features/profile/screens/driver_support_screen.dart';
import 'package:rider_app/driver_features/profile/screens/driver_profile_screen.dart';

class NavigationBottomNav extends StatelessWidget {
  final String driverPhotoUrl;

  const NavigationBottomNav({
    super.key,
    required this.driverPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'label': 'HOME', 'icon': Icons.home_outlined},
      {'label': 'EARNINGS', 'icon': Icons.payments_outlined},
      {'label': 'HELP', 'icon': Icons.headset_mic_outlined},
      {'label': 'SETTINGS', 'icon': Icons.settings_outlined},
    ];

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (idx) {
            final item = navItems[idx];
            final isSelected = idx == 0;

            return GestureDetector(
              onTap: () {
                if (idx == 0) {
                  context.go(AppRoutes.home);
                } else if (idx == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DriverEarningsScreen(
                        profilePhotoUrl: driverPhotoUrl,
                        onClose: () => Navigator.pop(context),
                      ),
                    ),
                  );
                } else if (idx == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DriverSupportScreen(),
                    ),
                  );
                } else if (idx == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DriverProfileScreen(),
                    ),
                  );
                }
              },
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF1D4ED8,
                      ).withValues(alpha: isSelected ? 0.4 : 0.2),
                      blurRadius: isSelected ? 8 : 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
