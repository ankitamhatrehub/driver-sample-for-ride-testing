part of 'package:rider_app/driver_features/rides/ride_flow_screen.dart';

class _RouteMap extends StatefulWidget {
  const _RouteMap({
    required this.pickup,
    required this.drop,
    required this.distance,
    required this.duration,
    required this.vehicleAsset,
    this.navigating = false,
  });

  final LatLng pickup;
  final LatLng drop;
  final String distance;
  final String duration;
  final String vehicleAsset;
  final bool navigating;

  @override
  State<_RouteMap> createState() => _RouteMapState();
}
