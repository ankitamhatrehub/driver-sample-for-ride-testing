import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Floating card displaying real-time GPS speed in km/h.
class SpeedometerWidget extends StatelessWidget {
  final int speedKmH;

  const SpeedometerWidget({
    super.key,
    required this.speedKmH,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$speedKmH',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: context.torkk.textPrimary,
              height: 1.1,
            ),
          ),
          Text(
            'km/h',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.torkk.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
