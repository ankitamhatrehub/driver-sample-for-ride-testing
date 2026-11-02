import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Reusable row containing Incentives card and Driver Rating card.
class HomeMetricsRow extends StatelessWidget {
  final double incentives;
  final double driverRating;
  final VoidCallback? onIncentivesTap;

  const HomeMetricsRow({
    super.key,
    required this.incentives,
    required this.driverRating,
    this.onIncentivesTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = context.themed(
      light: const Color(0xFF111827),
      dark: context.torkk.textPrimary,
    );
    final subtextColor = context.themed(
      light: const Color(0xFF6B7280),
      dark: context.torkk.textSecondary,
    );
    final cardBg = context.torkk.surface;
    final borderColor = context.themed(
      light: const Color(0xFFE5E7EB),
      dark: context.torkk.border,
    );

    return Row(
      children: [
        // Incentives Card
        Expanded(
          child: GestureDetector(
            onTap: onIncentivesTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Incentives',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹ ${incentives.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Rating Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Rating',
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      driverRating.toStringAsFixed(1),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFEAB308), // Yellow Star
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
