import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_text.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class SubscriptionWarningBox extends StatelessWidget {
  const SubscriptionWarningBox({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(12)),
      decoration: BoxDecoration(
        color: context.adaptiveTint(const Color(0xFFFFF1F2)),
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bold.copyWith(
              color: context.torkk.textPrimary,
              fontSize: 13,
              height: 1.2,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: context.h(6)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.cancel,
                color: context.legible(Color(0xFFEF4444)),
                size: 16,
              ),
              SizedBox(width: context.w(8)),
              Expanded(
                child: Text(
                  body,
                  style: subscriptionMuted(
                    context,
                  ).copyWith(color: context.torkk.textBody),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SubscriptionAlertBadge extends StatelessWidget {
  const SubscriptionAlertBadge({
    super.key,
    required this.color,
    required this.halo,
  });

  final Color color;
  final Color halo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: context.w(100),
        height: context.w(100),
        decoration: BoxDecoration(color: halo, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Container(
          width: context.w(70),
          height: context.w(70),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const Icon(Icons.priority_high_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
