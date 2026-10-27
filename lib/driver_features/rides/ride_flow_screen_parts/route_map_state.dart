part of 'package:rider_app/driver_features/rides/ride_flow_screen.dart';

class _RouteMapState extends State<_RouteMap> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};

  static final _bounds = LatLngBounds(
    southwest: LatLng(28.5652, 77.3194),
    northeast: LatLng(28.5730, 77.3286),
  );

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  @override
  void didUpdateWidget(covariant _RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigating == widget.navigating) return;
    _loadMarkers();
    _frame();
  }

  Future<void> _loadMarkers() async {
    final pickup = await _blueDot();
    final drop = await _redPin();
    final markers = <Marker>{
      Marker(markerId: const MarkerId('pickup'), position: _pickup, icon: pickup, anchor: const Offset(0.5, 0.5), zIndexInt: 2),
      Marker(markerId: const MarkerId('drop'), position: _drop, icon: drop, anchor: const Offset(0.5, 1), zIndexInt: 2),
    };
    if (widget.navigating) {
      markers.add(
        Marker(
          markerId: const MarkerId('label'),
          position: _labelPoint,
          icon: await _distanceLabel(),
          anchor: const Offset(0.15, 0.85),
          zIndexInt: 3,
        ),
      );
    }
    if (!mounted) return;
    setState(() => _markers = markers);
  }

  void _frame() {
    final controller = _controller;
    if (controller == null) return;
    controller.moveCamera(CameraUpdate.newLatLngBounds(_bounds, 28));
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(28.5690, 77.3240), zoom: 14.6),
      padding: EdgeInsets.only(top: 64, bottom: widget.navigating ? 130 : 240),
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (controller) {
        _controller = controller;
        WidgetsBinding.instance.addPostFrameCallback((_) => _frame());
      },
      polylines: {
        const Polyline(
          polylineId: PolylineId('ride'),
          color: Color(0xFF4285F4),
          width: 6,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          points: _route,
        ),
      },
      markers: _markers,
    );
  }
}
