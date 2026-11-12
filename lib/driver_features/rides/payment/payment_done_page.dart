import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/rides/payment/payment_result.dart';
import 'package:rider_app/driver_features/rides/payment/payment_widgets.dart';

/// Step 4: payment confirmed, with details, breakdown and the driver's earning.
class PaymentDonePage extends StatelessWidget {
  const PaymentDonePage({
    super.key,
    required this.result,
    required this.riderId,
    required this.distanceLabel,
    required this.earning,
    required this.onContinue,
    required this.onBack,
  });

  final RidePaymentResult result;
  final String riderId;
  final String distanceLabel;
  final double earning;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  String get _method {
    if (result.upi > 0 && result.cash > 0) return AppStrings.payMethodUpiCash;
    return result.upi > 0 ? AppStrings.payMethodUpi : AppStrings.payMethodCash;
  }

  String get _status {
    if (result.outstanding > 0) return AppStrings.payOutstanding;
    return result.change > 0
        ? AppStrings.payStatusChangeSettled
        : AppStrings.payStatusSettled;
  }

  @override
  Widget build(BuildContext context) {
    final r = result;
    final collected = r.upi + r.cash;
    return PaymentScaffold(
      onBack: onBack,
      title: AppStrings.payRidePayment,
      bottom: UnifiedButton(
        label: AppStrings.payContinue,
        onPressed: onContinue,
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          SizedBox(height: context.h(8)),
          const PaymentBadge(check: true),
          SizedBox(height: context.h(12)),
          Text(
            AppStrings.payConfirmed,
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(fontSize: 18),
          ),
          SizedBox(height: context.h(4)),
          Text(
            AppStrings.payConfirmedHint,
            textAlign: TextAlign.center,
            style: AppTypography.regular.copyWith(
              fontSize: 12,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(8)),
          Text(
            rupee2(collected),
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(fontSize: 30),
          ),
          if (r.outstanding == 0)
            Text(
              AppStrings.payPaymentSuccessful,
              textAlign: TextAlign.center,
              style: AppTypography.regular.copyWith(
                fontSize: 13,
                color: paymentGreen,
              ),
            ),
          PaymentSectionTitle(AppStrings.payPaymentDetails),
          PaymentCard(
            children: [
              PaymentRow(label: AppStrings.payRiderId, value: riderId),
              PaymentRow(label: AppStrings.payMethod, value: _method),
              PaymentRow(label: AppStrings.payStatus, value: _status),
              PaymentRow(
                label: AppStrings.payRideDistance,
                value: distanceLabel,
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
                    AppStrings.payBreakdown,
                    style: AppTypography.bold.copyWith(fontSize: 14),
                  ),
                ),
              ),
              PaymentRow(
                label: AppStrings.payAmountPaid,
                value: rupee(collected + r.change),
              ),
              if (r.change > 0)
                PaymentRow(
                  label: AppStrings.payChangeToRider,
                  value: rupee(r.change),
                ),
              if (r.outstanding > 0)
                PaymentRow(
                  label: AppStrings.payOutstanding,
                  value: rupee(r.outstanding),
                  valueColor: paymentRed,
                ),
            ],
          ),
          SizedBox(height: context.h(12)),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.payYourEarning,
                  style: AppTypography.bold.copyWith(
                    fontSize: 15,
                    color: paymentGreen,
                  ),
                ),
              ),
              Text(
                rupee(earning),
                style: AppTypography.bold.copyWith(
                  fontSize: 15,
                  color: paymentGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
