import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'common/constants/api_constants.dart';
import 'driver/services/ride_alert_service.dart';

class FCMService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> setupHandlers() async {
    FirebaseMessaging.onMessage.listen((message) async {
      await _showFromRemote(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('FCM opened from background: ${message.data}');
    });

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      print('FCM opened from terminated: ${initial.data}');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await registerFCMToken('driver', tokenOverride: token);
    });
  }

  static Future<void> _showFromRemote(RemoteMessage message) async {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'New ride request';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        'Open TORKK Driver to accept the ride';
    await RideAlertService.showNewRideNotification(
      title: title,
      body: body,
      payload: message.data['ride_id']?.toString(),
    );
  }

  static Future<void> registerFCMToken(
    String type, {
    String? tokenOverride,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!isLoggedIn) return;

    final phone = prefs.getString('user_phone');
    if (phone == null || phone.isEmpty) return;

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android 13+ notification permission is also requested via local notifications.
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final token = tokenOverride ?? await messaging.getToken();
    if (token == null || token.isEmpty) return;

    print('FCM Token: $token');
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/fcm-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'fcm_token': token,
          'type': type,
        }),
      );
      print('FCM Token registration response: ${response.statusCode} ${response.body}');
    } catch (e) {
      print('Error registering FCM token: $e');
    }
  }

  static Future<void> setOnlineStatus(bool isOnline) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone');
    if (phone == null || phone.isEmpty) return;
    try {
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/driver/online-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'is_online': isOnline,
        }),
      );
    } catch (e) {
      print('Error updating online status: $e');
    }
  }
}
