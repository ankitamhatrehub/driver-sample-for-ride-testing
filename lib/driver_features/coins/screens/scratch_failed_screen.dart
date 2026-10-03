import 'package:flutter/material.dart';

import 'package:rider_app/driver_features/coins/widgets/coin_result.dart';

class ScratchFailedScreen extends StatelessWidget {
  const ScratchFailedScreen({super.key, required this.onBack, required this.onTryAgain});

  final VoidCallback onBack;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return CoinResultPage(
      badge: true,
      title: "Couldn't reveal your reward",
      body: 'We are facing a temporary issue. Please try again later',
      button: 'Try Again',
      onTap: onTryAgain,
      onBack: onBack,
    );
  }
}
