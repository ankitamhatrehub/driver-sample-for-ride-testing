import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

enum KycItemStatus { verified, pending, notStarted }

class KycStatusRow extends StatelessWidget {
  const KycStatusRow({
    super.key,
    required this.title,
    required this.status,
    this.onTap,
  });

  final String title;
  final KycItemStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      KycItemStatus.verified => AppColors.emerald500,
      KycItemStatus.pending => const Color(0xFFEF4444),
      KycItemStatus.notStarted => AppColors.secondaryTextColor,
    };
    final statusLabel = switch (status) {
      KycItemStatus.verified => AppStrings.kycVerified,
      KycItemStatus.pending => AppStrings.kycPending,
      KycItemStatus.notStarted => AppStrings.kycNotStarted,
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              debugPrint('KYC row tapped: $title');
              onTap!();
            },
      child: Container(
        padding: EdgeInsets.all(context.w(14)),
        decoration: BoxDecoration(
          color: context.torkk.surface,
          borderRadius: BorderRadius.circular(context.r(12)),
          border: Border.all(color: context.torkk.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          children: [
            _statusMark(status == KycItemStatus.verified, context),
            SizedBox(width: context.w(14)),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bold.copyWith(
                      fontSize: 12,
                      height: 1.15,
                      color: context.torkk.textPrimary,
                    ),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    statusLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.regular.copyWith(
                      fontSize: 10,
                      height: 1.15,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            if (status == KycItemStatus.notStarted)
              Container(
                width: context.w(30),
                height: context.w(30),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.torkk.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.slate400,
                  size: context.w(16),
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                color: AppColors.slate400,
                size: context.w(22),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusMark(bool verified, BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: verified
            ? context.adaptiveTint(Color(0xFFE8F8EE))
            : context.torkk.surface,
        border: Border.all(
          color: verified ? AppColors.emerald500 : AppColors.slate300,
        ),
      ),
      child: verified
          ? Icon(Icons.check, size: context.w(16), color: AppColors.emerald500)
          : null,
    );
  }
}
