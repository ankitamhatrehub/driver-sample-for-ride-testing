import 'dart:io';

import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/profile/models/support_ticket.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/follow_up_screen.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_widgets.dart';

class TicketFullDetailsScreen extends StatelessWidget {
  const TicketFullDetailsScreen({super.key, required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Tickets Details',
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(16)),
        child: SizedBox(
          width: double.infinity,
          height: context.h(48),
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => FollowUpScreen(ticket: ticket)),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: profileAccent(context),
              side: BorderSide(color: profileAccent(context)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
            ),
            child: Text('Follow up', style: AppTypography.bold.copyWith(fontSize: 15, height: 1, color: profileAccent(context))),
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(12)),
        children: [
          ticketCard(context, ticket),
          SizedBox(height: context.h(14)),
          _pair(context, 'Created', ticket.created),
          _pair(context, 'Last Updated', ticket.updated),
          _pair(context, 'Issue', ticket.issue, bold: true),
          _pair(context, 'Category', ticket.category, bold: true),
          SizedBox(height: context.h(8)),
          Text('Description', style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary)),
          Text(ticket.description, style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: context.h(12)),
          Text('Attachments', style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary)),
          SizedBox(height: context.h(8)),
          Row(
            children: [
              for (final path in ticket.photos.take(2))
                Padding(
                  padding: EdgeInsets.only(right: context.w(8)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.r(10)),
                    child: Image.file(File(path), width: context.w(64), height: context.w(64), fit: BoxFit.cover),
                  ),
                ),
              if (ticket.photos.length > 2)
                Container(
                  width: context.w(64),
                  height: context.w(64),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.r(10)),
                    border: Border.all(color: context.torkk.border),
                  ),
                  child: Text('+${ticket.photos.length - 2}', style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pair(BuildContext context, String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary))),
          Text(value, style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}
