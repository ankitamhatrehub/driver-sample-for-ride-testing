import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/service/api_client.dart';

/// Answer of `POST /api/v1/location/check`.
class ServiceAvailability {
  const ServiceAvailability({
    required this.comingSoon,
    required this.latitude,
    required this.longitude,
  });

  /// True when Torkk does not run in the driver's area yet (outside Delhi NCR).
  final bool comingSoon;
  final double latitude;
  final double longitude;
}

/// Is Torkk live where the driver is? Plus the "Notify me" sign-up for areas
/// that are not live yet.
class LocationAvailabilityService {
  static const _timeout = Duration(seconds: 15);

  /// The device position if location is already allowed. Null when it is not
  /// allowed or no position can be read.
  static Future<Position?> currentPosition() async {
    try {
      // Never asks the OS for permission here: that only happens after the
      // in-app disclosure (LocationPermissionFlow). Without permission this
      // just returns null.
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('[LOCATION API] permission not granted: $permission');
        return null;
      }
      // A recent known position is plenty for a city check and avoids waiting
      // for a GPS fix every time the app opens.
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('[LOCATION API] current position failed: $e');
      return Geolocator.getLastKnownPosition();
    }
  }

  /// POST /v1/location/check with the current position. Returns null when the
  /// position or the server answer is unavailable, so a hiccup never locks a
  /// driver out (the backend still enforces the service area).
  static Future<ServiceAvailability?> check() async {
    final position = await currentPosition();
    if (position == null) return null;
    final body = {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
    debugPrint('[LOCATION API] check -> ${AppUrls.locationCheck} body=$body');
    try {
      final response = await apiClient
          .post(
            Uri.parse(AppUrls.locationCheck),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      debugPrint(
        '[LOCATION API] check <- status=${response.statusCode} '
        'body=${response.body}',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;
      final data = decoded['data'] is Map ? decoded['data'] as Map : const {};
      final flag =
          decoded['coming_soon'] ??
          data['coming_soon'] ??
          decoded['is_coming_soon'] ??
          data['is_coming_soon'];
      final comingSoon = flag == true;
      debugPrint(
        '[LOCATION API] check parsed: coming_soon=$flag -> '
        '${comingSoon ? 'show Coming Soon' : 'go to home'}',
      );
      return ServiceAvailability(
        comingSoon: comingSoon,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      debugPrint('[LOCATION API] check FAILED: $e');
      return null;
    }
  }

  /// POST /v1/location/notify-me. Returns the server's message. Throws an
  /// [Exception] with a readable message on failure.
  static Future<String> notifyMe({double? latitude, double? longitude}) async {
    var lat = latitude;
    var lng = longitude;
    if (lat == null || lng == null) {
      final position = await currentPosition();
      if (position == null) {
        throw Exception('Turn on location so we can tell you when we arrive.');
      }
      lat = position.latitude;
      lng = position.longitude;
    }
    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('[LOCATION API] FCM token failed: $e');
    }
    final body = {'latitude': lat, 'longitude': lng, 'fcm_token': token};
    debugPrint(
      '[LOCATION API] notify-me -> ${AppUrls.locationNotifyMe} body=$body',
    );
    final response = await apiClient
        .post(
          Uri.parse(AppUrls.locationNotifyMe),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    debugPrint(
      '[LOCATION API] notify-me <- status=${response.statusCode} '
      'body=${response.body}',
    );
    Map<String, dynamic> decoded = {};
    try {
      final d = jsonDecode(response.body);
      if (d is Map) decoded = Map<String, dynamic>.from(d);
    } catch (_) {}
    final ok =
        response.statusCode >= 200 &&
        response.statusCode < 300 &&
        decoded['success'] != false;
    if (!ok) {
      throw Exception(
        '${decoded['message'] ?? decoded['error'] ?? 'Could not save your request. Please try again.'}',
      );
    }
    return '${decoded['message'] ?? 'You will be notified when services become available in your area.'}';
  }
}
