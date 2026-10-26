import 'dart:io';

import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class KycRequiredLabel extends StatelessWidget {
  const KycRequiredLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: AppTypography.regular.copyWith(fontSize: 13, height: 1.2),
        children: [
          TextSpan(
            text: ' *',
            style: AppTypography.regular.copyWith(fontSize: 13, color: context.legible(AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class KycUploadTile extends StatelessWidget {
  const KycUploadTile({
    super.key,
    required this.label,
    required this.uploaded,
    required this.onTap,
  });

  final String label;
  final bool uploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: context.h(110),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.adaptiveTint(const Color(0xFFFAF5FF)),
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(color: uploaded ? AppColors.primary : const Color(0xFFE9D5FF)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              uploaded ? Icons.check_circle : Icons.description_outlined,
              color: context.legible(AppColors.primary),
              size: context.w(26),
            ),
            SizedBox(height: context.h(8)),
            Text(label, style: AppTypography.bold.copyWith(fontSize: 13, height: 1.2, color: context.legible(AppColors.primary))),
            Text(
              uploaded ? AppStrings.kycVerified : AppStrings.tapToUpload,
              style: AppTypography.regular.copyWith(fontSize: 11, color: context.torkk.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class KycPreviewCard extends StatelessWidget {
  const KycPreviewCard({super.key, required this.onRetake, this.imagePath});

  final VoidCallback onRetake;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(10)),
      decoration: BoxDecoration(
        color: context.torkk.surfaceMuted,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(
        children: [
          Container(
            height: context.h(72),
            decoration: BoxDecoration(
              color: context.torkk.surface,
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: imagePath == null
                ? Icon(Icons.badge_outlined, color: AppColors.slate300, size: context.w(32))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(context.r(10)),
                    child: Image.file(File(imagePath!), fit: BoxFit.cover, width: double.infinity),
                  ),
          ),
          SizedBox(height: context.h(8)),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onRetake,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, size: context.w(14), color: context.legible(AppColors.primary)),
                      SizedBox(width: context.w(4)),
                      Text(
                        AppStrings.retake,
                        style: AppTypography.regular.copyWith(fontSize: 12, color: context.legible(AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(Icons.more_horiz, size: context.w(16), color: AppColors.slate400),
            ],
          ),
        ],
      ),
    );
  }
}

class KycPendingBanner extends StatelessWidget {
  const KycPendingBanner({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(12)),
      decoration: BoxDecoration(
        color: context.adaptiveTint(const Color(0xFFFFF7ED)),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: const Color(0xFFFDBA74)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: context.legible(AppColors.amber600), size: context.w(18)),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bold.copyWith(fontSize: 13, height: 1.2, color: context.legible(AppColors.amber700)),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: context.h(2)),
                  Text(
                    subtitle!,
                    style: AppTypography.regular.copyWith(fontSize: 12, color: context.legible(AppColors.amber700)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KycDetailRow extends StatelessWidget {
  const KycDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(10)),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.torkk.border)),
      ),
      child: Row(
        children: [
          Icon(icon, size: context.w(18), color: AppColors.slate400),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.regular.copyWith(fontSize: 11, color: context.torkk.textSecondary),
                ),
                Text(value, style: AppTypography.bold.copyWith(fontSize: 13, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
