
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
