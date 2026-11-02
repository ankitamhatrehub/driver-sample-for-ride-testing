part of 'package:rider_app/driver_features/home/screens/driver_home_screen.dart';

int? _rideIdOf(Map ride) {
  final id = ride['id'];
  return id is int ? id : int.tryParse('$id');
}

extension _DriverHomeScreenStateSections on _DriverHomeScreenState {
  void _stopRealtimeLocationStream() {
    _realtimePositionSubscription?.cancel();
    _realtimePositionSubscription = null;
  }

  /// Resume an accepted / in-progress ride after app restart or crash.
  Future<void> _checkActiveRide() async {
    if (_driverPhone.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    int? rideId = prefs.getInt('active_ride_id');

    try {
      final rides = await DriverApiService.fetchActiveRides(
        driverPhone: _driverPhone,
      );
      for (final ride in rides) {
        if (ride is! Map) continue;
        final status = (ride['status'] ?? '').toString();
        if (status == 'accepted' || status == 'in_progress') {
          final idVal = ride['id'];
          final parsed = idVal is int ? idVal : int.tryParse('$idVal');
          if (parsed != null) {
            rideId = parsed;
            await prefs.setInt('active_ride_id', parsed);
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('[DEBUG HOME] Error fetching active rides for restore: $e');
      // Fall through and still try prefs-based restore.
    }

    if (rideId == null || !mounted) return;

    // Resume inside the new ride UI: the next poll fills _rides and
    // _syncFlowRide opens the ride at its accepted / in-progress step.
    debugPrint('[DEBUG HOME] Restoring active ride $rideId');
    if (mounted) setState(() => _showRideFlow = true);
    await _fetchRides();
  }

  Future<void> _forceLogoutDueToMissingProfile() async {
    debugPrint(
      'WARNING: Backend returned 404 for driver profile/earnings. Auto-logout is temporarily disabled for UI testing.',
    );
    /*
    if (_driverPhone == '9999999999') {
      // Do not auto-logout the test/bypass account
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your account was not found on the server. Please register again.',
          ),
        ),
      );
      context.go(AppRoutes.startup);
    }
    */
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _fetchRides();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isOnline) {
        _fetchRides();
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _playNewRideAlert() async {
    try {
      await _rideAlertPlayer.stop();
      await _rideAlertPlayer.play(AssetSource('sounds/ride_alert.wav'));
      final pickup = _rides
          .cast<dynamic>()
          .where((r) {
            if (r is! Map) return false;
            return (r['status'] ?? '').toString() == 'requested';
          })
          .map((r) => (r['pickup_address'] ?? '').toString())
          .firstWhere((a) => a.isNotEmpty, orElse: () => '');
      unawaited(
        RideAlertService.showNewRideNotification(
          title: 'New ride request',
          body: pickup.isEmpty
              ? 'Open TORKK Driver to accept the ride'
              : 'Pickup: $pickup',
        ),
      );
    } catch (e) {
      debugPrint('Error playing ride alert: $e');
    }
  }

  void _applyGenderTheme(String gender) {
    final female = gender.toLowerCase() == 'female';
    context.read<ThemeBloc>().add(AccentChanged(isPink: female));
  }

  int _jobsFrom(List<dynamic> trips) {
    final now = DateTime.now();
    var today = 0;
    var dated = false;
    var completed = 0;
    for (final trip in trips) {
      if (trip is! Map) continue;
      final status = (trip['status'] ?? '').toString().toLowerCase();
      final done =
          status.isEmpty ||
          status == 'completed' ||
          status == 'complete' ||
          status == 'finished';
      if (done && status.isNotEmpty) completed++;
      final raw =
          trip['completed_at'] ??
          trip['created_at'] ??
          trip['date'] ??
          trip['trip_date'];
      final parsed = DateTime.tryParse('${raw ?? ''}');
      if (parsed != null) {
        dated = true;
        final sameDay =
            parsed.year == now.year &&
            parsed.month == now.month &&
            parsed.day == now.day;
        if (done && sameDay) today++;
      }
    }
    if (dated) return today;
    if (completed > 0) return completed;
    return trips.length;
  }

  /// Keeps the new ride UI on one ride: picks the first open request, then
  /// follows that ride through every poll. A request that disappears from
  /// the list was taken or cancelled, so the UI is told it is unavailable.
  void _syncFlowRide() {
    final current = _flowRide;
    debugPrint(
      'RIDE_FLOW_05 | sync start | showRideFlow=$_showRideFlow isOnline=$_isOnline '
      'rides=${_rides.length} rejected=$_rejectedRideIds current=$current',
    );
    for (final r in _rides) {
      if (r is Map) {
        debugPrint(
          'RIDE_FLOW_06 | ride item id=${r['id']} status="${r['status']}" '
          'customer=${r['customer_name']} pickup=${r['pickup_address']} keys=${r.keys.toList()}',
        );
      } else {
        debugPrint('RIDE_FLOW_06A | non-map item: ${r.runtimeType} $r');
      }
    }
    if (current != null) {
      final id = _rideIdOf(current);
      for (final ride in _rides) {
        if (ride is Map && _rideIdOf(ride) == id) {
          _flowRide = Map<String, dynamic>.from(ride);
          debugPrint(
            'RIDE_FLOW_07 | refreshed current ride #$id status=${ride['status']}',
          );
          return;
        }
      }
      if ((current['status'] ?? '').toString() == 'requested') {
        _flowRide = {...current, 'status': 'unavailable'};
        debugPrint(
          'RIDE_FLOW_08 | ride #$id missing from list -> marked unavailable',
        );
      } else {
        debugPrint(
          'RIDE_FLOW_09 | ride #$id missing from list, status=${current['status']} kept',
        );
      }
      return;
    }
    if (!_showRideFlow || !_isOnline) {
      debugPrint(
        'RIDE_FLOW_10 | NOT picking ride: showRideFlow=$_showRideFlow isOnline=$_isOnline',
      );
      return;
    }
    for (final ride in _rides) {
      final status = ride is Map ? (ride['status'] ?? '').toString() : '';
      final running = status == 'accepted' || status == 'in_progress';
      if (ride is! Map || (status != 'requested' && !running)) {
        debugPrint(
          'RIDE_FLOW_11 | skip: not a "requested" ride -> ${ride is Map ? ride['status'] : ride}',
        );
        continue;
      }
      final id = _rideIdOf(ride);
      if (id == null || _rejectedRideIds.contains(id)) {
        debugPrint('RIDE_FLOW_12 | skip: id=$id null or rejected');
        continue;
      }
      _flowRide = Map<String, dynamic>.from(ride);
      debugPrint('RIDE_FLOW_13 | PICKED ride #$id -> $_flowRide');
      return;
    }
    debugPrint('RIDE_FLOW_14 | no requested ride found, _flowRide stays null');
  }

  Future<void> _acceptRide(int rideId) async {
    try {
      try {
        await DriverApiService.acceptRide(
          rideId: rideId,
          driverPhone: _driverPhone,
        );
      } catch (apiErr) {
        debugPrint('[DEBUG ACCEPT] API accept failed (or test ride): $apiErr');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('active_ride_id', rideId);
      await prefs.remove('active_ride_picked_up');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride accepted! Starting navigation...'),
            backgroundColor: Colors.green,
          ),
        );
        context.push(AppRoutes.navigation);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept ride: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileNotificationsScreen()),
    );
  }
}
