import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/service/api_client.dart';
import 'package:rider_app/common/constants/app_urls.dart';

/// Keeps polling for rides while the driver is online, even if the UI is closed.
/// Shows a high-priority local notification with the custom ride alert sound.
class RideAlertService {
  static const String rideChannelId = 'ride_requests';
  static const String onlineChannelId = 'driver_online';
  static const int rideNotificationId = 4401;
  static const int onlineNotificationId = 888;

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings();
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );

    // Only configure the background service daemon on Android.
    // On iOS, background isolates cannot sustain arbitrary polling and trigger
    // "Communicating on a dead channel" loops on hot restart.
    if (!Platform.isAndroid) return;

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        rideChannelId,
        'Ride Requests',
        description: 'Alerts when a new ride request arrives',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('ride_alert'),
        enableVibration: true,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        onlineChannelId,
        'Driver Online',
        description: 'Shown while you are online and searching for rides',
        importance: Importance.low,
      ),
    );

    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onBackgroundStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: onlineChannelId,
        initialNotificationTitle: 'TORKK Driver',
        initialNotificationContent: 'Searching for rides...',
        foregroundServiceNotificationId: onlineNotificationId,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onBackgroundStart,
      ),
    );
  }

  static Future<void> start() async {
    if (!Platform.isAndroid) return;
    try {
      final service = FlutterBackgroundService();
      final running = await service.isRunning();
      if (!running) {
        await service.startService();
      } else {
        service.invoke('refresh');
      }
    } catch (_) {}
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) {
      await _notifications.cancel(id: rideNotificationId);
      return;
    }
    try {
      final service = FlutterBackgroundService();
      final running = await service.isRunning();
      if (running) {
        service.invoke('stop');
      }
    } catch (_) {}
    await _notifications.cancel(id: rideNotificationId);
  }

  static Future<void> showNewRideNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        rideChannelId,
        'Ride Requests',
        channelDescription: 'Alerts when a new ride request arrives',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('ride_alert'),
        enableVibration: true,
        category: AndroidNotificationCategory.event,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
      ),
    );
    await _notifications.show(
      id: rideNotificationId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }
}

@pragma('vm:entry-point')
Future<void> _onBackgroundStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final notifications = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
  const iosInit = DarwinInitializationSettings();
  await notifications.initialize(
    settings: const InitializationSettings(android: androidInit, iOS: iosInit),
  );

  final knownRideIds = <int>{};
  var seeded = false;

  Future<void> poll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('user_phone') ?? '';
      final isOnline = prefs.getBool('driver_is_online') ?? false;
      if (!isOnline || phone.isEmpty) {
        try {
          service.invoke('stop');
        } catch (_) {}
        return;
      }

      final uri = Uri.parse(AppUrls.activeRides(driverPhone: phone));
      final response = await apiClient.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      if (data is! List) return;

      final currentIds = <int>{};
      String? pickupHint;
      for (final ride in data) {
        if (ride is! Map) continue;
        if ((ride['status'] ?? '').toString() != 'requested') continue;
        final idVal = ride['id'];
        final id = idVal is int ? idVal : int.tryParse('$idVal');
        if (id == null) continue;
        currentIds.add(id);
        pickupHint ??=
            (ride['pickup_address'] ?? ride['pickup'] ?? 'Nearby pickup')
                .toString();
      }

      if (!seeded) {
        knownRideIds
          ..clear()
          ..addAll(currentIds);
        seeded = true;
        return;
      }

      final brandNew = currentIds.difference(knownRideIds);
      knownRideIds
        ..clear()
        ..addAll(currentIds);

      if (brandNew.isEmpty) return;

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          RideAlertService.rideChannelId,
          'Ride Requests',
          channelDescription: 'Alerts when a new ride request arrives',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('ride_alert'),
          enableVibration: true,
          category: AndroidNotificationCategory.event,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
        ),
      );

      await notifications.show(
        id: RideAlertService.rideNotificationId,
        title: 'New ride request',
        body: pickupHint == null || pickupHint.isEmpty
            ? 'Open TORKK Driver to accept the ride'
            : 'Pickup: $pickupHint',
        notificationDetails: details,
        payload: 'new_ride',
      );
    } catch (e) {
      debugPrint('[RideAlertService] poll error: $e');
    }
  }

  if (service is AndroidServiceInstance) {
    service.on('stop').listen((event) {
      service.stopSelf();
    });
    service.setAsForegroundService();
  } else {
    service.on('stop').listen((event) {
      service.stopSelf();
    });
  }

  service.on('refresh').listen((event) {
    seeded = false;
    knownRideIds.clear();
  });

  Timer.periodic(const Duration(seconds: 4), (_) {
    unawaited(poll());
  });
  await poll();
}
