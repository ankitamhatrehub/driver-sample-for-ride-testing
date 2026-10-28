import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/service/api_client.dart';

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

/// Verifies a driving licence through the Torkk server, which keeps the
/// Surepass token. The login Bearer token is added by [apiClient].
///
/// Pass either [idNumber] + [dob] (typed or read from the card), or
/// [docNumber] + [phone] (DigiLocker flow).
Future<DrivingLicenceDetails> verifyDrivingLicence({
  String? idNumber,
  String? dob,
  String? docNumber,
  String? phone,
}) async {
  final viaDigilocker = docNumber != null;
  assert(
    viaDigilocker ? (phone != null) : (idNumber != null && dob != null),
    'Pass idNumber + dob, or docNumber + phone',
  );
  final body = viaDigilocker
      ? {'doc_number': docNumber, 'phone': phone}
      : {'id_number': idNumber, 'dob': dob};
  debugPrint('[DL][api] POST ${AppUrls.verifyDl} (${viaDigilocker ? 'digilocker' : 'manual'})');
  final response = await apiClient
      .post(
        Uri.parse(AppUrls.verifyDl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
      .timeout(const Duration(seconds: 20));
  debugPrint('[DL][api] status ${response.statusCode}, ${response.body.length} bytes');

  if (response.statusCode < 200 || response.statusCode >= 300) {
    debugPrint('[DL][api] error body: ${response.body}');
    throw DlVerificationException(_errorMessage(response.body));
  }
  return DrivingLicenceDetails.fromBody(
    response.body,
    fallbackNumber: docNumber ?? idNumber ?? '',
    fallbackDob: dob ?? '',
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
