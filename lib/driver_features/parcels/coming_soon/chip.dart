import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const Chip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: context.themed(
            light: const Color(0xFFE6E1EE),
            dark: context.torkk.border,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1A1030),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: context.themed(
              light: const Color(0xFF5C6570),
              dark: context.torkk.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: context.torkk.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
