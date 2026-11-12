import 'package:rider_app/common/widgets/sheet_with_sos.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/dashboard/ride_details_loading_dialog.dart';
import 'package:rider_app/driver_features/rides/ride_payment_flow.dart';
import 'package:rider_app/driver_features/rides/widgets/passenger_gender_bubbles.dart';
import 'package:rider_app/service/driver_api_service.dart';
import 'package:rider_app/driver_features/profile/screens/tickets_screen.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

part 'ride_flow_screen_parts/ride_otp_boxes.dart';
part 'ride_flow_screen_parts/ride_otp_boxes_state.dart';
part 'ride_flow_screen_parts/route_map.dart';
part 'ride_flow_screen_parts/route_map_state.dart';
part 'ride_flow_screen_sections.dart';

/// New ride UI. Driven by a ride from `active-rides`; calls the ride APIs
/// (accept, start, pickup with OTP, reached, complete) as the driver moves on.
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
  payment,
  completed,
  rate,
  reward,
  unavailable,
  expired,
}

const _pickup = LatLng(28.5666, 77.3208);
const _drop = LatLng(28.5716, 77.3272);

class RideFlowScreen extends StatefulWidget {
  const RideFlowScreen({
    super.key,
    required this.ride,
    required this.driverPhone,
    required this.driverName,
    required this.onClose,
  });

  /// Latest ride payload from the active-rides poll.
  final Map<String, dynamic> ride;
  final String driverPhone;
  final String driverName;
  final VoidCallback onClose;

  @override
  State<RideFlowScreen> createState() => _RideFlowScreenState();
}

class _RideFlowScreenState extends State<RideFlowScreen> {
  /// A ride resumed after app restart opens at its real step, not the request.
  late _Phase _phase = switch ((widget.ride['status'] ?? '')
      .toString()
      .toLowerCase()) {
    'accepted' => _Phase.toPickup,
    'in_progress' || 'picked_up' => _Phase.active,
    _ => _Phase.request,
  };
  late Map<String, dynamic> _ride = Map<String, dynamic>.from(widget.ride);
  bool _busy = false;
  double _earnings = 0;
  int _offer = 28;
  int _wait = 133;
  int _arrivedSecs = 0;
  RidePaymentResult? _payment;
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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_phase == _Phase.request && _offer > 0) {
          _offer--;
          if (_offer == 0) _phase = _Phase.expired;
        }
        if (_phase == _Phase.waiting) _wait++;
        if (_phase == _Phase.arrived) {
          // Customer has not shown up yet: start the waiting-charges timer.
          if (++_arrivedSecs >= 10) {
            _arrivedSecs = 0;
            _wait = 0;
            _phase = _Phase.waiting;
          }
        } else {
          _arrivedSecs = 0;
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant RideFlowScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.ride, widget.ride)) return;
    _ride = {..._ride, ...widget.ride};
    final status = (_ride['status'] ?? '').toString().toLowerCase();
    final gone =
        status == 'cancelled' ||
        status == 'canceled' ||
        status == 'unavailable';
    final live =
        _phase != _Phase.completed &&
        _phase != _Phase.rate &&
        _phase != _Phase.reward &&
        _phase != _Phase.unavailable &&
        _phase != _Phase.expired;
    if (gone && live) {
      _timer?.cancel();
      setState(() => _phase = _Phase.unavailable);
    }
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

  // ----- ride data -----
  int? get _rideId {
    final id = _ride['id'];
    return id is int ? id : int.tryParse('$id');
  }

  bool get _isSample => _rideId == 9901 || _rideId == 9902;

  /// Sample rides (ids 9901/9902) are local only; skip the backend for them.
  bool get _callsApi =>
      _rideId != null && !_isSample && widget.driverPhone.isNotEmpty;

  String _text(List<String> keys, String fallback) {
    for (final key in keys) {
      final value = _ride[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return fallback;
  }

  String get _customerName => _text([
    'customer_name',
    'user_name',
    'passenger_name',
    'name',
  ], 'Customer');
  String get _pickupAddress => _text(['pickup_address'], '-');
  String get _dropAddress => _text(['drop_address'], '-');
  String get _vehicleLabel =>
      _text(['vehicle_type', 'service_type'], 'CAB').toUpperCase();

  /// Vehicle picture for the ride's vehicle type (cab.png, bike.png, ...).
  String get _vehicleAsset {
    final type = _vehicleLabel.toLowerCase();
    if (type.contains('bike')) return AppAssets.bike;
    if (type.contains('auto')) return AppAssets.auto;
    if (type.contains('xl')) return AppAssets.xlCab;
    if (type.contains('ev')) return AppAssets.evCab;
    return AppAssets.cab;
  }

  /// Masked number issued by the backend for this ride. The driver never sees
  /// the customer's real number, and the customer never sees the driver's.
  String get _virtualNumber => _text([
    'virtual_number',
    'masked_number',
    'proxy_number',
    'call_number',
  ], '');

  /// Amount to collect from the rider.
  double get _payTotal {
    final fare = num.tryParse(
      _text(['estimated_fare', 'fare', 'total_fare'], ''),
    );
    if (fare != null && fare > 0) return fare.toDouble();
    if (_earnings > 0) return _earnings;
    return 450;
  }

  String get _riderId =>
      _text(['customer_id', 'user_id', 'rider_id'], 'TRK${_rideId ?? 10245}');

  String get _fareLabel {
    final fare = num.tryParse(
      _text(['estimated_fare', 'fare', 'total_fare'], ''),
    );
    return fare == null ? '-' : '₹${fare.round()}';
  }

  String get _distanceText {
    final km = num.tryParse(_text(['distance_km'], ''));
    return km == null
        ? '-'
        : '${km % 1 == 0 ? km.toInt() : km.toStringAsFixed(1)} km';
  }

  String get _durationText {
    final mins = num.tryParse(
      _text([
        'duration_mins',
        'duration_minutes',
        'eta_mins',
        'estimated_duration',
      ], ''),
    );
    return mins == null ? '-' : '${mins.round()} min';
  }

  LatLng get _pickupPoint => _point('pickup_lat', 'pickup_lng') ?? _pickup;
  LatLng get _dropPoint => _point('drop_lat', 'drop_lng') ?? _drop;

  LatLng? _point(String latKey, String lngKey) {
    final lat = double.tryParse('${_ride[latKey]}');
    final lng = double.tryParse('${_ride[lngKey]}');
    if (lat == null || lng == null || (lat == 0 && lng == 0)) return null;
    return LatLng(lat, lng);
  }

  void _toast(String message, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  String _errorText(Object e) => e.toString().replaceFirst('Exception: ', '');

  // ----- ride APIs -----
  Future<void> _accept() async {
    if (_busy || _sheetLocked) return;
    setState(() => _busy = true);
    try {
      if (!_callsApi) {
        debugPrint(
          '[RIDE API] accept-ride SKIPPED: rideId=$_rideId '
          'driverPhone="${widget.driverPhone}" (sample ride or empty phone)',
        );
      }
      if (_callsApi) {
        await DriverApiService.acceptRide(
          rideId: _rideId!,
          driverPhone: widget.driverPhone,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('active_ride_id', _rideId!);
        await prefs.remove('active_ride_picked_up');
      }
      if (!mounted) return;
      setState(() => _busy = false);
      _openNextSheet(_Phase.toPickup);
    } catch (e) {
      debugPrint(
        '[RIDE API] accept-ride failed ($e); '
        'showing "unavailable"',
      );
      if (!mounted) return;
      setState(() => _busy = false);
      _openNextSheet(_Phase.unavailable);
    }
  }

  /// Navigate on "Heading to Pickup": goes straight to the Arrived sheet
  /// (Verify OTP). The distance / duration screen is only for the drop leg.
  void _startTrip() => _go(_Phase.arrived);

  /// "Start Ride" on the waiting sheet: tells the backend the ride started,
  /// then asks for the customer's OTP. A failure is logged and does not block.
  void _startRide() {
    if (_callsApi) {
      DriverApiService.startRide(
        rideId: _rideId!,
        driverPhone: widget.driverPhone,
      ).catchError((Object e) {
        debugPrint('[RIDE FLOW] start-ride failed: $e');
      });
    } else {
      debugPrint(
        '[RIDE API] start-ride SKIPPED: rideId=$_rideId driverPhone="${widget.driverPhone}"',
      );
    }
    _go(_Phase.otp);
  }

  Future<void> _verifyOtp() async {
    if (_busy || _otp.text.length != 4) return;
    setState(() => _busy = true);
    try {
      if (_callsApi) {
        await DriverApiService.pickupCustomer(
          rideId: _rideId!,
          driverPhone: widget.driverPhone,
          rideCode: _otp.text,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('active_ride_picked_up', true);
      }
      if (!mounted) return;
      _otp.clear();
      setState(() => _busy = false);
      _go(_Phase.active);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast(_errorText(e));
    }
  }

  /// Same payment handling the old trip-summary screen did: if the customer
  /// already paid online (transaction id on the ride) it is UPI, otherwise the
  /// saved method (default cash). The method is sent to the backend with
  /// set-payment-method so the customer's app shows the right payment screen.
  Future<String> _settlePaymentMethod() async {
    var method = _text(['payment_method'], 'cash').toLowerCase();
    var paidOnline = false;
    try {
      final response = await DriverApiService.fetchRideDetailResponse(
        rideId: _rideId!,
        driverPhone: widget.driverPhone,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body is Map && body['ride'] is Map ? body['ride'] : body;
        if (data is Map) {
          final txn = (data['transaction_id'] ?? '').toString();
          final saved = (data['payment_method'] ?? '').toString().toLowerCase();
          if (txn.isNotEmpty && txn.toUpperCase() != 'CASH') {
            method = 'upi';
            paidOnline = true;
          } else if (saved == 'cash' || saved == 'upi') {
            method = saved;
          }
        }
      }
    } catch (e) {
      debugPrint('[RIDE FLOW] payment status check failed: $e');
    }
    if (method != 'cash' && method != 'upi') method = 'cash';
    if (!paidOnline) {
      try {
        await DriverApiService.setPaymentMethod(
          rideId: _rideId!,
          driverPhone: widget.driverPhone,
          paymentMethod: method,
        );
      } catch (e) {
        debugPrint('[RIDE FLOW] set-payment-method failed: $e');
      }
    }
    _ride['payment_method'] = method;
    return method;
  }

  Future<void> _endRide() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_callsApi) {
        try {
          await DriverApiService.markReached(rideId: _rideId);
        } catch (e) {
          debugPrint('[RIDE FLOW] reached failed: $e');
        }
        final method = await _settlePaymentMethod();
        _earnings = await DriverApiService.completeRide(
          rideId: _rideId!,
          driverPhone: widget.driverPhone,
          paymentMethod: method,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('active_ride_id');
        await prefs.remove('active_ride_picked_up');
      } else {
        _earnings = double.tryParse(_text(['estimated_fare'], '')) ?? 0;
      }
      if (!mounted) return;
      setState(() => _busy = false);
      _go(_Phase.payment);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast(_errorText(e));
    }
  }

  void _callCustomer() {
    final number = _virtualNumber;
    if (number.isEmpty) {
      _toast('Virtual number not available yet');
      return;
    }
    launchUrl(Uri.parse('tel:$number'));
  }

  bool get _showSos => switch (_phase) {
    _Phase.toPickup ||
    _Phase.arrived ||
    _Phase.waiting ||
    _Phase.active ||
    _Phase.drop => true,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _Phase.loading => const Stack(
        children: [
          Positioned.fill(
            child: ModalBarrier(color: Color(0x21000000), dismissible: false),
          ),
          RideDetailsLoadingOverlay(),
        ],
      ),
      _Phase.request => _requestOverlay(context),
      _Phase.otp => _otpPage(context),
      _Phase.payment => RidePaymentFlow(
        total: _payTotal,
        earning: _earnings,
        riderId: _riderId,
        rideId: '${_rideId ?? ''}',
        distanceLabel: _distanceText,
        onBack: () => _toast(AppStrings.payBackBlocked, error: false),
        onDone: (result) {
          setState(() => _payment = result);
          _go(_Phase.completed);
        },
      ),
      _Phase.completed => _completedPage(context),
      _Phase.rate => _ratePage(context),
      _Phase.reward => _rewardPage(context),
      _Phase.unavailable => _noticePage(
        context,
        icon: Icons.directions_car_filled_rounded,
        title: 'Ride no longer available',
        body:
            'This ride has been taken by another driver or no longer available.',
      ),
      _Phase.expired => _noticePage(
        context,
        icon: Icons.wifi_off_rounded,
        title: 'Request Expired',
        body: "You didn't respond in time.",
      ),
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
    const tags = [
      'Polite',
      'On time',
      'Good Communication',
      'Safe ride',
      'Helpful',
    ];
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
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.r(14)),
                ),
              ),
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          Center(
            child: CircleAvatar(
              radius: context.w(28),
              backgroundColor: context.adaptiveTint(const Color(0xFFF3E8FF)),
              child: Icon(
                Icons.person,
                color: context.legible(Color(0xFFBA2879)),
              ),
            ),
          ),
          SizedBox(height: context.h(8)),
          Text(
            _customerName,
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(fontSize: 16),
          ),
          SizedBox(height: context.h(10)),
          Text(
            'How was your Ride?',
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _stars = i),
                  icon: Icon(
                    Icons.star_rounded,
                    color: i <= _stars
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFE2E8F0),
                    size: 32,
                  ),
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
                  onTap: () => setState(
                    () => _pickedTags.contains(tag)
                        ? _pickedTags.remove(tag)
                        : _pickedTags.add(tag),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _pickedTags.contains(tag)
                          ? accent.withValues(alpha: 0.12)
                          : context.adaptiveTint(Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: AppTypography.regular.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                style: AppTypography.regular.copyWith(
                  fontSize: 13,
                  height: 1.4,
                  color: context.torkk.textPrimary,
                ),
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
            child: Text(
              '${_comment.text.length}/200',
              style: AppTypography.regular.copyWith(
                fontSize: 11,
                color: AppColors.slate400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _back(VoidCallback onTap) => IconButton(
    onPressed: onTap,
    icon: Icon(
      Icons.arrow_back_ios_new,
      size: 18,
      color: context.torkk.textPrimary,
    ),
  );
}

Future<BitmapDescriptor> _blueDot() {
  return _markerImage(56, (canvas) {
    final center = const Offset(28, 28);
    canvas.drawCircle(center, 14, Paint()..color = const Color(0x332563EB));
    canvas.drawCircle(center, 9, Paint()..color = const Color(0xFF2563EB));
    canvas.drawCircle(center, 3.5, Paint()..color = Colors.white);
  });
}

/// The ride's vehicle picture (cab.png, bike.png, ...) as a small map marker,
/// shown at the ride's start point. Falls back to the blue dot.
Future<BitmapDescriptor> _vehicleMarker(String asset) async {
  try {
    final data = await rootBundle.load(asset);
    final bytes = data.buffer.asUint8List();
    final probe = await (await ui.instantiateImageCodec(bytes)).getNextFrame();
    final portrait = probe.image.height > probe.image.width;
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: portrait ? null : 160,
      targetHeight: portrait ? 160 : null,
    );
    final image = (await codec.getNextFrame()).image;
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    // 160 px drawn at about 56 logical px on the map.
    return BitmapDescriptor.bytes(
      png!.buffer.asUint8List(),
      imagePixelRatio: 160 / 56,
    );
  } catch (_) {
    return _blueDot();
  }
}

Future<BitmapDescriptor> _redPin() {
  return _markerImage(64, (canvas) {
    final path = Path()
      ..moveTo(32, 58)
      ..quadraticBezierTo(14, 36, 14, 24)
      ..arcToPoint(
        const Offset(50, 24),
        radius: const Radius.circular(18),
        clockwise: true,
      )
      ..quadraticBezierTo(50, 36, 32, 58)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFEA4335));
    canvas.drawCircle(const Offset(32, 24), 6, Paint()..color = Colors.white);
  }, logical: 32);
}

/// Map marker bitmap: always drawn on white, so its text colors are fixed.
Future<BitmapDescriptor> _distanceLabel(String distance, String duration) {
  return _markerImage(120, (canvas) {
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4, 4, 78, 40),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      rect.shift(const Offset(0, 1)),
      Paint()..color = const Color(0x1A000000),
    );
    canvas.drawRRect(rect, Paint()..color = Colors.white);
    _paintLine(
      canvas,
      distance,
      const Offset(12, 8),
      TextStyle(
        color: Color.fromARGB(255, 30, 41, 59),
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
    _paintLine(
      canvas,
      duration,
      const Offset(12, 24),
      TextStyle(
        color: Color.fromARGB(255, 100, 116, 139),
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1,
      ),
    );
  }, logical: 60);
}

void _paintLine(Canvas canvas, String text, Offset offset, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, offset);
}

Future<BitmapDescriptor> _markerImage(
  int size,
  void Function(Canvas canvas) draw, {
  double? logical,
}) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder));
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.bytes(
    bytes!.buffer.asUint8List(),
    imagePixelRatio: size / (logical ?? size / 2),
  );
}
