
import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/profile/models/support_ticket.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_details_screen.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_widgets.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  int _tab = 0;

  List<SupportTicket> get _visible {
    if (_tab == 1) return supportTickets.where((t) => t.status == TicketStatus.underReview).toList();
    if (_tab == 2) return supportTickets.where((t) => t.status != TicketStatus.underReview).toList();
    return supportTickets;
  }

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    const tabs = ['All', 'Open', 'Resolved'];
    return ProfilePage(
      title: 'My Tickets',
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
        children: [
          Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Padding(
                  padding: EdgeInsets.only(right: context.w(8)),
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: context.w(18), vertical: context.h(8)),
                      decoration: BoxDecoration(
                        color: _tab == i ? accent : context.adaptiveTint(Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(context.r(10)),
                      ),
                      child: Text(
                        tabs[i],
                        style: AppTypography.regular.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _tab == i ? Theme.of(context).colorScheme.onPrimary : context.torkk.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.h(14)),
          for (final ticket in _visible)
            Padding(
              padding: EdgeInsets.only(bottom: context.h(10)),
              child: ticketCard(
                context,
                ticket,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => TicketDetailsScreen(ticket: ticket)),
                  );
                  if (mounted) setState(() {});
                },
              ),
            ),
        ],
      ),
    );
  }
}
