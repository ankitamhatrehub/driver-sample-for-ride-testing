import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';

class CoinMoneyCard extends StatelessWidget {
  const CoinMoneyCard({super.key, required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.regular.copyWith(fontSize: 11, color: AppColors.slate500),
          ),
          SizedBox(height: context.h(6)),
          Text(
            value,
            style: AppTypography.bold.copyWith(
              fontSize: 16,
              height: 1.3,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class CoinLinkRow extends StatelessWidget {
  const CoinLinkRow({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(14)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(12)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(14)),
          border: Border.all(color: const Color(0xFFE8EDF5)),
        ),
        child: Row(
          children: [
            Container(
              width: context.w(36),
              height: context.w(36),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(context.r(10)),
              ),
              child: Icon(icon, color: color, size: context.w(18)),
            ),
            SizedBox(width: context.w(10)),
            Expanded(
              child: Text(
                label,
                style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: context.w(20)),
          ],
        ),
      ),
    );
  }
}

class CoinInfoTile extends StatelessWidget {
  const CoinInfoTile({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(36),
            height: context.w(36),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: Icon(icon, color: color, size: context.w(18)),
          ),
          SizedBox(width: context.w(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
