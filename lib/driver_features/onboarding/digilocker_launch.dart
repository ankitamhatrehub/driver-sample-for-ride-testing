import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import 'package:rider_app/common/constants/api_constants.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';

/// Opens DigiLocker from the Aadhaar route and writes the result into [OnboardingSession].
Future<String?> launchDigilocker(BuildContext context) async {
  final session = OnboardingSession.instance;
  session.loading = true;
  session.touch();
  try {
    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/api/kyc/digilocker/initialize'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'signup_flow': true}),
        )
        .timeout(const Duration(seconds: 10));
    session.loading = false;
    session.touch();
    if (response.statusCode != 200) {
      return 'Server Error: ${response.statusCode}';
    }
    final data = json.decode(response.body);
    if (data['success'] != true) {
      return 'Failed to initialize Digilocker: ${data['message']}';
    }
    session.digilockerClientId = data['client_id']?.toString();
    session.digilockerUrl = data['url']?.toString();
    if (data['mock'] == true || !context.mounted) {
      return _download(context);
    }
    final url = session.digilockerUrl;
    if (url == null || url.isEmpty) return 'DigiLocker link was empty';
    if (!context.mounted) return null;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) {
                if (request.url.startsWith('https://google.com')) {
                  Navigator.of(dialogContext).pop();
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(url));
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SizedBox(
            height: MediaQuery.sizeOf(dialogContext).height * 0.85,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
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
    if (!context.mounted) return null;
    return _download(context);
  } catch (e) {
    session.loading = false;
    session.touch();
    return 'Network error: $e';
  }
}

Future<String?> _download(BuildContext context) async {
  final session = OnboardingSession.instance;
  session.loading = true;
  session.touch();
  try {
    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/api/kyc/digilocker/download'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'client_id': session.digilockerClientId}),
        )
        .timeout(const Duration(seconds: 15));
    session.loading = false;
    session.touch();
    if (response.statusCode != 200) return 'Server Error: ${response.statusCode}';
    final body = json.decode(response.body);
    if (body['success'] != true) return 'Failed to fetch details: ${body['message']}';
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      await session.applyDigilockerDownload(data);
    } else if (data is Map) {
      await session.applyDigilockerDownload(Map<String, dynamic>.from(data));
    }
    return null;
  } catch (e) {
    session.loading = false;
    session.touch();
    return 'Network error: $e';
  }
}
