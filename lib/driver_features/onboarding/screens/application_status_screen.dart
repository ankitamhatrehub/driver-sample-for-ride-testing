import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/status_result.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

enum ApplicationOutcome { underReview, approved, actionRequired, rejected }

/// Status after the driver submits.
///
/// Under review keeps the confetti and clipboard. Approved keeps the confetti
/// and uses the verified icon. Action required and rejected show the reason
/// and the resubmit actions.
class ApplicationStatusScreen extends StatelessWidget {
  const ApplicationStatusScreen({
    super.key,
    required this.gender,
    required this.submittedAt,
    required this.outcome,
    required this.onBack,
    required this.onGoHome,
    required this.onResubmit,
    required this.onMakeCorrections,
    this.reasonTitle,
    this.reasonBody,
  });

  final String gender;
  final DateTime submittedAt;
  final ApplicationOutcome outcome;
  final VoidCallback onBack;
  final VoidCallback onGoHome;
  final VoidCallback onResubmit;
  final VoidCallback onMakeCorrections;
  final String? reasonTitle;
  final String? reasonBody;

  bool get _problem =>
      outcome == ApplicationOutcome.actionRequired ||
      outcome == ApplicationOutcome.rejected;

  Color get _accent => gender == AppStrings.genderFemale
      ? AppColors.femalePink
      : AppColors.maleBlue;

  @override
  Widget build(BuildContext context) {
    return StatusResult(
      onBack: onBack,
      celebration: !_problem,
      icon: _statusIcon(context),
      title: _title,
      subtitle: _subtitle,
      button: UnifiedButton(
        label: _problem ? AppStrings.uploadAndResubmit : AppStrings.goHome,
        backgroundColor: _accent,
        onPressed: _problem ? onResubmit : onGoHome,
      ),
      extraButton: outcome == ApplicationOutcome.rejected
          ? UnifiedButton(
              label: AppStrings.makeCorrections,
              variant: UnifiedButtonVariant.outline,
              onPressed: onMakeCorrections,
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.currentStatus,
            style: AppTypography.bold.copyWith(fontSize: 12, height: 1.3),
          ),
          SizedBox(height: context.h(14)),
          _banner(context),
          SizedBox(height: context.h(14)),
          if (_problem) _reason(context) else _timeline(context),
        ],
      ),
    );
  }

  Widget _statusIcon(BuildContext context) {
    if (outcome == ApplicationOutcome.rejected) {
      return Image.asset(
        AppAssets.failedIcon,
        width: context.w(96),
        height: context.w(96),
        fit: BoxFit.contain,
      );
    }
    if (outcome == ApplicationOutcome.actionRequired) {
      return const _ActionClipboard();
    }
    return Image.asset(
      outcome == ApplicationOutcome.approved ? AppAssets.verifiedIcon : AppAssets.applicationIcon,
      width: context.w(200),
      fit: BoxFit.contain,
    );
  }

  String get _title {
    switch (outcome) {
      case ApplicationOutcome.approved:
        return AppStrings.applicationApproved;
      case ApplicationOutcome.actionRequired:
        return AppStrings.actionRequired;
      case ApplicationOutcome.rejected:
        return AppStrings.applicationRejected;
      case ApplicationOutcome.underReview:
        return AppStrings.applicationSubmitted;
    }
  }

  String get _subtitle {
    switch (outcome) {
      case ApplicationOutcome.approved:
        return AppStrings.applicationApprovedSubtitle;
      case ApplicationOutcome.actionRequired:
        return AppStrings.actionRequiredSubtitle;
      case ApplicationOutcome.rejected:
        return AppStrings.applicationRejectedSubtitle;
      case ApplicationOutcome.underReview:
        return AppStrings.applicationSubmittedSubtitle;
    }
  }

  Widget _banner(BuildContext context) {
    final Color background;
    final Color border;
    final Color iconColor;
    final IconData icon;
    final String title;
    final String body;
    switch (outcome) {
      case ApplicationOutcome.approved:
        background = const Color(0xFFF0FDF4);
        border = const Color(0xFFBBF7D0);
        iconColor = AppColors.green600;
        icon = Icons.check_circle;
        title = AppStrings.applicationApprovedStatus;
        body = AppStrings.applicationApprovedHint;
      case ApplicationOutcome.actionRequired:
      case ApplicationOutcome.rejected:
        background = const Color(0xFFFEF2F2);
        border = const Color(0xFFFECACA);
        iconColor = AppColors.error;
        icon = Icons.error;
        title = AppStrings.actionRequired;
        body = AppStrings.actionRequiredBanner;
      case ApplicationOutcome.underReview:
        background = const Color(0xFFFFCA24).withValues(alpha: 0.1);
        border = const Color(0xFFD9AA16);
        iconColor = const Color(0xFFFFCA24);
        icon = Icons.access_time_filled;
        title = AppStrings.underReview;
        body = AppStrings.underReviewHint;
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.w(8),
        vertical: context.h(14),
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: context.w(20)),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bold.copyWith(fontSize: 12, height: 1.3),
                ),
                SizedBox(height: context.h(2)),
                Text(
                  body,
                  style: AppTypography.regular.copyWith(
                    fontSize: 10,
                    height: 1.4,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reason(BuildContext context) {
    final title = (reasonTitle == null || reasonTitle!.trim().isEmpty)
        ? AppStrings.documentsNeedAttention
        : reasonTitle!.trim();
    final body = (reasonBody == null || reasonBody!.trim().isEmpty)
        ? AppStrings.documentsNeedAttentionHint
        : reasonBody!.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.reason,
          style: AppTypography.bold.copyWith(fontSize: 14, height: 1.3),
        ),
        SizedBox(height: context.h(12)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: context.w(22),
              height: context.w(22),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.priority_high,
                color: Colors.white,
                size: context.w(14),
              ),
            ),
            SizedBox(width: context.w(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bold.copyWith(
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: context.h(2)),
                  Text(
                    body,
                    style: AppTypography.regular.copyWith(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _timeline(BuildContext context) {
    final approved = outcome == ApplicationOutcome.approved;
    final steps = [
      _StatusStep(
        AppStrings.applicationSubmittedStep,
        _formatSubmittedAt(submittedAt),
        _Mark.done,
      ),
      _StatusStep(
        AppStrings.underReviewStep,
        AppStrings.underReviewNotify,
        approved ? _Mark.done : _Mark.current,
      ),
      _StatusStep(
        AppStrings.applicationApprovedStatus,
        AppStrings.startDrivingWithTorkk,
        approved ? _Mark.done : _Mark.pending,
      ),
    ];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        context.w(12),
        context.h(8),
        context.w(12),
        context.h(8),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            _timelineRow(context, steps[i], isLast: i == steps.length - 1),
        ],
      ),
    );
  }

  Widget _timelineRow(
    BuildContext context,
    _StatusStep step, {
    required bool isLast,
  }) {
    final titleColor = step.mark == _Mark.pending
        ? AppColors.slate400
        : AppColors.textPrimary;
    final lineColor = step.mark == _Mark.done
        ? AppColors.green600
        : AppColors.slate200;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.w(22),
            child: Column(
              children: [
                _mark(context, step.mark),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: lineColor)),
              ],
            ),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? context.h(8) : context.h(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppTypography.bold.copyWith(
                      fontSize: 13,
                      height: 1.3,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: context.h(2)),
                  Text(
                    step.subtitle,
                    style: AppTypography.regular.copyWith(
                      fontSize: 11,
                      height: 1.35,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mark(BuildContext context, _Mark mark) {
    if (mark == _Mark.done) {
      return Icon(
        Icons.check_circle,
        color: AppColors.green600,
        size: context.w(22),
      );
    }
    if (mark == _Mark.current) {
      return Container(
        width: context.w(22),
        height: context.w(22),
        alignment: Alignment.center,
        child: Container(
          width: context.w(14),
          height: context.w(14),
          decoration: const BoxDecoration(
            color: Color(0xFF86EFAC),
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    return Container(
      width: context.w(22),
      height: context.w(22),
      alignment: Alignment.center,
      child: Container(
        width: context.w(16),
        height: context.w(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.slate300, width: 1.6),
        ),
      ),
    );
  }

  String _formatSubmittedAt(DateTime time) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${time.day} ${months[time.month - 1]} ${time.year}, $hour:$minute $period';
  }
}

class _ActionClipboard extends StatelessWidget {
  const _ActionClipboard();

  @override
  Widget build(BuildContext context) {
    final size = context.w(84);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: const _ClipboardPainter(AppColors.error),
          ),
          Positioned(
            right: 0,
            bottom: context.w(2),
            child: Container(
              width: context.w(26),
              height: context.w(26),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: context.w(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClipboardPainter extends CustomPainter {
  const _ClipboardPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.2,
        size.width * 0.7,
        size.height * 0.72,
      ),
      Radius.circular(size.width * 0.1),
    );
    canvas.drawRRect(body, stroke);

    final clip = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.24,
        size.height * 0.08,
        size.width * 0.38,
        size.height * 0.16,
      ),
      Radius.circular(size.width * 0.04),
    );
    canvas.drawRRect(clip, stroke);

    final hole = Paint()..color = color;
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.32 + i * 0.11), size.height * 0.16),
        size.width * 0.02,
        hole,
      );
    }

    final line = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.4 + i * 0.14);
      canvas.drawLine(
        Offset(size.width * 0.22, y),
        Offset(size.width * (i == 2 ? 0.42 : 0.58), y),
        line,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ClipboardPainter oldDelegate) =>
      oldDelegate.color != color;
}

enum _Mark { done, current, pending }

class _StatusStep {
  const _StatusStep(this.title, this.subtitle, this.mark);

  final String title;
  final String subtitle;
  final _Mark mark;
}
