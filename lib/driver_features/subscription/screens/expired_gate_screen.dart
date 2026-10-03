import 'package:flutter/material.dart';

import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_feedback.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_page.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_text.dart';

class ExpiredGateScreen extends StatelessWidget {
  const ExpiredGateScreen({super.key, required this.onBack, required this.onRecharge});

  final VoidCallback onBack;
  final VoidCallback onRecharge;

  @override
  Widget build(BuildContext context) {
    return SubscriptionPage(
      onBack: onBack,
      bottom: SubscriptionButton(label: 'Recharge Now', onTap: onRecharge),
      child: Column(
        children: [
          const Spacer(),
          const SubscriptionAlertBadge(color: Color(0xFFEF4444), halo: Color(0xFFFEE2E2)),
          SizedBox(height: context.h(36)),
          Text('Your Plan has Expired', style: subscriptionTitle()),
          SizedBox(height: context.h(4)),
          Text(
            'Your CAB EV Plan has expired on 20 April 2026.\nRecharge now to continue getting benefits',
            textAlign: TextAlign.center,
            style: subscriptionMuted(),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
