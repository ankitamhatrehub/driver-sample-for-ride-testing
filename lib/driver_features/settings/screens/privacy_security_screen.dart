import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/settings/screens/change_pin_screen.dart';
import 'package:rider_app/driver_features/settings/screens/set_pin_screen.dart';

import '../../../common/constants/string_constants.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/widgets/app_switch.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _showProfile = false;
  bool _shareLocation = true;
  bool _hasPin = false;

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
      _hasPin = (prefs.getString('account_pin') ?? '').length == 4;
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
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => hasPin ? const ChangePinScreen() : const SetPinScreen(),
      ),
    );
    if (result == true) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return ProfilePage(
      title: AppStrings.privacyPolicy,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(20),
        ),
        children: [
          Material(
            color: context.adaptiveTint(const Color(0xFFF5F3FF)),
            borderRadius: BorderRadius.circular(context.r(16)),
            child: InkWell(
              onTap: _openPin,
              borderRadius: BorderRadius.circular(context.r(16)),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(14),
                  vertical: context.h(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: context.w(40),
                      height: context.w(40),
                      decoration: BoxDecoration(
                        color: context.torkk.surface,
                        borderRadius: BorderRadius.circular(context.r(12)),
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: accent,
                        size: context.w(20),
                      ),
                    ),
                    SizedBox(width: context.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.setChangePin,
                            style: AppTypography.bold.copyWith(
                              color: context.torkk.textPrimary,
                              fontSize: 14,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            _hasPin
                                ? 'PIN is active. Tap to change PIN'
                                : AppStrings.secureAccountPin,
                            style: AppTypography.regular.copyWith(
                              fontSize: 12,
                              color: context.torkk.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.slate400,
                      size: context.w(22),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(18)),
          Text(
            AppStrings.privacySettings,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(10)),
          _PrivacySwitch(
            icon: Icons.person_outline_rounded,
            title: AppStrings.showMyProfileToDriver,
            subtitle: AppStrings.showMyProfileToDriverSubtitle,
            value: _showProfile,
            onChanged: (value) {
              setState(() => _showProfile = value);
              _save('show_profile_to_driver', value);
            },
          ),
          SizedBox(height: context.h(12)),
          _PrivacySwitch(
            icon: Icons.location_on_outlined,
            title: AppStrings.locationSharing,
            subtitle: AppStrings.locationSharingSubtitle,
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
              color: context.torkk.textSecondary,
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
                  style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2),
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
