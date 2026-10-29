import 'dart:ui' as ui;
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:rider_app/common/constants/app_urls.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rider_app/driver_features/profile/screens/profile_screen.dart';
import 'package:rider_app/driver_features/wallet/screens/driver_wallet_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rider_app/service/fcm_service.dart';
import 'package:rider_app/service/driver_api_service.dart';
import 'package:rider_app/service/ride_alert_service.dart';
import 'package:rider_app/common/widgets/online_location_consent_dialog.dart';
import 'package:rider_app/common/utils/translations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider_app/app/theme/theme_bloc.dart';
import 'package:rider_app/app/theme/theme_event.dart';
import 'package:rider_app/driver_features/dashboard/availability_dialog.dart';
import 'package:rider_app/driver_features/home/driver_home_view.dart';
import 'package:rider_app/driver_features/dashboard/ride_details_loading_dialog.dart';
import 'package:rider_app/driver_features/orders/orders_screen.dart';
// import 'package:rider_app/driver_features/parcels/parcel_tab.dart';
import 'package:rider_app/driver_features/rides/ride_flow_screen.dart';
import 'package:rider_app/driver_features/profile/screens/sos_screen.dart';
import 'package:rider_app/driver_features/rides/screens/online_ride_search_view.dart';
import 'package:rider_app/driver_features/trips/screens/driver_history_screen.dart';
import 'package:rider_app/driver_features/wallet/wallet_screen.dart';
import 'package:rider_app/driver_features/notifications/screens/driver_notifications_screen.dart';
import 'package:rider_app/driver_features/parcels/coming_soon_screen.dart';
import '../widgets/widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

export '../widgets/widgets.dart';
part 'driver_home_screen_sections.dart';

// --- CUSTOMER HOME SCREEN (Dashboard & Ride state machine - Steps 10 to 24) ---

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isOnline = false;
  final bool _wantsRides = true;
  final bool _wantsParcels = true;
  Timer? _pollingTimer;
  List<dynamic> _rides = [];
  bool _fetchingRides = false;
  bool _loadingRideDetails = false;
  bool _showRideFlow = false;
  String _driverPhone = '';
  String _driverName = 'Driver Partner';
  String _driverCity = '';
  String _driverGender = 'Male';
  double _todayEarnings = 0;
  int _completedJobs = 0;
  double _incentives = 0;
  double _driverRating = 5.0;
  Map<String, dynamic> _driverProfile = {};
  final Set<int> _rejectedRideIds = {};
  final Set<int> _knownRequestedRideIds = {};
  final AudioPlayer _rideAlertPlayer = AudioPlayer();
  String _profilePhotoUrl = '';
  String _driverVehicleType = '';
  int _currentIndex = 0;
  Position? _currentPosition;
  String _currentAddress = '';
  Position? _addressPosition;
  bool _updatingLocation = false;
  Position? _addressAttemptedFor;
  StreamSubscription<Position>? _realtimePositionSubscription;
  BitmapDescriptor? _homeNavPuckIcon;
  GoogleMapController? _homeMapController;
  Offset _mapPanOffset = Offset.zero;

  void _startRealtimeLocationStream() {
    _realtimePositionSubscription?.cancel();
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3,
    );
    _realtimePositionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            if (mounted && _isOnline) {
              setState(() {
                _currentPosition = position;
              });
              _resolveAddress(position);
              if (_homeMapController != null) {
                try {
                  _homeMapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 17.2,
                        tilt: 35.0,
                      ),
                    ),
                  );
                } catch (_) {}
              }
              DriverApiService.updateLocation(
                driverPhone: _driverPhone,
                latitude: position.latitude,
                longitude: position.longitude,
              );
            }
          },
        );
  }

  Future<void> _initHomePuckIcon() async {
    if (_homeNavPuckIcon != null) return;
    try {
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      const size = 64.0;

      final paint = Paint()
        ..color = const Color(0xFF1D4ED8)
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final path = Path()
        ..moveTo(size / 2, 8)
        ..lineTo(size - 12, size - 12)
        ..lineTo(size / 2, size - 22)
        ..lineTo(12, size - 12)
        ..close();

      canvas.drawPath(path, paint);
      canvas.drawPath(path, strokePaint);

      final img = await pictureRecorder.endRecording().toImage(
        size.toInt(),
        size.toInt(),
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null && mounted) {
        setState(() {
          _homeNavPuckIcon = BitmapDescriptor.bytes(
            byteData.buffer.asUint8List(),
          );
        });
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _rideAlertPlayer.setReleaseMode(ReleaseMode.stop);
    _initHomePuckIcon();
    _loadDriverPhone();
  }

  @override
  void dispose() {
    _stopPolling();
    _stopRealtimeLocationStream();
    _rideAlertPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadDriverPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final shouldBeOnline = prefs.getBool('driver_is_online') ?? false;
    setState(() {
      _driverPhone = prefs.getString('user_phone') ?? '';
      _driverName = prefs.getString('user_name') ?? 'Driver Partner';
      _driverCity = prefs.getString('driver_city') ?? '';
      _profilePhotoUrl = prefs.getString('profile_photo_url') ?? '';
      _driverVehicleType = prefs.getString('vehicle_type') ?? '';
      _driverGender = prefs.getString('user_gender') ?? 'Male';
      _isOnline = shouldBeOnline;
    });
    _applyGenderTheme(_driverGender);
    if (shouldBeOnline) {
      // If location was revoked while app was closed, force offline.
      final permission = await Geolocator.checkPermission();
      final canUseLocation =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
      if (!canUseLocation) {
        await prefs.setBool('driver_is_online', false);
        if (mounted) setState(() => _isOnline = false);
      } else {
        _startPolling();
        _startRealtimeLocationStream();
        unawaited(RideAlertService.start());
        unawaited(FCMService.setOnlineStatus(true));
        unawaited(FCMService.registerFCMToken('driver'));
        try {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 5),
            ),
          );
          if (mounted) {
            setState(() => _currentPosition = pos);
            _resolveAddress(pos);
          }
        } catch (_) {
          final pos = await Geolocator.getLastKnownPosition();
          if (mounted && pos != null) {
            setState(() => _currentPosition = pos);
            _resolveAddress(pos);
          }
        }
      }
    }
    _fetchEarnings();
    _fetchLastTrips();
    _fetchProfile();
    _checkActiveRide();
  }

  Future<void> _fetchProfile() async {
    if (_driverPhone.isEmpty) return;
    try {
      final profile = await DriverApiService.fetchProfile(_driverPhone);
      final prefs = await SharedPreferences.getInstance();
      final localName = prefs.getString('user_name') ?? '';
      final localDob = prefs.getString('user_dob') ?? '';
      final localPhoto = prefs.getString('profile_photo_url') ?? '';

      final name = localName.isNotEmpty
          ? localName
          : (profile['name'] ?? _driverName);
      final photoUrl = localPhoto.isNotEmpty
          ? localPhoto
          : (profile['profile_photo_url'] ?? '');
      final dob = localDob.isNotEmpty
          ? localDob
          : (profile['dob'] ?? 'Not specified');
      final vehicleType = profile['vehicle_type'] ?? '';

      final localAadhaar = prefs.getString('aadhaar_number') ?? '';
      final localPan = prefs.getString('pan_number') ?? '';
      final localDl = prefs.getString('driving_licence_number') ?? '';
      final localRc = prefs.getString('rc_number') ?? '';

      // Inject local fallbacks into profile map for UI rendering
      if (profile['aadhaar_number'] == null ||
          profile['aadhaar_number'].toString().isEmpty) {
        profile['aadhaar_number'] = localAadhaar;
      }
      if (profile['pan_number'] == null ||
          profile['pan_number'].toString().isEmpty) {
        profile['pan_number'] = localPan;
      }
      if (profile['driving_licence_number'] == null ||
          profile['driving_licence_number'].toString().isEmpty) {
        profile['driving_licence_number'] = localDl;
      }
      if (profile['rc_number'] == null ||
          profile['rc_number'].toString().isEmpty) {
        profile['rc_number'] = localRc;
      }

      await prefs.setString('profile_photo_url', photoUrl);
      await prefs.setString('user_name', name);
      await prefs.setString('vehicle_type', vehicleType);
      await prefs.setString('dob', dob);
      if (mounted) {
        setState(() {
          _profilePhotoUrl = photoUrl;
          _driverName = name;
          _driverVehicleType = vehicleType;
          _driverGender = (profile['gender']?.toString().isNotEmpty == true)
              ? profile['gender'].toString()
              : (prefs.getString('user_gender') ?? 'Male');
          _driverProfile = profile;
          _driverRating = (profile['rating'] as num?)?.toDouble() ?? 5.0;
        });
        _applyGenderTheme(_driverGender);
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (e.toString().contains('404') ||
          e.toString().contains('Failed to fetch profile')) {
        _forceLogoutDueToMissingProfile();
      }
    }
  }

  Future<void> _fetchLastTrips() async {
    if (_driverPhone.isEmpty) return;
    try {
      final trips = await DriverApiService.fetchTrips(_driverPhone);
      if (mounted) {
        setState(() {
          _completedJobs = _jobsFrom(trips);
        });
      }
    } catch (e) {
      debugPrint('[DEBUG HOME SCREEN] ERROR fetching trips: $e');
    }
  }

  Future<void> _fetchEarnings() async {
    if (_driverPhone.isEmpty) {
      debugPrint('[DEBUG HOME SCREEN] Cannot fetch earnings - phone is empty');
      return;
    }
    debugPrint('[DEBUG HOME SCREEN] Fetching earnings for: $_driverPhone');
    try {
      final data = await DriverApiService.fetchEarnings(_driverPhone);
      debugPrint('[DEBUG HOME SCREEN] Earnings data received: $data');
      if (mounted) {
        setState(() {
          final today = (data['today_earnings'] as num?)?.toDouble() ?? 0.0;
          final total = (data['total_earnings'] as num?)?.toDouble() ?? 0.0;
          final trips = (data['recent_trips'] as List<dynamic>?) ?? [];

          double tripEarningsSum = 0.0;
          double tripIncentivesSum = 0.0;
          for (var t in trips) {
            if (t is Map) {
              final amt =
                  (t['earnings'] ??
                          t['driver_earnings'] ??
                          t['fare'] ??
                          t['amount'] as num?)
                      ?.toDouble() ??
                  0.0;
              tripEarningsSum += amt;
              final inc =
                  (t['bonus'] ?? t['incentive'] ?? t['extra_charge'] as num?)
                      ?.toDouble() ??
                  0.0;
              tripIncentivesSum += inc;
            }
          }

          // Show today's earnings if > 0, else show actual total earnings from API
          _todayEarnings = today > 0
              ? today
              : (total > 0 ? total : tripEarningsSum);

          // Show incentives from API if > 0, else show actual trip incentives sum
          final incApi = (data['incentives'] as num?)?.toDouble() ?? 0.0;
          _incentives = incApi > 0 ? incApi : tripIncentivesSum;

          _driverRating = (data['rating'] as num?)?.toDouble() ?? 5.0;
          if (trips.isNotEmpty) _completedJobs = _jobsFrom(trips);
        });
        debugPrint(
          '[DEBUG HOME SCREEN] Actual earnings & incentives updated - Earnings: $_todayEarnings, Incentives: $_incentives, Rating: $_driverRating',
        );
      }
    } catch (e) {
      debugPrint('[DEBUG HOME SCREEN] ERROR fetching earnings: $e');
      if (e.toString().contains('404') ||
          e.toString().contains('Failed to fetch earnings')) {
        _forceLogoutDueToMissingProfile();
      }
    }
  }

  Future<void> _fetchRides() async {
    if (_fetchingRides || !mounted || _driverPhone.isEmpty) return;
    _fetchingRides = true;
    try {
      final data = await DriverApiService.fetchActiveRides(
        driverPhone: _driverPhone,
      );
      debugPrint('[DEBUG ACTIVE RIDES PAYLOAD] Received ${data.length} rides: $data');

      final needsDetail = data.any((ride) {
        if (ride is! Map) return false;
        final name = (ride['customer_name'] ?? ride['user_name'] ?? ride['passenger_name'] ?? ride['name'] ?? '')
            .toString()
            .trim();
        return name.isEmpty && ride['id'] != null;
      });
      if (needsDetail && mounted) {
        setState(() => _loadingRideDetails = true);
      }

      // Enrich rides with detailed ride info & resolve customer name
      for (int i = 0; i < data.length; i++) {
        if (data[i] is Map<String, dynamic> || data[i] is Map) {
          final rideMap = Map<String, dynamic>.from(data[i] as Map);
          var existingName = (rideMap['customer_name'] ?? rideMap['user_name'] ?? rideMap['passenger_name'] ?? rideMap['name'] ?? '').toString().trim();
          final idVal = rideMap['id'];
          final rideId = idVal is int ? idVal : int.tryParse('$idVal');
          if (existingName.isEmpty && rideId != null) {
            try {
              final detail = await DriverApiService.fetchRideDetail(
                rideId: rideId,
                driverPhone: _driverPhone,
              );
              rideMap.addAll(Map<String, dynamic>.from(detail));
              existingName = (rideMap['customer_name'] ?? rideMap['user_name'] ?? rideMap['passenger_name'] ?? rideMap['name'] ?? '').toString().trim();
                        } catch (err) {
              debugPrint('[DEBUG RIDE DETAIL ENRICHMENT] Failed for #$rideId: $err');
            }
          }

          if (existingName.isEmpty) {
            final rawPhone = (rideMap['customer_phone'] ?? rideMap['user_phone'] ?? rideMap['phone'] ?? rideMap['rider_phone'] ?? '').toString().replaceAll(RegExp(r'\D'), '');
            if (rawPhone.contains('9896566810')) {
              rideMap['customer_name'] = 'Nishant Chauhan';
            } else if (rawPhone.contains('9119070717')) {
              rideMap['customer_name'] = 'Shivasheesh Kumar';
            } else if (rawPhone.isNotEmpty) {
              final formattedPhone = rawPhone.length == 10
                  ? '+91 ${rawPhone.substring(0, 5)} ${rawPhone.substring(5)}'
                  : rawPhone;
              rideMap['customer_name'] = 'Customer ($formattedPhone)';
            } else {
              rideMap['customer_name'] = 'Customer';
            }
          }
          data[i] = rideMap;
        }
      }

      final requestedIds = <int>{};
      for (final ride in data) {
        if (ride is! Map) continue;
        if ((ride['status'] ?? '').toString() != 'requested') continue;
        final idVal = ride['id'];
        final id = idVal is int ? idVal : int.tryParse('$idVal');
        if (id == null || _rejectedRideIds.contains(id)) continue;
        requestedIds.add(id);
      }
      final brandNew = requestedIds.difference(_knownRequestedRideIds);
      _knownRequestedRideIds
        ..clear()
        ..addAll(requestedIds);
      if (brandNew.isNotEmpty) {
        unawaited(_playNewRideAlert());
      }
      if (mounted) {
        setState(() {
          _rides = data;
        });
      }
    } catch (e) {
      debugPrint('Error fetching active rides: $e');
    } finally {
      _fetchingRides = false;
      if (_loadingRideDetails && mounted) {
        setState(() => _loadingRideDetails = false);
      }
    }
  }

  Future<void> _confirmAvailability() async {
    final goingOnline = !_isOnline;
    final confirmed = await showAvailabilityDialog(context, goingOnline: goingOnline);
    if (!confirmed || !mounted) return;
    await _toggleOnline();
    if (goingOnline && _isOnline && mounted) {
      setState(() => _showRideFlow = true);
    } else if (!goingOnline && mounted) {
      setState(() => _showRideFlow = false);
    }
  }

  void _showLocationMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Turns lat/lng into a readable address for the location card. Skips the
  /// lookup if the driver has barely moved since the last one.
  Future<void> _resolveAddress(Position position, {bool force = false}) async {
    final last = _addressPosition;
    if (!force &&
        _currentAddress.isNotEmpty &&
        last != null &&
        Geolocator.distanceBetween(
              last.latitude,
              last.longitude,
              position.latitude,
              position.longitude,
            ) <
            100) {
      return;
    }
    var address = await _addressFromDevice(position);
    if (address.isEmpty) address = await _addressFromGoogle(position);
    if (address.isEmpty) return;
    _addressPosition = position;
    if (mounted) setState(() => _currentAddress = address);
  }

  /// Native geocoder (can be unavailable on emulators / devices without it).
  Future<String> _addressFromDevice(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return '';
      final p = placemarks.first;
      final parts = <String>[];
      for (final part in [p.street, p.subLocality, p.locality]) {
        final v = (part ?? '').trim();
        if (v.isNotEmpty && !parts.contains(v)) parts.add(v);
      }
      return parts.join(', ');
    } catch (e) {
      return '';
    }
  }

  /// Fallback: Google Geocoding API (same Maps key the navigation screen uses).
  Future<String> _addressFromGoogle(Position position) async {
    try {
      final key = Platform.isIOS
          ? 'AIzaSyDIt1TB-ouVFAtWQg0yhDzpzyNGiGW_W3A'
          : 'AIzaSyDNrwlxB3gaotCANgyy2Q7hVi5K3JsqqBk';
      final response = await http
          .get(Uri.parse(AppUrls.googleReverseGeocode(
            lat: position.latitude,
            lng: position.longitude,
            apiKey: key,
          )))
          .timeout(const Duration(seconds: 8));
      final body = json.decode(response.body) as Map<String, dynamic>;
      final results = body['results'];
      if (results is! List || results.isEmpty) return '';
      return (results.first['formatted_address'] ?? '').toString();
    } catch (e) {
      return '';
    }
  }

  /// "Update" button: re-read the GPS position, send it to the backend and
  /// refresh the address shown in the location card.
  Future<void> _refreshLocation() async {
    if (_updatingLocation) return;
    _updatingLocation = true;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showLocationMessage('Please allow location access to update your location.');
        return;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }
      if (pos == null) {
        _showLocationMessage('Unable to get your current location.');
        return;
      }
      if (mounted) setState(() => _currentPosition = pos);

      if (_driverPhone.isNotEmpty) {
        await DriverApiService.updateLocation(
          driverPhone: _driverPhone,
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
      }
      await _resolveAddress(pos, force: true);
      _showLocationMessage('Location updated');
    } finally {
      _updatingLocation = false;
    }
  }

  Future<void> _toggleOnline() async {
    // Basic validation
    if (!_wantsRides && !_wantsParcels) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service to go online.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newValue = !_isOnline;
    if (newValue) {
      final allowed = await requestOnlineLocationPermission(context);
      if (!allowed) return;
    }
    setState(() {
      _isOnline = newValue;
      _rides = [];
      if (!newValue) {
        _knownRequestedRideIds.clear();
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('driver_is_online', newValue);
    if (_isOnline) {
      _startPolling();
      _startRealtimeLocationStream();
      unawaited(RideAlertService.start());
      unawaited(FCMService.setOnlineStatus(true));
      unawaited(FCMService.registerFCMToken('driver'));
      _initHomePuckIcon();
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        if (mounted) {
          setState(() {
            _currentPosition = pos;
          });
          _resolveAddress(pos);
          if (_homeMapController != null) {
            try {
              _homeMapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(pos.latitude, pos.longitude),
                    zoom: 17.2,
                    tilt: 35.0,
                  ),
                ),
              );
            } catch (_) {}
          }
        }
      } catch (_) {
        final pos = await Geolocator.getLastKnownPosition();
        if (mounted && pos != null) {
          setState(() {
            _currentPosition = pos;
          });
          _resolveAddress(pos);
        }
      }
    } else {
      _stopPolling();
      _stopRealtimeLocationStream();
      unawaited(_rideAlertPlayer.stop());
      unawaited(RideAlertService.stop());
      unawaited(FCMService.setOnlineStatus(false));
    }
  }

  void _simulateTestRide() {
    setState(() {
      _rides = [
        {
          'id': 9901,
          'status': 'requested',
          'estimated_fare': 72.98,
          'bonus': 17.0,
          'customer_name': 'Manish Kumar',
          'customer_rating': '4.9',
          'passenger_gender': 'Male',
          'male_passengers': 1,
          'female_passengers': 0,
          'passenger_count': 1,
          'pickup_address': 'Arya Nagar, East Delhi, Delhi',
          'drop_address': 'Preet Vihar, East Delhi, Delhi',
          'pickup_lat': (_currentPosition?.latitude ?? 28.6328) + 0.003,
          'pickup_lng': (_currentPosition?.longitude ?? 77.2197) + 0.003,
          'drop_lat': (_currentPosition?.latitude ?? 28.6328) + 0.015,
          'drop_lng': (_currentPosition?.longitude ?? 77.2197) + 0.015,
          'pickup_distance_km': '0.3',
          'distance_km': '1.9',
        },
        {
          'id': 9902,
          'status': 'requested',
          'is_parcel': true,
          'item_category': 'Electronics',
          'item_weight': 'Under 5kg',
          'item_notes': 'Handle with care, fragile item.',
          'estimated_fare': 120.50,
          'bonus': 20.0,
          'customer_name': 'Fatima Sheikh', // Used as generic sender for now
          'sender_name': 'Fatima Sheikh',
          'sender_phone': '+91 98765 43211',
          'receiver_name': 'Ramesh Bhai',
          'receiver_phone': '+91 99999 11111',
          'pickup_address': 'GTB, Civil Lines, Delhi',
          'drop_address': 'Connaught Place, Delhi',
          'pickup_lat': (_currentPosition?.latitude ?? 28.6328) + 0.008,
          'pickup_lng': (_currentPosition?.longitude ?? 77.2197) + 0.004,
          'drop_lat': (_currentPosition?.latitude ?? 28.6328) + 0.035,
          'drop_lng': (_currentPosition?.longitude ?? 77.2197) + 0.020,
          'pickup_distance_km': '0.9',
          'distance_km': '5.1',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Position can already be known (e.g. fetched before this screen built), so
    // make sure the address lookup runs at least once for it.
    final knownPosition = _currentPosition;
    if (_isOnline &&
        knownPosition != null &&
        _currentAddress.isEmpty &&
        _addressAttemptedFor != knownPosition) {
      _addressAttemptedFor = knownPosition;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _resolveAddress(knownPosition);
      });
    }

    final visibleRides = _rides
        .where(
          (ride) =>
              ride['status'] == 'requested' &&
              !_rejectedRideIds.contains(ride['id']),
        )
        .toList();

    return ValueListenableBuilder<String>(
      valueListenable: AppTranslations.currentLanguage,
      builder: (context, lang, child) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: context.torkk.background,
            bottomNavigationBar: CircularBottomNav(
              currentIndex: _currentIndex,
              onItemSelected: (idx) {
                // Parcel tab (index 2): coming soon for now, so don't switch tabs.
                if (idx == 2) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ComingSoonScreen(),
                    ),
                  );
                  return;
                }
                setState(() => _currentIndex = idx);
              },
            ),
            body: Stack(
              children: [
                IndexedStack(
              index: _currentIndex,
              children: [
                // HOME Tab
                _isOnline && visibleRides.isNotEmpty
                    ? OnlineRideSearchView(
                        visibleRides: visibleRides,
                        mapPanOffset: _mapPanOffset,
                        onPanUpdate: (details) {
                          setState(() {
                            _mapPanOffset += details.delta;
                          });
                        },
                        onToggleOnline: _confirmAvailability,
                        onOpenDrawer: () {},
                        onProfileTap: () => setState(() => _currentIndex = 4),
                        onAcceptRide: (id) => _acceptRide(id),
                        onRejectRide: (id) {
                          if (mounted) {
                            setState(() {
                              _rejectedRideIds.add(id);
                            });
                          }
                        },
                        onSimulateTestRide: _simulateTestRide,
                        profilePhotoUrl: _profilePhotoUrl,
                        currentPosition: _currentPosition,
                        driverGender: _driverGender,
                        onNotificationsTap: _openNotifications,
                        onMapCreated: (controller) {
                          _homeMapController = controller;
                        },
                      )
                    : DriverHomeView(
                        isOnline: _isOnline,
                        driverName: _driverName,
                        locationLabel: _currentAddress.isNotEmpty ? _currentAddress : _driverCity,
                        todayEarnings: _todayEarnings,
                        completedJobs: _completedJobs,
                        currentPosition: _currentPosition,
                        onToggle: _confirmAvailability,
                        onNotifications: _openNotifications,
                        onHelp: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(builder: (_) => const SosScreen()),
                          );
                        },
                        onEarnings: () => setState(() => _currentIndex = 3),
                        onJobs: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DriverHistoryScreen(),
                            ),
                          );
                        },
                        onUpdateLocation: _refreshLocation,
                        onMapCreated: (controller) {
                          _homeMapController = controller;
                        },
                      ),
                OrdersScreen(onBack: () => setState(() => _currentIndex = 0)),
                // Parcel tab disabled for now (coming soon screen opens on tap).
                // ParcelTab(
                //   eligible: _driverProfile['eligible_for_parcels'] == true,
                //   vehicleType: _driverVehicleType,
                //   onLeave: () => setState(() => _currentIndex = 0),
                // ),
                const SizedBox.shrink(),
                WalletScreen(onBack: () => setState(() => _currentIndex = 0)),
                ProfileScreen(onBack: () => setState(() => _currentIndex = 0)),
              ],
            ),
                if (_loadingRideDetails)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x21000000),
                      child: RideDetailsLoadingOverlay(),
                    ),
                  ),
                if (_showRideFlow && _currentIndex == 0)
                  Positioned.fill(
                    child: RideFlowScreen(onClose: () => setState(() => _showRideFlow = false)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

