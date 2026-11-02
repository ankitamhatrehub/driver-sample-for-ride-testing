import 'package:flutter/material.dart';

import 'package:rider_app/driver_features/settings/legal/legal_document_screen.dart';

class CancellationRefundPolicyScreen extends StatelessWidget {
  const CancellationRefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Cancellation & Refund Policy',
      blocks: _blocks,
    );
  }
}

const List<LegalBlock> _blocks = [
  LegalBlock.heading('CANCELLATION & REFUND POLICY'),
  LegalBlock.text(
    'Brand Name: Torkk | Operated by: BLACKORIGINX PRIVATE LIMITED',
  ),
  LegalBlock.text(
    'This Cancellation and Refund Policy ("Policy") establishes the terms, conditions, and operational parameters governing the cancellation of service bookings, allocation of convenience charges, and processing of monetary refunds for rides, deliveries, and associated mobility services provided through the Torkk mobile application or digital ecosystem. This Policy constitutes a binding legal addendum to the User Terms of Service between BLACKORIGINX PRIVATE LIMITED ("the Company", "Torkk", "We", "Us") and the registered consumer ("User", "Passenger", "You"). Torkk functions under strict compliance with the Consumer Protection Act, 2019, the Consumer Protection (E-Commerce) Rules, 2020, and the regulatory frameworks established by the Central Consumer Protection Authority (CCPA) and the Reserve Bank of India (RBI).',
  ),
  LegalBlock.heading('1. Core Definitions & Policy Scope'),
  LegalBlock.text(
    '1.1 Platform Services: Refers to the ride-hailing, bike-taxi matching, auto-rickshaw pooling, hyper-local package delivery, and courier logistics software routed via the Torkk app. 1.2 Torkk Captain / Partner: The independent driver, vehicle operator, or delivery rider contracted to fulfill the transaction requested by the User.',
  ),
  LegalBlock.text(
    '1.3 Booking Confirmation: The precise moment the Torkk algorithmic engine matches a User\'s request with a nearby Captain, generating a unique booking ID.',
  ),
  LegalBlock.heading(
    '2. Passenger / User Cancellations & Associated Fee Structure',
  ),
  LegalBlock.text(
    '2.1 Free Cancellation Window: A User may cancel a confirmed ride or logistics order without incurring any financial fee within exactly three (3.00) minutes from the moment a Torkk Captain accepts the assignment.',
  ),
  LegalBlock.text(
    '2.2 Late Cancellation Surcharge: If a User cancels a transaction after the expiration of the three-minute free window, or after the assigned Captain has already reached the designated pickup coordinate, a dynamic cancellation fee will be levied.',
  ),
  LegalBlock.text(
    '2.3 User No-Show Threshold: If the Captain arrives at the pickup point, attempts communication, and waits for more than five (5.00) minutes without the User boarding the vehicle or handing over the cargo, the Captain is authorized to cancel the ride. This will result in a standard User No-Show charge added to the User\'s next invoice.',
  ),
  LegalBlock.text(
    '2.4 Cancellation Fee Caps: All cancellation charges are algorithmically calculated based on distance traveled by the Captain toward the pickup and regional caps, conforming with local state aggregate rules.',
  ),
  LegalBlock.heading(
    '3. Service Failures, Platform Errors & System Exemptions',
  ),
  LegalBlock.text(
    '3.1 Driver-Side Cancellations: If an assigned Captain cancels a booking or fails to arrive at the coordinate entirely, no cancellation fee will be assessed against the User. Any advance collection will be instantly rolled back.',
  ),
  LegalBlock.text(
    '3.2 Excessive Arrival Latency: No cancellation charge shall be applied if the User cancels a ride due to severe Captain delay, defined as the Captain arriving more than five (5.00) minutes past the original Estimated Time of Arrival (ETA) shown during booking.',
  ),
  LegalBlock.text(
    '3.3 Mid-Transit Mechanical Breakdowns: In the event of a vehicle accident, structural failure, or regulatory impound during an active trip, the current fare is voided. Torkk will either auto-route a replacement Captain or issue a full transaction reversal.',
  ),
  LegalBlock.text(
    '3.4 Technical Transaction Discrepancies: In instances where user bank accounts, credit cards, or UPI links are debited but network failure prevents booking confirmation on the Torkk application, the captured amount will be systematically logged for an automatic refund.',
  ),
  LegalBlock.heading('4. Statutory CCPA Refund Mechanisms & User Autonomy'),
  LegalBlock.text(
    '4.1 Prohibition of Forced App Credits: In strict compliance with the Central Consumer Protection Authority (CCPA) mandates, Torkk firmly rejects the practice of forcing consumers to accept platform coupons, app credits, or closed-loop digital tokens for failed services. 4.2 Explicit Consumer Selection: Whenever a refund arises, the Torkk interface will present an unselected, clear, and equal choice to the consumer to determine their preferred destination channel. 4.4 Refund Destination Channels: The consumer can voluntarily route their funds to: (a) The Original Payment Source (Direct settlement reversal to the originating UPI ID, Bank Account, NetBanking layout, or Credit/Debit Card network); or (b) The Torkk App Wallet (An instant credit balance valid for future mobility or logistics consumption across the Torkk ecosystem).',
  ),
  LegalBlock.heading('5. Settlement Timelines & Banking Protocols'),
  LegalBlock.text(
    '5.1 Internal Torkk Processing: Upon audit approval of a cancellation dispute or technical failure, Torkk initiates corporate clearing mandates within 24 to 48 hours.',
  ),
  LegalBlock.text(
    '5.2 Financial Institution Clearing Cycles: For direct source-account reversals, actual credit reflection is governed by clearing timelines: (a) UPI Transfers: 1 to 3 business days; (b) Credit/Debit Cards & NetBanking: 5 to 7 business days, dependent on the User\'s card-issuing bank and centralized merchant aggregators.',
  ),
  LegalBlock.heading('6. Consumer Grievance Redressal & Disputes'),
  LegalBlock.text(
    '6.1 Window of Dispute Filing: Users must lodge any objections regarding wrongful cancellation fees or missing refund items within thirty (30) days from the specific booking date. 6.2 Redressal Pathways: Disputes can be formally logged via the dedicated \'Help Center\' tab inside the Torkk mobile app, or by transmitting an email containing booking references to support@torkk.in.',
  ),
  LegalBlock.text(
    '6.3 Escalation Protocol: Pursuant to the Consumer Protection (E-Commerce) Rules, 2020, unresolved consumer grievances can be escalated to the designated Nodal Grievance Officer of BLACKORIGINX PRIVATE LIMITED.',
  ),
  LegalBlock.text(
    'Corporate Compliance Operations | BLACKORIGINX PRIVATE LIMITED',
  ),
];
