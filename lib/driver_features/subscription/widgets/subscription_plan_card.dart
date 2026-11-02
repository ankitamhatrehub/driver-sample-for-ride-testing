import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_text.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class SubscriptionPlanCard extends StatelessWidget {
  const SubscriptionPlanCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.trailing,
    this.subtitleColor,
    this.footer,
  });

  final String name;
  final String subtitle;
  final Widget? trailing;
  final Color? subtitleColor;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(14)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                AppAssets.goldCrown,
                width: context.w(34),
                height: context.w(34),
                fit: BoxFit.contain,
              ),
              SizedBox(width: context.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.bold.copyWith(
                        fontSize: 12,
                        height: 1.2,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.regular.copyWith(
                        fontSize: 11,
                        color:
                            subtitleColor ??
                            context.legible(AppColors.slate500),
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          if (footer != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(10)),
              child: Divider(height: 1, color: context.torkk.border),
            ),
            footer!,
          ],
        ],
      ),
    );
  }
}

class SubscriptionAmountBlock extends StatelessWidget {
  const SubscriptionAmountBlock({super.key, required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Plan Amount', style: subscriptionMuted(context)),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '₹$amount',
            style: AppTypography.bold.copyWith(
              fontSize: 16,
              height: 1.3,
              letterSpacing: -0.3,
            ),
          ),
        ),
        SizedBox(height: context.h(8)),
        const Row(
          children: [
            Expanded(
              child: SubscriptionDateColumn('Activation Date', '20 Aug 2026'),
            ),
            Expanded(
              child: SubscriptionDateColumn('Expiry Date', '20 Aug 2027'),
            ),
          ],
        ),
      ],
    );
  }
}

class SubscriptionDateColumn extends StatelessWidget {
  const SubscriptionDateColumn(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: subscriptionMuted(context)),
        Text(
          value,
          style: AppTypography.regular.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class SubscriptionInfoRow extends StatelessWidget {
  const SubscriptionInfoRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Text(label, style: subscriptionMuted(context)),
          Text(
            value,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionStatusChip extends StatelessWidget {
  const SubscriptionStatusChip({
    super.key,
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF16A34A) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.regular.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
