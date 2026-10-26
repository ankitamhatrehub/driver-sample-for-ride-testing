import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Shared confirm dialog used for logout, delete, online/offline, SOS, and notices.
///
/// Returns true when the filled button is pressed.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required Widget icon,
  required String title,
  required String subtitle,
  required String confirmLabel,
  String? cancelLabel,
  Color? accent,
}) {
  final color = accent ?? Theme.of(context).colorScheme.primary;
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.28),
    builder: (context) => AppConfirmDialog(
      icon: icon,
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      accent: color,
      onCancel: () => Navigator.of(context).pop(false),
      onConfirm: () => Navigator.of(context).pop(true),
    ),
  ).then((value) => value ?? false);
}

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.cancelLabel,
    required this.accent,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final String? cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: context.w(36)),
      child: AppConfirmCard(
        icon: icon,
        title: title,
        subtitle: subtitle,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        accent: accent,
        onCancel: onCancel,
        onConfirm: onConfirm,
      ),
    );
  }
}

class AppConfirmCard extends StatelessWidget {
  const AppConfirmCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.cancelLabel,
    required this.accent,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final String? cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final effCancel = cancelLabel ?? AppStrings.cancel;
    return Container(
      width: context.w(321),
      padding: EdgeInsets.fromLTRB(context.w(16), context.h(28), context.w(16), context.h(28)),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(context.r(27.17)),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 10.2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(height: context.h(18)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(
              fontSize: 20,
              height: 28 / 20,
              letterSpacing: -0.5,
              color: context.torkk.textPrimary,
            ),
          ),
          SizedBox(height: context.h(4)),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.regular.copyWith(
              fontSize: 12,
              height: 19.5 / 12,
              letterSpacing: 0,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(18)),
          Row(
            children: [
              Expanded(child: _DialogAction(label: effCancel, filled: false, color: accent, onTap: onCancel)),
              SizedBox(width: context.w(8)),
              Expanded(child: _DialogAction(label: confirmLabel, filled: true, color: accent, onTap: onConfirm)),
            ],
          ),
        ],
      ),
    );
  }
}

class AppDialogBadge extends StatelessWidget {
  const AppDialogBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    this.badge,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: context.w(62),
      height: context.w(62),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: context.legible(color), size: context.w(28)),
    );
    if (badge == null) return mark;
    return SizedBox(
      width: context.w(62),
      height: context.w(62),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          mark,
          Positioned(right: -2, bottom: -2, child: badge!),
        ],
      ),
    );
  }
}

class _DialogAction extends StatelessWidget {
  const _DialogAction({
    required this.label,
    required this.filled,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.h(48),
      child: Material(
        color: filled ? color : context.torkk.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.r(14)),
          side: BorderSide(color: context.legible(color), width: 1.4),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.r(14)),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.bold.copyWith(
                fontSize: 14,
                height: 1.2,
                color: filled
                    ? (context.isDarkTheme ? onColorFor(color) : Colors.white)
                    : context.legible(color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
