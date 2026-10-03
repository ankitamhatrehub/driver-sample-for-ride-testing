import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/subscription/models/subscription_plan.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_text.dart';

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.asset,
  });

  final PayMethod method;
  final bool selected;
  final String title;
  final String subtitle;
  final ValueChanged<PayMethod> onTap;
  final IconData? icon;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return GestureDetector(
      onTap: () => onTap(method),
      child: Container(
        margin: EdgeInsets.only(bottom: context.h(10)),
        padding: EdgeInsets.all(context.w(12)),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(context.r(14)),
          border: Border.all(
            color: selected ? accent : const Color(0xFFE8EDF5),
          ),
        ),
        child: Row(
          children: [
            if (asset != null)
              Image.asset(
                asset!,
                width: context.w(36),
                height: context.w(36),
                fit: BoxFit.contain,
              )
            else
              Container(
                width: context.w(36),
                height: context.w(36),
                decoration: BoxDecoration(
                  color: selected ? accent.withValues(alpha: 0.12) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(context.r(10)),
                ),
                child: Icon(
                  icon,
                  color: selected ? accent : const Color(0xFFF59E0B),
                  size: context.w(18),
                ),
              ),
            SizedBox(width: context.w(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.regular.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(subtitle, style: subscriptionMuted()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
