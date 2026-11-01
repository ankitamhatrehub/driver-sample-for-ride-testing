import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/profile/models/support_ticket.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_full_details_screen.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/follow_up_screen.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_widgets.dart';

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({super.key, required this.ticket});

  final SupportTicket ticket;

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final reopen = ticket.status != TicketStatus.underReview;
    return ProfilePage(
      title: 'Ticket Details',
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(16),
        ),
        child: SizedBox(
          width: double.infinity,
          height: context.h(48),
          child: OutlinedButton(
            onPressed: () async {
              if (reopen) {
                setState(() => ticket.status = TicketStatus.underReview);
                return;
              }
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FollowUpScreen(ticket: ticket),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: profileAccent(context),
              side: BorderSide(color: profileAccent(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.r(14)),
              ),
            ),
            child: Text(
              reopen ? 'Reopen Ticket' : 'Follow up',
              style: AppTypography.bold.copyWith(
                fontSize: 15,
                height: 1,
                color: profileAccent(context),
              ),
            ),
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(12),
        ),
        children: [
          ticketCard(context, ticket),
          SizedBox(height: context.h(16)),
          ticketTimeline(context, ticket.status),
          SizedBox(height: context.h(16)),
          ticketMetaCard(context, ticket),
          SizedBox(height: context.h(8)),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TicketFullDetailsScreen(ticket: ticket),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(8)),
              child: Row(
                children: [
                  Text(
                    'View Details',
                    style: AppTypography.regular.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: profileAccent(context),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: profileAccent(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
