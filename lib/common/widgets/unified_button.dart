import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/screen_utils.dart';
import 'bouncing_widget.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

enum UnifiedButtonVariant { filled, outline, error }

/// Full-width action button. [label] is the text shown on the button.
///
/// [UnifiedButtonVariant.filled] is the normal accent button.
/// [UnifiedButtonVariant.error] is the same shape in red.
/// [UnifiedButtonVariant.outline] is a white button with a gray border.
class UnifiedButton extends StatelessWidget {
  const UnifiedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
    this.icon,
    this.iconAtEnd = false,
    this.variant = UnifiedButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;
  final IconData? icon;
  final bool iconAtEnd;
  final UnifiedButtonVariant variant;

  bool get _canTap => enabled && !isLoading && onPressed != null;

  bool get _outline => variant == UnifiedButtonVariant.outline;

  @override
  Widget build(BuildContext context) {
    final themeColor = context.brandColor;
    final color = variant == UnifiedButtonVariant.error
        ? (backgroundColor ?? AppColors.error)
        : (backgroundColor ?? themeColor);
    final labelColor =
        foregroundColor ??
        (_outline
            ? context.torkk.textPrimary
            : (context.isDarkTheme ? onColorFor(color) : Colors.white));
    final button = Container(
      width: double.infinity,
      height: context.h(52),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _outline
            ? (backgroundColor ?? context.torkk.surface)
            : (_canTap ? color : color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(context.r(14)),
        border: _outline
            ? Border.all(color: borderColor ?? context.torkk.border, width: 1)
            : null,
      ),
      child: isLoading
          ? SizedBox(
              width: context.w(22),
              height: context.w(22),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: labelColor,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null && !iconAtEnd) ...[
                  Icon(icon, color: labelColor, size: 18),
                  SizedBox(width: context.w(8)),
                ],
                Text(
                  label,
                  style: AppTypography.bold.copyWith(
                    color: labelColor,
                    fontSize: context.sp(16),
                    height: 1.2,
                  ),
                ),
                if (icon != null && iconAtEnd) ...[
                  SizedBox(width: context.w(8)),
                  Icon(icon, color: labelColor, size: 18),
                ],
              ],
            ),
    );

    if (!_canTap) return button;
    return BouncingWidget(onTap: onPressed, child: button);
  }
}
