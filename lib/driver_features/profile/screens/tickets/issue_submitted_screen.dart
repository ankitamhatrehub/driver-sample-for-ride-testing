import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/profile/models/support_ticket.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_details_screen.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_widgets.dart';

class IssueSubmittedScreen extends StatelessWidget {
  const IssueSubmittedScreen({super.key, required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: '',
      bottom: ticketFilled(context, 'View Ticket Details', () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TicketDetailsScreen(ticket: ticket),
          ),
        );
      }),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          SizedBox(height: context.h(24)),
          Center(
            child: Container(
              width: context.w(72),
              height: context.w(72),
              decoration: BoxDecoration(
                color: context.adaptiveTint(Color(0xFFDCFCE7)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: context.legible(Color(0xFF16A34A)),
                size: context.w(36),
              ),
            ),
          ),
          SizedBox(height: context.h(16)),
          Text(
            'Issue Submitted',
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(
              fontSize: 20,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            'Your request has been submitted successfully',
            textAlign: TextAlign.center,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(18)),
          Container(
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
                        'Ticket ID',
                        style: AppTypography.regular.copyWith(
                          fontSize: 12,
                          color: context.torkk.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '# tk2345',
                      style: AppTypography.bold.copyWith(
                        fontSize: 14,
                        height: 1.2,
                        letterSpacing: -0.2,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Clipboard.setData(
                        const ClipboardData(text: 'tk2345'),
                      ),
                      icon: Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: profileAccent(context),
                      ),
                    ),
                  ],
                ),
                _line(context, 'Issue', ticket.issue),
                _line(context, 'Category', ticket.category),
              ],
            ),
          ),
          SizedBox(height: context.h(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info, size: 16, color: profileAccent(context)),
              SizedBox(width: context.w(6)),
              Text(
                "We'll notify you once there is an update.",
                style: AppTypography.regular.copyWith(
                  fontSize: 12,
                  color: context.torkk.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.regular.copyWith(
                fontSize: 13,
                color: context.torkk.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
