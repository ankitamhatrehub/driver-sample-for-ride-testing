import 'dart:convert';

import 'package:rider_app/service/api_client.dart';
import 'package:rider_app/common/constants/app_urls.dart';

/// Vehicle details returned after the registration number is checked.
class VehicleRcDetails {
  const VehicleRcDetails({
    required this.registrationNumber,
    required this.model,
    required this.vehicleType,
  });

  final String registrationNumber;
  final String model;
  final String vehicleType;

  factory VehicleRcDetails.fromBody(
    String body, {
    required String fallbackNumber,
  }) {
    final decoded = jsonDecode(body);
    final root = decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};
    final data = _map(root['data']);
    final extracted = _map(root['extracted']);
    final source = data.isNotEmpty ? data : extracted;

    String pick(List<String> keys) {
      for (final key in keys) {
        final value = source[key] ?? root[key];
        final text = _text(value);
        if (text.isNotEmpty && text != 'null') return text;
      }
      return '';
    }

    final number = pick(['rc_number', 'registration_number', 'id_number']);
    return VehicleRcDetails(
      registrationNumber: number.isEmpty ? fallbackNumber : number,
      model: pick(['maker_model', 'model', 'vehicle_model']),
      vehicleType: pick([
        'vehicle_category_description',
        'vehicle_category',
        'vehicle_type',
      ]),
    );
  }
}

class RcVerificationException implements Exception {
  RcVerificationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Posts `{ "id_number" }` to the Torkk server.
/// The server keeps the Surepass token and calls
/// `POST /api/v1/rc/rc-full` with that same body.
Future<VehicleRcDetails> verifyVehicleRc({required String idNumber}) async {
  final response = await apiClient
      .post(
        Uri.parse(AppUrls.verifyRc),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_number': idNumber}),
      )
      .timeout(const Duration(seconds: 20));

  if (response.statusCode < 200 ||
      response.statusCode >= 300 ||
      !_accepted(response.body)) {
    throw RcVerificationException(_errorMessage(response.body));
  }
  return VehicleRcDetails.fromBody(response.body, fallbackNumber: idNumber);
}

bool _accepted(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map) return true;
    if (decoded['success'] == false) return false;
    final status = decoded['status_code'];
    if (status is num && status >= 400) return false;
    return true;
  } catch (_) {
    return false;
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

String _text(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

String _errorMessage(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      for (final key in ['message', 'error', 'detail']) {
        final text = _text(decoded[key]);
        if (text.isNotEmpty && text != 'null') return text;
      }
    }
  } catch (_) {}
  return 'Verification Failed.';
}
