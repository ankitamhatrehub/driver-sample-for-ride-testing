import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_feedback.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_page.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_text.dart';

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({
    super.key,
    required this.onRetry,
    required this.onChangeMethod,
    required this.onBack,
  });

  final VoidCallback onRetry;
  final VoidCallback onChangeMethod;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return SubscriptionPage(
      onBack: onBack,
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(context.w(20), 0, context.w(20), context.h(16)),
        child: Column(
          children: [
            SubscriptionButton(label: 'Retry Payment', onTap: onRetry, padded: false),
            SizedBox(height: context.h(10)),
            SizedBox(
              width: double.infinity,
              height: context.h(48),
              child: OutlinedButton(
                onPressed: onChangeMethod,
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
                ),
                child: Text(
                  'Change Payment Method',
                  style: AppTypography.bold.copyWith(fontSize: 15, height: 1, color: accent),
                ),
              ),
            ),
          ],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          SizedBox(height: context.h(28)),
          const SubscriptionAlertBadge(color: Color(0xFFEF4444), halo: Color(0xFFFEE2E2)),
          SizedBox(height: context.h(16)),
          Text('Payment Failed', textAlign: TextAlign.center, style: subscriptionTitle()),
          SizedBox(height: context.h(6)),
          Text(
            "We couldn't process your payment.\nPlease try again",
            textAlign: TextAlign.center,
            style: subscriptionMuted(context),
          ),
          SizedBox(height: context.h(18)),
          const SubscriptionWarningBox(
            title: 'Reason',
            body: 'Payment was declined by your bank. Please try again or use a different payment method',
          ),
        ],
      ),
    );
  }
}
