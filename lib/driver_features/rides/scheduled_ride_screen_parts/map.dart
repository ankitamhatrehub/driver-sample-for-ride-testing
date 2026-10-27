part of 'package:rider_app/driver_features/rides/scheduled_ride_screen.dart';

class _Map extends StatelessWidget {
  const _Map();

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(28.5692, 77.3242),
        zoom: 14.6,
      ),
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      polylines: {
        const Polyline(
          polylineId: PolylineId('scheduled'),
          color: Color(0xFF2563EB),
          width: 5,
          points: _route,
        ),
      },
      markers: {
        Marker(
          markerId: const MarkerId('pickup'),
          position: _pickup,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
        Marker(
          markerId: const MarkerId('drop'),
          position: _drop,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      },
    );
  }
}
