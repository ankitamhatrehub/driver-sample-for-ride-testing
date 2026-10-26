import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/dashboard/ride_details_loading_dialog.dart';
import 'package:rider_app/driver_features/profile/screens/sos_screen.dart';
import 'package:rider_app/driver_features/profile/screens/tickets_screen.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Sample ride shown after the driver goes online. No backend yet.
enum _Phase {
  loading,
  request,
  toPickup,
  arrived,
  waiting,
  otp,
  active,
  navigating,
  drop,
  completed,
  rate,
  reward,
  unavailable,
  expired,
}

const _pickup = LatLng(28.5666, 77.3208);
const _drop = LatLng(28.5716, 77.3272);
const _labelPoint = LatLng(28.5672, 77.3236);
const _route = [
  LatLng(28.5666, 77.3208),
  LatLng(28.5669, 77.3222),
  LatLng(28.5674, 77.3248),
  LatLng(28.5679, 77.3264),
  LatLng(28.5696, 77.3268),
  LatLng(28.5716, 77.3272),
];

class RideFlowScreen extends StatefulWidget {
  const RideFlowScreen({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<RideFlowScreen> createState() => _RideFlowScreenState();
}

class _RideFlowScreenState extends State<RideFlowScreen> {
  _Phase _phase = _Phase.loading;
  int _offer = 28;
  int _wait = 133;
  int _stars = 5;
  bool _sheetLocked = false;
  Timer? _timer;
  Timer? _navTimer;
  _Phase _navNext = _Phase.drop;
  _Phase _navBack = _Phase.active;
  final _pickedTags = <String>{};
  final _otp = TextEditingController();
  final _otpFocus = FocusNode();
  final _comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _phase == _Phase.loading) setState(() => _phase = _Phase.request);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_phase == _Phase.request && _offer > 0) {
          _offer--;
          if (_offer == 0) _phase = _Phase.expired;
        }
        if (_phase == _Phase.waiting) _wait++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _navTimer?.cancel();
    _otp.dispose();
    _comment.dispose();
    super.dispose();
  }

  void _go(_Phase phase) {
    if (phase != _Phase.navigating) _navTimer?.cancel();
    setState(() => _phase = phase);
  }

  void _startNav(_Phase next) {
    _navTimer?.cancel();
    setState(() {
      _navBack = _phase;
      _navNext = next;
      _phase = _Phase.navigating;
    });
    _navTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || _phase != _Phase.navigating) return;
      setState(() => _phase = _navNext);
    });
  }

  void _openNextSheet(_Phase phase) {
    if (_sheetLocked) return;
    setState(() => _sheetLocked = true);
    Future<void>.delayed(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() {
        _phase = phase;
        _sheetLocked = false;
      });
    });
  }

  String get _offerLabel => '00:${_offer.toString().padLeft(2, '0')}';

  String get _waitLabel {
    final minutes = (_wait ~/ 60).toString().padLeft(2, '0');
    final seconds = (_wait % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _close() => widget.onClose();

  bool get _showSos => switch (_phase) {
        _Phase.toPickup || _Phase.arrived || _Phase.waiting || _Phase.active || _Phase.drop => true,
        _ => false,
      };

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _Phase.loading => const Stack(
          children: [
            Positioned.fill(child: ModalBarrier(color: Color(0x21000000), dismissible: false)),
            RideDetailsLoadingOverlay(),
          ],
        ),
      _Phase.request => _requestOverlay(context),
      _Phase.otp => _otpPage(context),
      _Phase.completed => _completedPage(context),
      _Phase.rate => _ratePage(context),
      _Phase.reward => _rewardPage(context),
      _Phase.unavailable => _noticePage(context, icon: Icons.directions_car_filled_rounded, title: 'Ride no longer available', body: 'This ride has been taken by another driver or no longer available.'),
      _Phase.expired => _noticePage(context, icon: Icons.wifi_off_rounded, title: 'Request Expired', body: "You didn't respond in time."),
      _ => _mapPage(context),
    };
  }

  Widget _mapPage(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _RouteMap(navigating: _phase == _Phase.navigating)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(context.w(12), context.h(4), context.w(16), 0),
                child: _phase == _Phase.request ? _greeting(context) : Align(alignment: Alignment.centerLeft, child: _back(() => _go(_backPhase))),
              ),
            ),
          ),
          if (_phase == _Phase.arrived)
            Positioned(top: context.h(100), left: context.w(16), right: context.w(80), child: _banner("You've arrived", 'Please wait for the customer.')),
          if (_phase == _Phase.waiting)
            Positioned(
              top: context.h(150),
              left: context.w(16),
              right: context.w(80),
              child: _banner('Waiting charges (if applicable) ₹10 per minute', '', warn: true),
            ),
          Align(alignment: Alignment.bottomCenter, child: _sheet(context)),
          if (_showSos)
            Positioned(
              right: context.w(28),
              top: context.h(300),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SosScreen())),
                child: Container(
                  width: context.w(66),
                  height: context.w(66),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4)],
                  ),
                  child: Text('SOS', style: AppTypography.bold.copyWith(fontSize: 14, color: Colors.white, height: 1)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  _Phase get _backPhase => switch (_phase) {
        _Phase.toPickup => _Phase.request,
        _Phase.arrived => _Phase.toPickup,
        _Phase.waiting => _Phase.arrived,
        _Phase.active => _Phase.otp,
        _Phase.navigating => _navBack,
        _Phase.drop => _Phase.navigating,
        _ => _Phase.request,
      };

  Widget _sheet(BuildContext context) {
    if (_phase == _Phase.navigating) {
      return Padding(
        padding: EdgeInsets.fromLTRB(context.w(16), 0, context.w(16), context.h(24)),
        child: Container(
          padding: EdgeInsets.fromLTRB(context.w(14), context.h(12), context.w(4), context.h(12)),
          decoration: BoxDecoration(
            color: context.torkk.surface,
            borderRadius: BorderRadius.circular(context.r(20)),
            boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: context.w(40),
                height: context.w(40),
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
              ),
              SizedBox(width: context.w(12)),
              Expanded(child: _metric('4.2 km', 'Distance')),
              Container(width: 1, height: context.h(28), color: context.adaptiveTint(const Color(0xFFE2E8F0))),
              SizedBox(width: context.w(14)),
              Expanded(child: _metric('18 min', 'Est. duration')),
              IconButton(onPressed: () => _go(_navNext), icon: const Icon(Icons.close, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(left: context.w(8)),
      child: Container(
      width: context.w(378),
      padding: EdgeInsets.fromLTRB(context.w(20), context.h(28), context.w(20), context.h(80)),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.r(32))),
        boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(0, -11), blurRadius: 16.8)],
      ),
      child: switch (_phase) {
        _Phase.toPickup => _stopSheet(context, title: 'Heading to Pickup', chip: '2 mins away', place: 'Sector 62, Noida', action: 'Navigate', onAction: () => _startNav(_Phase.arrived)),
        _Phase.arrived => _stopSheet(context, title: 'Arrived', chip: '', place: 'Sector 62, Noida', action: '', onAction: () => _go(_Phase.waiting)),
        _Phase.waiting => _waitingSheet(context),
        _Phase.active => _activeSheet(context),
        _Phase.drop => _stopSheet(context, title: 'Drop', chip: '', place: 'Sector 62, Noida', action: 'End Ride', onAction: () => _go(_Phase.completed), drop: true),
        _ => const SizedBox.shrink(),
      },
      ),
    );
  }

  Widget _greeting(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning,', style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary)),
              Text('Rahul Sharma', style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2, letterSpacing: -0.3)),
            ],
          ),
        ),
        Icon(Icons.notifications_none_rounded, size: context.w(22)),
        SizedBox(width: context.w(8)),
        CircleAvatar(radius: context.w(16), backgroundColor: accent, child: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimary, size: context.w(16))),
      ],
    );
  }

  Widget _requestOverlay(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: context.w(7),
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: context.w(58),
                height: context.w(58),
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                child: Text(_offerLabel, style: AppTypography.bold.copyWith(fontSize: 13, color: Colors.white, height: 1)),
              ),
              SizedBox(height: context.h(8)),
              AbsorbPointer(
                absorbing: _sheetLocked,
                child: Opacity(opacity: _sheetLocked ? 0.45 : 1, child: _requestCard(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _requestCard(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      width: context.w(378),
      padding: EdgeInsets.fromLTRB(context.w(20), context.h(28), context.w(20), context.h(28)),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.r(32))),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), offset: Offset(0, -3), blurRadius: 11.1),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New ride request', style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2, letterSpacing: -0.3)),
          SizedBox(height: context.h(14)),
          Row(
            children: [
              Icon(Icons.local_taxi_rounded, color: context.torkk.textPrimary, size: context.w(22)),
              SizedBox(width: context.w(8)),
              Text('CAB', style: AppTypography.bold.copyWith(fontSize: 15, height: 1.2, letterSpacing: -0.2)),
              const Spacer(),
              Text('₹240', style: AppTypography.bold.copyWith(fontSize: 22, height: 1, color: accent, letterSpacing: -0.4)),
            ],
          ),
          SizedBox(height: context.h(14)),
          _requestRider(context, accent),
          SizedBox(height: context.h(14)),
          _requestRoute(context),
          SizedBox(height: context.h(14)),
          Container(
            width: context.w(338),
            height: context.h(61),
            padding: EdgeInsets.fromLTRB(context.w(12), context.h(10), context.w(12), context.h(10)),
            decoration: BoxDecoration(
              color: const Color(0xCCF8FAFC),
              borderRadius: BorderRadius.circular(context.r(12)),
              border: Border.all(color: const Color(0xB2F1F5F9)),
            ),
            child: Row(
              children: [
                Expanded(child: _requestStat('4.2 km', 'Distance')),
                SizedBox(width: context.w(10)),
                Container(width: 1, height: context.h(28), color: context.adaptiveTint(const Color(0xFFE2E8F0))),
                SizedBox(width: context.w(10)),
                Expanded(child: _requestStat('18 min', 'Est. duration')),
              ],
            ),
          ),
          SizedBox(height: context.h(24)),
          Row(
            children: [
              Expanded(child: _requestDecline(context)),
              SizedBox(width: context.w(12)),
              Expanded(child: _requestAccept(context, accent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _requestRider(BuildContext context, Color accent) {
    return Row(
      children: [
        CircleAvatar(
          radius: context.w(22),
          backgroundColor: context.adaptiveTint(const Color(0xFFF1F5F9)),
          child: Icon(Icons.person, color: AppColors.slate400, size: context.w(24)),
        ),
        SizedBox(width: context.w(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rahul', style: AppTypography.bold.copyWith(fontSize: 16, height: 1.2, letterSpacing: -0.2)),
              SizedBox(height: context.h(4)),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.w(8), vertical: context.h(3)),
                    decoration: BoxDecoration(color: context.torkk.surfaceMuted, borderRadius: BorderRadius.circular(context.r(20))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_alt_outlined, size: context.w(12), color: context.torkk.textSecondary),
                        SizedBox(width: context.w(4)),
                        Text('3 passengers', style: AppTypography.regular.copyWith(fontSize: 11, color: context.torkk.textSecondary)),
                      ],
                    ),
                  ),
                  SizedBox(width: context.w(6)),
                  _countBadge(Icons.thumb_up_alt_rounded, '1', const Color(0xFF2563EB)),
                  SizedBox(width: context.w(4)),
                  _countBadge(Icons.thumb_down_alt_rounded, '2', const Color(0xFFEC4899)),
                ],
              ),
            ],
          ),
        ),
        _outlineAction(accent, Icons.chat_bubble_outline_rounded),
        SizedBox(width: context.w(8)),
        _outlineAction(accent, Icons.call_outlined),
      ],
    );
  }

  Widget _countBadge(IconData icon, String count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(6), vertical: context.h(3)),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(context.r(20))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.w(11), color: Colors.white),
          SizedBox(width: context.w(2)),
          Text(count, style: AppTypography.bold.copyWith(fontSize: 11, color: Colors.white, height: 1)),
        ],
      ),
    );
  }

  Widget _outlineAction(Color color, IconData icon) {
    return Container(
      width: context.w(40),
      height: context.w(40),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.torkk.border),
      ),
      child: Icon(icon, color: color, size: context.w(18)),
    );
  }

  Widget _requestRoute(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.w(4), context.h(8), 0, context.h(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.w(16),
            child: Column(
              children: [
                Container(width: context.w(10), height: context.w(10), decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
                Container(width: 2, height: context.h(36), color: context.adaptiveTint(const Color(0xFFE2E8F0))),
                Container(width: context.w(10), height: context.w(10), decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
              ],
            ),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pickup', style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate400)),
                Text('Sector 18, Noida', style: AppTypography.bold.copyWith(fontSize: 15, height: 1.3, letterSpacing: -0.2)),
                SizedBox(height: context.h(16)),
                Text('Drop', style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate400)),
                Text('DLF Mall of India', style: AppTypography.bold.copyWith(fontSize: 15, height: 1.3, letterSpacing: -0.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestStat(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, textAlign: TextAlign.center, style: AppTypography.bold.copyWith(fontSize: 16, height: 1, letterSpacing: -0.2)),
        SizedBox(height: context.h(2)),
        Text(label, textAlign: TextAlign.center, style: AppTypography.regular.copyWith(fontSize: 12, height: 1, color: AppColors.slate400)),
      ],
    );
  }

  Widget _requestDecline(BuildContext context) {
    return SizedBox(
      height: context.h(52),
      child: OutlinedButton(
        onPressed: () => _openNextSheet(_Phase.unavailable),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(16))),
        ),
        child: Text('Decline', style: AppTypography.bold.copyWith(fontSize: 16, color: const Color(0xFFEF4444), height: 1)),
      ),
    );
  }

  Widget _requestAccept(BuildContext context, Color accent) {
    return SizedBox(
      height: context.h(52),
      child: FilledButton(
        onPressed: () => _openNextSheet(_Phase.toPickup),
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(16))),
        ),
        child: Text('Accept', style: AppTypography.bold.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary, height: 1)),
      ),
    );
  }

  Widget _statusChip(BuildContext context, String title, String chip) {
    const success = Color(0xFF1A995B);
    return Row(
      children: [
        Container(
          height: context.h(28),
          padding: EdgeInsets.fromLTRB(context.w(8), context.h(6), context.w(8), context.h(6)),
          decoration: BoxDecoration(color: const Color(0x121A995B), borderRadius: BorderRadius.circular(context.r(7))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: context.w(8), height: context.w(8), decoration: const BoxDecoration(color: success, shape: BoxShape.circle)),
              SizedBox(width: context.w(10)),
              Text(title, style: AppTypography.bold.copyWith(fontSize: 12, height: 16 / 12, letterSpacing: 0, color: success)),
            ],
          ),
        ),
        const Spacer(),
        if (chip.isNotEmpty)
          Container(
            height: context.h(28),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: context.w(10)),
            decoration: BoxDecoration(color: context.adaptiveTint(const Color(0xFFEFF6FF)), borderRadius: BorderRadius.circular(context.r(8))),
            child: Text(chip, style: AppTypography.bold.copyWith(fontSize: 12, height: 16 / 12, color: context.legible(Color(0xFF2563EB)))),
          ),
      ],
    );
  }

  Widget _stopSheet(
    BuildContext context, {
    required String title,
    required String chip,
    required String place,
    required String action,
    required VoidCallback onAction,
    bool drop = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _statusChip(context, title, chip),
        SizedBox(height: context.h(18)),
        _rider(context),
        SizedBox(height: context.h(18)),
        _place(context, drop ? const Color(0xFFEF4444) : const Color(0xFF1A995B), drop ? 'DROP' : 'PICKUP', place),
        if (action.isEmpty)
          TextButton(onPressed: onAction, child: const Text('Customer is here'))
        else ...[
          SizedBox(height: context.h(50)),
          Row(
            children: [
              Expanded(child: _outline(context, 'Cancel', () => _cancel(context))),
              SizedBox(width: context.w(10)),
              Expanded(child: _fill(context, action, onAction, icon: action == 'Navigate' ? Icons.navigation_rounded : null)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _waitingSheet(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time_filled_rounded, color: Color(0xFFF59E0B), size: 18),
            SizedBox(width: context.w(6)),
            Text('Waiting', style: AppTypography.bold.copyWith(fontSize: 16, height: 1.2)),
          ],
        ),
        SizedBox(height: context.h(10)),
        _rider(context),
        _place(context, const Color(0xFF16A34A), 'PICKUP', 'Sector 62, Noida'),
        SizedBox(height: context.h(8)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: context.h(10)),
          decoration: BoxDecoration(color: context.adaptiveTint(const Color(0xFFFFF1F2)), borderRadius: BorderRadius.circular(context.r(12))),
          child: Column(
            children: [
              Text(_waitLabel, style: AppTypography.bold.copyWith(fontSize: 22, color: context.legible(Color(0xFFEF4444)), letterSpacing: -0.3)),
              Text('Customer has been notified', style: AppTypography.regular.copyWith(fontSize: 12, color: context.legible(Color(0xFFEF4444)))),
            ],
          ),
        ),
        SizedBox(height: context.h(12)),
        Row(
          children: [
            Expanded(child: _outline(context, 'Cancel', () => _cancel(context))),
            SizedBox(width: context.w(10)),
            Expanded(child: _fill(context, 'Start Ride', () => _go(_Phase.otp))),
          ],
        ),
      ],
    );
  }

  Widget _activeSheet(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _statusChip(context, 'Active Ride', ''),
        SizedBox(height: context.h(18)),
        _rider(context),
        SizedBox(height: context.h(18)),
        _place(context, const Color(0xFF1A995B), 'Pickup', 'Sector 18, Noida'),
        SizedBox(height: context.h(12)),
        _place(context, const Color(0xFFEF4444), 'Drop', 'DLF Mall of India'),
        SizedBox(height: context.h(50)),
        Row(
          children: [
            Expanded(child: _outline(context, 'Cancel', () => _cancel(context))),
            SizedBox(width: context.w(10)),
            Expanded(child: _fill(context, 'Navigate', () => _startNav(_Phase.drop), icon: Icons.navigation_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _otpPage(BuildContext context) {
    return _page(
      context,
      title: 'Ride Verification',
      onBack: () => _go(_Phase.waiting),
      child: Padding(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(18), context.w(24), 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter 4-digit OTP', style: AppTypography.bold.copyWith(fontSize: 24, height: 1.2)),
            SizedBox(height: context.h(8)),
            Text(
              'Ask the customer for their 4-digit ride OTP.',
              style: AppTypography.regular.copyWith(fontSize: 14.5, color: context.torkk.textSecondary),
            ),
            SizedBox(height: context.h(28)),
            _RideOtpBoxes(controller: _otp, focusNode: _otpFocus, length: 4),
            SizedBox(height: context.h(28)),
            _fill(context, 'Verify & Start Ride', () {
              if (_otp.text.length != 4) return;
              _otp.clear();
              _go(_Phase.active);
            }),
          ],
        ),
      ),
    );
  }

  Widget _completedPage(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return _page(
      context,
      title: '',
      onBack: () => _go(_Phase.drop),
      bottom: Column(
        children: [
          _fill(context, 'Done', () => _go(_Phase.rate)),
      SizedBox(
        width: double.infinity,
        child:TextButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const IssueCategoryScreen())),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
            label: Text('Report an Issue', style: AppTypography.bold.copyWith(fontSize: 14, color: const Color(0xFFEF4444))),
          ),
      )],
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          SizedBox(
            height: context.h(140),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0]),
                  child: Image.asset(AppAssets.celebration, width: context.w(240), fit: BoxFit.contain),
                ),
                Container(
                  width: context.w(72),
                  height: context.w(72),
                  decoration: BoxDecoration(color: context.adaptiveTint(Color(0xFFDCFCE7)), shape: BoxShape.circle),
                  child: Icon(Icons.check_rounded, color: context.legible(Color(0xFF16A34A)), size: context.w(36)),
                ),
              ],
            ),
          ),
          Text('Ride Completed !', textAlign: TextAlign.center, style: AppTypography.bold.copyWith(fontSize: 20, letterSpacing: -0.3)),
          Text('Great job', textAlign: TextAlign.center, style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary)),
          SizedBox(height: context.h(16)),
          _money(context, "Driver's Earning", '₹ 85'),
          SizedBox(height: context.h(8)),
          _money(context, 'Payment', 'Paid Cash'),
          SizedBox(height: context.h(12)),
          Container(
            padding: EdgeInsets.all(context.w(12)),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(context.r(14)), gradient: LinearGradient(colors: [accent, const Color(0xFF61217E), Color(0xFF0F3FBF), Color(0xFFBA2879)])),
            child: Row(
              children: [
                Icon(Icons.card_giftcard_rounded, color: Theme.of(context).colorScheme.onPrimary),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('You earned 200 coins', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w700)),
                      Text('Get your reward unlocked!', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onPrimary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _commentBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.r(16)),
      borderSide: BorderSide(color: context.torkk.border),
    );
  }

  Widget _ratePage(BuildContext context) {
    const tags = ['Polite', 'On time', 'Good Communication', 'Safe ride', 'Helpful'];
    final accent = Theme.of(context).colorScheme.primary;
    return _page(
      context,
      title: '',
      onBack: () => _go(_Phase.completed),
      bottom: Column(
        children: [
          _fill(context, 'Submit', () => _go(_Phase.reward)),
          SizedBox(height: context.h(8)),
          SizedBox(
            width: double.infinity,
            height: context.h(48),
            child: OutlinedButton(
              onPressed: () => _go(_Phase.reward),
              style: OutlinedButton.styleFrom(foregroundColor: accent, side: BorderSide(color: accent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14)))),
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          Center(child: CircleAvatar(radius: context.w(28), backgroundColor: context.adaptiveTint(const Color(0xFFF3E8FF)), child: Icon(Icons.person, color: context.legible(Color(0xFFBA2879))))),
          SizedBox(height: context.h(8)),
          Text('Rahul', textAlign: TextAlign.center, style: AppTypography.bold.copyWith(fontSize: 16)),
          SizedBox(height: context.h(10)),
          Text('How was your Ride?', textAlign: TextAlign.center, style: AppTypography.bold.copyWith(fontSize: 18, letterSpacing: -0.3)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _stars = i),
                  icon: Icon(Icons.star_rounded, color: i <= _stars ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0), size: 32),
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final tag in tags)
                GestureDetector(
                  onTap: () => setState(() => _pickedTags.contains(tag) ? _pickedTags.remove(tag) : _pickedTags.add(tag)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _pickedTags.contains(tag) ? accent.withValues(alpha: 0.12) : context.adaptiveTint(Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(tag, style: AppTypography.regular.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.h(44)),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: context.w(337),
              height: context.h(134),
              child: TextField(
                controller: _comment,
                maxLength: 200,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (_) => setState(() {}),
                style: AppTypography.regular.copyWith(fontSize: 13, height: 1.4, color: context.torkk.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Add a comment (Optional)',
                  hintStyle: AppTypography.regular.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 16.5 / 11,
                    letterSpacing: 0,
                    color: const Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: context.torkk.surface,
                  counterText: '',
                  contentPadding: EdgeInsets.all(context.w(12)),
                  border: _commentBorder(context),
                  enabledBorder: _commentBorder(context),
                  focusedBorder: _commentBorder(context),
                  disabledBorder: _commentBorder(context),
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(6)),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${_comment.text.length}/200', style: AppTypography.regular.copyWith(fontSize: 11, color: AppColors.slate400)),
          ),
        ],
      ),
    );
  }

  Widget _rewardPage(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.surfaceMuted,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0]),
                child: Image.asset(AppAssets.celebration, width: context.w(320), fit: BoxFit.contain),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: context.w(28)),
                padding: EdgeInsets.fromLTRB(context.w(16), context.h(16), context.w(16), context.h(16)),
                decoration: BoxDecoration(color: context.torkk.surface, borderRadius: BorderRadius.circular(context.r(20))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF7C3AED), borderRadius: BorderRadius.circular(20)),
                      child: Text('Torkk Rewards', style: AppTypography.bold.copyWith(fontSize: 12, color: Colors.white)),
                    ),
                    SizedBox(height: context.h(8)),
                    Text('You earned\n200 Torkk Coins !', textAlign: TextAlign.center, style: AppTypography.bold.copyWith(fontSize: 18, letterSpacing: -0.3)),
                    Image.asset(AppAssets.giftCard, width: context.w(120), height: context.w(120)),
                    Text('Scratch & Win', style: AppTypography.bold.copyWith(fontSize: 16)),
                    Text('Exciting reward await you.', style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary)),
                    SizedBox(height: context.h(12)),
                    _fill(context, 'Scratch Card', _close),
                    SizedBox(height: context.h(8)),
                    SizedBox(
                      width: double.infinity,
                      height: context.h(44),
                      child: OutlinedButton(onPressed: _close, child: const Text('Maybe Later')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noticePage(BuildContext context, {required IconData icon, required String title, required String body}) {
    return _page(
      context,
      title: '',
      onBack: _close,
      bottom: _fill(context, 'Back to Home', _close),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: context.w(72),
                height: context.w(72),
                decoration: BoxDecoration(color: context.adaptiveTint(Color(0xFFFEE2E2)), shape: BoxShape.circle),
                child: Icon(icon, color: context.legible(Color(0xFFEF4444)), size: 32),
              ),
              SizedBox(height: context.h(16)),
              Text(title, textAlign: TextAlign.center, style: AppTypography.bold.copyWith(fontSize: 18, letterSpacing: -0.3)),
              SizedBox(height: context.h(6)),
              Text(body, textAlign: TextAlign.center, style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  void _cancel(BuildContext context) {
    var reason = 0;
    const reasons = [
      "Customer isn't at pickup location",
      'Customer asked me to cancel',
      'Wrong pickup location',
      'Safety concern',
      'Vehicle issue',
      'Other',
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.torkk.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(context.r(20)))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(alignment: Alignment.centerRight, child: IconButton(onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close))),
                  Text('Cancel ride ?', style: AppTypography.bold.copyWith(fontSize: 18, letterSpacing: -0.3)),
                  Text('Are you sure you want to cancel the ride?', style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary)),
                  SizedBox(height: context.h(10)),
                  Text('Cancellation Reason?', style: AppTypography.bold.copyWith(fontSize: 14)),
                  for (var i = 0; i < reasons.length; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(reasons[i], style: AppTypography.regular.copyWith(fontSize: 14)),
                      trailing: Icon(reason == i ? Icons.radio_button_checked : Icons.radio_button_off, color: reason == i ? Theme.of(context).colorScheme.primary : AppColors.slate400),
                      onTap: () => setSheet(() => reason = i),
                    ),
                  _fill(context, 'Cancel Ride', () {
                    Navigator.pop(sheetContext);
                    _close();
                  }),
                  SizedBox(height: context.h(8)),
                  SizedBox(
                    width: double.infinity,
                    height: context.h(46),
                    child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext), child: const Text('Keep Ride')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _rider(BuildContext context, {int passengers = 4}) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(8)),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundColor: context.adaptiveTint(const Color(0xFFF1F5F9)), child: Icon(Icons.person, color: context.torkk.textSecondary)),
          SizedBox(width: context.w(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rahul', style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2)),
                Row(
                  children: [
                    Icon(Icons.people_alt_outlined, size: 14, color: AppColors.slate400),
                    const SizedBox(width: 4),
                    Text('$passengers passengers', style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary)),
                    const SizedBox(width: 6),
                    _pill(Icons.thumb_up_alt_rounded, '1', const Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    _pill(Icons.thumb_down_alt_rounded, '2', const Color(0xFFEF4444)),
                  ],
                ),
              ],
            ),
          ),
          _dot(accent, Icons.chat_bubble_rounded),
          SizedBox(width: context.w(6)),
          _dot(accent, Icons.call_rounded),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          Text(count, style: AppTypography.regular.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _dot(Color color, IconData icon) {
    return Container(width: 32, height: 32, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 15));
  }

  // Widget _place(BuildContext context, Color color, String label, String value) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: context.h(3)),
  //     child: Row(
  //       children: [
  //         Icon(Icons.circle, size: 8, color: color),
  //         SizedBox(width: context.w(8)),
  //         Text('$label  ', style: AppTypography.regular.copyWith(fontSize: 11, color: AppColors.slate400)),
  //         Expanded(child: Text(value, style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600))),
  //       ],
  //     ),
  //   );
  // }
  Widget _place(BuildContext context, Color color, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(3)),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          SizedBox(width: context.w(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label  ',
                  style: AppTypography.regular.copyWith(
                    fontSize: 11,
                    color: AppColors.slate400,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.regular.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2)),
        Text(label, style: AppTypography.regular.copyWith(fontSize: 11, color: AppColors.slate400)),
      ],
    );
  }

  Widget _banner(String title, String body, {bool warn = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: warn ? context.adaptiveTint(const Color(0xFFFFF7ED)) : context.torkk.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(warn ? Icons.error_outline : Icons.check_circle, color: warn ? const Color(0xFFF59E0B) : const Color(0xFF16A34A), size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bold.copyWith(fontSize: 13, height: 1.2)),
                if (body.isNotEmpty) Text(body, style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _money(BuildContext context, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(12)),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(context.r(12)), border: Border.all(color: context.torkk.border)),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary))),
          Text(value, style: AppTypography.bold.copyWith(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _page(BuildContext context, {required String title, required VoidCallback onBack, required Widget child, Widget? bottom}) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(context.w(8), context.h(4), context.w(16), 0),
              child: Row(children: [_back(onBack), Expanded(child: Text(title, style: AppTypography.bold.copyWith(fontSize: 18, letterSpacing: -0.3)))]),
            ),
            Expanded(child: child),
            if (bottom != null) Padding(padding: EdgeInsets.fromLTRB(context.w(20), 0, context.w(20), context.h(12)), child: bottom),
          ],
        ),
      ),
    );
  }

  Widget _back(VoidCallback onTap) => IconButton(onPressed: onTap, icon: Icon(Icons.arrow_back_ios_new, size: 18, color: context.torkk.textPrimary));

  Widget _fill(BuildContext context, String label, VoidCallback onTap, {IconData? icon}) {
    return SizedBox(
      width: double.infinity,
      height: context.h(48),
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
        ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
          Text(
            label,
            style: AppTypography.bold.copyWith(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onPrimary,
              height: 1,
            ), ),
              if (icon != null) ...[
          const SizedBox(width: 8),
      Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 16),
      ],]  ),
    ));
  }

  Widget _outline(BuildContext context, String label, VoidCallback onTap) {
    return SizedBox(
      height: context.h(48),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
        ),
        child: Text(label, style: AppTypography.bold.copyWith(fontSize: 15, color: const Color(0xFFEF4444), height: 1)),
      ),
    );
  }
}

class _RideOtpBoxes extends StatefulWidget {
  const _RideOtpBoxes({required this.controller, required this.focusNode, required this.length});

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;

  @override
  State<_RideOtpBoxes> createState() => _RideOtpBoxesState();
}

class _RideOtpBoxesState extends State<_RideOtpBoxes> {
  int _tappedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_rebuild);
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  int get _cursorOffset {
    final text = widget.controller.text;
    final raw = widget.controller.selection.baseOffset;
    if (raw < 0) return text.length;
    return raw.clamp(0, text.length);
  }

  void _selectBox(int index) {
    final text = widget.controller.text;
    final offset = index < text.length ? index + 1 : text.length;
    widget.focusNode.requestFocus();
    widget.controller.value = widget.controller.value.copyWith(
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  }

  bool _cursorInBox(int index) {
    if (!widget.focusNode.hasFocus) return false;
    final textLength = widget.controller.text.length;
    final offset = _cursorOffset;
    if (offset == textLength) {
      final slot = textLength >= widget.length ? widget.length - 1 : textLength;
      return index == slot;
    }
    if (offset == 0) return index == 0;
    return index == offset - 1;
  }

  @override
  Widget build(BuildContext context) {
    final gap = context.w(8);
    final boxSize = (MediaQuery.sizeOf(context).width - context.w(48) - gap * (widget.length - 1)) / widget.length;
    return SizedBox(
      height: boxSize,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          IgnorePointer(
            child: Row(
              children: List.generate(widget.length, (index) {
                final char = index < widget.controller.text.length ? widget.controller.text[index] : '';
                final isActive = _cursorInBox(index);
                return Padding(
                  padding: EdgeInsets.only(right: index == widget.length - 1 ? 0 : gap),
                  child: Container(
                    width: boxSize,
                    height: boxSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.torkk.surface,
                      borderRadius: BorderRadius.circular(context.r(14)),
                      border: Border.all(
                        color: isActive ? AppColors.primary : AppColors.fieldBorder,
                        width: isActive ? 1.6 : 1,
                      ),
                    ),
                    child: Text(char, style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2)),
                  ),
                );
              }),
            ),
          ),
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                _tappedIndex = (event.localPosition.dx / (boxSize + gap)).floor().clamp(0, widget.length - 1).toInt();
                _selectBox(_tappedIndex);
              },
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType: TextInputType.number,
                autofocus: true,
                showCursor: false,
                cursorWidth: 0,
                maxLength: widget.length,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.transparent, fontSize: 1, height: 1),
                decoration: const InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  counterText: '',
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () => _selectBox(_tappedIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteMap extends StatefulWidget {
  const _RouteMap({this.navigating = false});

  final bool navigating;

  @override
  State<_RouteMap> createState() => _RouteMapState();
}

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

Future<BitmapDescriptor> _blueDot() {
  return _markerImage(56, (canvas) {
    final center = const Offset(28, 28);
    canvas.drawCircle(center, 14, Paint()..color = const Color(0x332563EB));
    canvas.drawCircle(center, 9, Paint()..color = const Color(0xFF2563EB));
    canvas.drawCircle(center, 3.5, Paint()..color = Colors.white);
  });
}

Future<BitmapDescriptor> _redPin() {
  return _markerImage(64, (canvas) {
    final path = Path()
      ..moveTo(32, 58)
      ..quadraticBezierTo(14, 36, 14, 24)
      ..arcToPoint(const Offset(50, 24), radius: const Radius.circular(18), clockwise: true)
      ..quadraticBezierTo(50, 36, 32, 58)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFEA4335));
    canvas.drawCircle(const Offset(32, 24), 6, Paint()..color = Colors.white);
  }, logical: 32);
}

/// Map marker bitmap: always drawn on white, so its text colors are fixed.
Future<BitmapDescriptor> _distanceLabel() {
  return _markerImage(120, (canvas) {
    final rect = RRect.fromRectAndRadius(const Rect.fromLTWH(4, 4, 78, 40), const Radius.circular(6));
    canvas.drawRRect(rect.shift(const Offset(0, 1)), Paint()..color = const Color(0x1A000000));
    canvas.drawRRect(rect, Paint()..color = Colors.white);
    _paintLine(canvas, '4.8 km', const Offset(12, 8), TextStyle(color: Color.fromARGB(255, 30, 41, 59), fontSize: 13, fontWeight: FontWeight.w700, height: 1));
    _paintLine(canvas, '12 min', const Offset(12, 24), TextStyle(color: Color.fromARGB(255, 100, 116, 139), fontSize: 11, fontWeight: FontWeight.w500, height: 1));
  }, logical: 60);
}

void _paintLine(Canvas canvas, String text, Offset offset, TextStyle style) {
  final painter = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
  painter.paint(canvas, offset);
}

Future<BitmapDescriptor> _markerImage(int size, void Function(Canvas canvas) draw, {double? logical}) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder));
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.bytes(bytes!.buffer.asUint8List(), imagePixelRatio: size / (logical ?? size / 2));
}
