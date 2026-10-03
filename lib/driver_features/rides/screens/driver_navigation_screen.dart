import 'package:go_router/go_router.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'dart:io';
import 'package:rider_app/common/utils/translations.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rider_app/driver_features/profile/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rider_app/common/constants/api_constants.dart';
import 'package:rider_app/service/location_consent_service.dart';
import 'package:rider_app/service/driver_api_service.dart';
import 'package:rider_app/driver_features/notifications/screens/driver_notifications_screen.dart';
import 'package:rider_app/driver_features/profile/screens/sos_screen.dart';
import 'package:rider_app/driver_features/chat/screens/driver_customer_chat_screen.dart';
import 'package:rider_app/driver_features/summary/screens/driver_trip_summary_screen.dart';
import 'package:rider_app/common/constants/map_styles.dart';
import '../widgets/widgets.dart';
export '../widgets/widgets.dart';

// --- DRIVER NAVIGATION / TRIP PROGRESS SCREEN ---
class DriverNavigationScreen extends StatefulWidget {
  const DriverNavigationScreen({super.key});

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

enum TripPhase { goingToPickup, goingToDrop }

enum DriverRideUiMode {
  accept, // RideAccept (RideCard2)
  navigation, // RideStart
  waiting, // RideWaiting (RideCard3)
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  Timer? _locationTimer;
  String _driverPhone = '';
  String _driverGender = 'Male';
  int? _rideId;
  Map<String, dynamic>? _ride;
  bool _isLoading = true;
  bool _isProcessing = false;

  Position? _currentPosition;
  GoogleMapController? _mapController;
  TripPhase _tripPhase = TripPhase.goingToPickup;
  final bool _showFullRoute = false;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Circle> _circles = {};
  BitmapDescriptor? _navPuckIcon;

  static const String _navigationMapStyle = MapStyles.navigationMapStyle;

  Future<void> _initNavigationPuckIcon() async {
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

      final path = Path();
      path.moveTo(size / 2, 6);
      path.lineTo(size - 10, size - 10);
      path.lineTo(size / 2, size - 20);
      path.lineTo(10, size - 10);
      path.close();

      canvas.drawPath(path, paint);
      canvas.drawPath(path, strokePaint);

      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes != null) {
        _navPuckIcon = BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('[DEBUG NAV] Error creating nav puck icon: $e');
    }
  }

  int get _currentSpeedKmH {
    if (_currentPosition == null) return 0;
    final speed = _currentPosition!.speed;
    if (speed.isNaN || speed.isInfinite || speed <= 0.3) return 0;
    return (speed * 3.6).round().clamp(0, 180);
  }

  String get _dynamicEtaText {
    final pickupLat = _asDouble(_ride?['pickup_lat']);
    final pickupLng =
        _ride?['pickup_lng'] != null ? _asDouble(_ride?['pickup_lng']) : null;
    final dropLat = _asDouble(_ride?['drop_lat']);
    final dropLng =
        _ride?['drop_lng'] != null ? _asDouble(_ride?['drop_lng']) : null;

    final targetLat =
        _tripPhase == TripPhase.goingToPickup ? pickupLat : dropLat;
    final targetLng =
        _tripPhase == TripPhase.goingToPickup ? pickupLng : dropLng;

    double? distMeters;

    // 1. Calculate from driver's GPS if within 50 km
    if (_currentPosition != null && targetLat != null && targetLng != null) {
      final gpsDist = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        targetLat,
        targetLng,
      );
      if (gpsDist < 50000) {
        distMeters = gpsDist;
      }
    }

    // 2. Fallback for simulator mismatch: calculate between pickup & drop
    if (distMeters == null &&
        pickupLat != null &&
        pickupLng != null &&
        dropLat != null &&
        dropLng != null) {
      distMeters = Geolocator.distanceBetween(
        pickupLat,
        pickupLng,
        dropLat,
        dropLng,
      );
    }

    if (distMeters != null) {
      final mins = (distMeters / 500.0).ceil().clamp(1, 180);
      return '$mins minutes away';
    }

    final payloadEta =
        _ride?['estimated_duration_minutes'] ??
        _ride?['eta'] ??
        _ride?['duration_minutes'];
    if (payloadEta != null) {
      return '$payloadEta minutes away';
    }

    return '5 minutes away';
  }

  String get _dynamicInstructionText {
    if (_tripPhase == TripPhase.goingToPickup) {
      return 'Head to pickup location';
    } else {
      return 'Head to drop location';
    }
  }

  // Google Directions route cache (avoid refetching every GPS tick).
  static String get _mapsApiKey => Platform.isIOS
      ? 'AIzaSyDIt1TB-ouVFAtWQg0yhDzpzyNGiGW_W3A'
      : 'AIzaSyDNrwlxB3gaotCANgyy2Q7hVi5K3JsqqBk';
  List<LatLng> _cachedRoutePoints = [];
  String? _cachedRouteKey;
  int _mapSetupToken = 0;

  // RideWaiting & RideOTP state variables
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DriverRideUiMode _uiMode = DriverRideUiMode.accept;
  int _waitingSeconds = 150; // 02:30 countdown
  Timer? _waitingTimer;
  String _driverPhotoUrl = '';
  double _driverRating = 4.8;

  Future<void> _openGoogleMapsApp() async {
    double? destLat;
    double? destLng;
    if (_tripPhase == TripPhase.goingToPickup) {
      destLat = _asDouble(_ride?['pickup_lat']) ?? 28.6328;
      destLng = _asDouble(_ride?['pickup_lng']) ?? 77.2197;
    } else {
      destLat = _asDouble(_ride?['drop_lat']) ?? 28.6328;
      destLng = _asDouble(_ride?['drop_lng']) ?? 77.2197;
    }
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=driving',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('[DEBUG NAV] Error launching Google Maps: $e');
    }
  }

  void _recenterMap() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 17,
            tilt: 35,
          ),
        ),
      );
    }
  }

  String get _formattedWaitingTime {
    final m = (_waitingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_waitingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startWaitingTimer() {
    if (_waitingTimer != null && _waitingTimer!.isActive) return;
    _waitingTimer?.cancel();
    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_tripPhase != TripPhase.goingToPickup) {
        timer.cancel();
        _waitingTimer = null;
        return;
      }
      setState(() {
        _waitingSeconds++;
      });
    });
  }

  void _stopWaitingTimer() {
    _waitingTimer?.cancel();
    _waitingTimer = null;
    _waitingSeconds = 0;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _initNavigationPuckIcon();
    _initTrip();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _waitingTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initTrip() async {
    debugPrint('[DEBUG NAV] Initializing trip');
    final prefs = await SharedPreferences.getInstance();
    _driverPhone = prefs.getString('user_phone') ?? '';
    _driverGender = prefs.getString('driver_gender') ?? 'Male';
    _driverPhotoUrl =
        prefs.getString('driver_profile_photo') ??
        prefs.getString('profile_photo_url') ??
        '';
    _driverRating =
        double.tryParse(prefs.getString('driver_rating') ?? '') ?? 4.8;
    _rideId = prefs.getInt('active_ride_id');

    if (_rideId == null || _driverPhone.isEmpty) {
      debugPrint('[DEBUG NAV] No active ride or phone');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active ride found'),
            backgroundColor: Colors.orange,
          ),
        );
        context.go(AppRoutes.home);
      }
      return;
    }

    try {
      Map<String, dynamic>? ride;
      Object? lastError;
      // Retry briefly — local backend / emulator networking can flap on restart.
      for (var attempt = 1; attempt <= 5; attempt++) {
        try {
          ride = await DriverApiService.fetchRideDetail(
            rideId: _rideId!,
            driverPhone: _driverPhone,
          );
          lastError = null;
          break;
        } catch (e) {
          lastError = e;
          debugPrint('[DEBUG NAV] fetchRideDetail attempt $attempt failed: $e');
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
      if (ride == null) {
        if (_rideId == 9902) {
          ride = {
            'id': 9902,
            'status': 'accepted',
            'ride_status': 'accepted',
            'is_parcel': true,
            'item_category': 'Electronics',
            'item_weight': 'Under 5kg',
            'item_notes': 'Handle with care, fragile item.',
            'user_name': 'Fatima Sheikh',
            'customer_name': 'Fatima Sheikh',
            'sender_name': 'Fatima Sheikh',
            'sender_phone': '+91 98765 43211',
            'receiver_name': 'Ramesh Bhai',
            'receiver_phone': '+91 99999 11111',
            'user_phone': '+91 98765 43211',
            'estimated_fare': 120.50,
            'fare': 120.50,
            'bonus': 20.0,
            'pickup_address': 'GTB, Civil Lines, Delhi',
            'drop_address': 'Cannought Place, Delhi',
            'pickup_distance_km': '0.9',
            'distance_km': '5.1',
            'pickup_lat': 28.6980,
            'pickup_lng': 77.2100,
            'drop_lat': 28.6328,
            'drop_lng': 77.2197,
            'otp': '4821',
          };
        } else if (_rideId == 9901) {
          ride = {
            'id': 9901,
            'status': 'accepted',
            'ride_status': 'accepted',
            'user_name': 'Manish Kumar',
            'customer_name': 'Manish Kumar',
            'user_phone': '+91 98765 43210',
            'estimated_fare': 72.98,
            'fare': 72.98,
            'bonus': 17.0,
            'pickup_address': 'Arya Nagar, East Delhi, Delhi',
            'drop_address': 'Preet Vihar, East Delhi, Delhi',
            'pickup_distance_km': '0.3',
            'distance_km': '1.9',
            'pickup_lat': 28.6420,
            'pickup_lng': 77.2800,
            'drop_lat': 28.6360,
            'drop_lng': 77.2950,
            'otp': '1234',
          };
        } else {
          throw lastError ?? Exception('Unable to load ride');
        }
      }

      final rideStatus = (ride['ride_status'] ?? ride['status'] ?? '')
          .toString();
      debugPrint('[DEBUG NAV] Current ride status: $rideStatus');

      if (rideStatus == 'accepted') {
        _uiMode = DriverRideUiMode.accept;
      } else if (rideStatus == 'in_progress') {
        _uiMode = DriverRideUiMode.navigation;
      }

      final pickedUpFromApi = _isTruthyFlag(ride['is_picked_up']);
      final pickedUpFromPrefs = prefs.getBool('active_ride_picked_up') ?? false;
      final pickedUp = pickedUpFromApi || pickedUpFromPrefs;

      debugPrint(
        '[DEBUG NAV] Ride details loaded, is_picked_up api=$pickedUpFromApi prefs=$pickedUpFromPrefs => $pickedUp',
      );

      if (pickedUp) {
        await prefs.setBool('active_ride_picked_up', true);
      }

      if (mounted) {
        setState(() {
          _ride = ride;
          _tripPhase = pickedUp
              ? TripPhase.goingToDrop
              : TripPhase.goingToPickup;
          _isLoading = false;
        });
        _setupMap();
        _startLocationUpdates();
        _startWaitingTimer();

        DriverApiService.fetchProfile(_driverPhone)
            .then((profile) {
              if (mounted) {
                setState(() {
                  if (profile['name'] != null &&
                      profile['name'].toString().isNotEmpty) {
                  }
                  if (profile['profile_photo'] != null &&
                      profile['profile_photo'].toString().isNotEmpty) {
                    _driverPhotoUrl = profile['profile_photo'].toString();
                  }
                  if (profile['rating'] != null) {
                    _driverRating =
                        double.tryParse(profile['rating'].toString()) ??
                        _driverRating;
                  }
                });
              }
            })
            .catchError((_) {});
      }
    } catch (e) {
      debugPrint('[DEBUG NAV] Error initializing trip: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Accepts 1/0, true/false, "true"/"1" from different API shapes.
  bool _isTruthyFlag(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final s = value.toString().trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }

  void _clearRouteCache() {
    _cachedRouteKey = null;
    _cachedRoutePoints = [];
  }

  /// Decode Google encoded polyline into LatLng points.
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  Future<List<LatLng>> _getDrivingRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    // ~100m cache grid so we don't hit routing APIs on every GPS tick.
    final cacheKey =
        '${origin.latitude.toStringAsFixed(3)},${origin.longitude.toStringAsFixed(3)}->'
        '${destination.latitude.toStringAsFixed(3)},${destination.longitude.toStringAsFixed(3)}';
    if (_cachedRouteKey == cacheKey && _cachedRoutePoints.length >= 2) {
      return _cachedRoutePoints;
    }

    // 1) Google Directions
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=$_mapsApiKey',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status']?.toString() ?? '';
        final routes = data['routes'];
        if (status == 'OK' && routes is List && routes.isNotEmpty) {
          final overview = routes[0]['overview_polyline'];
          final encoded = overview is Map
              ? overview['points']?.toString()
              : null;
          if (encoded != null && encoded.isNotEmpty) {
            final points = _decodePolyline(encoded);
            if (points.length >= 2) {
              _cachedRouteKey = cacheKey;
              _cachedRoutePoints = points;
              return points;
            }
          }
        } else {
          debugPrint('[DEBUG NAV] Google Directions status: $status');
        }
      } else {
        debugPrint('[DEBUG NAV] Google Directions HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[DEBUG NAV] Google Directions error: $e');
    }

    // 2) OSRM road route fallback (works when Maps key blocks Directions)
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=polyline',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final routes = data['routes'];
        if (data['code']?.toString() == 'Ok' &&
            routes is List &&
            routes.isNotEmpty) {
          final encoded = routes[0]['geometry']?.toString();
          if (encoded != null && encoded.isNotEmpty) {
            final points = _decodePolyline(encoded);
            if (points.length >= 2) {
              debugPrint('[DEBUG NAV] Using OSRM road route (${points.length} pts)');
              _cachedRouteKey = cacheKey;
              _cachedRoutePoints = points;
              return points;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[DEBUG NAV] OSRM route error: $e');
    }

    // Last resort: straight line (should rarely happen)
    final straightPoints = [origin, destination];
    _cachedRouteKey = cacheKey;
    _cachedRoutePoints = straightPoints;
    return straightPoints;
  }

  void _updateDriverMarkerOnly() {
    if (_currentPosition == null || !mounted) return;
    final pos = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    final heading = _currentPosition!.heading;
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'driver');
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: pos,
          icon:
              _navPuckIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          rotation: heading,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          infoWindow: const InfoWindow(title: 'Your location'),
          zIndex: 5,
        ),
      );
      _circles.removeWhere((c) => c.circleId.value == 'driver_aura');
      _circles.add(
        Circle(
          circleId: const CircleId('driver_aura'),
          center: pos,
          radius: 35,
          fillColor: const Color(0xFF2563EB).withValues(alpha: 0.22),
          strokeColor: const Color(0xFF2563EB).withValues(alpha: 0.45),
          strokeWidth: 1,
          zIndex: 4,
        ),
      );

      // Live Polyline Trimming: Trim route behind driver as driver moves forward
      if (_cachedRoutePoints.length >= 2) {
        int closestIndex = 0;
        double minDistance = double.infinity;
        for (int i = 0; i < _cachedRoutePoints.length; i++) {
          final dist = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            _cachedRoutePoints[i].latitude,
            _cachedRoutePoints[i].longitude,
          );
          if (dist < minDistance) {
            minDistance = dist;
            closestIndex = i;
          }
        }
        final remaining = [
          pos,
          ..._cachedRoutePoints.sublist(
            (closestIndex + 1).clamp(0, _cachedRoutePoints.length),
          ),
        ];
        if (remaining.length >= 2) {
          final routeColor = _tripPhase == TripPhase.goingToPickup
              ? const Color(0xFF2563EB)
              : const Color(0xFF10B981);
          _polylines
            ..clear()
            ..add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: remaining,
                color: routeColor,
                width: 6,
                jointType: JointType.round,
                endCap: Cap.roundCap,
                startCap: Cap.roundCap,
              ),
            );
        }
      }
    });
  }

  Future<void> _setupMap() async {
    if (_ride == null) return;

    final token = ++_mapSetupToken;
    debugPrint('[DEBUG NAV] Setting up map for phase: $_tripPhase');
    try {
      _markers.removeWhere((m) => m.markerId.value != 'driver');

      LatLng? origin;
      LatLng? destination;
      const routeColor = Color(0xFF2563EB); // blue road route

      if (_showFullRoute) {
        final pickupLat = _asDouble(_ride!['pickup_lat']);
        final pickupLng = _asDouble(_ride!['pickup_lng']);
        final dropLat = _asDouble(_ride!['drop_lat']);
        final dropLng = _asDouble(_ride!['drop_lng']);

        if (pickupLat != null && pickupLng != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('pickup'),
              position: LatLng(pickupLat, pickupLng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
              infoWindow: InfoWindow(
                title: 'Pickup Location',
                snippet: '${_ride!['pickup_address'] ?? ''}',
              ),
            ),
          );
          origin = LatLng(pickupLat, pickupLng);
        }
        if (dropLat != null && dropLng != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('drop'),
              position: LatLng(dropLat, dropLng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(
                title: 'Drop Location',
                snippet: '${_ride!['drop_address'] ?? ''}',
              ),
            ),
          );
          destination = LatLng(dropLat, dropLng);
        }
      } else if (_tripPhase == TripPhase.goingToPickup) {
        final pickupLat = _asDouble(_ride!['pickup_lat']);
        final pickupLng = _asDouble(_ride!['pickup_lng']);

        if (pickupLat != null && pickupLng != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('pickup'),
              position: LatLng(pickupLat, pickupLng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
              infoWindow: InfoWindow(
                title: 'Pickup Location',
                snippet: '${_ride!['pickup_address'] ?? ''}',
              ),
            ),
          );
          destination = LatLng(pickupLat, pickupLng);
        }
        if (_currentPosition != null) {
          origin = LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
        }
      } else {
        final dropLat = _asDouble(_ride!['drop_lat']);
        final dropLng = _asDouble(_ride!['drop_lng']);

        if (dropLat != null && dropLng != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('drop'),
              position: LatLng(dropLat, dropLng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(
                title: 'Drop Location',
                snippet: '${_ride!['drop_address'] ?? ''}',
              ),
            ),
          );
          destination = LatLng(dropLat, dropLng);
        }
        if (_currentPosition != null) {
          origin = LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
        }
      }

      // Driver / car navigation arrow marker & halo
      if (_currentPosition != null) {
        final pos = LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        final heading = _currentPosition!.heading;
        _markers.removeWhere((m) => m.markerId.value == 'driver');
        _markers.add(
          Marker(
            markerId: const MarkerId('driver'),
            position: pos,
            icon:
                _navPuckIcon ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
            rotation: heading,
            anchor: const Offset(0.5, 0.5),
            flat: true,
            infoWindow: const InfoWindow(title: 'Your location'),
            zIndex: 5,
          ),
        );
        _circles.removeWhere((c) => c.circleId.value == 'driver_aura');
        _circles.add(
          Circle(
            circleId: const CircleId('driver_aura'),
            center: pos,
            radius: 35,
            fillColor: const Color(0xFF2563EB).withValues(alpha: 0.22),
            strokeColor: const Color(0xFF2563EB).withValues(alpha: 0.45),
            strokeWidth: 1,
            zIndex: 4,
          ),
        );
      }

      if (mounted && token == _mapSetupToken) {
        setState(() {});
      }

      List<LatLng> routePoints = [];
      if (origin != null && destination != null) {
        routePoints = await _getDrivingRoute(origin, destination);
        if (routePoints.length < 2) {
          routePoints = [origin, destination];
        }
      }

      if (!mounted || token != _mapSetupToken) return;

      _polylines
        ..clear()
        ..addAll(
          routePoints.length >= 2
              ? [
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: routePoints,
                    color: routeColor,
                    width: 6,
                    jointType: JointType.round,
                    endCap: Cap.roundCap,
                    startCap: Cap.roundCap,
                  ),
                ]
              : [],
        );

      setState(() {});
      _fitMapBounds();
    } catch (e, st) {
      debugPrint('[DEBUG NAV] Map setup error: $e\n$st');
    }
  }

  void _fitMapBounds() {
    if (_mapController == null || _markers.isEmpty) return;

    final bounds = _calculateBounds(_markers.map((m) => m.position).toList());
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  LatLngBounds _calculateBounds(List<LatLng> positions) {
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (var pos in positions) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _startLocationUpdates() {
    _updateLocation();
    _locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _updateLocation(),
    );
  }

  Future<void> _updateLocation() async {
    if (_driverPhone.isEmpty) return;

    // Status check must happen FIRST, before any Geolocator/location calls,
    // to ensure cancellation is detected even if location permissions or GPS are off/failing.
    if (_rideId != null) {
      try {
        final rideDetail = await DriverApiService.fetchRideDetail(
          rideId: _rideId!,
          driverPhone: _driverPhone,
        );
        if (rideDetail['status'] == 'cancelled' ||
            rideDetail['ride_status'] == 'cancelled') {
          _locationTimer?.cancel();
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('active_ride_id');
          await prefs.remove('active_ride_picked_up');
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => RideCancelledDialog(
                onDismiss: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close navigation screen
                },
              ),
            );
          }
          return;
        }
      } catch (e) {
        debugPrint('[DEBUG NAV] Status check error: $e');
      }
    }

    try {
      if (!await LocationConsentService.hasAccepted()) return;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      await DriverApiService.updateLocation(
        driverPhone: _driverPhone,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      final newPos = LatLng(position.latitude, position.longitude);
      _currentPosition = position;

      // Move driver marker every tick; only rebuild road route when cache misses (~100m).
      _updateDriverMarkerOnly();

      // Trigger waiting timer automatically when driver arrives at pickup location (<=150m)
      if (_tripPhase == TripPhase.goingToPickup) {
        final pickupLat = _asDouble(_ride?['pickup_lat']);
        final pickupLng = _asDouble(_ride?['pickup_lng']);
        if (pickupLat != null && pickupLng != null) {
          final distM = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            pickupLat,
            pickupLng,
          );
          if (distM <= 150) {
            _startWaitingTimer();
          }
        }
      }

      if (_polylines.isEmpty || _cachedRoutePoints.length < 2) {
        await _setupMap();
      } else {
        // Soft-refresh route if driver moved out of cache grid.
        final dest = _tripPhase == TripPhase.goingToPickup
            ? (_asDouble(_ride?['pickup_lat']) != null &&
                      _asDouble(_ride?['pickup_lng']) != null
                  ? LatLng(
                      _asDouble(_ride!['pickup_lat'])!,
                      _asDouble(_ride!['pickup_lng'])!,
                    )
                  : null)
            : (_asDouble(_ride?['drop_lat']) != null &&
                      _asDouble(_ride?['drop_lng']) != null
                  ? LatLng(
                      _asDouble(_ride!['drop_lat'])!,
                      _asDouble(_ride!['drop_lng'])!,
                    )
                  : null);
        if (dest != null) {
          final cacheKey =
              '${newPos.latitude.toStringAsFixed(3)},${newPos.longitude.toStringAsFixed(3)}->'
              '${dest.latitude.toStringAsFixed(3)},${dest.longitude.toStringAsFixed(3)}';
          if (_cachedRouteKey != cacheKey) {
            await _setupMap();
          }
        }
      }
    } catch (e) {
      debugPrint('[DEBUG NAV] Location update error: $e');
    }
  }

  void _showRideOtpSheet() {
    final bool isParcel = _ride?['is_parcel'] == true || _ride?['service_type'] == 'parcel';
    showRideOtpBottomSheet(
      context: context,
      rideCode: (_ride?['ride_code'] ?? '').toString(),
      subtitle: isParcel ? 'Ask the Sender for Pickup OTP' : 'Ask the Passenger for OTP',
      onVerify: (otp) => _verifyAndPickupCustomer(otp),
    );
  }

  Future<void> _verifyAndPickupCustomer(String codeEntered) async {
    if (codeEntered.isEmpty || _rideId == null) return;
    debugPrint(
      '[DEBUG NAV] Customer picked up - calling API with code: $codeEntered',
    );
    setState(() => _isProcessing = true);

    try {
      await DriverApiService.pickupCustomer(
        rideId: _rideId!,
        driverPhone: _driverPhone,
        rideCode: codeEntered,
      );

      debugPrint('[DEBUG NAV] Pickup API success - switching to drop phase');
      _stopWaitingTimer();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('active_ride_picked_up', true);
      _clearRouteCache();
      setState(() {
        _tripPhase = TripPhase.goingToDrop;
        _uiMode = DriverRideUiMode.navigation;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer picked up! Heading to drop location.'),
            backgroundColor: Colors.green,
          ),
        );
        _setupMap();
      }
    } catch (e) {
      debugPrint('[DEBUG NAV] Pickup API error: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handlePickedUp() async {
    if (_isProcessing || _rideId == null) return;
    _showRideOtpSheet();
  }

  void _showDeliveryOtpSheet() {
    showRideOtpBottomSheet(
      context: context,
      rideCode: (_ride?['delivery_code'] ?? '').toString(),
      subtitle: 'Ask the Receiver for Delivery OTP',
      onVerify: (otp) => _verifyAndCompleteTrip(otp),
    );
  }

  Future<void> _verifyAndCompleteTrip(String otp) async {
    if (otp.isEmpty) return;
    setState(() => _isProcessing = true);
    // Proceed to complete trip after "verifying" delivery OTP
    await _completeTrip();
  }

  Future<void> _completeTrip() async {
    if (_rideId == null || _isProcessing || _ride == null) return;

    // Set is_dropped = 1 on the backend so customer receives payment screen
    try {
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/driver/reached'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ride_id': _rideId}),
      );
    } catch (e) {
      debugPrint('[DEBUG NAV] Error marking drop reached: $e');
    }

    _locationTimer?.cancel();
    _waitingTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_ride_id');
    await prefs.remove('active_ride_picked_up');

    if (mounted) {
      final bool isParcel = _ride!['is_parcel'] == true || _ride!['service_type'] == 'parcel';
      final customerName = isParcel
          ? (_ride!['receiver_name'] ?? _ride!['customer_name'] ?? 'Receiver')
          : (_ride!['customer_name'] ?? 'Customer');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DriverTripSummaryScreen(
            rideId: _rideId!,
            driverPhone: _driverPhone,
            estimatedFare:
                (_ride!['estimated_fare'] as num?)?.toDouble() ?? 0.0,
            customerName: customerName.toString(),
            customerPhone: _ride!['receiver_phone'] ?? _ride!['customer_phone'] ?? '',
          ),
        ),
      );
    }
  }


  void _openChat() {
    final phone = _ride?['customer_phone'] ?? '';
    final name = _ride?['customer_name'] ?? 'Customer';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DriverCustomerChatScreen(customerName: name, customerPhone: phone),
      ),
    );
  }

  void _callCustomer() {
    final phone = _ride?['customer_phone'] ?? '';
    if (phone.isNotEmpty) {
      launchUrl(Uri.parse('tel:$phone'));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer phone not available')),
      );
    }
  }

  void _onSliderAction() {
    if (_tripPhase == TripPhase.goingToDrop) {
      final bool isParcel = _ride?['is_parcel'] == true || _ride?['service_type'] == 'parcel';
      if (isParcel) {
        _showDeliveryOtpSheet();
      } else {
        _completeTrip();
      }
    } else {
      if (_uiMode == DriverRideUiMode.accept) {
        setState(() {
          _uiMode = DriverRideUiMode.navigation;
        });
        if (_rideId != null &&
            _rideId != 9901 &&
            _rideId != 9902 &&
            _driverPhone.isNotEmpty) {
          DriverApiService.startRide(
            rideId: _rideId!,
            driverPhone: _driverPhone,
          ).catchError((e) {
            debugPrint('[DEBUG NAV] Error starting ride in backend: $e');
            return null;
          });
        }
      } else if (_uiMode == DriverRideUiMode.waiting) {
        _handlePickedUp();
      } else {
        setState(() {
          _uiMode = DriverRideUiMode.waiting;
        });
      }
    }
  }

  Widget _buildSliderButton() {
    return NavigationSliderButton(
      isDrop: _tripPhase == TripPhase.goingToDrop,
      isProcessing: _isProcessing,
      onAction: _onSliderAction,
    );
  }



  void _showLocationDetailBottomSheet({
    required String title,
    required String address,
    required String distanceText,
    required Color color,
    double? lat,
    double? lng,
  }) {
    showLocationDetailBottomSheet(
      context: context,
      title: title,
      address: address,
      distanceText: distanceText,
      color: color,
      lat: lat,
      lng: lng,
    );
  }

  Widget _buildRideCard() {
    final isAccept =
        _tripPhase == TripPhase.goingToPickup &&
        _uiMode == DriverRideUiMode.accept;
    final isDrop = _tripPhase == TripPhase.goingToDrop;

    return NavigationRideCard(
      ride: _ride,
      isAccept: isAccept,
      isDrop: isDrop,
      currentPosition: _currentPosition,
      onNavigate: () {
        setState(() {
          _uiMode = DriverRideUiMode.navigation;
        });
      },
      onChat: _openChat,
      onCall: _callCustomer,
      onLocationTap: ({
        required String title,
        required String address,
        required String distanceText,
        required Color color,
        double? lat,
        double? lng,
      }) {
        _showLocationDetailBottomSheet(
          title: title,
          address: address,
          distanceText: distanceText,
          color: color,
          lat: lat,
          lng: lng,
        );
      },
      sliderButton: _buildSliderButton(),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBottomNav(driverPhotoUrl: _driverPhotoUrl);
  }

  @override
  Widget build(BuildContext context) {
    final isNavigatingMode = _uiMode == DriverRideUiMode.navigation;

    return ValueListenableBuilder<String>(
      valueListenable: AppTranslations.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          key: _scaffoldKey,
          /* drawer: CustomDriverDrawer(
            profilePhotoUrl: _driverPhotoUrl,
            driverName: _driverName,
            driverRating: _driverRating,
            driverDob: _driverDob,
            driverProfile: _driverProfile,
            onClose: () => Navigator.pop(context),
          ), */
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    // 1. FULLSCREEN GOOGLE MAP WITH SCREENSHOT THEME & AURA
                    Positioned.fill(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition != null
                              ? LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                )
                              : LatLng(
                                  _asDouble(_ride?['pickup_lat']) ?? 28.6139,
                                  _asDouble(_ride?['pickup_lng']) ?? 77.2090,
                                ),
                          zoom: 17.2,
                          tilt: 35.0,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                        circles: _circles,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        trafficEnabled: true,
                        buildingsEnabled: true,
                        indoorViewEnabled: true,
                        compassEnabled: true,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          controller.setMapStyle(_navigationMapStyle);
                          _fitMapBounds();
                        },
                      ),
                    ),

                    // 2. TOP FLOATING BAR (Notification Bell + Green >| Icon on Left, ONLINE Pill in Center, Driver Avatar on Right)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left Group: Notification Bell + (Green >| Button when Ride Active)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Notification Bell Button
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DriverNotificationsScreen(
                                            profilePhotoUrl: _driverPhotoUrl,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF334155),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
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
                              if (_ride != null) ...[
                                const SizedBox(width: 8),
                                // Green >| Circular Icon (Placed right next to Notification Bell in RideAccept/RideStart)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isNavigatingMode) {
                                        _uiMode =
                                            _tripPhase == TripPhase.goingToPickup
                                            ? DriverRideUiMode.waiting
                                            : DriverRideUiMode.accept;
                                      } else {
                                        _uiMode = DriverRideUiMode.navigation;
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF22C55E,
                                          ).withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/nav_next_icon.png',
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Center Action Pill: ONLINE Pill Button (in RideSearch1 when _ride == null)
                          if (_ride == null)
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF22C55E,
                                      ).withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'ONLINE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),

                          // Driver Profile Avatar with Dynamic Gender Ring
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfileScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      _driverGender.trim().toLowerCase() ==
                                          'female'
                                      ? const Color(0xFFEC4899)
                                      : const Color(0xFF1D4ED8),
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _driverPhotoUrl.isNotEmpty
                                    ? Image.network(
                                        _driverPhotoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, error, stackTrace) => Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.person,
                                            color: Color(0xFF334155),
                                            size: 24,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.person,
                                          color: Color(0xFF334155),
                                          size: 24,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. RIDESTART FLOATING SPEEDOMETER (Top-Left, Real GPS Speed)
                    if (isNavigatingMode)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 68,
                        left: 16,
                        child: SpeedometerWidget(speedKmH: _currentSpeedKmH),
                      ),

                    // 4. RIDESTART FLOATING "Open Maps" CAPSULE (Bottom-Left)
                    if (isNavigatingMode)
                      Positioned(
                        bottom: 124,
                        left: 16,
                        child: GestureDetector(
                          onTap: _openGoogleMapsApp,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF334155),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.near_me_rounded,
                                    color: Color(0xFF2563EB),
                                    size: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Open Maps',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // 5. RIDESTART FLOATING BUTTONS (Recenter & SOS, Bottom-Right)
                    if (isNavigatingMode)
                      Positioned(
                        bottom: 124,
                        right: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _recenterMap,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF334155),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.my_location_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SosScreen(),
                                ),
                              ),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFEF4444,
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'SOS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 6. RIDESTART BOTTOM ETA DRAWER (Dynamic GPS ETA & Instruction)
                    if (isNavigatingMode)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _uiMode = _tripPhase == TripPhase.goingToPickup
                                  ? DriverRideUiMode.waiting
                                  : DriverRideUiMode.accept;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              10,
                              20,
                              MediaQuery.of(context).padding.bottom + 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
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
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(
                                      Icons.format_list_bulleted_rounded,
                                      color: Color(0xFF334155),
                                      size: 24,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          _dynamicEtaText,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _dynamicInstructionText,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: _openChat,
                                      child: Image.asset(
                                        'assets/chat_icon.png',
                                        width: 22,
                                        height: 22,
                                        color: const Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // 7. UNIFIED BOTTOM PANEL (RideAccept, RideWaiting, RideCompleted matching Figma)
                    if (!isNavigatingMode)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 20,
                                offset: const Offset(0, -6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 12),
                              // 02:30 countdown pill in RideWaiting
                              if (_uiMode == DriverRideUiMode.waiting) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _formattedWaitingTime,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF334155),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 36,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF334155),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: _buildRideCard(),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                color: const Color(0xFFE2E8F0),
                              ),
                              _buildBottomNav(),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}


