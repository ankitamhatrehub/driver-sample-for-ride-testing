part of 'package:rider_app/driver_features/trips/screens/driver_history_screen.dart';

extension _DriverHistoryScreenStateSections on _DriverHistoryScreenState {
  Widget _buildTripTile(BuildContext context, Map<String, dynamic> trip) {
    final textColor = context.torkk.textPrimary;
    final subTextColor = context.torkk.textSecondary;

    String name =
        (trip['customer_name'] ??
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

    final address =
        (trip['drop_address'] ??
                trip['pickup_address'] ??
                trip['address'] ??
                'Location N/A')
            .toString();
    final fare =
        (trip['driver_earnings'] ??
                trip['fare'] ??
                trip['earnings'] ??
                trip['amount'] as num?)
            ?.toDouble() ??
        0.0;
    final gender = trip['gender'] ?? trip['passenger_gender'] ?? 'male';
    final isMale = gender.toString().toLowerCase() != 'female';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              // Circular initial avatar badge (M: Blue #1D4ED8, F: Pink #EC4899)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isMale
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFFEC4899),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name and Address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount
              Text(
                '₹ ${fare.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: context.torkk.border,
          indent: 84,
          endIndent: 20,
        ),
      ],
    );
  }
}
