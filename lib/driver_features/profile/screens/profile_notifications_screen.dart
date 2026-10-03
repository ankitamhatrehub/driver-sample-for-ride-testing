import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/screens/notification_preferences_screen.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class ProfileNotificationsScreen extends StatelessWidget {
  const ProfileNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    final items = [
      _Notice('New ride request', 'Noida', Icons.directions_car_filled_rounded, accent, accent.withValues(alpha: 0.12), true),
      const _Notice('Parcel request nearby', 'DLF', Icons.inventory_2_outlined, Color(0xFFF59E0B), Color(0xFFFFF7ED), false),
      const _Notice('Payment credited', '320 added to my wallet', Icons.account_balance_wallet_outlined, Color(0xFF16A34A), Color(0xFFDCFCE7), true),
      const _Notice('New Scheduled request', 'Parcel delivery request', Icons.schedule_rounded, Color(0xFFF59E0B), Color(0xFFFFF7ED), false),
      const _Notice('Torkk pass offer', 'Get 20% off on your next plan', Icons.toll_rounded, Color(0xFFF59E0B), Color(0xFFFFF7ED), false),
    ];

    if (items.isEmpty) {
      return const ProfilePage(
        title: '',
        child: _EmptyNotifications(),
      );
    }

    return ProfilePage(
      title: AppStrings.notification,
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
        children: [
          Material(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(context.r(16)),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const NotificationPreferencesScreen()),
                );
              },
              borderRadius: BorderRadius.circular(context.r(16)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(14)),
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, color: accent, size: context.w(22)),
                    SizedBox(width: context.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notification Preferences',
                            style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2, letterSpacing: -0.2),
                          ),
                          Text(
                            'Choose what you want to be notified about',
                            style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: context.w(22)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(18)),
          Text(
            'Recent Notifications',
            style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.slate500),
          ),
          SizedBox(height: context.h(10)),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: context.h(10)),
            _NoticeCard(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        SizedBox(
          width: context.w(140),
          height: context.w(140),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: context.w(120),
                height: context.w(120),
                decoration: const BoxDecoration(color: Color(0xFFFFF7ED), shape: BoxShape.circle),
              ),
              Image.asset(AppAssets.notification, width: context.w(88), height: context.w(88)),
              Positioned(
                right: context.w(22),
                bottom: context.w(28),
                child: Container(
                  width: context.w(22),
                  height: context.w(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: context.w(12)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.h(16)),
        Text(
          'You have no new notifications.',
          style: AppTypography.regular.copyWith(fontSize: 14, color: AppColors.slate400),
        ),
        const Spacer(),
      ],
    );
  }
}

class _Notice {
  const _Notice(this.title, this.subtitle, this.icon, this.iconColor, this.iconBg, this.unread);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool unread;
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.item});

  final _Notice item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(40),
            height: context.w(40),
            decoration: BoxDecoration(color: item.iconBg, borderRadius: BorderRadius.circular(context.r(12))),
            child: Icon(item.icon, color: item.iconColor, size: context.w(20)),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2, letterSpacing: -0.2)),
                Text(item.subtitle, style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500)),
              ],
            ),
          ),
          Text('2 hours ago', style: AppTypography.regular.copyWith(fontSize: 11, color: AppColors.slate400)),
          if (item.unread) ...[
            SizedBox(width: context.w(6)),
            Container(
              width: context.w(8),
              height: context.w(8),
              decoration: BoxDecoration(color: profileAccent(context), shape: BoxShape.circle),
            ),
          ],
        ],
      ),
    );
  }
}
