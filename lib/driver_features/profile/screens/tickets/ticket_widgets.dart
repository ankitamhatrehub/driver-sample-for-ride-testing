import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/profile/models/support_ticket.dart';

Widget ticketCard(
  BuildContext context,
  SupportTicket ticket, {
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(context.r(16)),
    child: Container(
      padding: EdgeInsets.all(context.w(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(36),
            height: context.w(36),
            decoration: BoxDecoration(
              color: context.adaptiveTint(const Color(0xFFF3E8FF)),
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: Icon(
              Icons.confirmation_number_outlined,
              color: context.legible(Color(0xFF7C3AED)),
              size: context.w(18),
            ),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.orderId,
                  style: AppTypography.bold.copyWith(
                    fontSize: 14,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  ticket.title,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    color: context.torkk.textSecondary,
                  ),
                ),
                Text(
                  ticket.date,
                  style: AppTypography.regular.copyWith(
                    fontSize: 11,
                    color: AppColors.slate400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(8),
              vertical: context.h(3),
            ),
            decoration: BoxDecoration(
              color: ticket.chipColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
            child: Text(
              ticket.chip,
              style: AppTypography.regular.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ticket.chipColor,
              ),
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.slate400,
              size: context.w(18),
            ),
        ],
      ),
    ),
  );
}

Widget ticketTimeline(BuildContext context, TicketStatus status) {
  final steps = [
    ('Submitted', '12 Jan 2026, 10:24 AM', true, false),
    (
      'Under Review',
      'Our team is reviewing your request.',
      status != TicketStatus.underReview,
      status == TicketStatus.underReview,
    ),
    (
      status == TicketStatus.underReview
          ? 'Waiting for Confirmation'
          : 'Confirmed',
      status == TicketStatus.underReview ? '' : 'Issue will be resolved soon',
      status == TicketStatus.closed,
      false,
    ),
    ('Resolved', '', status == TicketStatus.closed, false),
  ];
  return Column(
    children: [
      for (var i = 0; i < steps.length; i++)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  steps[i].$3
                      ? Icons.check_circle
                      : steps[i].$4
                      ? Icons.circle
                      : Icons.circle_outlined,
                  color: steps[i].$3 || steps[i].$4
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFCBD5E1),
                  size: context.w(18),
                ),
                if (i < steps.length - 1)
                  Container(
                    width: 2,
                    height: context.h(28),
                    color: context.adaptiveTint(const Color(0xFFDCFCE7)),
                  ),
              ],
            ),
            SizedBox(width: context.w(10)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: context.h(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[i].$1,
                      style: AppTypography.regular.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (steps[i].$2.isNotEmpty)
                      Text(
                        steps[i].$2,
                        style: AppTypography.regular.copyWith(
                          fontSize: 12,
                          color: context.torkk.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
    ],
  );
}

Widget ticketMetaCard(BuildContext context, SupportTicket ticket) {
  return Container(
    padding: EdgeInsets.all(context.w(14)),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(context.r(16)),
      border: Border.all(color: context.torkk.border),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Issue',
                style: AppTypography.regular.copyWith(
                  fontSize: 13,
                  color: context.torkk.textSecondary,
                ),
              ),
            ),
            Text(
              ticket.issue,
              style: AppTypography.regular.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(8)),
        Row(
          children: [
            Expanded(
              child: Text(
                'Category',
                style: AppTypography.regular.copyWith(
                  fontSize: 13,
                  color: context.torkk.textSecondary,
                ),
              ),
            ),
            Text(
              ticket.category,
              style: AppTypography.regular.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget ticketChoice(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required Color background,
  required String label,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: context.h(10)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(14)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(12),
          vertical: context.h(14),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(14)),
          border: Border.all(color: context.torkk.border),
        ),
        child: Row(
          children: [
            Container(
              width: context.w(36),
              height: context.w(36),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(context.r(10)),
              ),
              child: Icon(icon, color: color, size: context.w(18)),
            ),
            SizedBox(width: context.w(10)),
            Expanded(
              child: Text(
                label,
                style: AppTypography.regular.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.slate400,
              size: context.w(20),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget ticketCommentBox(
  BuildContext context,
  TextEditingController controller,
  VoidCallback onChanged,
) {
  return TextField(
    controller: controller,
    maxLength: 200,
    maxLines: 4,
    onChanged: (_) => onChanged(),
    decoration: InputDecoration(
      hintText: 'Add a comment',
      hintStyle: AppTypography.regular.copyWith(
        fontSize: 14,
        color: AppColors.slate400,
      ),
      counterText: '${controller.text.length}/200',
      contentPadding: EdgeInsets.all(context.w(12)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.r(12)),
        borderSide: BorderSide(color: context.torkk.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.r(12)),
        borderSide: BorderSide(color: context.torkk.border),
      ),
    ),
  );
}

Widget ticketFilled(BuildContext context, String label, VoidCallback onTap) {
  return Padding(
    padding: EdgeInsets.fromLTRB(
      context.w(20),
      context.h(8),
      context.w(20),
      context.h(16),
    ),
    child: SizedBox(
      width: double.infinity,
      height: context.h(48),
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: profileAccent(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.r(14)),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bold.copyWith(
            fontSize: 15,
            height: 1,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    ),
  );
}
