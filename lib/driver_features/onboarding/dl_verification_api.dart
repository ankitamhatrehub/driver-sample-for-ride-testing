import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/service/api_client.dart';
import 'package:rider_app/common/constants/app_urls.dart';

/// Details returned after the licence number and date of birth are checked.
class DrivingLicenceDetails {
  const DrivingLicenceDetails({
    required this.name,
    required this.licenseNumber,
    required this.dob,
    required this.vehicleClass,
    required this.validity,
  });

  final String name;
  final String licenseNumber;
  final String dob;
  final String vehicleClass;
  final String validity;

  factory DrivingLicenceDetails.fromBody(
    String body, {
    required String fallbackNumber,
    required String fallbackDob,
  }) {
    final decoded = jsonDecode(body);
    final root = decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
    final data = _map(root['data']);
    final extracted = _map(root['extracted']);
    final source = data.isNotEmpty ? data : extracted;

    String pick(List<String> keys) {
      for (final key in keys) {
        final value = source[key] ?? root[key];
        final text = _text(value);
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    return DrivingLicenceDetails(
      name: pick(['name', 'full_name', 'holder_name']),
      licenseNumber: pick(['license_number', 'licence_number', 'dl_number', 'id_number']).isEmpty
          ? fallbackNumber
          : pick(['license_number', 'licence_number', 'dl_number', 'id_number']),
      dob: pick(['dob', 'date_of_birth']).isEmpty ? fallbackDob : pick(['dob', 'date_of_birth']),
      vehicleClass: _vehicleClass(source['vehicle_classes'] ?? source['vehicle_class'] ?? root['vehicle_classes']),
      validity: pick(['doe', 'expiry', 'expiry_date', 'validity', 'valid_till']),
    );
  }
}

class DlVerificationException implements Exception {
  DlVerificationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Posts `{ "phone", "document_no" }` to the Torkk server (Bearer token is
/// added by [apiClient]). The server keeps the Surepass token and does the
/// licence lookup itself. [dob] is only used for the on-device fallback.
Future<DrivingLicenceDetails> verifyDrivingLicence({
  required String idNumber,
  required String dob,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final phone = prefs.getString('user_phone') ?? '';
  debugPrint('[DL][api] POST ${AppUrls.verifyDl} (id length ${idNumber.length})');
  final response = await apiClient
      .post(
        Uri.parse(AppUrls.verifyDl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'document_no': idNumber}),
      )
      .timeout(const Duration(seconds: 20));
  debugPrint('[DL][api] status ${response.statusCode}, ${response.body} bytes');

  if (response.statusCode < 200 || response.statusCode >= 300) {
    debugPrint('[DL][api] error body: ${response.body}');
    throw DlVerificationException(_errorMessage(response.body));
  }
  return DrivingLicenceDetails.fromBody(
    response.body,
    fallbackNumber: idNumber,
    fallbackDob: dob,
  );
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

String _text(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

String _vehicleClass(dynamic value) {
  if (value is List) {
    return value
        .map((item) {
          if (item is Map) {
            return _text(item['class'] ?? item['cov'] ?? item['vehicle_class'] ?? item['desc']);
          }
          return _text(item);
        })
        .where((item) => item.isNotEmpty)
        .join(', ');
  }
  return _text(value);
}

String _errorMessage(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      for (final key in ['message', 'error', 'detail']) {
        final text = _text(decoded[key]);
        if (text.isNotEmpty) return text;
      }
    }
  } catch (_) {}
  return 'Driving licence could not be verified.';
}
