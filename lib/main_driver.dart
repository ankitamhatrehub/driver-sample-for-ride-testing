import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'driver/driver_app.dart';
import 'driver/services/ride_alert_service.dart';
import 'fcm_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // System tray notification is shown by Android when payload has `notification`.
  // For data-only messages, show a local notification with custom sound.
  if (message.notification == null) {
    await RideAlertService.showNewRideNotification(
      title: message.data['title']?.toString() ?? 'New ride request',
      body: message.data['body']?.toString() ??
          'Open TORKK Driver to accept the ride',
      payload: message.data['ride_id']?.toString(),
    );
  }
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await RideAlertService.initialize();
  await FCMService.setupHandlers();
  await FCMService.registerFCMToken('driver');

  runApp(const DriverApp());
}
