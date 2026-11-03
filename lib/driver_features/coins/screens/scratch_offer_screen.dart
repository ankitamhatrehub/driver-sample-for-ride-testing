import 'package:flutter/material.dart';

import 'package:rider_app/driver_features/coins/models/coin_models.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/coins/widgets/how_it_works_card.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class ScratchOfferScreen extends StatelessWidget {
  const ScratchOfferScreen({
    super.key,
    required this.card,
    required this.onBack,
    required this.onScratch,
  });

  final ScratchCard? card;

  final VoidCallback onBack;
  final VoidCallback onScratch;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Scratch Card',
      onBack: onBack,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(20),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: context.h(18)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(18)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.adaptiveTint(Color(0xFFF5F3FF)),
                  context.torkk.surface,
                ],
              ),
            ),
            child: Column(
              children: [
                Image.asset(
                  AppAssets.giftCard,
                  width: context.w(140),
                  height: context.w(140),
                ),
                SizedBox(height: context.h(12)),
                Text(
                  (card?.title ?? '').isEmpty ? 'Scratch Card' : card!.title,
                  style: AppTypography.bold.copyWith(
                    fontSize: 16,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: context.h(4)),
                Text(
                  (card?.description ?? '').isEmpty
                      ? 'Win up to 500 coins, discounts'
                      : card!.description,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    color: context.torkk.textSecondary,
                  ),
                ),
                SizedBox(height: context.h(20)),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.w(16),
                    context.h(8),
                    context.w(16),
                    0,
                  ),
                  child: UnifiedButton(
                    label: 'Scratch Now',
                    onPressed: onScratch,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(16)),
          const HowItWorksCard(),
        ],
      ),
    );
  }
}
