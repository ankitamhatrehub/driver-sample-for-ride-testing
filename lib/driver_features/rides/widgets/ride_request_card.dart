import 'package:flutter/material.dart';
import 'timed_accept_ride_button.dart';

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

    final rawPhone = (ride['customer_phone'] ??
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

  Widget _buildPassengerGenderBadges(Map<String, dynamic> ride) {
    final dynamic maleVal =
        ride['male_passengers'] ?? ride['male_count'] ?? ride['males'];
    final dynamic femaleVal =
        ride['female_passengers'] ?? ride['female_count'] ?? ride['females'];
    final dynamic totalVal =
        ride['passenger_count'] ?? ride['total_passengers'] ?? ride['seats'];
    final String gender = (ride['gender'] ??
            ride['customer_gender'] ??
            ride['passenger_gender'] ??
            '')
        .toString()
        .trim()
        .toLowerCase();

    int? maleCount = (maleVal is num)
        ? maleVal.toInt()
        : int.tryParse(maleVal?.toString() ?? '');
    int? femaleCount = (femaleVal is num)
        ? femaleVal.toInt()
        : int.tryParse(femaleVal?.toString() ?? '');
    int totalCount = (totalVal is num)
        ? totalVal.toInt()
        : (int.tryParse(totalVal?.toString() ?? '') ?? 1);

    Widget badge1Content;
    Color badge1Color;
    Widget? badge2Content;
    Color badge2Color = const Color(0xFFEC4899);

    if (maleCount != null && femaleCount != null) {
      badge1Color = const Color(0xFF1D4ED8);
      badge1Content =
          const Icon(Icons.male_rounded, size: 18, color: Colors.white);
      if (femaleCount > 0) {
        badge2Color = const Color(0xFFEC4899);
        badge2Content = femaleCount > 1
            ? Text(
                '$femaleCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              )
            : const Icon(Icons.female_rounded, size: 18, color: Colors.white);
      }
    } else if (gender == 'female' || gender == 'f') {
      badge1Color = const Color(0xFFEC4899);
      badge1Content =
          const Icon(Icons.female_rounded, size: 18, color: Colors.white);
      if (totalCount > 1) {
        badge2Color = const Color(0xFF1D4ED8);
        badge2Content = Text(
          '+${totalCount - 1}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        );
      }
    } else {
      badge1Color = const Color(0xFF1D4ED8);
      badge1Content =
          const Icon(Icons.male_rounded, size: 18, color: Colors.white);
      if (totalCount > 1) {
        badge2Color = const Color(0xFFEC4899);
        badge2Content = Text(
          '+${totalCount - 1}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        );
      }
    }

    final bool hasSecondBadge = badge2Content != null;

    return SizedBox(
      width: hasSecondBadge ? 56 : 32,
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badge1Color,
                shape: BoxShape.circle,
              ),
              child: Center(child: badge1Content),
            ),
          ),
          if (hasSecondBadge)
            Positioned(
              left: 20,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: badge2Color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Center(child: badge2Content),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParcelBadges(Map<String, dynamic> ride) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981), // Emerald green
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            (ride['item_weight'] ?? 'Parcel').toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estFare = (ride['estimated_fare'] ??
            ride['fare'] ??
            ride['amount'] as num?)
        ?.toDouble() ??
        0.0;
    final bonusVal = (ride['bonus'] ??
            ride['incentive'] ??
            ride['extra_charge'] as num?)
        ?.toDouble();

    final pDist = (ride['pickup_distance_km'] ??
            ride['pickup_distance'] ??
            '')
        .toString();
    final pAddr = (ride['pickup_address'] ??
            ride['pickup_location'] ??
            ride['pickup'] ??
            '')
        .toString();
    final dDist = (ride['distance_km'] ??
            ride['drop_distance'] ??
            ride['distance'] ??
            '')
        .toString();
    final dAddr = (ride['drop_address'] ??
            ride['destination'] ??
            ride['drop'] ??
            '')
        .toString();

    final customerName = resolveCustomerName(ride);
    final customerRating = (ride['customer_rating'] ??
            ride['user_rating'] ??
            ride['rating'] ??
            '4.9')
        .toString();

    final bool isParcel = ride['is_parcel'] == true || ride['service_type'] == 'parcel';
    final displayName = isParcel ? 'Parcel: $customerName' : customerName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
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
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            customerRating,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB45309),
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
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
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
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pAddr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dDist.toLowerCase().contains('km')
                          ? dDist
                          : (dDist.isNotEmpty ? '$dDist Km' : ''),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dAddr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
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
