import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/profile/models/support_ticket.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/issue_submitted_screen.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_widgets.dart';

class AdditionalDetailsScreen extends StatefulWidget {
  const AdditionalDetailsScreen({
    super.key,
    required this.category,
    required this.problem,
    required this.photos,
  });

  final String category;
  final String problem;
  final List<String> photos;

  @override
  State<AdditionalDetailsScreen> createState() =>
      _AdditionalDetailsScreenState();
}

class _AdditionalDetailsScreenState extends State<AdditionalDetailsScreen> {
  final _note = TextEditingController();
  int _selected = 0;
  static const _notes = [
    'Sender not picking up the call',
    'Parcel has not been delivered',
    'Wrong drop location',
    'Payment is still pending',
  ];

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    final ticket = SupportTicket(
      orderId: '#ORD98232',
      title: widget.problem,
      date: '12 Aug, 2026',
      status: TicketStatus.underReview,
      issue: widget.category,
      category: widget.problem,
      description: _note.text.trim().isEmpty
          ? _notes[_selected]
          : _note.text.trim(),
      photos: widget.photos,
    );
    supportTickets.insert(0, ticket);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => IssueSubmittedScreen(ticket: ticket),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Additional Details',
      bottom: ticketFilled(context, 'Submit Issue', _submit),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          0,
          context.w(20),
          context.h(12),
        ),
        children: [
          Text(
            'Add any additional information to help us resolve the issue.',
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(14)),
          Text(
            'Quick notes (optional)',
            style: AppTypography.regular.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.h(8)),
          for (var i = 0; i < _notes.length; i++)
            GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: Container(
                margin: EdgeInsets.only(bottom: context.h(8)),
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(14),
                  vertical: context.h(14),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.r(12)),
                  border: Border.all(color: context.torkk.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _notes[i],
                        style: AppTypography.regular.copyWith(fontSize: 14),
                      ),
                    ),
                    Icon(
                      _selected == i
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: _selected == i
                          ? profileAccent(context)
                          : AppColors.slate400,
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: context.h(8)),
          Text(
            'Add more details (optional)',
            style: AppTypography.regular.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.h(8)),
          ticketCommentBox(context, _note, () => setState(() {})),
        ],
      ),
    );
  }
}
