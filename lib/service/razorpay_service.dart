import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:rider_app/service/razorpay_config.dart';

/// A UPI QR created for one ride fare.
class RazorpayQr {
  const RazorpayQr({
    required this.id,
    required this.imageUrl,
    required this.imageContent,
    required this.amountPaise,
  });

  final String id;

  /// PNG of the QR, shown to the customer.
  final String imageUrl;

  /// The `upi://pay?...` string the QR encodes.
  final String imageContent;
  final int amountPaise;
}

/// How much has been paid on a QR so far.
class RazorpayQrStatus {
  const RazorpayQrStatus({
    required this.status,
    required this.receivedPaise,
    required this.paymentsCount,
  });

  /// `active` or `closed`.
  final String status;
  final int receivedPaise;
  final int paymentsCount;

  bool get isClosed => status == 'closed';
}

class RazorpayException implements Exception {
  RazorpayException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Razorpay UPI QR calls, made straight from the app.
///
/// NOTE: the key secret ships inside the app, so anyone can extract it. This
/// is acceptable for `rzp_test_` keys only; before going live, move these
/// calls behind your own backend.
class RazorpayService {
  RazorpayService._();

  static const _base = 'https://api.razorpay.com/v1';
  static const _timeout = Duration(seconds: 20);

  static bool get isConfigured =>
      RazorpayConfig.keyId.isNotEmpty && RazorpayConfig.keySecret.isNotEmpty;

  static Map<String, String> get _headers {
    final token = base64Encode(
      utf8.encode('${RazorpayConfig.keyId}:${RazorpayConfig.keySecret}'),
    );
    return {
      'Authorization': 'Basic $token',
      'Content-Type': 'application/json',
    };
  }

  /// Creates a single-use, fixed-amount UPI QR for [amountRupees].
  /// The QR closes by itself after [validFor] if nobody pays.
  static Future<RazorpayQr> createUpiQr({
    required double amountRupees,
    required String rideId,
    Duration validFor = const Duration(minutes: 30),
  }) async {
    final paise = (amountRupees * 100).round();
    final closeBy = DateTime.now().add(validFor).millisecondsSinceEpoch ~/ 1000;
    final body = await _send(
      'qr create',
      () => http.post(
        Uri.parse('$_base/payments/qr_codes'),
        headers: _headers,
        body: jsonEncode({
          'type': 'upi_qr',
          'name': 'Torkk Ride $rideId',
          'usage': 'single_use',
          'fixed_amount': true,
          'payment_amount': paise,
          'description': 'Fare for ride $rideId',
          'close_by': closeBy,
          'notes': {'ride_id': rideId},
        }),
      ),
    );
    return RazorpayQr(
      id: '${body['id']}',
      imageUrl: '${body['image_url']}',
      imageContent: '${body['image_content'] ?? ''}',
      amountPaise: paise,
    );
  }

  /// Reads how much has been paid on [qrId].
  static Future<RazorpayQrStatus> fetchQrStatus(String qrId) async {
    final body = await _send(
      'qr status',
      () => http.get(
        Uri.parse('$_base/payments/qr_codes/$qrId'),
        headers: _headers,
      ),
    );
    return RazorpayQrStatus(
      status: '${body['status']}',
      receivedPaise: _asInt(body['payments_amount_received']),
      paymentsCount: _asInt(body['payments_count_received']),
    );
  }

  /// Closes an unpaid QR (cash chosen, or the driver left the screen).
  /// Failures are ignored: the QR also expires on its own.
  static Future<void> closeQr(String qrId) async {
    try {
      await http
          .post(
            Uri.parse('$_base/payments/qr_codes/$qrId/close'),
            headers: _headers,
          )
          .timeout(_timeout);
    } catch (e) {
      debugPrint('[RAZORPAY] close qr failed: $e');
    }
  }

  static int _asInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('$v') ?? 0;

  static Future<Map<String, dynamic>> _send(
    String label,
    Future<http.Response> Function() call,
  ) async {
    if (!isConfigured) {
      throw RazorpayException('Razorpay keys are not set');
    }
    try {
      final response = await call().timeout(_timeout);
      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded as Map<String, dynamic>;
      }
      final error = decoded is Map ? decoded['error'] : null;
      final description = error is Map ? '${error['description']}' : '';
      debugPrint(
        '[RAZORPAY] $label failed ${response.statusCode}: $description',
      );
      throw RazorpayException(
        description.isNotEmpty ? description : 'Razorpay error',
      );
    } on RazorpayException {
      rethrow;
    } catch (e) {
      debugPrint('[RAZORPAY] $label failed: $e');
      throw RazorpayException('Could not reach Razorpay');
    }
  }
}
