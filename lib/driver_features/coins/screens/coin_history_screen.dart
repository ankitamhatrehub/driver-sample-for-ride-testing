import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  static const _tabs = ['All', 'Earned', 'Redeemed'];
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    const earned = [
      (Icons.directions_car_filled_rounded, Color(0xFF7C3AED), Color(0xFFF3E8FF), 'Ride Completed', '2:00 am'),
      (Icons.inventory_2_rounded, Color(0xFFF59E0B), Color(0xFFFEF3C7), 'Parcel Delivered', '2:00 am'),
      (Icons.confirmation_number_outlined, Color(0xFFF59E0B), Color(0xFFFEF3C7), 'Scratch Card Reward', '2:00 am'),
    ];
    final rows = _tab == 2 ? const <(IconData, Color, Color, String, String)>[] : earned;
    return ProfilePage(
      title: 'Coin History',
      onBack: widget.onBack,
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
        children: [
          Container(
            padding: EdgeInsets.all(context.w(4)),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(context.r(14)),
            ),
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: Container(
                        height: context.h(36),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _tab == i ? accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(context.r(10)),
                        ),
                        child: Text(
                          _tabs[i],
                          style: AppTypography.regular.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _tab == i ? Colors.white : AppColors.slate500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: context.h(14)),
          for (final row in rows)
            Container(
              margin: EdgeInsets.only(bottom: context.h(10)),
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
                      color: row.$3,
                      borderRadius: BorderRadius.circular(context.r(10)),
                    ),
                    child: Icon(row.$1, color: row.$2, size: context.w(18)),
                  ),
                  SizedBox(width: context.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.$4,
                          style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          row.$5,
                          style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+ ₹50.00',
                    style: AppTypography.regular.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                  SizedBox(width: context.w(4)),
                  Image.asset(AppAssets.rewardCoins, width: context.w(16), height: context.w(16)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
