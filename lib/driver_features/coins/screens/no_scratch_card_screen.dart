import 'package:flutter/material.dart';

import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/coins/widgets/coin_result.dart';
import 'package:rider_app/driver_features/coins/widgets/coins_text.dart';
import 'package:rider_app/driver_features/coins/widgets/how_it_works_card.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class NoScratchCardScreen extends StatelessWidget {
  const NoScratchCardScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Scratch Card',
      onBack: onBack,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(12),
          context.w(20),
          context.h(20),
        ),
        children: [
          const CoinGiftMark(
            icon: Icons.close_rounded,
            color: Color(0xFFEF4444),
          ),
          Text(
            'No Scratch Card Available',
            textAlign: TextAlign.center,
            style: coinsTitle(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(16)),
            child: Text(
              "You'll get a scratch card after completing an eligible job. One eligible job gives you one scratch card as per reward rules.",
              textAlign: TextAlign.center,
              style: coinsMuted(context),
            ),
          ),
          SizedBox(height: context.h(18)),
          const HowItWorksCard(),
        ],
      ),
    );
  }
}
