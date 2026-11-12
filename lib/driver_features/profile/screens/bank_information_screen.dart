import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/profile/screens/edit_bank_details_screen.dart';
import 'package:rider_app/service/driver_api_service.dart';

class BankInformationScreen extends StatefulWidget {
  const BankInformationScreen({super.key});

  @override
  State<BankInformationScreen> createState() => _BankInformationScreenState();
}

class _BankInformationScreenState extends State<BankInformationScreen> {
  BankDetails _details = const BankDetails();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('user_phone') ?? '';
      final profile = await DriverApiService.fetchProfile(phone);
      debugPrint('BANK_SCREEN_03 | profile response=$profile');
      if (!mounted) return;
      setState(() {
        _details = BankDetails.fromProfile(profile);
        _loading = false;
      });
    } catch (e) {
      debugPrint('BANK_SCREEN_04 | load failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit() async {
    final result = await Navigator.of(context).push<BankDetails>(
      MaterialPageRoute(
        builder: (_) => EditBankDetailsScreen(initial: _details),
      ),
    );
    if (result != null && mounted) setState(() => _details = result);
  }

  static String _masked(String number) {
    if (number.length <= 4) return number;
    return '${'*' * (number.length - 4)}${number.substring(number.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return ProfilePage(
      title: AppStrings.bankInformation,
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(16),
        ),
        child: UnifiedButton(
          label: AppStrings.editReplace,
          icon: Icons.sync_rounded,
          iconAtEnd: true,
          onPressed: _loading ? null : _edit,
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(12),
          context.w(20),
          context.h(12),
        ),
        children: [
          Container(
            padding: EdgeInsets.all(context.w(14)),
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
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(context.r(12)),
                  ),
                  child: Icon(
                    Icons.account_balance_outlined,
                    color: accent,
                    size: context.w(20),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _details.bankName.isEmpty
                          ? 'Not added'
                          : _details.bankName,
                      style: AppTypography.bold.copyWith(
                        fontSize: 14,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      _details.accountNumber.isEmpty
                          ? '-'
                          : _masked(_details.accountNumber),
                      style: AppTypography.regular.copyWith(
                        fontSize: 12,
                        color: context.torkk.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(12)),
          ProfileMenuCard(
            items: [
              ProfileValueRow(
                icon: Icons.person_outline,
                label: AppStrings.accountHolderName,
                value: _details.accountHolderName.isEmpty
                    ? '-'
                    : _details.accountHolderName,
              ),
              ProfileValueRow(
                icon: Icons.credit_card_outlined,
                label: AppStrings.accountNumber,
                value: _details.accountNumber.isEmpty
                    ? '-'
                    : _details.accountNumber,
              ),
              ProfileValueRow(
                icon: Icons.account_balance_outlined,
                label: AppStrings.ifscCode,
                value: _details.ifscCode.isEmpty ? '-' : _details.ifscCode,
              ),
              ProfileValueRow(
                icon: Icons.location_city_outlined,
                label: 'Branch name',
                value: _details.branchName.isEmpty ? '-' : _details.branchName,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
