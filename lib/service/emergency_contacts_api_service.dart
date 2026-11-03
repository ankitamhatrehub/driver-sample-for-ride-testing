import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/service/api_client.dart';

/// Emergency contacts (`/api/user/emergency-contacts`). A contact is a
/// `{name, phone}` map. Methods throw an [Exception] with the server message
/// on failure.
class EmergencyContactsApiService {
  static const _timeout = Duration(seconds: 15);

  static Future<String> _phone() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone') ?? '';
    if (phone.isEmpty) {
      throw Exception('Phone number not found. Please log in.');
    }
    return phone;
  }

  /// GET /emergency-contacts?phone=
  static Future<List<Map<String, String>>> fetch() async {
    final url = AppUrls.emergencyContacts(await _phone());
    debugPrint('[EMERGENCY CONTACTS GET] -> GET $url');
    final response = await apiClient.get(Uri.parse(url)).timeout(_timeout);
    debugPrint(
      '[EMERGENCY CONTACTS GET] <- status=${response.statusCode} '
      'body=${response.body}',
    );
    final body = _decode(response.body);
    _check(response.statusCode, body);
    return [
      for (final c in (body['contacts'] as List? ?? const []))
        {'name': '${(c as Map)['name'] ?? ''}', 'phone': '${c['phone'] ?? ''}'},
    ];
  }

  /// POST /emergency-contacts/save. Replaces the saved list with [contacts].
  static Future<void> save(List<Map<String, String>> contacts) async {
    final payload = {'customer_phone': await _phone(), 'contacts': contacts};
    debugPrint(
      '[EMERGENCY CONTACTS SAVE] -> POST ${AppUrls.saveEmergencyContacts} '
      'body=${jsonEncode(payload)}',
    );
    final response = await apiClient
        .post(
          Uri.parse(AppUrls.saveEmergencyContacts),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(_timeout);
    debugPrint(
      '[EMERGENCY CONTACTS SAVE] <- status=${response.statusCode} '
      'body=${response.body}',
    );
    _check(response.statusCode, _decode(response.body));
  }

  static Map<String, dynamic> _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {};
  }

  static void _check(int statusCode, Map<String, dynamic> body) {
    if (statusCode >= 200 && statusCode < 300 && body['status'] != 'error') {
      return;
    }
    final message = body['message'] ?? body['error'];
    throw Exception(
      message != null && '$message'.isNotEmpty
          ? '$message'
          : 'Request failed ($statusCode)',
    );
  }
}
