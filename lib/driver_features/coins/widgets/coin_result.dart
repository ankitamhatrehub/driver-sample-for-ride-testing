import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/coins/widgets/coin_bottom_button.dart';
import 'package:rider_app/driver_features/coins/widgets/coins_text.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class CoinConfettiImage extends StatelessWidget {
  const CoinConfettiImage({super.key, required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    const bits = [
      (Color(0xFF60A5FA), -50.0, -8.0),
      (Color(0xFFF59E0B), 52.0, -12.0),
      (Color(0xFFA78BFA), -36.0, 28.0),
      (Color(0xFF34D399), 40.0, 24.0),
      (Color(0xFFF472B6), 6.0, -40.0),
    ];
    return SizedBox(
      width: context.w(size + 40),
      height: context.w(size + 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final bit in bits)
            Transform.translate(
              offset: Offset(context.w(bit.$2), context.h(bit.$3)),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: bit.$1, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          Image.asset(asset, width: context.w(size), height: context.w(size)),
        ],
      ),
    );
  }
}

class CoinGiftMark extends StatelessWidget {
  const CoinGiftMark({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: context.w(150),
          height: context.w(150),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(AppAssets.giftCard, width: context.w(130), height: context.w(130)),
              Positioned(
                right: context.w(18),
                bottom: context.h(28),
                child: Container(
                  width: context.w(22),
                  height: context.w(22),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Icon(icon, color: Colors.white, size: context.w(14)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CoinResultPage extends StatelessWidget {
  const CoinResultPage({
    super.key,
    required this.title,
    required this.body,
    required this.button,
    required this.onTap,
    required this.onBack,
    this.image,
    this.badge = false,
    this.confetti = false,
  });

  final String? image;
  final bool badge;
  final bool confetti;
  final String title;
  final String body;
  final String button;
  final VoidCallback onTap;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: '',
      onBack: onBack,
      bottom: CoinBottomButton(label: button, onPressed: onTap),
      child: Column(
        children: [
          const Spacer(),
          if (image != null)
            confetti
                ? CoinConfettiImage(asset: image!, size: 150)
                : Image.asset(image!, width: context.w(150), height: context.w(150)),
          if (badge)
            Container(
              width: context.w(72),
              height: context.w(72),
              decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Container(
                width: context.w(48),
                height: context.w(48),
                decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                child: const Icon(Icons.priority_high_rounded, color: Colors.white),
              ),
            ),
          SizedBox(height: context.h(16)),
          Text(title, textAlign: TextAlign.center, style: coinsTitle()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(32)),
            child: Text(body, textAlign: TextAlign.center, style: coinsMuted()),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
