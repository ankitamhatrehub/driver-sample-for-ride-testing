import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class NavigationRideCard extends StatelessWidget {
  final Map<String, dynamic>? ride;
  final bool isAccept;
  final bool isDrop;
  final Position? currentPosition;
  final VoidCallback onNavigate;
  final VoidCallback onChat;
  final VoidCallback onCall;
  final void Function({
    required String title,
    required String address,
    required String distanceText,
    required Color color,
    double? lat,
    double? lng,
  }) onLocationTap;
  final Widget sliderButton;

  const NavigationRideCard({
    super.key,
    required this.ride,
    required this.isAccept,
    required this.isDrop,
    required this.currentPosition,
    required this.onNavigate,
    required this.onChat,
    required this.onCall,
    required this.onLocationTap,
    required this.sliderButton,
  });

  static double? _asDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  static String _resolveRideCustomerName(Map<String, dynamic>? ride) {
    if (ride == null) return 'Customer';
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
      if (c != null &&
          c is String &&
          c.trim().isNotEmpty &&
          c.trim() != 'Passenger') {
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

  @override
  Widget build(BuildContext context) {
    final bool isParcel = ride?['is_parcel'] == true || ride?['service_type'] == 'parcel';
    final rawCustomerName = _resolveRideCustomerName(ride);
    final customerName = isParcel 
        ? (isDrop ? (ride?['receiver_name'] ?? rawCustomerName) : (ride?['sender_name'] ?? rawCustomerName))
        : rawCustomerName;
    
    final displayName = isParcel
        ? (isDrop ? 'Receiver: $customerName' : 'Sender: $customerName')
        : customerName;

    final customerInitial = customerName.trim().isNotEmpty
        ? customerName.trim()[0].toUpperCase()
        : 'C';
    final rawRating = (ride?['customer_rating'] ??
            ride?['user_rating'] ??
            ride?['rating'])
        ?.toString();
    final customerRating = (rawRating != null && rawRating.isNotEmpty)
        ? rawRating.replaceAll('+', '').trim()
        : null;
    final estimatedFare = (ride?['estimated_fare'] ??
            ride?['fare'] ??
            ride?['total_fare'] ??
            ride?['amount'] as num?)
        ?.toDouble() ??
        0.0;
    final bonusVal =
        (ride?['bonus'] ??
                ride?['incentive'] ??
                ride?['extra_charge'] as num?)
            ?.toDouble();
    final pickupAddress = (ride?['pickup_address'] ??
            ride?['pickup_location'] ??
            ride?['pickup_name'] ??
            '')
        .toString();
    final dropAddress = (ride?['drop_address'] ??
            ride?['drop_location'] ??
            ride?['drop_name'] ??
            '')
        .toString();

    // Dynamically calculate GPS distance to pickup with sanity check
    double? pickupDistKm;
    final pickupLat = _asDouble(ride?['pickup_lat']);
    final pickupLng = _asDouble(ride?['pickup_lng']);
    if (currentPosition != null &&
        pickupLat != null &&
        pickupLng != null &&
        pickupLat != 0.0 &&
        pickupLng != 0.0 &&
        currentPosition!.latitude != 0.0 &&
        currentPosition!.longitude != 0.0) {
      final distM = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        pickupLat,
        pickupLng,
      );
      pickupDistKm = distM / 1000.0;
      if (pickupDistKm > 500) {
        pickupDistKm = null;
      }
    }
    final pickupDistText = pickupDistKm != null
        ? '${pickupDistKm.toStringAsFixed(1)} Km'
        : (ride?['pickup_distance_km'] != null
              ? '${ride!['pickup_distance_km']} Km'
              : (ride?['pickup_distance'] != null
                    ? '${ride!['pickup_distance']} Km'
                    : ''));

    // Dynamically calculate distance to drop with sanity check
    double? dropDistKm;
    final dropLat = _asDouble(ride?['drop_lat']);
    final dropLng = _asDouble(ride?['drop_lng']);
    if (isDrop &&
        currentPosition != null &&
        dropLat != null &&
        dropLng != null &&
        dropLat != 0.0 &&
        dropLng != 0.0) {
      final distM = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        dropLat,
        dropLng,
      );
      dropDistKm = distM / 1000.0;
      if (dropDistKm > 500) dropDistKm = null;
    } else if (pickupLat != null &&
        pickupLng != null &&
        dropLat != null &&
        dropLng != null &&
        pickupLat != 0.0 &&
        dropLat != 0.0) {
      final distM = Geolocator.distanceBetween(
        pickupLat,
        pickupLng,
        dropLat,
        dropLng,
      );
      dropDistKm = distM / 1000.0;
      if (dropDistKm > 500) dropDistKm = null;
    } else if (ride?['distance_km'] != null) {
      dropDistKm = _asDouble(ride!['distance_km']);
    }
    final dropDistText = dropDistKm != null
        ? '${dropDistKm.toStringAsFixed(1)} Km'
        : (ride?['distance_km'] != null
              ? '${ride!['distance_km']} Km'
              : (ride?['distance'] != null
                    ? '${ride!['distance']} Km'
                    : ''));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. If RideAccept (RideCard2): Show Fare at the top
          if (isAccept) ...[
            Row(
              children: [
                Text(
                  '₹ ${estimatedFare > 0 ? estimatedFare.toStringAsFixed(2) : '0.00'}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                if (bonusVal != null && bonusVal > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+₹ ${bonusVal.round()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                GestureDetector(
                  onTap: onNavigate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.navigation_rounded,
                          size: 14,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Navigate',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // 2. Passenger / Sender / Receiver Row
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isParcel ? const Color(0xFF10B981) : const Color(0xFF1D4ED8),
                backgroundImage: (!isParcel && ride?['customer_photo'] != null &&
                        ride!['customer_photo'].toString().isNotEmpty)
                    ? NetworkImage(ride!['customer_photo']) as ImageProvider
                    : null,
                child: isParcel
                    ? const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 24)
                    : ((ride?['customer_photo'] == null ||
                            ride!['customer_photo'].toString().isEmpty)
                        ? Text(
                            customerInitial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        : null),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isParcel && customerRating != null && customerRating.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Color(0xFFEAB308),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            customerRating,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (isParcel && ride?['item_category'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Category: ${ride!['item_category']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onChat,
                icon: Image.asset(
                  'assets/chat_icon.png',
                  width: 22,
                  height: 22,
                  color: const Color(0xFF334155),
                ),
              ),
              IconButton(
                onPressed: onCall,
                icon: Image.asset(
                  'assets/call_icon.png',
                  width: 22,
                  height: 22,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3. Stops Section
          // Stop 1: Pickup Location
          GestureDetector(
            onTap: () {
              onLocationTap(
                title: 'Pickup Location',
                address: pickupAddress,
                distanceText: pickupDistText,
                color: const Color(0xFF2563EB),
                lat: pickupLat,
                lng: pickupLng,
              );
            },
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pickupDistText.isNotEmpty)
                        Text(
                          pickupDistText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        pickupAddress.isNotEmpty
                            ? pickupAddress
                            : 'Pickup Location',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    onLocationTap(
                      title: 'Pickup Location',
                      address: pickupAddress,
                      distanceText: pickupDistText,
                      color: const Color(0xFF2563EB),
                      lat: pickupLat,
                      lng: pickupLng,
                    );
                  },
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          // Connecting blue vertical line
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 2,
                height: 16,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
          // Stop 2: Drop Location
          GestureDetector(
            onTap: () {
              onLocationTap(
                title: 'Drop Location',
                address: dropAddress,
                distanceText: dropDistText,
                color: isDrop
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                lat: dropLat,
                lng: dropLng,
              );
            },
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isDrop
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (dropDistText.isNotEmpty)
                        Text(
                          dropDistText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        dropAddress.isNotEmpty ? dropAddress : 'Drop Location',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    onLocationTap(
                      title: 'Drop Location',
                      address: dropAddress,
                      distanceText: dropDistText,
                      color: isDrop
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      lat: dropLat,
                      lng: dropLng,
                    );
                  },
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Slide to Start/Complete the Ride
          sliderButton,
        ],
      ),
    );
  }
}
