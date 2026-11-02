part of 'package:rider_app/driver_features/rides/widgets/ride_request_card.dart';

extension _RideRequestCardSections on RideRequestCard {
  Widget _buildPassengerGenderBadges(Map<String, dynamic> ride) {
    final dynamic maleVal =
        ride['male_passengers'] ?? ride['male_count'] ?? ride['males'];
    final dynamic femaleVal =
        ride['female_passengers'] ?? ride['female_count'] ?? ride['females'];
    final dynamic totalVal =
        ride['passenger_count'] ?? ride['total_passengers'] ?? ride['seats'];
    final String gender =
        (ride['gender'] ??
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
      badge1Content = const Icon(
        Icons.male_rounded,
        size: 18,
        color: Colors.white,
      );
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
      badge1Content = const Icon(
        Icons.female_rounded,
        size: 18,
        color: Colors.white,
      );
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
      badge1Content = const Icon(
        Icons.male_rounded,
        size: 18,
        color: Colors.white,
      );
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
                  border: Border.all(color: Colors.white, width: 2),
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
}
