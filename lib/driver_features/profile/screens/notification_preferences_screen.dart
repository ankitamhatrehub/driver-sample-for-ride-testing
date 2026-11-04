import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/widgets/app_switch.dart';
import 'package:rider_app/service/notifications_api_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  NotificationPreferences _prefs = const NotificationPreferences(
    rideParcelUpdates: false,
    offerRewards: false,
    paymentUpdates: false,
  );
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await NotificationsApiService.fetchPreferences();
      if (!mounted) return;
      setState(() {
        _prefs = prefs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  /// Flips a switch right away, saves it, and puts it back if saving fails.
  Future<void> _change(NotificationPreferences next) async {
    final previous = _prefs;
    setState(() {
      _prefs = next;
      _saving = true;
    });
    try {
      final saved = await NotificationsApiService.updatePreferences(next);
      if (!mounted) return;
      setState(() {
        _prefs = saved;
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _prefs = previous;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ProfilePage(
        title: 'Notification Preferences',
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return ProfilePage(
        title: 'Notification Preferences',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              TextButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    return ProfilePage(
      title: 'Notification Preferences',
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(16),
          context.w(20),
          context.h(20),
        ),
        children: [
          _PreferenceTile(
            icon: Icons.two_wheeler_outlined,
            title: 'Ride & Parcel Updates',
            subtitle: 'Booking, driver details, delivery status and more',
            value: _prefs.rideParcelUpdates,
            onChanged: _saving
                ? null
                : (v) => _change(_prefs.copyWith(rideParcelUpdates: v)),
          ),
          SizedBox(height: context.h(12)),
          _PreferenceTile(
            icon: Icons.card_giftcard_outlined,
            title: 'Offer & Rewards',
            subtitle: 'Offers, coins, scratch cards and rewards',
            value: _prefs.offerRewards,
            onChanged: _saving
                ? null
                : (v) => _change(_prefs.copyWith(offerRewards: v)),
          ),
          SizedBox(height: context.h(12)),
          _PreferenceTile(
            icon: Icons.credit_card_rounded,
            title: 'Payment Updates',
            subtitle: 'Wallet credits, payouts and payment status',
            value: _prefs.paymentUpdates,
            onChanged: _saving
                ? null
                : (v) => _change(_prefs.copyWith(paymentUpdates: v)),
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
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(12),
        vertical: context.h(12),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(40),
            height: context.w(40),
            decoration: BoxDecoration(
              color: context.torkk.surfaceMuted,
              borderRadius: BorderRadius.circular(context.r(12)),
            ),
            child: Icon(
              icon,
              color: value ? accent : AppColors.slate400,
              size: context.w(20),
            ),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bold.copyWith(
                    fontSize: 14,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    height: 1.3,
                    color: context.torkk.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AppSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
