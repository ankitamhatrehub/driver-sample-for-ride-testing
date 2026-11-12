import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/rides/payment/payment_widgets.dart';

/// Step 2b: the rider paid only part by UPI; how was the rest handled?
class PaymentAdjustPage extends StatelessWidget {
  const PaymentAdjustPage({
    super.key,
    required this.upiPaid,
    required this.remaining,
    required this.paymentId,
    required this.byCash,
    required this.onChoose,
    required this.onContinue,
    required this.onBack,
  });

  final double upiPaid;
  final double remaining;
  final String paymentId;
  final bool byCash;
  final ValueChanged<bool> onChoose;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return PaymentScaffold(
      onBack: onBack,
      bottom: UnifiedButton(
        label: AppStrings.payContinue,
        onPressed: onContinue,
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          SizedBox(height: context.h(4)),
          PaymentAmountHeader(
            label: AppStrings.payTotalCollected,
            amount: upiPaid,
          ),
          SizedBox(height: context.h(14)),
          Center(child: PaymentQrBlock(paymentId: paymentId, size: 170)),
          SizedBox(height: context.h(16)),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.payRemainingAmount,
                  style: AppTypography.regular.copyWith(fontSize: 14),
                ),
              ),
              Text(
                rupee(remaining),
                style: AppTypography.bold.copyWith(
                  fontSize: 15,
                  color: paymentRed,
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(10)),
          PaymentCard(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: context.h(4)),
                  child: Text(
                    AppStrings.payAdjustment,
                    style: AppTypography.bold.copyWith(fontSize: 14),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.payAdjustmentHint,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    color: context.torkk.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: context.h(6)),
              PaymentChoice(
                label: AppStrings.payCashCollected,
                selected: byCash,
                onTap: () => onChoose(true),
              ),
              PaymentChoice(
                label: AppStrings.payOutstanding,
                selected: !byCash,
                onTap: () => onChoose(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
