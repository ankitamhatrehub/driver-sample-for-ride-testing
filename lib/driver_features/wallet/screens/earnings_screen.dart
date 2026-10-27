import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  int _range = 0;

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    const ranges = ['Day', 'Week', 'Month'];
    return ProfilePage(
      title: 'Earnings',
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
        children: [
          Container(
            padding: EdgeInsets.all(context.w(4)),
            decoration: BoxDecoration(
              color: context.torkk.surfaceMuted,
              borderRadius: BorderRadius.circular(context.r(14)),
            ),
            child: Row(
              children: [
                for (var i = 0; i < ranges.length; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _range = i),
                      child: Container(
                        height: context.h(36),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _range == i ? accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(context.r(10)),
                        ),
                        child: Text(
                          ranges[i],
                          style: AppTypography.regular.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _range == i ? Theme.of(context).colorScheme.onPrimary : AppColors.slate500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: context.h(14)),
          Row(
            children: [
              Icon(Icons.chevron_left_rounded, color: AppColors.slate400, size: context.w(22)),
              Expanded(
                child: Text(
                  _range == 0 ? 'Today, 12 Jan 2024' : _range == 1 ? 'This Week' : 'January 2024',
                  textAlign: TextAlign.center,
                  style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: context.w(22)),
            ],
          ),
          SizedBox(height: context.h(14)),
          Container(
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: context.torkk.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Earnings", style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary)),
                      Text('₹680.00', style: AppTypography.bold.copyWith(fontSize: 22, height: 1.2, letterSpacing: -0.4)),
                    ],
                  ),
                ),
                Icon(Icons.star_rounded, color: const Color(0xFFF472B6), size: context.w(22)),
              ],
            ),
          ),
          SizedBox(height: context.h(12)),
          _group(context, const [
            _EarnRow(Icons.directions_car_filled_rounded, Color(0xFF7C3AED), Color(0xFFF3E8FF), 'Ride Earnings', '8 trips', '₹520.00'),
            _EarnRow(Icons.inventory_2_rounded, Color(0xFFF59E0B), Color(0xFFFEF3C7), 'Parcel Earnings', '2 delivers', '₹520.00'),
            _EarnRow(Icons.star_rounded, Color(0xFFDB2777), Color(0xFFFCE7F3), 'Bonus/Incentives', '', '₹520.00'),
          ]),
          SizedBox(height: context.h(12)),
          _group(context, const [
            _EarnRow(Icons.nightlight_round, Color(0xFF7C3AED), Color(0xFFF3E8FF), 'Night Charges', '10:00 am - 5:00 am', '₹520.00'),
            _EarnRow(Icons.access_time_filled_rounded, Color(0xFFF59E0B), Color(0xFFFEF3C7), 'Waiting Charges', 'after 5 mins of waiting', '₹520.00'),
            _EarnRow(Icons.two_wheeler_rounded, Color(0xFFF59E0B), Color(0xFFFEF3C7), 'Fair / km Plan(Bike)', 'Standard Plan', '₹520.00'),
          ]),
        ],
      ),
    );
  }

  Widget _group(BuildContext context, List<_EarnRow> rows) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: context.torkk.border),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(12)),
              child: Row(
                children: [
                  Container(
                    width: context.w(36),
                    height: context.w(36),
                    decoration: BoxDecoration(color: rows[i].background, borderRadius: BorderRadius.circular(context.r(10))),
                    child: Icon(rows[i].icon, color: rows[i].color, size: context.w(18)),
                  ),
                  SizedBox(width: context.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rows[i].title, style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                        if (rows[i].subtitle.isNotEmpty)
                          Text(rows[i].subtitle, style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary)),
                      ],
                    ),
                  ),
                  Text(rows[i].amount, style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EarnRow {
  const _EarnRow(this.icon, this.color, this.background, this.title, this.subtitle, this.amount);
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String subtitle;
  final String amount;
}
