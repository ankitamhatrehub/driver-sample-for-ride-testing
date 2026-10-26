import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: context.w(100),
              height: context.w(100),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: 0.28), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                color: accent,
                size: context.w(40),
              ),
            ),
            Positioned(
              right: 0,
              bottom: context.h(6),
              child: Container(
                width: context.w(28),
                height: context.w(28),
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: context.w(13),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(8)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Rahul',
              style: AppTypography.bold.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:  Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(width: context.w(10)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(8),
                vertical: context.h(3),
              ),
              decoration: BoxDecoration(
                color: context.adaptiveTint(const Color(0xFFDCFCE7)),
                borderRadius: BorderRadius.circular(context.r(20)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: context.w(6),
                    height: context.w(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: context.w(4)),
                  Text(
                    AppStrings.ordersOnline,
                    style: AppTypography.regular.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.legible(Color(0xFF16A34A)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(10)),
        Text(
          AppStrings.driversId,
          style: AppTypography.regular.copyWith(
            fontSize: 12,
            color: context.torkk.textSecondary,
          ),
        ),
      ],
    );
  }
}
