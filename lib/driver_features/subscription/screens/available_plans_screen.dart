import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/subscription/models/subscription_plan.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_page.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_text.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class AvailablePlansScreen extends StatelessWidget {
  const AvailablePlansScreen({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onContinue,
    required this.onBack,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return ProfilePage(
      title: 'Subscription',
      onBack: onBack,
      bottom: SubscriptionButton(label: AppStrings.continueAction, onTap: onContinue),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(12)),
        children: [
          Text(
            'Available Plans',
            style: AppTypography.regular.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: context.h(10)),
          Container(
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              color: const Color(0xFFCFD9F2).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(context.r(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Plans Include',
                  style: AppTypography.bold.copyWith(fontSize: 12, height: 1.2, letterSpacing: -0.2),
                ),
                SizedBox(height: context.h(18)),
                for (final benefit in subscriptionBenefits)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: context.h(4)),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: const Color(0xFF16A34A), size: context.w(16)),
                        SizedBox(width: context.w(10)),
                        Expanded(child: Text(benefit, style: subscriptionMuted(context))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: context.h(18)),
          for (var i = 0; i < subscriptionPlans.length; i++) ...[
            GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                margin: EdgeInsets.only(bottom: context.h(10)),
                padding: EdgeInsets.all(context.w(14)),
                decoration: BoxDecoration(
                  color: selected == i ? accent.withValues(alpha: 0.06) : context.torkk.surface,
                  borderRadius: BorderRadius.circular(context.r(14)),
                  border: Border.all(
                    color: selected == i ? accent : const Color(0xFFE8EDF5),
                    width: selected == i ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        subscriptionPlans[i].name,
                        style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '₹ ${subscriptionPlans[i].price}',
                      style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2, letterSpacing: -0.2),
                    ),
                    Text(' / ${subscriptionPlans[i].unit}', style: subscriptionMuted(context)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
