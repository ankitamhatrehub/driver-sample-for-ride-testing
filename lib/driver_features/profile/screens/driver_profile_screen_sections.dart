part of 'package:rider_app/driver_features/profile/screens/driver_profile_screen.dart';

extension _DriverProfileScreenStateSections on _DriverProfileScreenState {
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.torkk.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: context.torkk.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.torkk.border,
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.torkk.textPrimary,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.torkk.textPrimary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, {int currentIndex = 3}) {
    final navItems = [
      {'label': 'HOME', 'icon': Icons.home_outlined, 'route': AppRoutes.home},
      {
        'label': 'EARNINGS',
        'icon': Icons.payments_outlined,
        'route': AppRoutes.earnings,
      },
      {
        'label': 'HELP',
        'icon': Icons.headset_mic_outlined,
        'route': AppRoutes.support,
      },
      {
        'label': 'SETTINGS',
        'icon': Icons.settings_outlined,
        'route': AppRoutes.profile,
      },
    ];

    return Container(
      color: context.torkk.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (idx) {
            final item = navItems[idx];
            final isSelected = currentIndex == idx;

            return GestureDetector(
              onTap: () {
                if (currentIndex == idx) return;
                final route = item['route'] as String;
                context.go(route);
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
