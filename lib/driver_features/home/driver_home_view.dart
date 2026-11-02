import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/home/home_header.dart';
import 'package:rider_app/driver_features/home/home_map_style.dart';
import 'package:rider_app/driver_features/home/home_plan_card.dart';
import 'package:rider_app/driver_features/home/home_stats_card.dart';
import 'package:rider_app/driver_features/home/home_status_card.dart';
import 'package:rider_app/driver_features/home/screens/plan_driving_hours_screen.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Home map and cards shown when the driver is not in an active ride search.
class DriverHomeView extends StatefulWidget {
  const DriverHomeView({
    super.key,
    required this.isOnline,
    required this.driverName,
    required this.locationLabel,
    required this.todayEarnings,
    required this.completedJobs,
    required this.onToggle,
    required this.onNotifications,
    required this.onHelp,
    required this.onEarnings,
    required this.onJobs,
    required this.onUpdateLocation,
    this.currentPosition,
    this.onMapCreated,
  });

  final bool isOnline;
  final String driverName;
  final String locationLabel;
  final double todayEarnings;
  final int completedJobs;
  final VoidCallback onToggle;
  final VoidCallback onNotifications;
  final VoidCallback onHelp;
  final VoidCallback onEarnings;
  final VoidCallback onJobs;
  final VoidCallback onUpdateLocation;
  final Position? currentPosition;
  final void Function(GoogleMapController controller)? onMapCreated;

  @override
  State<DriverHomeView> createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView> {
  GoogleMapController? _mapController;

  @override
  void didUpdateWidget(DriverHomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.currentPosition;
    final previous = oldWidget.currentPosition;
    if (next == null || _mapController == null) return;
    if (previous?.latitude == next.latitude &&
        previous?.longitude == next.longitude)
      return;
    _mapController!.animateCamera(
      CameraUpdate.newLatLng(LatLng(next.latitude, next.longitude)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final female = accent == AppColors.femalePink;
    final position = widget.currentPosition;
    final target = position == null
        ? const LatLng(28.6139, 77.2090)
        : LatLng(position.latitude, position.longitude);
    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: target, zoom: 15),
            myLocationEnabled: position != null,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            style: context.isDarkTheme ? homeDarkMapStyle : null,
            compassEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              widget.onMapCreated?.call(controller);
            },
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: context.h(160),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: context.isDarkTheme
                    ? [
                        context.torkk.background.withValues(alpha: 0.85),
                        context.torkk.background.withValues(alpha: 0),
                      ]
                    : [const Color(0xF2FFFFFF), const Color(0x00FFFFFF)],
              ),
            ),
          ),
        ),
        HomeHeader(
          driverName: widget.driverName,
          onNotifications: widget.onNotifications,
          onHelp: widget.onHelp,
        ),
        Positioned(
          top: context.h(120),
          left: 0,
          right: 0,
          bottom: 0,
          // Sheet hugs its content and sits at the bottom, so offline (no
          // location row) there is no empty space above the nav bar.
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                // Dark: same as the scaffold behind the floating nav bar, so
                // there is no color strip between the sheet and the nav.
                color: context.isDarkTheme
                    ? context.torkk.background
                    : context.torkk.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.r(26)),
                ),
              ),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(
                  top: context.h(14),
                  bottom: context.h(10),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                    child: HomeStatusCard(
                      isOnline: widget.isOnline,
                      onToggle: widget.onToggle,
                      female: female,
                      locationLabel: widget.locationLabel,
                      onUpdateLocation: widget.onUpdateLocation,
                    ),
                  ),
                  SizedBox(height: context.h(10)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                    child: HomeStatsCard(
                      todayEarnings: widget.todayEarnings,
                      completedJobs: widget.completedJobs,
                      onEarnings: widget.onEarnings,

                      accent: accent,
                    ),
                  ),
                  SizedBox(height: context.h(10)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PlanDrivingHoursScreen(),
                        ),
                      ),
                      child: HomePlanCard(accent: accent, female: female),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
