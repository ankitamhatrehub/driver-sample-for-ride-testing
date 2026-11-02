import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:rider_app/service/api_client.dart';
import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';

/// Opens DigiLocker from the Aadhaar route and writes the result into [OnboardingSession].
Future<String?> launchDigilocker(BuildContext context) async {
  final session = OnboardingSession.instance;
  session.loading = true;
  session.touch();
  try {
    final prefs = await SharedPreferences.getInstance();
    final cleanPhone =
        session.phone.text.replaceAll(' ', '').replaceAll('-', '').isNotEmpty
        ? session.phone.text.replaceAll(' ', '').replaceAll('-', '')
        : (prefs.getString('user_phone') ?? '');

    final headers = <String, String>{'Content-Type': 'application/json'};
    final requestBody = <String, dynamic>{
      'signup_flow': true,
      if (cleanPhone.isNotEmpty) 'phone': cleanPhone,
    };
    final startUri = Uri.parse(AppUrls.digilockerStart);
    final response = await apiClient
        .post(startUri, headers: headers, body: json.encode(requestBody))
        .timeout(const Duration(seconds: 10));
    session.loading = false;
    session.touch();
    if (!_isSuccessful(response.statusCode)) {
      return _requestError('DigiLocker start', startUri, response);
    }
    final decoded = json.decode(response.body);
    if (decoded is! Map) {
      return 'DigiLocker start returned an invalid response.';
    }
    final data = Map<String, dynamic>.from(decoded);
    if (data['success'] != true) {
      return 'Failed to initialize Digilocker: ${data['message']}';
    }
    session.digilockerClientId = data['client_id']?.toString();
    session.digilockerUrl = data['url']?.toString();
    if (data['mock'] == true) {
      return await _download();
    }
    final url = session.digilockerUrl;
    if (url == null || url.isEmpty) return 'DigiLocker link was empty';
    if (!context.mounted) return null;
    final authorized = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) {
                final uri = Uri.tryParse(request.url);
                if (uri?.scheme == 'https' && uri?.host == 'google.com') {
                  Navigator.of(dialogContext).pop(true);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(url));
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: SizedBox(
            height: MediaQuery.sizeOf(dialogContext).height * 0.85,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ),
                Expanded(child: WebViewWidget(controller: controller)),
              ],
            ),
          ),
        );
      },
    );
    if (authorized != true) {
      return 'DigiLocker authorization was cancelled before completion.';
    }
    if (!context.mounted) return null;
    return await _download();
  } catch (e) {
    session.loading = false;
    session.touch();
    return 'Network error: $e';
  }
}

Future<String?> _download() async {
  // reason of this folder ?
  //=> ans -> This folder is used to store the code related to the onboarding process of the driver features,
  //specifically for launching and handling DigiLocker integration. It contains the necessary logic to initiate the DigiLocker flow,
  //handle user authorization, and download the required documents from DigiLocker. The code ensures that the user's session
  //is managed properly and that any errors during the process are handled gracefully.
  final session = OnboardingSession.instance;
  session.loading = true;
  session.touch();
  try {
    final prefs = await SharedPreferences.getInstance();
    final headers = <String, String>{'Content-Type': 'application/json'};
    final clientId = session.digilockerClientId ?? '';
    debugPrint('[DigiLocker][_download] client_id: "$clientId"');
    if (clientId.isEmpty) {
      session.loading = false;
      session.touch();
      return 'DigiLocker session was not initialized. Please try again.';
    }
    final enteredPhone = session.phone.text
        .replaceAll(' ', '')
        .replaceAll('-', '');
    var mobile = enteredPhone.isNotEmpty
        ? enteredPhone
        : (prefs.getString('user_phone') ?? '');
    if (mobile.length > 10) mobile = mobile.substring(mobile.length - 10);
    final requestBody = <String, dynamic>{
      'client_id': clientId,
      'number': mobile,
    };

    final downloadUri = Uri.parse(AppUrls.digilockerDownload);
    debugPrint('[DigiLocker][_download] POST $downloadUri');
    debugPrint('[DigiLocker][_download] body: ${json.encode(requestBody)}');
    final response = await apiClient
        .post(downloadUri, headers: headers, body: json.encode(requestBody))
        .timeout(const Duration(seconds: 15));
    debugPrint('[DigiLocker][_download] status: ${response.statusCode}');
    debugPrint('[DigiLocker][_download] response body: ${response.body}');
    session.loading = false;
    session.touch();
    if (!_isSuccessful(response.statusCode)) {
      return _requestError(
        'DigiLocker document download',
        downloadUri,
        response,
      );
    }
    final decoded = json.decode(response.body);
    if (decoded is! Map) {
      return 'DigiLocker document download returned an invalid response.';
    }
    final body = Map<String, dynamic>.from(decoded);
    if (body['success'] != true) {
      return 'Failed to fetch details: ${body['message']}';
    }
    final rawData = body['data'];
    final data = rawData is Map ? Map<String, dynamic>.from(rawData) : body;
    await session.applyDigilockerDownload(data);
    return null;
  } catch (e, st) {
    debugPrint('[DigiLocker][_download] exception: $e\n$st');
    session.loading = false;
    session.touch();
    return 'Network error: $e';
  }
}

/// Debug helper: decodes the JWT payload (no signature check) to show its role.
bool _isSuccessful(int statusCode) => statusCode >= 200 && statusCode < 300;

String _requestError(String operation, Uri uri, http.Response response) {
  String? serverMessage;
  try {
    final decoded = json.decode(response.body);
    if (decoded is Map) {
      for (final key in ['message', 'error', 'detail']) {
        final value = decoded[key]?.toString().trim();
        if (value != null && value.isNotEmpty) {
          serverMessage = value;
          break;
        }
      }
    }
  } on FormatException {
    // Non-JSON responses are identified by endpoint and status below.
  }

  final endpoint = '${uri.path} (HTTP ${response.statusCode})';
  if (serverMessage != null) {
    return '$operation failed at $endpoint: $serverMessage';
  }
  if (response.statusCode == 404) {
    return '$operation endpoint was not found: $endpoint. Check the backend route.';
  }
  return '$operation failed at $endpoint.';
}
