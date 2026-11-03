import 'package:flutter/material.dart';

import 'package:rider_app/driver_features/coins/models/coin_models.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/status_result.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/coins/widgets/coin_tiles.dart';

class RewardCreditedScreen extends StatelessWidget {
  const RewardCreditedScreen({
    super.key,
    required this.claim,
    required this.onBack,
    required this.onContinue,
  });

  final ScratchClaim? claim;

  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return StatusResult(
      onBack: onBack,
      celebration: true,
      icon: Image.asset(
        AppAssets.rewardCoins,
        width: context.w(120),
        height: context.w(120),
      ),
      title: 'Reward Credited',
      subtitle:
          'You have received ${claim?.coinsAwarded ?? 0} coins from scratch card reward',
      button: UnifiedButton(
        label: AppStrings.continueAction,
        onPressed: onContinue,
      ),
      child: Column(
        children: [
          CoinInfoTile(
            icon: Icons.directions_car_filled_rounded,
            color: Color(0xFF7C3AED),
            background: Color(0xFFF3E8FF),
            title: 'Scratch Card',
            subtitle: claim?.cardId ?? '',
          ),
          SizedBox(height: context.h(10)),
          CoinInfoTile(
            icon: Icons.toll_rounded,
            color: Color(0xFFF59E0B),
            background: Color(0xFFFEF3C7),
            title: 'New Coin Balance',
            subtitle: '${claim?.newBalance ?? 0}',
          ),
        ],
      ),
    );
  }
}
