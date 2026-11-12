import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/rides/payment/payment_result.dart';
import 'package:rider_app/driver_features/rides/payment/payment_widgets.dart';

/// Step 3: review what was collected before confirming.
class PaymentReviewPage extends StatelessWidget {
  const PaymentReviewPage({
    super.key,
    required this.result,
    required this.riderId,
    required this.onConfirm,
    required this.onBack,
  });

  final RidePaymentResult result;
  final String riderId;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final r = result;
    final collected = r.upi + r.cash;
    final mixed = r.upi > 0 && r.cash > 0;
    return PaymentScaffold(
      onBack: onBack,
      title: AppStrings.payPaymentConfirmation,
      bottom: UnifiedButton(
        label: AppStrings.payConfirmDetails,
        onPressed: onConfirm,
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          SizedBox(height: context.h(8)),
          const PaymentBadge(),
          SizedBox(height: context.h(12)),
          PaymentAmountHeader(
            label: AppStrings.payTotalCollected,
            amount: collected,
            sub: '${AppStrings.payRiderId}:  $riderId',
          ),
          if (r.outstanding == 0 && r.upi >= r.total)
            Padding(
              padding: EdgeInsets.only(top: context.h(8)),
              child: Center(
                child: Text(
                  AppStrings.payPaymentSuccessful,
                  style: AppTypography.regular.copyWith(
                    fontSize: 13,
                    color: paymentGreen,
                  ),
                ),
              ),
            ),
          PaymentSectionTitle(AppStrings.payPaymentDetails),
          PaymentCard(
            children: [
              if (r.upi > 0)
                PaymentRow(
                  label: AppStrings.payUpiPayment,
                  value: rupee(r.upi),
                ),
              if (r.cash > 0 || r.upi == 0)
                PaymentRow(
                  label: AppStrings.payCashPayment,
                  value: rupee(r.cash),
                ),
              if (r.change > 0)
                PaymentRow(
                  label: AppStrings.payChangeReturned,
                  value: rupee(r.change),
                ),
              if (r.outstanding > 0)
                PaymentRow(
                  label: AppStrings.payPaymentOutstanding,
                  value: rupee(r.outstanding),
                  valueColor: paymentRed,
                ),
              if (mixed || r.outstanding > 0 || r.change > 0)
                PaymentRow(
                  label: AppStrings.payNetCollection,
                  value: rupee(collected),
                  bold: true,
                ),
            ],
          ),
          if (r.outstanding > 0) ...[
            PaymentSectionTitle(AppStrings.payRemainingAmount),
            Text(
              rupee(r.outstanding),
              style: AppTypography.bold.copyWith(
                fontSize: 16,
                color: paymentRed,
              ),
            ),
            SizedBox(height: context.h(8)),
            Text(
              AppStrings.payCarriedNote,
              style: AppTypography.regular.copyWith(
                fontSize: 12,
                color: context.torkk.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
