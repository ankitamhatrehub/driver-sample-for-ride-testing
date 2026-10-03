import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/widgets/app_confirm_dialog.dart';

/// Asks before the driver goes online or offline. Returns true when confirmed.
Future<bool> showAvailabilityDialog(
  BuildContext context, {
  required bool goingOnline,
}) {
  final accent = Theme.of(context).colorScheme.primary;
  return showAppConfirmDialog(
    context,
    accent: accent,
    icon: AppDialogBadge(
      icon: goingOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
      color: goingOnline ? const Color(0xFF10B981) : AppColors.error,
      background: goingOnline ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
    ),
    title: goingOnline ? AppStrings.goOnline : AppStrings.goOffline,
    subtitle: goingOnline ? AppStrings.goOnlineBody : AppStrings.goOfflineBody,
    confirmLabel: goingOnline ? AppStrings.goOnline : AppStrings.goOffline,
  );
}
