import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/torkk_colors.dart';
import 'bouncing_widget.dart';
import '../utils/screen_utils.dart';

/// Full-width pill button used on onboarding and other primary actions.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;

  bool get _canTap => enabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final fill = context.torkk.actionFill(AppColors.zinc800);
    final labelColor = onColorFor(fill);
    final button = Container(
      width: double.infinity,
      height: context.h(56),
      decoration: BoxDecoration(
        color: _canTap ? fill : fill.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(context.r(28)),
      ),
      alignment: Alignment.center,
      child: isLoading
          ? SizedBox(
              width: context.w(22),
              height: context.w(22),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: labelColor,
              ),
            )
          : Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: context.sp(16),
                fontWeight: FontWeight.w600,
              ),
            ),
    );

    if (!_canTap) return button;

    return BouncingWidget(onTap: onPressed, child: button);
  }
}
