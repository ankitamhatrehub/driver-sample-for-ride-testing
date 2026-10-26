import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class BankInformationScreen extends StatelessWidget {
  const BankInformationScreen({super.key});

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
          backgroundColor: const Color(0xFF0F3FBF),
          onPressed: () {},
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(12), context.w(20), context.h(12)),
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
                  child: Icon(Icons.account_balance_outlined, color: accent, size: context.w(20)),
                ),
                SizedBox(width: context.w(12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HDFC Bank',
                      style: AppTypography.bold.copyWith(fontSize: 14, height: 1.3, letterSpacing: -0.2),
                    ),
                    Text(
                      '******68787',
                      style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(12)),
          ProfileMenuCard(
            items: [
              ProfileValueRow(icon: Icons.person_outline, label: AppStrings.accountHolderName, value: 'Rahul'),
              ProfileValueRow(icon: Icons.credit_card_outlined, label: AppStrings.accountNumber, value: '6767676767'),
              ProfileValueRow(icon: Icons.account_balance_outlined, label: AppStrings.ifscCode, value: '6767676767'),
            ],
          ),
        ],
      ),
    );
  }
}
