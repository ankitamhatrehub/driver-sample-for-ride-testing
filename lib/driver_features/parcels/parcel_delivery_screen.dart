import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Shown on the Parcel tab until the driver is eligible for parcel requests.
class ParcelDeliveryScreen extends StatelessWidget {
  const ParcelDeliveryScreen({super.key, required this.onBack, required this.onContinue});

  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(context.w(8), context.h(4), context.w(16), 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: Icon(Icons.arrow_back_ios_new, size: 18, color: context.torkk.textPrimary),
                  ),
                  Text(
                    AppStrings.parcelDelivery,
                    style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2, letterSpacing: -0.3),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(context.w(28), context.h(12), context.w(28), context.h(12)),
                children: [
                  Center(
                    child: Image.asset(
                      AppAssets.parcel,
                      width: context.w(220),
                      height: context.w(220),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: context.h(8)),
                  Text(
                    AppStrings.unlockParcelTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.bold.copyWith(fontSize: 22, height: 1.25, letterSpacing: -0.4),
                  ),
                  SizedBox(height: context.h(8)),
                  Text(
                    AppStrings.unlockParcelSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.regular.copyWith(fontSize: 14, height: 1.4, color: context.torkk.textSecondary),
                  ),
                  SizedBox(height: context.h(22)),
                  _StepsCard(accent: accent),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(context.w(28), context.h(8), context.w(28), context.h(12)),
              child: SizedBox(
                width: double.infinity,
                height: context.h(52),
                child: FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
                  ),
                  child: Text(
                    AppStrings.continueAction,
                    style: AppTypography.bold.copyWith(fontSize: 16, height: 1.2, color: Theme.of(context).colorScheme.onPrimary, letterSpacing: -0.2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _Step(Icons.home_rounded, AppStrings.completeEarningTasks, AppStrings.completeEarningTasksHint, false),
       _Step(Icons.monetization_on_rounded, AppStrings.collect100Coins, AppStrings.collect100CoinsHint, true),
       _Step(Icons.inventory_2_rounded, AppStrings.startDeliveringParcels, AppStrings.startDeliveringParcelsHint, false),
    ];
    return Container(
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            _StepRow(step: steps[i], accent: accent, showDivider: i > 0),
        ],
      ),
    );
  }
}

class _Step {
  const _Step(this.icon, this.title, this.subtitle, this.coin);

  final IconData icon;
  final String title;
  final String subtitle;
  final bool coin;
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.accent, required this.showDivider});

  final _Step step;
  final Color accent;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final iconColor = step.coin ? const Color(0xFFF59E0B) : accent;
    final iconBackground = step.coin ? const Color(0xFFFEF3C7) : accent.withValues(alpha: 0.1);
    return Container(
      height: context.h(64),
      padding: EdgeInsets.symmetric(horizontal: context.w(14)),
      decoration: BoxDecoration(
        border: showDivider ? Border(top: BorderSide(color: context.torkk.border)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: context.w(36),
            height: context.w(36),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: Icon(step.icon, color: iconColor, size: context.w(18)),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bold.copyWith(fontSize: 14, height: 1.15, letterSpacing: -0.2),
                ),
                Text(
                  step.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.regular.copyWith(fontSize: 12, height: 1.2, color: context.torkk.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
