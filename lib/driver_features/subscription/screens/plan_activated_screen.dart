import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/subscription/models/subscription_plan.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_page.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_plan_card.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_text.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class PlanActivatedScreen extends StatelessWidget {
  const PlanActivatedScreen({
    super.key,
    required this.plan,
    required this.onBack,
  });

  final SubscriptionPlan plan;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SubscriptionPage(
      onBack: onBack,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          SizedBox(height: context.h(24)),
          Center(
            child: Container(
              width: context.w(72),
              height: context.w(72),
              decoration: BoxDecoration(
                color: context.adaptiveTint(Color(0xFFDCFCE7)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: context.legible(Color(0xFF16A34A)),
                size: context.w(36),
              ),
            ),
          ),
          SizedBox(height: context.h(16)),
          Text(
            'Plan Activated',
            textAlign: TextAlign.center,
            style: subscriptionTitle(),
          ),
          SizedBox(height: context.h(6)),
          Text(
            'Your CAB EV Plan is now active. You can start accepting rides and parcels',
            textAlign: TextAlign.center,
            style: subscriptionMuted(context),
          ),
          SizedBox(height: context.h(18)),
          SubscriptionPlanCard(
            name: plan.name.replaceAll(' - ', '- '),
            subtitle: plan.validity,
            trailing: Text(
              '₹ ${plan.price}',
              style: AppTypography.bold.copyWith(
                fontSize: 16,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
          ),
          SizedBox(height: context.h(16)),
          Text(
            'Plan Benefits',
            style: AppTypography.regular.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.h(8)),
          Container(
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              color: context.torkk.surfaceMuted,
              borderRadius: BorderRadius.circular(context.r(16)),
            ),
            child: Column(
              children: [
                for (final benefit in subscriptionBenefits)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: context.h(4)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: const Color(0xFF16A34A),
                          size: context.w(16),
                        ),
                        SizedBox(width: context.w(8)),
                        Expanded(
                          child: Text(
                            benefit,
                            style: subscriptionMuted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
