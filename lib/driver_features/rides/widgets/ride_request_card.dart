import 'package:flutter/material.dart';
import 'timed_accept_ride_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
part 'ride_request_card_sections.dart';

/// Individual ride request card displayed in the online search view list.
/// Features customer info, fare, bonuses, route addresses, passenger badges,
/// and the animated timed accept button.
class RideRequestCard extends StatelessWidget {
  final Map<String, dynamic> ride;
  final int index;
  final VoidCallback onAccept;
  final VoidCallback? onTimeout;

  const RideRequestCard({
    super.key,
    required this.ride,
    required this.index,
    required this.onAccept,
    this.onTimeout,
  });

  static String resolveCustomerName(Map<String, dynamic> ride) {
    final nameCandidates = [
      ride['customer_name'],
      ride['user_name'],
      ride['passenger_name'],
      ride['rider_name'],
      ride['client_name'],
      ride['name'],
      ride['full_name'],
      ride['customer'] is Map
          ? (ride['customer']['name'] ?? ride['customer']['full_name'])
          : ride['customer'],
      ride['user'] is Map
          ? (ride['user']['name'] ?? ride['user']['full_name'])
          : ride['user'],
      ride['rider'] is Map
          ? (ride['rider']['name'] ?? ride['rider']['full_name'])
          : ride['rider'],
      ride['passenger'] is Map
          ? (ride['passenger']['name'] ?? ride['passenger']['full_name'])
          : ride['passenger'],
    ];
    for (final c in nameCandidates) {
      if (c != null && c is String && c.trim().isNotEmpty) {
        return c.trim();
      }
    }

    final rawPhone =
        (ride['customer_phone'] ??
                ride['user_phone'] ??
                ride['phone'] ??
                ride['rider_phone'] ??
                '')
            .toString()
            .replaceAll(RegExp(r'\D'), '');
    if (rawPhone.isNotEmpty) {
      final formattedPhone = rawPhone.length == 10
          ? '+91 ${rawPhone.substring(0, 5)} ${rawPhone.substring(5)}'
          : rawPhone;
      return 'Customer ($formattedPhone)';
    }

    return 'Customer';
  }

  @override
  Widget build(BuildContext context) {
    final estFare =
        (ride['estimated_fare'] ?? ride['fare'] ?? ride['amount'] as num?)
            ?.toDouble() ??
        0.0;
    final bonusVal =
        (ride['bonus'] ?? ride['incentive'] ?? ride['extra_charge'] as num?)
            ?.toDouble();

    final pDist = (ride['pickup_distance_km'] ?? ride['pickup_distance'] ?? '')
        .toString();
    final pAddr =
        (ride['pickup_address'] ??
                ride['pickup_location'] ??
                ride['pickup'] ??
                '')
            .toString();
    final dDist =
        (ride['distance_km'] ?? ride['drop_distance'] ?? ride['distance'] ?? '')
            .toString();
    final dAddr =
        (ride['drop_address'] ?? ride['destination'] ?? ride['drop'] ?? '')
            .toString();

    final customerName = resolveCustomerName(ride);
    final customerRating =
        (ride['customer_rating'] ??
                ride['user_rating'] ??
                ride['rating'] ??
                '4.9')
            .toString();

    final bool isParcel =
        ride['is_parcel'] == true || ride['service_type'] == 'parcel';
    final displayName = isParcel ? 'Parcel: $customerName' : customerName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.torkk.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Customer Full Name + Rating on Left, Gender Circles on Right
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: context.torkk.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.adaptiveTint(const Color(0xFFFEF3C7)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: context.legible(Color(0xFFD97706)),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            customerRating,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: context.legible(Color(0xFFB45309)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isParcel)
                _buildParcelBadges(ride)
              else
                _buildPassengerGenderBadges(ride),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Dynamic Fare & Bonus
          Row(
            children: [
              Text(
                '₹ ${estFare.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: context.torkk.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (bonusVal != null && bonusVal > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '+ ₹ ${bonusVal.round()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ],
          ),
          if (isParcel && ride['item_category'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Category: ${ride['item_category']}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.torkk.textBody,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Vertical Route Timeline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D4ED8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 36,
                    color: const Color(0xFF1D4ED8),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D4ED8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pDist.toLowerCase().contains('km')
                          ? pDist
                          : (pDist.isNotEmpty ? '$pDist Km' : ''),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: context.torkk.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pAddr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.torkk.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dDist.toLowerCase().contains('km')
                          ? dDist
                          : (dDist.isNotEmpty ? '$dDist Km' : ''),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: context.torkk.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dAddr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.torkk.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Animated Timed Accept Ride Button
          TimedAcceptRideButton(
            key: ValueKey('accept_button_${ride['id']}'),
            rideId: ride['id'] is int
                ? ride['id']
                : (int.tryParse('${ride['id']}') ?? 0),
            timeoutSeconds: 20,
            onAccept: onAccept,
            onTimeout: () {
              if (onTimeout != null) {
                onTimeout!();
              }
            },
          ),
        ],
      ),
    );
  }
}
