import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

export '../widgets/widgets.dart';

class OnlineRideSearchView extends StatefulWidget {
  final List<dynamic> visibleRides;
  final Offset mapPanOffset;
  final ValueChanged<DragUpdateDetails> onPanUpdate;
  final VoidCallback onToggleOnline;
  final VoidCallback onOpenDrawer;
  final VoidCallback onProfileTap;
  final Function(int) onAcceptRide;
  final Function(int)? onRejectRide;
  final VoidCallback onSimulateTestRide;
  final String profilePhotoUrl;
  final Position? currentPosition;
  final MapCreatedCallback? onMapCreated;
  final String driverGender;
  final VoidCallback? onNotificationsTap;

  const OnlineRideSearchView({
    super.key,
    required this.visibleRides,
    required this.mapPanOffset,
    required this.onPanUpdate,
    required this.onToggleOnline,
    required this.onOpenDrawer,
    required this.onProfileTap,
    required this.onAcceptRide,
    this.onRejectRide,
    required this.onSimulateTestRide,
    required this.profilePhotoUrl,
    this.currentPosition,
    this.onMapCreated,
    this.driverGender = 'Male',
    this.onNotificationsTap,
  });

  @override
  State<OnlineRideSearchView> createState() => _OnlineRideSearchViewState();
}

class _OnlineRideSearchViewState extends State<OnlineRideSearchView> {
  bool _showOnlineText = false;

  static const String _highDetailRideMapStyle = '''
[
  {
    "featureType": "all",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#1e293b"}]
  },
  {
    "featureType": "all",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#ffffff"}, {"weight": 3}]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#0f172a"}]
  },
  {
    "featureType": "administrative.neighborhood",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#334155"}, {"visibility": "on"}]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#f1f5f9"}]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#e2e8f0"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#dcfce7"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#15803d"}, {"visibility": "on"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#ffffff"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#cbd5e1"}, {"weight": 1}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#334155"}, {"visibility": "on"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#fde047"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#eab308"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#ffffff"}]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#ffffff"}]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#475569"}, {"visibility": "on"}]
  },
  {
    "featureType": "transit",
    "elementType": "all",
    "stylers": [{"visibility": "on"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#38bdf8"}]
  }
]
''';

  @override
  void didUpdateWidget(covariant OnlineRideSearchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visibleRides.isEmpty && oldWidget.visibleRides.isNotEmpty) {
      _showOnlineText = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultLatLng = widget.currentPosition != null
        ? LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude)
        : const LatLng(28.6139, 77.2090);

    final isFemale = widget.driverGender.trim().toLowerCase() == 'female';
    final avatarBorderColor =
        isFemale ? const Color(0xFFEC4899) : const Color(0xFF1D4ED8);

    return Stack(
      children: [
        // 1. FULLSCREEN HIGH-DETAIL GOOGLE MAP (Ola/Uber/Rapido Mode)
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: defaultLatLng,
              zoom: 17.2,
              tilt: 35.0,
            ),
            mapType: MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            buildingsEnabled: true,
            onMapCreated: (controller) {
              try {
                controller.setMapStyle(_highDetailRideMapStyle);
              } catch (_) {}
              if (widget.onMapCreated != null) {
                widget.onMapCreated!(controller);
              }
            },
          ),
        ),

        // 2. TOP BAR (Notification Bell, Green ONLINE Pill / Fast Forward Circle, Driver Avatar)
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Notification Bell Button
              GestureDetector(
                onTap: widget.onNotificationsTap ?? widget.onOpenDrawer,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),

              // ONLINE Pill / Fast Forward Button (>| Icon when compact, ONLINE when tapped or no rides)
              GestureDetector(
                onTap: () {
                  if (widget.visibleRides.isNotEmpty && !_showOnlineText) {
                    setState(() {
                      _showOnlineText = true;
                    });
                  } else if (widget.visibleRides.isNotEmpty && _showOnlineText) {
                    setState(() {
                      _showOnlineText = false;
                    });
                  } else {
                    widget.onToggleOnline();
                  }
                },
                onLongPress: widget.onToggleOnline,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: (widget.visibleRides.isNotEmpty && !_showOnlineText)
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withAlpha(89),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: (widget.visibleRides.isNotEmpty && !_showOnlineText)
                      ? Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.skip_next_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        )
                      : const Text(
                          'ONLINE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 0.8,
                          ),
                        ),
                ),
              ),

              // Driver Profile Avatar with Dynamic Gender Border
              GestureDetector(
                onTap: widget.onProfileTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: avatarBorderColor,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(38),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: widget.profilePhotoUrl.isNotEmpty
                        ? Image.network(
                            widget.profilePhotoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: context.themed(light: Colors.grey.shade200, dark: context.torkk.surfaceMuted),
                              child: Icon(
                                Icons.person,
                                color: context.torkk.textBody,
                                size: 24,
                              ),
                            ),
                          )
                        : Container(
                            color: context.themed(light: Colors.grey.shade200, dark: context.torkk.surfaceMuted),
                            child: Icon(
                              Icons.person,
                              color: context.torkk.textBody,
                              size: 24,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. BOTTOM DRAWER: RideSearch1 (Empty) vs RideSearch2 (Incoming Requests)
        if (widget.visibleRides.isEmpty) ...[
          // RideSearch1: Bottom Searching Drawer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: context.torkk.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: widget.onSimulateTestRide,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'searching',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.torkk.textSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // RideSearch2: List of Incoming RideCards
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.58,
              ),
              decoration: BoxDecoration(
                color: context.torkk.surfaceMuted,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(41),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        MediaQuery.of(context).padding.bottom + 12,
                      ),
                      itemCount: widget.visibleRides.length,
                      itemBuilder: (context, index) {
                        final ride = widget.visibleRides[index];
                        return RideRequestCard(
                          ride: ride,
                          index: index,
                          onAccept: () => widget.onAcceptRide(ride['id']),
                          onTimeout: () {
                            if (widget.onRejectRide != null) {
                              widget.onRejectRide!(ride['id']);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}


