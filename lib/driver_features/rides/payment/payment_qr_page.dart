import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/rides/payment/payment_widgets.dart';

/// Step 1: total amount and the QR the customer scans to pay by UPI.
class PaymentQrPage extends StatelessWidget {
  const PaymentQrPage({
    super.key,
    required this.total,
    required this.paymentId,
    required this.onBack,
    required this.onCollectCash,
    required this.onRetry,
    this.qrData,
    this.qrUrl,
    this.loading = false,
    this.error,
    this.onPartUpi,
  });

  final double total;
  final String paymentId;
  final VoidCallback onBack;
  final VoidCallback onCollectCash;
  final VoidCallback onRetry;

  /// Test-only shortcut for a part payment; null hides the button.
  final VoidCallback? onPartUpi;
  final String? qrData;
  final String? qrUrl;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return PaymentScaffold(
      onBack: onBack,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(24)),
        children: [
          SizedBox(height: context.h(8)),
          PaymentAmountHeader(label: AppStrings.payTotalAmount, amount: total),
          SizedBox(height: context.h(20)),
          Center(
            child: PaymentQrBlock(
              paymentId: paymentId,
              size: 220,
              qrData: qrData,
              imageUrl: qrUrl,
              loading: loading,
              error: error,
              onRetry: onRetry,
            ),
          ),
          SizedBox(height: context.h(18)),
          Text(
            AppStrings.payCollectPayment,
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(fontSize: 22),
          ),
          SizedBox(height: context.h(10)),
          Text(
            AppStrings.payScanQr,
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(fontSize: 15),
          ),
          SizedBox(height: context.h(4)),
          Text(
            AppStrings.payScanQrHint,
            textAlign: TextAlign.center,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(28)),
          if (qrData != null || qrUrl != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: context.w(16),
                  height: context.w(16),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: context.w(8)),
                Text(
                  AppStrings.payWaiting,
                  style: AppTypography.regular.copyWith(fontSize: 13),
                ),
              ],
            ),
          SizedBox(height: context.h(20)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCollectCash,
                  child: Text(AppStrings.payCollectCash),
                ),
              ),
              if (onPartUpi != null) ...[
                SizedBox(width: context.w(10)),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPartUpi,
                    child: Text(AppStrings.payPaidPartUpi),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
