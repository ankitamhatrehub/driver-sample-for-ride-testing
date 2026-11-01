import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/screens/edit_bank_details_screen.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/service/driver_api_service.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  BankDetails _details = const BankDetails();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Same profile API as Profile > Bank Information.
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('user_phone') ?? '';
      final profile = await DriverApiService.fetchProfile(phone);
      if (!mounted) return;
      setState(() {
        _details = BankDetails.fromProfile(profile);
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading bank account: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  static String _masked(String number) {
    if (number.length <= 4) return number;
    return '${'*' * (number.length - 4)}${number.substring(number.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return ProfilePage(
      title: AppStrings.bankAccount,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
              children: [
                Text('Primary Bank Account', style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary)),
                SizedBox(height: context.h(8)),
                Container(
                  padding: EdgeInsets.all(context.w(14)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.r(16)),
                    border: Border.all(color: context.torkk.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: context.w(36),
                        height: context.w(36),
                        decoration: BoxDecoration(color: context.adaptiveTint(const Color(0xFFF3E8FF)), borderRadius: BorderRadius.circular(context.r(10))),
                        child: Icon(Icons.account_balance_outlined, color: accent, size: context.w(18)),
                      ),
                      SizedBox(width: context.w(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _details.bankName.isEmpty ? 'Not added' : _details.bankName,
                              style: AppTypography.bold.copyWith(fontSize: 14, height: 1.3, letterSpacing: -0.2),
                            ),
                            Text(
                              _details.accountNumber.isEmpty ? '-' : _masked(_details.accountNumber),
                              style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary),
                            ),
                            if (_details.ifscCode.isNotEmpty || _details.branchName.isNotEmpty)
                              Text(
                                [_details.ifscCode, _details.branchName].where((e) => e.isNotEmpty).join(' • '),
                                style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.h(12)),
                Row(
                  children: [
                    Icon(Icons.lock_outline, size: context.w(14), color: const Color(0xFF16A34A)),
                    SizedBox(width: context.w(6)),
                    Text('Your Bank details are safe and secure with us', style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary)),
                  ],
                ),
                SizedBox(height: context.h(20)),
                _secureBanner(context, accent),
              ],
            ),
    );
  }

  Widget _secureBanner(BuildContext context, Color accent) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(18)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.2), accent.withValues(alpha: 0.05)],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -context.w(24),
            top: -context.w(24),
            child: Container(
              width: context.w(90),
              height: context.w(90),
              decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.08)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.w(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: context.w(46),
                      height: context.w(46),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Icon(Icons.shield_rounded, color: Colors.white, size: context.w(24)),
                    ),
                    SizedBox(width: context.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your payout account', style: AppTypography.bold.copyWith(fontSize: 14, color: context.torkk.textPrimary)),
                          SizedBox(height: context.h(2)),
                          Text(
                            'Your earnings are sent to the account shown above.',
                            style: AppTypography.regular.copyWith(fontSize: 12, height: 1.35, color: context.torkk.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(12)),
                Wrap(
                  spacing: context.w(8),
                  runSpacing: context.h(8),
                  children: [
                    _chip(context, Icons.lock_outline_rounded, 'Encrypted', const Color(0xFF16A34A)),
                    _chip(context, Icons.verified_outlined, 'Verified', accent),
                    _chip(context, Icons.bolt_rounded, 'Fast payouts', const Color(0xFFF59E0B)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, IconData icon, String label, Color color) {
    final c = context.legible(color, minContrast: 3);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.h(5)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDarkTheme ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.w(14), color: c),
          SizedBox(width: context.w(4)),
          Text(label, style: AppTypography.regular.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: c)),
        ],
      ),
    );
  }
}
