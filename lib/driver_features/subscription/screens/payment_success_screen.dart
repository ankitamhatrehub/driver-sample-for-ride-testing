import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/status_result.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_plan_card.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key, required this.methodLabel, required this.onContinue, required this.onBack});

  final String methodLabel;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return StatusResult(
      onBack: onBack,
      celebration: true,
      icon: Container(
        width: context.w(88),
        height: context.w(88),
        decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Container(
          width: context.w(64),
          height: context.w(64),
          decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
          child: Icon(Icons.check_rounded, color: Colors.white, size: context.w(34)),
        ),
      ),
      title: 'Payment Successful',
      subtitle: 'Your Torkk pro plan is now Active',
      button: UnifiedButton(label: 'Go to Subscription', onPressed: onContinue),
      child: SubscriptionPlanCard(
        name: 'CAB EV- Weekly',
        subtitle: 'Valid for 7 days',
        trailing: Text(
          '₹ 499',
          style: AppTypography.bold.copyWith(fontSize: 16, height: 1.2, letterSpacing: -0.3),
        ),
        footer: Column(
          children: [
            SubscriptionInfoRow('Payment', methodLabel),
            const SubscriptionInfoRow('Transaction ID', '#222222'),
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(8)),
              child: const Row(
                children: [
                  Expanded(child: SubscriptionDateColumn('Activation Date', '20 Aug 2026')),
                  Expanded(child: SubscriptionDateColumn('Expiry Date', '20 Aug 2027')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
