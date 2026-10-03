import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  bool _rides = false;
  bool _offers = false;
  bool _payments = true;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Notification Preferences',
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(16), context.w(20), context.h(20)),
        children: [
          _PreferenceTile(
            icon: Icons.two_wheeler_outlined,
            title: 'Ride & Parcel Updates',
            subtitle: 'Booking, driver details, delivery status and more',
            value: _rides,
            onChanged: (value) => setState(() => _rides = value),
          ),
          SizedBox(height: context.h(12)),
          _PreferenceTile(
            icon: Icons.card_giftcard_outlined,
            title: 'Offer & Rewards',
            subtitle: 'Booking, driver details, delivery status and more',
            value: _offers,
            onChanged: (value) => setState(() => _offers = value),
          ),
          SizedBox(height: context.h(12)),
          _PreferenceTile(
            icon: Icons.credit_card_rounded,
            title: 'Payment Updates',
            subtitle: 'Booking, driver details, delivery status and more',
            value: _payments,
            onChanged: (value) => setState(() => _payments = value),
          ),
        ],
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
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
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(context.r(12)),
            ),
            child: Icon(icon, color: value ? accent : AppColors.slate400, size: context.w(20)),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2, letterSpacing: -0.2),
                ),
                Text(
                  subtitle,
                  style: AppTypography.regular.copyWith(fontSize: 12, height: 1.3, color: AppColors.slate500),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return accent;
              return const Color(0xFFE5E7EB);
            }),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
