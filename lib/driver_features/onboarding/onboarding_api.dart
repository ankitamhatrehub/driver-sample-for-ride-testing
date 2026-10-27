import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/service/api_client.dart';

/// The onboarding HTTP calls. Each returns the raw response; the caller
/// ([OnboardingSession]) decides what the status and body mean.
class OnboardingApi {
  const OnboardingApi._();

  static Future<http.Response> sendOtp({required String phone}) {
    return apiClient
        .post(
          Uri.parse(AppUrls.sendOtp),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'phone': phone}),
        )
        .timeout(const Duration(seconds: 15));
  }

  static Future<http.Response> verifyOtp({
    required String phone,
    required String otp,
  }) {
    return apiClient
        .post(
          Uri.parse(AppUrls.verifyOtp),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'phone': phone, 'otp': otp, 'code': otp}),
        )
        .timeout(const Duration(seconds: 15));
  }

  static Future<http.Response> verifyAadhaar({
    required String aadhaarNumber,
    required String phone,
    required String panNumber,
  }) {
    return apiClient
        .post(
          Uri.parse(AppUrls.verifyAadhaar),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'aadhaar_number': aadhaarNumber,
            'phone': phone,
            'pan_number': panNumber,
          }),
        )
        .timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> register(Map<String, dynamic> body) {
    return apiClient
        .post(
          Uri.parse(AppUrls.driverRegister),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 15));
  }
}
