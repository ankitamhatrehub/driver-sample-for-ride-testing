import 'package:flutter/material.dart' hide Chip;
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/chip.dart';

class ServiceChips extends StatelessWidget {
  const ServiceChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Chip(icon: Icons.inventory_2_outlined, label: 'Parcel'),
        Container(
          width: 1,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          color: context.themed(
            light: const Color(0xFFE4E0EA),
            dark: context.torkk.border,
          ),
        ),
        const Chip(icon: Icons.directions_car_filled_outlined, label: 'Ride'),
      ],
    );
  }
}
