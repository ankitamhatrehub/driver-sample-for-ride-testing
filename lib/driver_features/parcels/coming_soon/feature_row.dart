
import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;

  const FeatureRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.adaptiveTint(iconBackground),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: context.legible(iconColor), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: context.torkk.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
