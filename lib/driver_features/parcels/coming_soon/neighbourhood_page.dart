import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/widgets/instagram_link.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/coming_soon_text.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/fill.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/gradient_line.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/hero_image.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/notify_button.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/service_chips.dart';

class NeighbourhoodPage extends StatelessWidget {
  final bool notified;
  final VoidCallback onNotify;
  final VoidCallback? onChangeLocation;

  const NeighbourhoodPage({
    super.key,
    required this.notified,
    required this.onNotify,
    this.onChangeLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Fill(
      children: [
        const SizedBox(height: 16),
        const GradientLine('Coming Soon'),
        Text(
          'to your',
          textAlign: TextAlign.center,
          style: Inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: context.legible(AppColors.primary),
          ),
        ),
        const GradientLine('Neighbourhood'),
        const SizedBox(height: 12),
        Text(
          "We're expanding soon. Be the first to\nknow when Torkk arrives on your area.",
          textAlign: TextAlign.center,
          style: Inter(
            fontSize: 14,
            height: 1.45,
            color: const Color(0xFF8B909C),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        const ServiceChips(),
        const Spacer(),
        HeroImage(
          'scooter_hero',
          height: 195,
          fallback: Icons.two_wheeler_rounded,
        ),
        const Spacer(),
        NotifyButton(
          label: notified
              ? "You're on the list"
              : 'Notify me when Torkk launches',
          icon: notified ? Icons.check_rounded : Icons.notifications_rounded,
          onPressed: notified ? null : onNotify,
        ),
        const SizedBox(height: 25),
        const InstagramLink(),
       const SizedBox(height: 16),
      ],
    );
  }
}
