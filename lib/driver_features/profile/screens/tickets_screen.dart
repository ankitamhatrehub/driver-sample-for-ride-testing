import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

enum TicketStatus { underReview, resolved, closed }

class SupportTicket {
  SupportTicket({
    required this.orderId,
    required this.title,
    required this.date,
    required this.status,
    required this.issue,
    required this.category,
    required this.description,
    this.created = '12 jan , 02:34 am',
    this.updated = '12 jan , 02:34 am',
    List<String>? photos,
  }) : photos = photos ?? [];

  final String orderId;
  final String title;
  final String date;
  TicketStatus status;
  final String issue;
  final String category;
  final String description;
  final String created;
  final String updated;
  final List<String> photos;

  String get chip {
    return switch (status) {
      TicketStatus.underReview => 'Under Review',
      TicketStatus.resolved => 'Resolved',
      TicketStatus.closed => 'Closed',
    };
  }

  Color get chipColor {
    return switch (status) {
      TicketStatus.underReview => const Color(0xFFF59E0B),
      TicketStatus.resolved => const Color(0xFF16A34A),
      TicketStatus.closed => const Color(0xFF64748B),
    };
  }
}

final List<SupportTicket> supportTickets = [
  SupportTicket(
    orderId: '#ORD98232',
    title: 'Payment not received',
    date: '12 Aug, 2026',
    status: TicketStatus.underReview,
    issue: 'Delivery Issue',
    category: 'Parcel Delayed',
    description: "My parcel is delayed and hasn't arrived yet",
  ),
  SupportTicket(
    orderId: '#ORD98232',
    title: 'Payment not received',
    date: '12 Aug, 2026',
    status: TicketStatus.resolved,
    issue: 'Delivery Issue',
    category: 'Parcel Delayed',
    description: "My parcel is delayed and hasn't arrived yet",
  ),
  SupportTicket(
    orderId: '#ORD98232',
    title: 'Payment not received',
    date: '12 Aug, 2026',
    status: TicketStatus.closed,
    issue: 'Delivery Issue',
    category: 'Parcel Delayed',
    description: "My parcel is delayed and hasn't arrived yet",
  ),
  SupportTicket(
    orderId: '#ORD98232',
    title: 'Payment not received',
    date: '12 Aug, 2026',
    status: TicketStatus.underReview,
    issue: 'Delivery Issue',
    category: 'Parcel Delayed',
    description: "My parcel is delayed and hasn't arrived yet",
  ),
];

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
                        color: _tab == i ? accent : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(context.r(10)),
                      ),
                      child: Text(
                        tabs[i],
                        style: AppTypography.regular.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _tab == i ? Colors.white : AppColors.slate500,
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
              child: _ticketCard(
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
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(16)),
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
                MaterialPageRoute<void>(builder: (_) => FollowUpScreen(ticket: ticket)),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: profileAccent(context),
              side: BorderSide(color: profileAccent(context)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
            ),
            child: Text(
              reopen ? 'Reopen Ticket' : 'Follow up',
              style: AppTypography.bold.copyWith(fontSize: 15, height: 1, color: profileAccent(context)),
            ),
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(12)),
        children: [
          _ticketCard(context, ticket),
          SizedBox(height: context.h(16)),
          _timeline(context, ticket.status),
          SizedBox(height: context.h(16)),
          _metaCard(context, ticket),
          SizedBox(height: context.h(8)),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => TicketFullDetailsScreen(ticket: ticket)),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(8)),
              child: Row(
                children: [
                  Text('View Details', style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: profileAccent(context))),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: profileAccent(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
          _ticketCard(context, ticket),
          SizedBox(height: context.h(14)),
          _pair('Created', ticket.created),
          _pair('Last Updated', ticket.updated),
          _pair('Issue', ticket.issue, bold: true),
          _pair('Category', ticket.category, bold: true),
          SizedBox(height: context.h(8)),
          Text('Description', style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500)),
          Text(ticket.description, style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: context.h(12)),
          Text('Attachments', style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500)),
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
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text('+${ticket.photos.length - 2}', style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pair(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500))),
          Text(value, style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}

class FollowUpScreen extends StatefulWidget {
  const FollowUpScreen({super.key, required this.ticket});

  final SupportTicket ticket;

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Follow up',
      bottom: _filled(context, 'Submit', () => Navigator.of(context).pop()),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(4), context.w(20), context.h(12)),
        children: [
          Text(
            'Add additional information to follow up on this ticket.',
            style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500),
          ),
          SizedBox(height: context.h(12)),
          _ticketCard(context, widget.ticket),
          SizedBox(height: context.h(16)),
          Text('Add your message here', style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: context.h(8)),
          _commentBox(context, _note, () => setState(() {})),
        ],
      ),
    );
  }
}

class IssueCategoryScreen extends StatelessWidget {
  const IssueCategoryScreen({super.key});

  static const _categories = [
    (Icons.receipt_long_rounded, Color(0xFFF59E0B), Color(0xFFFEF3C7), 'Earning & Payments'),
    (Icons.local_shipping_outlined, Color(0xFF7C3AED), Color(0xFFF3E8FF), 'Delivery Issue'),
    (Icons.phone_iphone_rounded, Color(0xFF7C3AED), Color(0xFFF3E8FF), 'App Issues'),
    (Icons.badge_outlined, Color(0xFF7C3AED), Color(0xFFF3E8FF), 'Account & Documents'),
  ];

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Select Issue Category',
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(4), context.w(20), context.h(20)),
        children: [
          Text('Choose the category that best match your issue', style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500)),
          SizedBox(height: context.h(12)),
          for (final item in _categories)
            _choice(
              context,
              icon: item.$1,
              color: item.$2,
              background: item.$3,
              label: item.$4,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => IssueProblemScreen(category: item.$4)),
                );
              },
            ),
        ],
      ),
    );
  }
}

class IssueProblemScreen extends StatelessWidget {
  const IssueProblemScreen({super.key, required this.category});

  final String category;

  List<(IconData, String)> get _problems {
    if (category == 'Earning & Payments') {
      return [
        (Icons.receipt_long_rounded, 'Payment not received'),
        (Icons.sell_outlined, 'Wrong fare'),
      ];
    }
    if (category == 'Delivery Issue') {
      return [
        (Icons.inventory_2_outlined, 'Parcel Delayed'),
        (Icons.phone_disabled_outlined, 'Sender not picking up the call'),
      ];
    }
    return [
      (Icons.bug_report_outlined, 'App not opening'),
      (Icons.location_off_outlined, 'Location not updating'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Select Specific Problem',
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(4), context.w(20), context.h(20)),
        children: [
          Text('Choose the issue you are facing', style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500)),
          SizedBox(height: context.h(12)),
          for (final item in _problems)
            _choice(
              context,
              icon: item.$1,
              color: category == 'Earning & Payments' ? const Color(0xFFF59E0B) : const Color(0xFF7C3AED),
              background: category == 'Earning & Payments' ? const Color(0xFFFEF3C7) : const Color(0xFFF3E8FF),
              label: item.$2,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AddPhotosScreen(category: category, problem: item.$2),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class AddPhotosScreen extends StatefulWidget {
  const AddPhotosScreen({super.key, required this.category, required this.problem});

  final String category;
  final String problem;

  @override
  State<AddPhotosScreen> createState() => _AddPhotosScreenState();
}

class _AddPhotosScreenState extends State<AddPhotosScreen> {
  final _photos = <String>[];

  Future<void> _add() async {
    final photo = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (photo == null) return;
    setState(() => _photos.add(photo.path));
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Add Photos',
      trailing: Icon(Icons.help_outline_rounded, color: profileAccent(context)),
      bottom: _filled(context, AppStrings.continueAction, () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AdditionalDetailsScreen(
              category: widget.category,
              problem: widget.problem,
              photos: List<String>.from(_photos),
            ),
          ),
        );
      }),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), 0, context.w(20), context.h(12)),
        children: [
          Text(
            'Add clear photos to help us understand the issue (Optional)',
            style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500),
          ),
          SizedBox(height: context.h(14)),
          Wrap(
            spacing: context.w(10),
            runSpacing: context.h(10),
            children: [
              _addTile(context),
              for (var i = 0; i < _photos.length; i++)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(context.r(12)),
                      child: Image.file(File(_photos[i]), width: context.w(96), height: context.w(96), fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.removeAt(i)),
                        child: const CircleAvatar(radius: 10, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 12, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: context.h(16)),
          Container(
            padding: EdgeInsets.all(context.w(12)),
            decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(context.r(12))),
            child: Row(
              children: [
                Icon(Icons.photo_camera_outlined, color: profileAccent(context), size: context.w(18)),
                SizedBox(width: context.w(8)),
                Expanded(
                  child: Text(
                    'Take photos of the location , parcel or any relevant details.',
                    style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addTile(BuildContext context) {
    return GestureDetector(
      onTap: _add,
      child: Container(
        width: context.w(96),
        height: context.w(96),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(context.r(12)),
          border: Border.all(color: const Color(0xFFE9D5FF)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera_outlined, color: profileAccent(context)),
            Text('Add Photo', style: AppTypography.regular.copyWith(fontSize: 11, color: profileAccent(context))),
          ],
        ),
      ),
    );
  }
}

class AdditionalDetailsScreen extends StatefulWidget {
  const AdditionalDetailsScreen({super.key, required this.category, required this.problem, required this.photos});

  final String category;
  final String problem;
  final List<String> photos;

  @override
  State<AdditionalDetailsScreen> createState() => _AdditionalDetailsScreenState();
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
      description: _note.text.trim().isEmpty ? _notes[_selected] : _note.text.trim(),
      photos: widget.photos,
    );
    supportTickets.insert(0, ticket);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => IssueSubmittedScreen(ticket: ticket)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Additional Details',
      bottom: _filled(context, 'Submit Issue', _submit),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), 0, context.w(20), context.h(12)),
        children: [
          Text(
            'Add any additional information to help us resolve the issue.',
            style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500),
          ),
          SizedBox(height: context.h(14)),
          Text('Quick notes (optional)', style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: context.h(8)),
          for (var i = 0; i < _notes.length; i++)
            GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: Container(
                margin: EdgeInsets.only(bottom: context.h(8)),
                padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(14)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.r(12)),
                  border: Border.all(color: const Color(0xFFE8EDF5)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(_notes[i], style: AppTypography.regular.copyWith(fontSize: 14))),
                    Icon(
                      _selected == i ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: _selected == i ? profileAccent(context) : AppColors.slate400,
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: context.h(8)),
          Text('Add more details (optional)', style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: context.h(8)),
          _commentBox(context, _note, () => setState(() {})),
        ],
      ),
    );
  }
}

class IssueSubmittedScreen extends StatelessWidget {
  const IssueSubmittedScreen({super.key, required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: '',
      bottom: _filled(context, 'View Ticket Details', () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => TicketDetailsScreen(ticket: ticket)),
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
              decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
              child: Icon(Icons.check_rounded, color: const Color(0xFF16A34A), size: context.w(36)),
            ),
          ),
          SizedBox(height: context.h(16)),
          Text('Issue Submitted', textAlign: TextAlign.center, style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2, letterSpacing: -0.3)),
          Text(
            'Your request has been submitted successfully',
            textAlign: TextAlign.center,
            style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500),
          ),
          SizedBox(height: context.h(18)),
          Container(
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: const Color(0xFFE8EDF5)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Ticket ID', style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500))),
                    Text('# tk2345', style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2, letterSpacing: -0.2)),
                    IconButton(
                      onPressed: () => Clipboard.setData(const ClipboardData(text: 'tk2345')),
                      icon: Icon(Icons.copy_rounded, size: 16, color: profileAccent(context)),
                    ),
                  ],
                ),
                _line('Issue', ticket.issue),
                _line('Category', ticket.category),
              ],
            ),
          ),
          SizedBox(height: context.h(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info, size: 16, color: profileAccent(context)),
              SizedBox(width: context.w(6)),
              Text("We'll notify you once there is an update.", style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500))),
          Text(value, style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

Widget _ticketCard(BuildContext context, SupportTicket ticket, {VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(context.r(16)),
    child: Container(
      padding: EdgeInsets.all(context.w(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(36),
            height: context.w(36),
            decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(context.r(10))),
            child: Icon(Icons.confirmation_number_outlined, color: const Color(0xFF7C3AED), size: context.w(18)),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.orderId, style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2, letterSpacing: -0.2)),
                Text(ticket.title, style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500)),
                Text(ticket.date, style: AppTypography.regular.copyWith(fontSize: 11, color: AppColors.slate400)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.w(8), vertical: context.h(3)),
            decoration: BoxDecoration(
              color: ticket.chipColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
            child: Text(ticket.chip, style: AppTypography.regular.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: ticket.chipColor)),
          ),
          if (onTap != null) Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: context.w(18)),
        ],
      ),
    ),
  );
}

Widget _timeline(BuildContext context, TicketStatus status) {
  final steps = [
    ('Submitted', '12 Jan 2026, 10:24 AM', true, false),
    ('Under Review', 'Our team is reviewing your request.', status != TicketStatus.underReview, status == TicketStatus.underReview),
    (
      status == TicketStatus.underReview ? 'Waiting for Confirmation' : 'Confirmed',
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
                  color: steps[i].$3 || steps[i].$4 ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                  size: context.w(18),
                ),
                if (i < steps.length - 1)
                  Container(width: 2, height: context.h(28), color: const Color(0xFFDCFCE7)),
              ],
            ),
            SizedBox(width: context.w(10)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: context.h(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(steps[i].$1, style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                    if (steps[i].$2.isNotEmpty)
                      Text(steps[i].$2, style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500)),
                  ],
                ),
              ),
            ),
          ],
        ),
    ],
  );
}

Widget _metaCard(BuildContext context, SupportTicket ticket) {
  return Container(
    padding: EdgeInsets.all(context.w(14)),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(context.r(16)),
      border: Border.all(color: const Color(0xFFE8EDF5)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: Text('Issue', style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500))),
            Text(ticket.issue, style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        SizedBox(height: context.h(8)),
        Row(
          children: [
            Expanded(child: Text('Category', style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500))),
            Text(ticket.category, style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    ),
  );
}

Widget _choice(
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
        padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(14)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(14)),
          border: Border.all(color: const Color(0xFFE8EDF5)),
        ),
        child: Row(
          children: [
            Container(
              width: context.w(36),
              height: context.w(36),
              decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(context.r(10))),
              child: Icon(icon, color: color, size: context.w(18)),
            ),
            SizedBox(width: context.w(10)),
            Expanded(child: Text(label, style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: context.w(20)),
          ],
        ),
      ),
    ),
  );
}

Widget _commentBox(BuildContext context, TextEditingController controller, VoidCallback onChanged) {
  return TextField(
    controller: controller,
    maxLength: 200,
    maxLines: 4,
    onChanged: (_) => onChanged(),
    decoration: InputDecoration(
      hintText: 'Add a comment',
      hintStyle: AppTypography.regular.copyWith(fontSize: 14, color: AppColors.slate400),
      counterText: '${controller.text.length}/200',
      contentPadding: EdgeInsets.all(context.w(12)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.r(12)), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(context.r(12)), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    ),
  );
}

Widget _filled(BuildContext context, String label, VoidCallback onTap) {
  return Padding(
    padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(16)),
    child: SizedBox(
      width: double.infinity,
      height: context.h(48),
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: profileAccent(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
        ),
        child: Text(label, style: AppTypography.bold.copyWith(fontSize: 15, height: 1, color: Colors.white)),
      ),
    ),
  );
}
