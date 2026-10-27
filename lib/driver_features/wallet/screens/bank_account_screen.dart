import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class BankAccountScreen extends StatelessWidget {
  const BankAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.bankAccount,
      child: ListView(
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
                  child: Icon(Icons.account_balance_outlined, color: profileAccent(context), size: context.w(18)),
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
        ],
      ),
    );
  }
}
