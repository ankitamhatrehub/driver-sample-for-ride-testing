import 'package:flutter/material.dart';
import 'package:rider_app/driver_features/home/widgets/widgets.dart';

class DriverHomeTab extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggleOnline;
  final String driverName;
  final String driverGender;
  final double driverRating;
  final double todayEarnings;
  final double incentives;
  final String goalsCompleted;
  final String upiId;
  final List<dynamic> lastTrips;
  final String profileImageUrl;
  final VoidCallback onMenuTap;
  final VoidCallback onProfileTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onAllTripsTap;
  final VoidCallback? onEarningsTap;
  final bool eligibleForParcels;
  final bool wantsRides;
  final bool wantsParcels;
  final Function(bool) onWantsRidesChanged;
  final Function(bool) onWantsParcelsChanged;

  const DriverHomeTab({
    super.key,
    required this.isOnline,
    required this.onToggleOnline,
    required this.driverName,
    this.driverGender = 'Male',
    this.driverRating = 5.0,
    required this.todayEarnings,
    required this.incentives,
    required this.goalsCompleted,
    required this.upiId,
    required this.lastTrips,
    required this.profileImageUrl,
    required this.onMenuTap,
    required this.onProfileTap,
    this.onNotificationsTap,
    this.onAllTripsTap,
    this.onEarningsTap,
    this.eligibleForParcels = false,
    this.wantsRides = true,
    this.wantsParcels = true,
    required this.onWantsRidesChanged,
    required this.onWantsParcelsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tripsToDisplay = lastTrips;
    final double displayEarnings = todayEarnings;
    final double displayIncentives = incentives;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtextColor = isDark ? Colors.grey.shade400 : const Color(0xFF6B7280);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE5E7EB);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        children: [
          // Top Header Row (Notification Bell | OFFLINE/ONLINE Pill | Profile Avatar)
          HomeHeaderRow(
            isOnline: isOnline,
            onToggleOnline: onToggleOnline,
            onProfileTap: onProfileTap,
            onNotificationsTap: onNotificationsTap,
            profileImageUrl: profileImageUrl,
            driverGender: driverGender,
          ),
          const SizedBox(height: 16),
          
          // Service Preferences (Only shown if offline and eligible for parcels)
          if (!isOnline && eligibleForParcels)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Online for:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          value: wantsRides,
                          onChanged: (val) {
                            if (val != null) onWantsRidesChanged(val);
                          },
                          title: const Text('Rides', style: TextStyle(fontWeight: FontWeight.w600)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: const Color(0xFF1D4ED8),
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          value: wantsParcels,
                          onChanged: (val) {
                            if (val != null) onWantsParcelsChanged(val);
                          },
                          title: const Text('Parcels', style: TextStyle(fontWeight: FontWeight.w600)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: const Color(0xFF1D4ED8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Earnings Hero Card (Purple Gradient)
          EarningsHeroCard(
            earnings: displayEarnings,
            onTap: onEarningsTap,
          ),
          const SizedBox(height: 16),

          // Metrics Row (Incentives & Rating Cards)
          HomeMetricsRow(
            incentives: displayIncentives,
            driverRating: driverRating,
            onIncentivesTap: onEarningsTap,
          ),
          const SizedBox(height: 28),

          // All Trips Header Row
          InkWell(
            onTap: onAllTripsTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Trips',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: textColor,
                  size: 24,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Trips List
          if (tripsToDisplay.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'No recent trips available',
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            ...tripsToDisplay.map((trip) {
              if (trip is! Map) return const SizedBox.shrink();

              // Smart name resolution
              String name = (trip['customer_name'] ??
                      trip['user_name'] ??
                      trip['passenger_name'] ??
                      '')
                  .toString()
                  .trim();
              if (name.isEmpty) {
                final rawName = (trip['name'] ?? '').toString().trim();
                final lower = rawName.toLowerCase();
                if (rawName.isNotEmpty &&
                    !lower.contains('marg') &&
                    !lower.contains('nagar') &&
                    !lower.contains('delhi') &&
                    !lower.contains('road') &&
                    !lower.contains('street') &&
                    !lower.contains('india')) {
                  name = rawName;
                } else {
                  name = 'Passenger';
                }
              }

              // Location resolution
              final location = (trip['drop_address'] ??
                      trip['pickup_address'] ??
                      trip['location'] ??
                      trip['address'] ??
                      'Location N/A')
                  .toString();

              final amount = (trip['driver_earnings'] as num?)?.toDouble() ??
                  (trip['fare'] as num?)?.toDouble() ??
                  (trip['amount'] as num?)?.toDouble() ??
                  0.0;
              final isItemFemale =
                  trip['gender']?.toString().toLowerCase() == 'female';

              final Color avatarColor = isItemFemale
                  ? const Color(0xFFEC4899)
                  : const Color(0xFF1D4ED8);

              return _buildTripItem(
                context,
                name: name,
                location: location,
                amount: amount,
                color: avatarColor,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTripItem(
    BuildContext context, {
    required String name,
    required String location,
    required double amount,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtextColor = isDark ? Colors.grey.shade400 : const Color(0xFF6B7280);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE5E7EB);
    final initialLetter =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'C';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initialLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹ ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        Divider(color: borderColor, height: 1),
      ],
    );
  }
}
