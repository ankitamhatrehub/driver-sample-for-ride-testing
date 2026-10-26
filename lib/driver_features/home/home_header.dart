import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';


class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.driverName,
    required this.onNotifications,
    required this.onHelp,
  });

  final String driverName;
  final VoidCallback onNotifications;
  final VoidCallback onHelp;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(context.w(40), context.h(20), context.w(30), 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting,
                    style: AppTypography.regular.copyWith(
                      fontSize: 12,
                      color: AppColors.gray500,
                    ),
                  ),
                  Text(
                    driverName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bold.copyWith(
                      fontSize: 16,
                      height: 1.3,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
