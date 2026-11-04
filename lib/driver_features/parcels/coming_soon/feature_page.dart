import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/coming_soon_text.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/feature_card.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/fill.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/gradient_line.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/hero_image.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/notify_button.dart';

class FeaturePage extends StatelessWidget {
  final VoidCallback onNotify;
  const FeaturePage({super.key, required this.onNotify});

  @override
  Widget build(BuildContext context) {
    return Fill(
      children: [
        const SizedBox(height: 8),
        HeroImage(
          'gift_box',
          height: 168,
          fallback: Icons.card_giftcard_rounded,
        ),
        const SizedBox(height: 8),
        Text(
          'New Feature',
          textAlign: TextAlign.center,
          style: Inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: context.legible(AppColors.primary),
          ),
        ),
        const GradientLine('Coming Soon', size: 30),
        const SizedBox(height: 8),
        Text(
          "We're working on something exciting to\nbring a better experience.",
          textAlign: TextAlign.center,
          style: Inter(
            fontSize: 14,
            height: 1.4,
            color: const Color(0xFF8B909C),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        const FeatureCard(),
        const Spacer(),
        NotifyButton(
          label: 'Notify Me',
          icon: Icons.notifications_rounded,
          onPressed: onNotify,
        ),
        const SizedBox(height: 10),
        const Text(
          'Be the first to know when it is live.',
          style: TextStyle(
            color: Color(0xFF8B909C),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
