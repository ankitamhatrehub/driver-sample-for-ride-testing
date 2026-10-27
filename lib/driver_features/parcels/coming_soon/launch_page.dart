import 'package:flutter/material.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/coming_soon_text.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/fill.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/gradient_line.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/hero_image.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/notify_button.dart';

class LaunchPage extends StatelessWidget {
  final VoidCallback onNotify;
  const LaunchPage({super.key, required this.onNotify});

  @override
  Widget build(BuildContext context) {
    return Fill(
      children: [
        const SizedBox(height: 12),
        HeroImage(
          'gift_box',
          height: 190,
          fallback: Icons.card_giftcard_rounded,
        ),
        const SizedBox(height: 18),
        const GradientLine('Coming Soon', size: 34),
        const Spacer(),
        HeroImage(
          'share_hero',
          height: 180,
          fallback: Icons.ios_share_rounded,
        ),
        const Spacer(),
        NotifyButton(
          label: 'Notify Me',
          icon: Icons.notifications_rounded,
          onPressed: onNotify,
        ),
        const SizedBox(height: 10),
        Text(
          'Be the first to know when it is live.',
          style: Inter(
            color: const Color(0xFF8B909C),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
