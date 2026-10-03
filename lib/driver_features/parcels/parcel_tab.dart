import 'package:flutter/material.dart';

import 'package:rider_app/driver_features/parcels/parcel_delivery_screen.dart';
import 'package:rider_app/driver_features/parcels/parcel_flow_screen.dart';
import 'package:rider_app/driver_features/parcels/parcel_vehicles_screen.dart';

/// Parcel tab: unlock steps, then the vehicle list, then parcel trips.
class ParcelTab extends StatefulWidget {
  const ParcelTab({
    super.key,
    required this.eligible,
    required this.vehicleType,
    required this.onLeave,
  });

  final bool eligible;
  final String vehicleType;
  final VoidCallback onLeave;

  @override
  State<ParcelTab> createState() => _ParcelTabState();
}

class _ParcelTabState extends State<ParcelTab> {
  var _showVehicles = false;

  @override
  Widget build(BuildContext context) {
    if (widget.eligible || _showVehicles) {
      return ParcelVehiclesScreen(
        onBack: () {
          if (_showVehicles && !widget.eligible) {
            setState(() => _showVehicles = false);
            return;
          }
          widget.onLeave();
        },
        onStart: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ParcelFlowScreen()),
          );
        },
      );
    }
    return ParcelDeliveryScreen(
      onBack: widget.onLeave,
      onContinue: () => setState(() => _showVehicles = true),
    );
  }
}
