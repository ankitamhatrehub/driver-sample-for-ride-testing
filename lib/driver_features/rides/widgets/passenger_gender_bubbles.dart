import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';

/// Two overlapping circles: blue = male passengers, pink = female passengers.
/// A circle is hidden when its count is 0.
class PassengerGenderBubbles extends StatelessWidget {
  const PassengerGenderBubbles({
    super.key,
    required this.male,
    required this.female,
    this.size = 24,
  });

  /// Reads the counts from a ride payload.
  ///
  /// Uses `male_passengers` / `female_passengers` when the API sends them.
  /// Otherwise the booker's gender is applied to `passenger_count`.
  factory PassengerGenderBubbles.fromRide(
    Map<String, dynamic> ride, {
    double size = 24,
  }) {
    final counts = genderCounts(ride);
    return PassengerGenderBubbles(
      male: counts.male,
      female: counts.female,
      size: size,
    );
  }

  static const Color pink = Color(0xFFD0509B);

  final int male;
  final int female;
  final double size;

  static int? _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

  static int totalPassengers(Map<String, dynamic> ride) {
    final total = _int(
      ride['passenger_count'] ?? ride['total_passengers'] ?? ride['seats'],
    );
    return (total != null && total > 0) ? total : 1;
  }

  static ({int male, int female}) genderCounts(Map<String, dynamic> ride) {
    final male = _int(
      ride['male_passengers'] ?? ride['male_count'] ?? ride['males'],
    );
    final female = _int(
      ride['female_passengers'] ?? ride['female_count'] ?? ride['females'],
    );
    if (male != null || female != null) {
      return (male: male ?? 0, female: female ?? 0);
    }
    final gender =
        (ride['gender'] ??
                ride['customer_gender'] ??
                ride['passenger_gender'] ??
                '')
            .toString()
            .trim()
            .toLowerCase();
    final total = totalPassengers(ride);
    if (gender == 'female' || gender == 'f') return (male: 0, female: total);
    return (male: total, female: 0);
  }

  @override
  Widget build(BuildContext context) {
    final bubbles = <(int, Color)>[
      if (male > 0) (male, AppColors.maleBlue),
      if (female > 0) (female, pink),
    ];
    if (bubbles.isEmpty) return const SizedBox.shrink();
    final overlap = size * 0.3;
    return SizedBox(
      width: size + (bubbles.length - 1) * (size - overlap),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < bubbles.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bubbles[i].$2,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${bubbles[i].$1}',
                  style: AppTypography.bold.copyWith(
                    fontSize: size * 0.5,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
