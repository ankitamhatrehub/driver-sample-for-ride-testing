import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_feedback.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_page.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_plan_card.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_text.dart';

class CurrentPlanScreen extends StatelessWidget {
  const CurrentPlanScreen({
    super.key,
    required this.active,
    required this.onBack,
    required this.onRenew,
  });

  final bool active;
  final VoidCallback onBack;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Subscription',
      onBack: onBack,
      bottom: active ? null : SubscriptionButton(label: 'Renew Plan', onTap: onRenew),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
        children: [
          Text('Current Plan', style: subscriptionMuted(context)),
          SizedBox(height: context.h(8)),
          SubscriptionPlanCard(
            name: 'CAB EV- Weekly',
            subtitle: active ? 'Valid for 7 days' : 'Your plan expired on 24 Aug 2027',
            subtitleColor: active ? AppColors.slate500 : const Color(0xFFEF4444),
            trailing: SubscriptionStatusChip(label: active ? 'Active' : 'Expired', active: active),
            footer: const SubscriptionAmountBlock(amount: 499),
          ),
          if (!active) ...[
            SizedBox(height: context.h(14)),
            const SubscriptionWarningBox(
              title: 'Your Plan has expired',
              body: 'You may receive fewer rides and parcel requests, No access to high-demand zones.',
            ),
          ],
        ],
      ),
    );
  }
}
