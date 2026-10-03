import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';

enum AppSnackBarType { success, error, info }

/// Floating snackbar used across the app.
class AppSnackBar {
  const AppSnackBar._();

  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _show(
      context,
      type: AppSnackBarType.success,
      title: title,
      message: message,
    );
  }

  static void showError(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _show(
      context,
      type: AppSnackBarType.error,
      title: title,
      message: message,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _show(
      context,
      type: AppSnackBarType.info,
      title: title,
      message: message,
    );
  }

  static void _show(
    BuildContext context, {
    required AppSnackBarType type,
    required String title,
    required String message,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: const Duration(seconds: 4),
          padding: EdgeInsets.zero,
          margin: EdgeInsets.fromLTRB(context.w(16), 0, context.w(16), context.h(16)),
          content: AppSnackBarBanner(
            type: type,
            title: title,
            message: message,
            onClose: messenger.hideCurrentSnackBar,
          ),
        ),
      );
  }
}

class AppSnackBarBanner extends StatelessWidget {
  const AppSnackBarBanner({
    required this.type,
    required this.title,
    required this.message,
    super.key,
    this.onClose,
  });

  final AppSnackBarType type;
  final String title;
  final String message;
  final VoidCallback? onClose;

  Color get _accent {
    return switch (type) {
      AppSnackBarType.success => AppColors.primary,
      AppSnackBarType.error => AppColors.error,
      AppSnackBarType.info => AppColors.blue600,
    };
  }

  IconData get _icon {
    return switch (type) {
      AppSnackBarType.success => Icons.check,
      AppSnackBarType.error => Icons.priority_high,
      AppSnackBarType.info => Icons.info_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.w(12),
        context.h(12),
        context.w(8),
        context.h(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.snackBarBackground,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: _accent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.w(32),
            height: context.w(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _accent),
            ),
            child: Icon(_icon, size: context.sp(16), color: _accent),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.bold.copyWith(
                    fontSize: 13,
                    height: 1.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: context.h(4)),
                Text(
                  message,
                  style: AppTypography.regular.copyWith(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              Icons.close,
              size: context.sp(16),
              color: AppColors.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
