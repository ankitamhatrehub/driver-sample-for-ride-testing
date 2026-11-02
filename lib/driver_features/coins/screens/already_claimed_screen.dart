import 'package:flutter/material.dart';

import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/coins/widgets/coin_bottom_button.dart';
import 'package:rider_app/driver_features/coins/widgets/coin_result.dart';
import 'package:rider_app/driver_features/coins/widgets/coins_text.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class AlreadyClaimedScreen extends StatelessWidget {
  const AlreadyClaimedScreen({
    super.key,
    required this.onBack,
    required this.onTryAgain,
  });

  final VoidCallback onBack;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: '',
      onBack: onBack,
      bottom: CoinBottomButton(label: 'Try Again', onPressed: onTryAgain),
      child: Column(
        children: [
          const Spacer(),
          const CoinGiftMark(
            icon: Icons.check_rounded,
            color: Color(0xFF16A34A),
          ),
          Text(
            'Already Claimed Reward',
            textAlign: TextAlign.center,
            style: coinsTitle(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(28)),
            child: Text(
              'You have already claimed a reward for this job. Each eligible job will give you only one scratch card',
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
