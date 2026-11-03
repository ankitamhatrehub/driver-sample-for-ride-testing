import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/service/api_client.dart';

/// SOS alerts (`/api/safety/sos` and `/api/safety/stop-sos`). Methods throw an
/// [Exception] with a readable message on failure.
class SosApiService {
  static const _timeout = Duration(seconds: 15);

  /// The ride the driver is on, saved by the ride flow.
  static Future<int?> activeRideId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('active_ride_id');
  }

  static Future<String> _phone() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone') ?? '';
    if (phone.isEmpty) {
      throw Exception('Phone number not found. Please log in.');
    }
    return phone;
  }

  /// POST /safety/sos with the ride, the driver's phone and live location.
  static Future<void> start({int? rideId}) async {
    final id = rideId ?? await activeRideId();
    if (id == null) throw Exception('No active ride to attach the SOS to.');
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 8),
      ),
    );
    final body = {
      'ride_id': id,
      'phone': await _phone(),
      'lat': position.latitude,
      'lng': position.longitude,
    };
    await _post('SOS START', AppUrls.sosStart, body);
  }

  /// POST /safety/stop-sos.
  static Future<void> stop({int? rideId}) async {
    final id = rideId ?? await activeRideId();
    if (id == null) throw Exception('No active ride to stop the SOS for.');
    final body = {'ride_id': id, 'phone': await _phone()};
    await _post('SOS STOP', AppUrls.sosStop, body);
  }

  static Future<void> _post(
    String label,
    String url,
    Map<String, dynamic> body,
  ) async {
    debugPrint(
      '[$label] before API call -> POST $url body=${json.encode(body)}',
    );
    try {
      final response = await apiClient
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(_timeout);
      debugPrint(
        '[$label] after API call <- status=${response.statusCode} '
        'body=${response.body}',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_message(response.body));
      }
    } catch (e) {
      debugPrint('[$label] after API call <- FAILED: $e');
      rethrow;
    }
  }

  static String _message(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map) {
        final msg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (msg != null) return '$msg';
      }
    } catch (_) {}
    return 'Something went wrong. Please try again.';
  }
}
