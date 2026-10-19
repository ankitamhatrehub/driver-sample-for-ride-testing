import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/app_snackbar.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

import '../../../common/constants/string_constants.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String _pin = '';

  Future<void> _tap(String digit) async {
    if (_pin.length >= 4) return;
    setState(() => _pin += digit);
    if (_pin.length < 4) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('account_pin', _pin);
    if (mounted) {
      AppSnackBar.showSuccess(
        context,
        title: 'PIN Set Successfully',
        message: 'Your 4-digit PIN is active now.',
      );
      Navigator.of(context).pop(true);
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return ProfilePage(
      title: 'Set Pin',
      child: Column(
        children: [
          SizedBox(height: context.h(28)),
          Container(
            width: context.w(72),
            height: context.w(72),
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.lock_outline_rounded, color: accent, size: context.w(32)),
          ),
          SizedBox(height: context.h(16)),
          Text(
            AppStrings.secureYourAccount,
            style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2, letterSpacing: -0.3),
          ),
          SizedBox(height: context.h(6)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(48)),
            child: Text(
              AppStrings.createPinSubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.regular.copyWith(fontSize: 13, height: 1.4, color: AppColors.slate500),
            ),
          ),
          SizedBox(height: context.h(28)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 4; i++)
                Container(
                  width: context.w(12),
                  height: context.w(12),
                  margin: EdgeInsets.symmetric(horizontal: context.w(8)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _pin.length ? accent : const Color(0xFFE5E7EB),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(context.w(36), 0, context.w(36), context.h(24)),
            child: Column(
              children: [
                for (final row in const [
                  ['1', '2', '3'],
                  ['4', '5', '6'],
                  ['7', '8', '9'],
                ])
                  Padding(
                    padding: EdgeInsets.only(bottom: context.h(14)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final digit in row) _key(context, digit, () => _tap(digit)),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: context.w(72)),
                    _key(context, '0', () => _tap('0')),
                    _key(context, '', _backspace, icon: Icons.backspace_outlined),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _key(BuildContext context, String label, VoidCallback onTap, {IconData? icon}) {
    return Material(
      color: const Color(0xFFF3F4F6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: context.w(72),
          height: context.w(72),
          child: Center(
            child: icon != null
                ? Icon(icon, color: AppColors.textPrimary, size: context.w(22))
                : Text(
                    label,
                    style: AppTypography.regular.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }
}
