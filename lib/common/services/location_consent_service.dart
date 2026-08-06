import 'package:shared_preferences/shared_preferences.dart';

/// Persists Play Store–required location disclosure consent.
class LocationConsentService {
  static const String consentKey = 'location_consent_accepted_v1';
  static const String consentTimestampKey = 'location_consent_accepted_at';

  static Future<bool> hasAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(consentKey) ?? false;
  }

  static Future<void> accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(consentKey, true);
    await prefs.setString(
      consentTimestampKey,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  static Future<void> revoke() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(consentKey);
    await prefs.remove(consentTimestampKey);
  }
}
