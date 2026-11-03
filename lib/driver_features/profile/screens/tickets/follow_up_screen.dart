import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/profile/models/support_ticket.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_widgets.dart';
import 'package:rider_app/service/support_api_service.dart';

class FollowUpScreen extends StatefulWidget {
  const FollowUpScreen({super.key, required this.ticket});

  final SupportTicket ticket;

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  final _note = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _note.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please add a message.')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await SupportApiService.followUp(widget.ticket.ticketId, message);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Follow-up sent')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Follow up',
      bottom: ticketFilled(context, 'Submit', _submit, loading: _submitting),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(4),
          context.w(20),
          context.h(12),
        ),
        children: [
          Text(
            'Add additional information to follow up on this ticket.',
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(12)),
          ticketCard(context, widget.ticket),
          SizedBox(height: context.h(16)),
          Text(
            'Add your message here',
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
