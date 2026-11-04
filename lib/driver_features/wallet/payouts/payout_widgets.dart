import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

/// Full-width primary button used on the payout screens.
class PayoutButton extends StatelessWidget {
  const PayoutButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outline = false,
    this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final bool outline;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? profileAccent(context);
    return SizedBox(
      width: double.infinity,
      height: context.h(48),
      child: outline
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: c,
                side: BorderSide(color: c),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.r(14)),
                ),
              ),
              child: Text(
                label,
                style: AppTypography.bold.copyWith(fontSize: 15),
              ),
            )
          : FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: c,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.r(14)),
                ),
              ),
              child: Text(
                label,
                style: AppTypography.bold.copyWith(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}

/// Centered hero used by the processing / success / failed screens: a tinted
/// halo with a solid circle and icon, then a title and a message.
class PayoutStatusHero extends StatelessWidget {
  const PayoutStatusHero({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.message,
    this.child,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String message;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: context.w(120),
          height: context.w(120),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child:
              child ??
              Container(
                width: context.w(64),
                height: context.w(64),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: context.w(34)),
              ),
        ),
        SizedBox(height: context.h(24)),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.bold.copyWith(fontSize: 22, letterSpacing: -0.4),
        ),
        SizedBox(height: context.h(8)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(32)),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.regular.copyWith(
              fontSize: 14,
              height: 1.4,
              color: context.torkk.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
