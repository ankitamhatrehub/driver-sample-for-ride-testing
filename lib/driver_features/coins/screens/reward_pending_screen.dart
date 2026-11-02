import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/coins/widgets/coins_text.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class RewardPendingScreen extends StatelessWidget {
  const RewardPendingScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Scratch Card',
      onBack: onBack,
      child: Column(
        children: [
          const Spacer(),
          Image.asset(
            AppAssets.rewardPending,
            width: context.w(140),
            height: context.w(140),
          ),
          SizedBox(height: context.h(16)),
          Text('Reward is Pending', style: coinsTitle()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(36)),
            child: Text(
              'Your reward will be credited soon. This may take a few moments',
              textAlign: TextAlign.center,
              style: coinsMuted(context),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
