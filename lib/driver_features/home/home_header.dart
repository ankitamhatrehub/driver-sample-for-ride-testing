import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.driverName,
    required this.onNotifications,
  });

  final String driverName;
  final VoidCallback onNotifications;

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
        padding: EdgeInsets.fromLTRB(
          context.w(40),
          context.h(20),
          context.w(30),
          0,
        ),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.isDarkTheme
                          ? context.torkk.textBody
                          : const Color(0xFF334155),
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
                      color: context.isDarkTheme
                          ? context.torkk.textPrimary
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            // Plain bell icon (no glass box); tap opens the notifications.
            GestureDetector(
              onTap: onNotifications,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: context.w(36),
                height: context.w(36),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: context.w(26),
                  color: context.isDarkTheme
                      ? context.torkk.textPrimary
                      : const Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
