import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/service/location_permission_flow.dart';

/// Permissions checked every time the app opens (from the splash screen), in a
/// fixed order:
///   1. Notifications: the system prompt is asked once per install (the phone
///      itself never shows it again after the driver has answered).
///   2. Location: checked on EVERY launch. If it is not allowed yet, our
///      prominent-disclosure screen is shown first, then the system prompt
///      (foreground only; background is offered later, when the driver goes
///      online). If it is already allowed, nothing is shown.
///
/// If location is blocked for good ("Don't ask again"), Android and iOS do not
/// allow another prompt; the driver has to enable it in phone Settings.
class StartupPermissions {
  static const _notificationsAskedKey = 'startup_notifications_asked_v1';

  static bool _running = false;

  static Future<void> run(BuildContext context) async {
    // The splash can call this twice (e.g. a rebuilt splash). Only one run at
    // a time, so the notification / location screens never appear twice.
    if (_running) return;
    _running = true;
    try {
      await _run(context);
    } finally {
      _running = false;
    }
  }

  static Future<void> _run(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_notificationsAskedKey) ?? false)) {
      // Marked first so a crash or a force-close never causes a prompt loop.
      await prefs.setBool(_notificationsAskedKey, true);
      await _askNotifications();
    }

    if (!context.mounted) return;
    // No-op when location is already allowed; otherwise disclosure -> prompt.
    await LocationPermissionFlow.ensure(context);
  }

  static Future<void> _askNotifications() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('[STARTUP] notification permission (FCM) failed: $e');
    }
    if (Platform.isAndroid) {
      try {
        // Android 13+ POST_NOTIFICATIONS (no-op if already decided).
        await FlutterLocalNotificationsPlugin()
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      } catch (e) {
        debugPrint('[STARTUP] notification permission (local) failed: $e');
      }
    }
  }
}
