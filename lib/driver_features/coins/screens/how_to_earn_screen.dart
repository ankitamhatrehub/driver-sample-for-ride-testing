import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/coins/widgets/coins_text.dart';
import 'package:rider_app/driver_features/coins/widgets/how_it_works_card.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

import '../../../common/constants/string_constants.dart';

class HowToEarnScreen extends StatelessWidget {
  const HowToEarnScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.howToEarnCoins,
      onBack: onBack,
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(12), context.w(20), context.h(20)),
        children: [
          SizedBox(
            height: context.h(160),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    1, 0, 0, 0, 0,
                    0, 1, 0, 0, 0,
                    0, 0, 1, 0, 0,
                    1, 1, 1, 0, 0,
                  ]),
                  child: Image.asset(
                    AppAssets.celebration,
                    width: context.w(220),
                    fit: BoxFit.contain,
                  ),
                ),
                Image.asset(AppAssets.giftCard, width: context.w(110), height: context.w(110)),
              ],
            ),
          ),
          Text(AppStrings.earnTorkkCoins, textAlign: TextAlign.center, style: coinsTitle()),
          SizedBox(height: context.h(6)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(48)),
            child: Text(
              AppStrings.completeRidesDeliveriesToEarnCoins,
              textAlign: TextAlign.center,
              style: coinsMuted(context),
            ),
          ),
          SizedBox(height: context.h(22)),
          const HowItWorksCard(showTitle: false),
        ],
      ),
    );
  }
}
