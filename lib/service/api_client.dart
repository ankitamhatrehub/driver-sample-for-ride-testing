import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/service/token_store.dart';

/// HTTP client that adds `Authorization: Bearer <token>` to every request
/// for our own backend, except the public endpoints.
///
/// Third-party hosts (Gemini, Google Maps, OSRM) never get the token.
class AuthClient extends http.BaseClient {
  AuthClient([http.Client? inner]) : _inner = inner ?? http.Client();

  final http.Client _inner;

  /// Called once when the server answers 401 to a request that carried (or
  /// should have carried) the token. Set by [AppBootstrap] to open login.
  static Future<void> Function()? onUnauthorized;

  /// The review/bypass account has no server token; never force it out.
  static const String _bypassPhone = '9999999999';

  static bool _handlingUnauthorized = false;

  static final String _backendHost = Uri.parse(AppUrls.baseUrl).authority;

  static final Set<String> _publicPaths = {
    Uri.parse(AppUrls.sendOtp).path,
    Uri.parse(AppUrls.verifyOtp).path,
  };

  static bool isProtected(Uri url) =>
      url.authority == _backendHost && !_publicPaths.contains(url.path);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var attachedToken = false;
    if (isProtected(request.url)) {
      final token = await TokenStore.read();
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
        attachedToken = true;
      }
    }
    final response = await _inner.send(request);
    if (response.statusCode == 401 && isProtected(request.url)) {
      debugPrint(
        '[API] 401 on ${request.method} ${request.url.path} '
        '(token sent: $attachedToken)',
      );
      unawaited(_handleUnauthorized());
    } else if (response.statusCode == 403 && isProtected(request.url)) {
      debugPrint(
        '[API] 403 on ${request.method} ${request.url.path} '
        '(token sent: $attachedToken)',
      );
    }
    return response;
  }

  Future<void> _handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString('user_phone') == _bypassPhone) return;
      // Already logged out by an earlier 401: nothing left to do.
      final loggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (!loggedIn && (await TokenStore.read()).isEmpty) return;
      await TokenStore.clear();
      await onUnauthorized?.call();
    } finally {
      _handlingUnauthorized = false;
    }
  }
}

/// Shared client for all backend calls.
final AuthClient apiClient = AuthClient();
