import 'package:flutter/material.dart';

enum TicketStatus { underReview, resolved, closed }

const _months = [
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

/// "2026-11-03T10:30:00Z" -> "3 Nov, 2026" (local time). Empty if unparsable.
String formatTicketDate(Object? iso) {
  final d = DateTime.tryParse('${iso ?? ''}')?.toLocal();
  if (d == null) return '';
  return '${d.day} ${_months[d.month - 1]}, ${d.year}';
}

class SupportTicket {
  SupportTicket({
    required this.ticketId,
    required this.ticketNumber,
    required this.title,
    required this.date,
    required this.status,
    required this.issue,
    required this.category,
    required this.description,
    this.rawStatus = '',
    this.created = '',
    this.updated = '',
    this.canFollowUp = true,
    this.canReopen = false,
    List<String>? photos,
    List<String>? attachments,
  }) : photos = photos ?? [],
       attachments = attachments ?? [];

  /// Parses a list item or detail payload from the support-tickets API.
  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final raw = '${json['status'] ?? ''}';
    final problem = '${json['problem'] ?? ''}';
    final created = formatTicketDate(json['created_at']);
    final status = statusFromApi(raw);
    return SupportTicket(
      ticketId: '${json['ticket_id'] ?? ''}',
      ticketNumber: '${json['ticket_number'] ?? ''}',
      title: problem,
      date: created,
      status: status,
      rawStatus: raw,
      issue: '${json['category'] ?? ''}',
      category: problem,
      description: '${json['description'] ?? ''}',
      created: created,
      updated: formatTicketDate(json['updated_at']),
      canFollowUp:
          json['can_follow_up'] as bool? ?? status == TicketStatus.underReview,
      canReopen: json['can_reopen'] as bool? ?? false,
      attachments: [
        for (final a in (json['attachments'] as List? ?? const []))
          a.toString(),
      ],
    );
  }

  static TicketStatus statusFromApi(String raw) => switch (raw) {
    'resolved' => TicketStatus.resolved,
    'closed' => TicketStatus.closed,
    _ => TicketStatus.underReview,
  };

  final String ticketId;
  final String ticketNumber;
  final String title;
  final String date;
  TicketStatus status;
  final String rawStatus;
  final String issue;
  final String category;
  final String description;
  final String created;
  final String updated;
  final bool canFollowUp;
  final bool canReopen;

  /// Local file paths picked by the driver (only on a just-created ticket).
  final List<String> photos;

  /// Uploaded attachment URLs returned by the server.
  final List<String> attachments;

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
