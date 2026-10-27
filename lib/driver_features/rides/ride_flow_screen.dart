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

part 'ride_flow_screen_parts/ride_otp_boxes.dart';
part 'ride_flow_screen_parts/ride_otp_boxes_state.dart';
part 'ride_flow_screen_parts/route_map.dart';
part 'ride_flow_screen_parts/route_map_state.dart';
part 'ride_flow_screen_sections.dart';

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

  _Phase get _backPhase => switch (_phase) {
        _Phase.toPickup => _Phase.request,
        _Phase.arrived => _Phase.toPickup,
        _Phase.waiting => _Phase.arrived,
        _Phase.active => _Phase.otp,
        _Phase.navigating => _navBack,
        _Phase.drop => _Phase.navigating,
        _ => _Phase.request,
      };

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

  Widget _back(VoidCallback onTap) => IconButton(onPressed: onTap, icon: Icon(Icons.arrow_back_ios_new, size: 18, color: context.torkk.textPrimary));

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
