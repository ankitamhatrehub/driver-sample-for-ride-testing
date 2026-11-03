part of 'package:rider_app/driver_features/rides/screens/driver_navigation_screen.dart';

extension _DriverNavigationScreenStateSections on _DriverNavigationScreenState {
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
      AppUrls.googleMapsNavigation(destLat: destLat, destLng: destLng),
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
        AppUrls.googleDirections(
          originLat: origin.latitude,
          originLng: origin.longitude,
          destLat: destination.latitude,
          destLng: destination.longitude,
          apiKey: _DriverNavigationScreenState._mapsApiKey,
        ),
      );
      debugPrint(
        '[API] before -> GET ${url.toString().replaceAll(RegExp(r'key=[^&]+'), 'key=***')}',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      debugPrint(
        '[API] after  <- GOOGLE DIRECTIONS status=${response.statusCode} '
        'body=${response.body.length > 300 ? '${response.body.substring(0, 300)}...' : response.body}',
      );
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
        AppUrls.osrmRoute(
          originLat: origin.latitude,
          originLng: origin.longitude,
          destLat: destination.latitude,
          destLng: destination.longitude,
        ),
      );
      debugPrint(
        '[API] before -> GET ${url.toString().replaceAll(RegExp(r'key=[^&]+'), 'key=***')}',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      debugPrint(
        '[API] after  <- OSRM ROUTE status=${response.statusCode} '
        'body=${response.body.length > 300 ? '${response.body.substring(0, 300)}...' : response.body}',
      );
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
              debugPrint(
                '[DEBUG NAV] Using OSRM road route (${points.length} pts)',
              );
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

  void _fitMapBounds() {
    if (_mapController == null || _markers.isEmpty) return;

    final bounds = _calculateBounds(_markers.map((m) => m.position).toList());
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
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
    final bool isParcel =
        _ride?['is_parcel'] == true || _ride?['service_type'] == 'parcel';
    showRideOtpBottomSheet(
      context: context,
      rideCode: (_ride?['ride_code'] ?? '').toString(),
      subtitle: isParcel
          ? 'Ask the Sender for Pickup OTP'
          : 'Ask the Passenger for OTP',
      onVerify: (otp) => _verifyAndPickupCustomer(otp),
    );
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

  Future<void> _completeTrip() async {
    if (_rideId == null || _isProcessing || _ride == null) return;

    // Set is_dropped = 1 on the backend so customer receives payment screen
    try {
      await DriverApiService.markReached(rideId: _rideId);
    } catch (e) {
      debugPrint('[DEBUG NAV] Error marking drop reached: $e');
    }

    _locationTimer?.cancel();
    _waitingTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_ride_id');
    await prefs.remove('active_ride_picked_up');

    if (mounted) {
      final bool isParcel =
          _ride!['is_parcel'] == true || _ride!['service_type'] == 'parcel';
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
            customerPhone:
                _ride!['receiver_phone'] ?? _ride!['customer_phone'] ?? '',
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

  Widget _buildBottomNav() {
    return NavigationBottomNav(driverPhotoUrl: _driverPhotoUrl);
  }
}
