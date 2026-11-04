import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/service/api_client.dart';

/// Which kinds of notifications the driver wants.
/// `GET/PUT /driver/notification-preferences` -> `{status, data: {...}}`.
class NotificationPreferences {
  const NotificationPreferences({
    required this.rideParcelUpdates,
    required this.offerRewards,
    required this.paymentUpdates,
  });

  final bool rideParcelUpdates;
  final bool offerRewards;
  final bool paymentUpdates;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        rideParcelUpdates: json['ride_parcel_updates'] == true,
        offerRewards: json['offer_rewards'] == true,
        paymentUpdates: json['payment_updates'] == true,
      );

  Map<String, dynamic> toJson() => {
    'ride_parcel_updates': rideParcelUpdates,
    'offer_rewards': offerRewards,
    'payment_updates': paymentUpdates,
  };

  NotificationPreferences copyWith({
    bool? rideParcelUpdates,
    bool? offerRewards,
    bool? paymentUpdates,
  }) => NotificationPreferences(
    rideParcelUpdates: rideParcelUpdates ?? this.rideParcelUpdates,
    offerRewards: offerRewards ?? this.offerRewards,
    paymentUpdates: paymentUpdates ?? this.paymentUpdates,
  );

  @override
  String toString() => toJson().toString();
}

/// One row of `GET /driver/notifications`.
class DriverNotification {
  const DriverNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;

  /// `ride`, `parcel`, `payment`, `offer`, ... (server defined).
  final String type;
  final bool isRead;
  final DateTime? createdAt;

  factory DriverNotification.fromJson(Map<String, dynamic> json) =>
      DriverNotification(
        id: '${json['id'] ?? ''}',
        title: '${json['title'] ?? ''}',
        message: '${json['message'] ?? ''}',
        type: '${json['type'] ?? ''}'.toLowerCase(),
        isRead: json['is_read'] == true,
        createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
      );

  DriverNotification asRead() => DriverNotification(
    id: id,
    title: title,
    message: message,
    type: type,
    isRead: true,
    createdAt: createdAt,
  );
}

/// One page of notifications plus whether more pages remain.
class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.page,
    required this.total,
  });

  final List<DriverNotification> items;
  final int page;
  final int total;
}

/// A failed notifications call. [message] is the server's text when it sent one.
class NotificationsApiException implements Exception {
  NotificationsApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Driver notification APIs. The bearer token is added by [apiClient]. Besides
/// the raw `[API] before/after` lines from the client, each call prints
/// `[NOTIF API]` lines showing the request and the parsed response.
class NotificationsApiService {
  static const _timeout = Duration(seconds: 15);

  /// GET /driver/notification-preferences
  static Future<NotificationPreferences> fetchPreferences() async {
    const url = AppUrls.notificationPreferences;
    debugPrint('[NOTIF API] prefs GET -> $url');
    final body = await _send('prefs GET', () => apiClient.get(Uri.parse(url)));
    final prefs = NotificationPreferences.fromJson(_map(body['data']));
    debugPrint('[NOTIF API] prefs GET parsed: $prefs');
    return prefs;
  }

  /// PUT /driver/notification-preferences. Returns the saved values.
  static Future<NotificationPreferences> updatePreferences(
    NotificationPreferences prefs,
  ) async {
    const url = AppUrls.notificationPreferences;
    debugPrint('[NOTIF API] prefs PUT -> $url body=${jsonEncode(prefs)}');
    final body = await _send(
      'prefs PUT',
      () => apiClient.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(prefs.toJson()),
      ),
    );
    final saved = NotificationPreferences.fromJson(_map(body['data']));
    debugPrint(
      '[NOTIF API] prefs PUT parsed: $saved message=${body['message']}',
    );
    return saved;
  }

  /// GET /driver/notifications?page=&limit=
  static Future<NotificationPage> fetchNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final url = AppUrls.driverNotifications(page: page, limit: limit);
    debugPrint('[NOTIF API] list GET -> $url');
    final body = await _send('list GET', () => apiClient.get(Uri.parse(url)));
    final items = <DriverNotification>[
      if (body['data'] is List)
        for (final m in body['data'] as List)
          if (m is Map)
            DriverNotification.fromJson(Map<String, dynamic>.from(m)),
    ];
    final pagination = _map(body['pagination']);
    final total = (pagination['total'] as num?)?.toInt() ?? items.length;
    debugPrint(
      '[NOTIF API] list GET parsed: page=$page items=${items.length} '
      'total=$total unread=${items.where((n) => !n.isRead).length}',
    );
    for (final n in items) {
      debugPrint(
        '[NOTIF API]   #${n.id} type=${n.type} read=${n.isRead} '
        'at=${n.createdAt} "${n.title}" - "${n.message}"',
      );
    }
    return NotificationPage(items: items, page: page, total: total);
  }

  /// PUT /driver/notifications/{id}/read
  static Future<void> markRead(String id) async {
    final url = AppUrls.notificationRead(id);
    debugPrint('[NOTIF API] read PUT -> $url');
    final body = await _send('read PUT', () => apiClient.put(Uri.parse(url)));
    debugPrint('[NOTIF API] read PUT parsed: message=${body['message']}');
  }

  static Future<Map<String, dynamic>> _send(
    String label,
    Future<dynamic> Function() call,
  ) async {
    try {
      final response = await call().timeout(_timeout);
      debugPrint(
        '[NOTIF API] $label <- status=${response.statusCode} '
        'body=${response.body}',
      );
      Map<String, dynamic> body = {};
      try {
        final decoded = json.decode(response.body as String);
        if (decoded is Map) body = Map<String, dynamic>.from(decoded);
      } catch (_) {}
      final code = response.statusCode as int;
      if (code < 200 || code >= 300 || body['status'] == 'error') {
        final msg = body['message'] ?? body['error'] ?? body['detail'];
        throw NotificationsApiException(
          msg == null ? 'Something went wrong. Please try again.' : '$msg',
          statusCode: code,
        );
      }
      return body;
    } catch (e) {
      debugPrint('[NOTIF API] $label FAILED: $e');
      rethrow;
    }
  }

  static Map<String, dynamic> _map(Object? v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
}
