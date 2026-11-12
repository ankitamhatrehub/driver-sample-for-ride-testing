import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/rides/payment/payment_widgets.dart';

enum PaymentSettle { wallet, cashReturned, upi }

/// Step 2: cash received, change to return and any outstanding amount.
class PaymentCashPage extends StatelessWidget {
  const PaymentCashPage({
    super.key,
    required this.upiPaid,
    required this.due,
    required this.riderId,
    required this.received,
    required this.settle,
    required this.carryAgreed,
    required this.onChanged,
    required this.onSettle,
    required this.onCarry,
    required this.onConfirm,
    required this.onBack,
  });

  final double upiPaid;
  final double due;
  final String riderId;
  final TextEditingController received;
  final PaymentSettle? settle;
  final bool carryAgreed;
  final VoidCallback onChanged;
  final ValueChanged<PaymentSettle> onSettle;
  final VoidCallback onCarry;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(received.text.trim()) ?? 0;
    final change = amount > due ? amount - due : 0.0;
    final short = amount < due ? due - amount : 0.0;
    final collected = upiPaid + (amount > due ? due : amount);
    final canConfirm =
        amount > 0 &&
        (change == 0 || settle != null) &&
        (short == 0 || carryAgreed);

    return PaymentScaffold(
      onBack: onBack,
      title: AppStrings.payPaymentConfirmation,
      bottom: UnifiedButton(
        label: AppStrings.payConfirmCash,
        enabled: canConfirm,
        onPressed: onConfirm,
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          SizedBox(height: context.h(8)),
          PaymentAmountHeader(
            label: AppStrings.payTotalCollected,
            amount: collected,
            sub: '${AppStrings.payRiderId}:  $riderId',
          ),
          PaymentSectionTitle(AppStrings.payCashCollection),
          PaymentCard(
            children: [
              _receivedRow(context),
              PaymentRow(
                label: AppStrings.payChangeReturned,
                value: rupee(change),
              ),
              PaymentRow(
                label: AppStrings.payCashOutstanding,
                value: rupee(short),
              ),
            ],
          ),
          SizedBox(height: context.h(10)),
          PaymentRow(
            label: AppStrings.payNetCollection,
            value: rupee(collected),
            bold: true,
          ),
          if (change > 0) ..._settlement(context, change),
          if (short > 0) ..._carry(context, short),
        ],
      ),
    );
  }

  Widget _receivedRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(6)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.payCashReceived,
              style: AppTypography.regular.copyWith(
                fontSize: 14,
                color: context.torkk.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: context.w(110),
            child: TextField(
              controller: received,
              textAlign: TextAlign.end,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                prefixText: '₹',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _settlement(BuildContext context, double change) {
    return [
      PaymentSectionTitle(AppStrings.payChangeSettlement),
      PaymentChoice(
        label: AppStrings.payCreditWallet(rupee(change)),
        selected: settle == PaymentSettle.wallet,
        onTap: () => onSettle(PaymentSettle.wallet),
      ),
      PaymentChoice(
        label: AppStrings.payCashReturnedNow,
        selected: settle == PaymentSettle.cashReturned,
        onTap: () => onSettle(PaymentSettle.cashReturned),
      ),
      PaymentChoice(
        label: AppStrings.payUpiMadeNow,
        selected: settle == PaymentSettle.upi,
        onTap: () => onSettle(PaymentSettle.upi),
      ),
      Padding(
        padding: EdgeInsets.only(top: context.h(8)),
        child: Text(
          AppStrings.payChangeWalletNote,
          style: AppTypography.regular.copyWith(
            fontSize: 12,
            color: context.brandColor,
          ),
        ),
      ),
    ];
  }

  List<Widget> _carry(BuildContext context, double short) {
    return [
      PaymentSectionTitle(AppStrings.payRemainingAmount),
      Text(
        rupee(short),
        style: AppTypography.bold.copyWith(fontSize: 16, color: paymentRed),
      ),
      SizedBox(height: context.h(10)),
      Text(
        AppStrings.payCarryTitle,
        style: AppTypography.bold.copyWith(fontSize: 13),
      ),
      Text(
        AppStrings.payCarryHint,
        style: AppTypography.regular.copyWith(
          fontSize: 12,
          color: context.torkk.textSecondary,
        ),
      ),
      SizedBox(height: context.h(8)),
      InkWell(
        onTap: onCarry,
        child: Row(
          children: [
            Icon(
              carryAgreed
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: carryAgreed
                  ? context.brandColor
                  : context.torkk.textDisabled,
            ),
            SizedBox(width: context.w(8)),
            Expanded(
              child: Text(
                AppStrings.payRiderAgrees(rupee(short)),
                style: AppTypography.regular.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
