import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class SettingsChoiceCard extends StatelessWidget {
  const SettingsChoiceCard({
    super.key,
    required this.leading,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: context.h(12)),
        padding: EdgeInsets.symmetric(
          horizontal: context.w(14),
          vertical: context.h(14),
        ),
        decoration: BoxDecoration(
          color: context.torkk.surface,
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(
            color: selected ? accent : context.torkk.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            leading,
            SizedBox(width: context.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.regular.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.torkk.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTypography.regular.copyWith(
                        fontSize: 12,
                        color: context.torkk.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? accent : context.torkk.textDisabled,
              size: context.w(22),
            ),
          ],
        ),
      ),
    );
  }
}
