import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/screen_utils.dart';

/// Radio-style option card used for language and similar single-choice lists.
class AppSelectionTile extends StatelessWidget {
  const AppSelectionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.blue700 : AppColors.slate200;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(20),
          vertical: context.h(18),
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.slate50 : Colors.white,
          border: Border.all(
            color: borderColor,
            width: selected ? 1.8 : 1.2,
          ),
          borderRadius: BorderRadius.circular(context.r(20)),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.blue700 : AppColors.slate400,
              size: context.w(24),
            ),
            SizedBox(width: context.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.sp(13),
                      color: AppColors.gray600,
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
