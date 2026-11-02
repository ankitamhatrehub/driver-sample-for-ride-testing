import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/feature_row.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.themed(
            light: const Color(0xFFE7E4EF),
            dark: context.torkk.border,
          ),
        ),
      ),
      child: Column(
        children: [
          FeatureRow(
            icon: Icons.monetization_on_rounded,
            iconColor: Color(0xFFF5B400),
            iconBackground: Color(0xFFFFF4D8),
            label: 'More Earning Opportunities',
          ),
          Divider(
            height: 1,
            color: context.themed(
              light: const Color(0xFFEDEAF2),
              dark: context.torkk.divider,
            ),
          ),
          FeatureRow(
            icon: Icons.card_giftcard_rounded,
            iconColor: Color(0xFF7A3EAF),
            iconBackground: Color(0xFFF4EEFF),
            label: 'Exciting New Features',
          ),
          Divider(
            height: 1,
            color: context.themed(
              light: const Color(0xFFEDEAF2),
              dark: context.torkk.divider,
            ),
          ),
          FeatureRow(
            icon: Icons.bookmark_rounded,
            iconColor: Color(0xFF7A3EAF),
            iconBackground: Color(0xFFF4EEFF),
            label: 'Better Experience',
          ),
        ],
      ),
    );
  }
}
