import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';

class HomeStatsCard extends StatelessWidget {
  const HomeStatsCard({
    super.key,
    required this.todayEarnings,
    required this.completedJobs,
    required this.onEarnings,
    required this.onJobs,
    required this.accent,
  });

  final double todayEarnings;
  final int completedJobs;
  final VoidCallback onEarnings;
  final VoidCallback onJobs;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.h(196),
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: const Color(0x0D57278D),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: const Color(0x3640105F)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 3.3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onEarnings,
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.todayEarnings,
                        style: AppTypography.regular.copyWith(fontSize: 11, color: AppColors.slate500),
                      ),
                      SizedBox(height: context.h(4)),
                      Text(
                        _rupees(todayEarnings),
                        style: AppTypography.bold.copyWith(fontSize: 26, height: 1.15, letterSpacing: -0.6),
                      ),
                      SizedBox(height: context.h(4)),
                      Text(
                        completedJobs == 1 ? '1 ride' : '$completedJobs rides',
                        style: AppTypography.regular.copyWith(fontSize: 14, color: AppColors.slate500),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: context.w(36),
                  height: context.w(36),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(context.r(10)),
                  ),
                  child: Icon(Icons.show_chart_rounded, color: accent, size: context.w(18)),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onJobs,
            child: Container(
              constraints: BoxConstraints(minHeight: context.h(55)),
              padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.h(6)),
              decoration: BoxDecoration(
                color: const Color(0xCCFFFFFF),
                borderRadius: BorderRadius.circular(context.r(12)),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.todayCompletedJobs,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.regular.copyWith(
                            fontSize: 12,
                            height: 1.1,
                            color: AppColors.slate500,
                          ),
                        ),
                        Text(
                          '$completedJobs',
                          style: AppTypography.bold.copyWith(fontSize: 16, height: 1.1, letterSpacing: -0.3),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.directions_car_filled_rounded, color: accent, size: context.w(18)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _rupees(double amount) {
    final digits = amount.round().abs().toString();
    if (digits.length <= 3) return '₹$digits';
    final tail = digits.substring(digits.length - 3);
    var head = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (head.length > 2) {
      parts.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    if (head.isNotEmpty) parts.insert(0, head);
    return '₹${parts.join(',')},$tail';
  }
}
