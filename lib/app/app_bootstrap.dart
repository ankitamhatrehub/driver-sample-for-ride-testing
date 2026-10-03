import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/app/theme/theme_repository.dart';
import 'package:rider_app/common/utils/translations.dart';
import 'package:rider_app/service/ride_alert_service.dart';
import 'package:rider_app/service/fcm_service.dart';

const _driverOnlineKey = 'driver_is_online';

/// Starts services the first frame depends on.
///
/// A failure in Firebase must not stop the driver from opening the app.
class AppBootstrap {
  const AppBootstrap._();

  static Future<ThemeRepository> start() async {
    await _startFirebase();
    await RideAlertService.initialize();
    await FCMService.setupHandlers();
    await AppTranslations.init();
    final preferences = await SharedPreferences.getInstance();
    return ThemeRepository(preferences);
  }

  static Future<void> _startFirebase() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );
    } catch (error, stackTrace) {
      debugPrint('Firebase did not start: $error\n$stackTrace');
    }
  }
}

/// Handles a ride alert while the app is in the background.
///
/// Must stay a top-level function. Firebase runs it in its own isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final preferences = await SharedPreferences.getInstance();
  final isOnline = preferences.getBool(_driverOnlineKey) ?? false;
  if (!isOnline) {
    debugPrint('Background ride alert skipped: driver is offline');
    return;
  }

  // Android already shows a tray notification when the payload has one.
  // Data-only messages need a local alert with the ride sound.
  if (message.notification == null) {
    await RideAlertService.showNewRideNotification(
      title: message.data['title']?.toString() ?? 'New ride request',
      body: message.data['body']?.toString() ??
          'Open TORKK Driver to accept the ride',
      payload: message.data['ride_id']?.toString(),
    );
  }

  debugPrint('Background message ${message.messageId}');
}
