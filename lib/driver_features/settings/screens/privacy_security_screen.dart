import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/settings/screens/change_pin_screen.dart';
import 'package:rider_app/driver_features/settings/screens/set_pin_screen.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _showProfile = false;
  bool _shareLocation = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _showProfile = prefs.getBool('show_profile_to_driver') ?? false;
      _shareLocation = prefs.getBool('location_sharing') ?? true;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _openPin() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPin = (prefs.getString('account_pin') ?? '').length == 4;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => hasPin ? const ChangePinScreen() : const SetPinScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return ProfilePage(
      title: 'Privacy & Security',
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
        children: [
          Material(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(context.r(16)),
            child: InkWell(
              onTap: _openPin,
              borderRadius: BorderRadius.circular(context.r(16)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(14)),
                child: Row(
                  children: [
                    Container(
                      width: context.w(40),
                      height: context.w(40),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(context.r(12))),
                      child: Icon(Icons.lock_outline_rounded, color: accent, size: context.w(20)),
                    ),
                    SizedBox(width: context.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Set/Change Pin',
                            style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2),
                          ),
                          Text(
                            'Secure your Account with a 4-digit Pin',
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
            'Privacy Settings',
            style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.slate500),
          ),
          SizedBox(height: context.h(10)),
          _PrivacySwitch(
            icon: Icons.person_outline_rounded,
            title: 'Show my profile to driver',
            subtitle: 'Allow drivers to see your profile picture and name',
            value: _showProfile,
            onChanged: (value) {
              setState(() => _showProfile = value);
              _save('show_profile_to_driver', value);
            },
          ),
          SizedBox(height: context.h(12)),
          _PrivacySwitch(
            icon: Icons.location_on_outlined,
            title: 'Location sharing',
            subtitle: 'Share your live location with drivers during rides',
            value: _shareLocation,
            onChanged: (value) {
              setState(() => _shareLocation = value);
              _save('location_sharing', value);
            },
          ),
        ],
      ),
    );
  }
}

class _PrivacySwitch extends StatelessWidget {
  const _PrivacySwitch({
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
            child: Icon(icon, color: AppColors.slate500, size: context.w(20)),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2)),
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
