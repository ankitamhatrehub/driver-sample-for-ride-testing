import 'package:flutter/material.dart';

import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_feedback.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_page.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_text.dart';

import '../../../common/constants/string_constants.dart';

class ExpiredGateScreen extends StatelessWidget {
  const ExpiredGateScreen({
    super.key,
    required this.onBack,
    required this.onRecharge,
  });

  final VoidCallback onBack;
  final VoidCallback onRecharge;

  @override
  Widget build(BuildContext context) {
    return SubscriptionPage(
      onBack: onBack,
      bottom: SubscriptionButton(
        label: AppStrings.rechargeNow,
        onTap: onRecharge,
      ),
      child: Column(
        children: [
          const Spacer(),
          const SubscriptionAlertBadge(
            color: Color(0xFFEF4444),
            halo: Color(0xFFFEE2E2),
          ),
          SizedBox(height: context.h(36)),
          Text(AppStrings.planExpiredTitle, style: subscriptionTitle()),
          SizedBox(height: context.h(4)),
          Text(
            AppStrings.planExpiredSubtitle,
            textAlign: TextAlign.center,
            style: subscriptionMuted(context),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
