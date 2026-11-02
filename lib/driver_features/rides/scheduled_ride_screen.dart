import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/widgets/app_confirm_dialog.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/screens/sos_screen.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

part 'scheduled_ride_screen_parts/map.dart';
part 'scheduled_ride_screen_sections.dart';

/// Sample scheduled ride. No backend yet.
enum _Step { offer, ready, trip, details }

const _pickup = LatLng(28.5708, 77.3219);
const _drop = LatLng(28.5672, 77.3264);
const _route = [
  LatLng(28.5708, 77.3219),
  LatLng(28.5716, 77.3234),
  LatLng(28.5694, 77.3248),
  LatLng(28.5672, 77.3264),
];

class ScheduledRideScreen extends StatefulWidget {
  const ScheduledRideScreen({super.key});

  @override
  State<ScheduledRideScreen> createState() => _ScheduledRideScreenState();
}

class _ScheduledRideScreenState extends State<ScheduledRideScreen> {
  _Step _step = _Step.offer;
  bool _showHour = false;
  bool _hourShown = false;
  bool _showScheduledCard = true;
  Timer? _hourTimer;

  @override
  void dispose() {
    _hourTimer?.cancel();
    super.dispose();
  }

  void _go(_Step step) {
    _hourTimer?.cancel();
    final show = step == _Step.trip && !_hourShown;
    setState(() {
      _step = step;
      _showHour = show;
      if (show) _hourShown = true;
    });
    if (!show) return;
    _hourTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showHour = false);
    });
  }

  void _hideHour() {
    _hourTimer?.cancel();
    setState(() => _showHour = false);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _Step.offer => _offer(context),
      _Step.ready => _ready(context),
      _Step.trip => _trip(context),
      _Step.details => _details(context),
    };
  }

  Widget _scheduledCard(BuildContext context, Color accent) {
    return Container(
      padding: EdgeInsets.all(context.w(12)),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(context.r(16)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car_filled,
                color: accent,
                size: context.w(16),
              ),
              SizedBox(width: context.w(6)),
              Text(
                'Scheduled Ride',
                style: AppTypography.bold.copyWith(fontSize: 13, height: 1.2),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(8),
                  vertical: context.h(3),
                ),
                decoration: BoxDecoration(
                  color: context.adaptiveTint(const Color(0xFFFFF7ED)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tomorrow at 6:30 am',
                  style: AppTypography.bold.copyWith(
                    fontSize: 10,
                    color: context.legible(Color(0xFFF97316)),
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(6)),
          Text(
            'Scheduled Ride Request',
            style: AppTypography.regular.copyWith(
              fontSize: 12,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(6)),
          Text(
            'Sector 62, Noida  →  DLF Mall of India',
            style: AppTypography.bold.copyWith(
              fontSize: 13,
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: context.h(4)),
          Text(
            '4.2 km   ·   18 min',
            style: AppTypography.regular.copyWith(
              fontSize: 12,
              color: AppColors.slate400,
            ),
          ),
          SizedBox(height: context.h(8)),
          _personRow(context, 'Rahul', '4 passengers', showActions: false),
          SizedBox(height: context.h(10)),
          Row(
            children: [
              Expanded(
                child: _decline(
                  context,
                  () => setState(() => _showScheduledCard = false),
                ),
              ),
              SizedBox(width: context.w(10)),
              Expanded(
                child: _accept(
                  context,
                  accent,
                  'Accept',
                  () => _go(_Step.ready),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
