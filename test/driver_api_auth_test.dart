import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/service/api_client.dart';
import 'package:rider_app/service/token_store.dart';

void main() {
  late http.BaseRequest seen;
  late int status;
  late AuthClient client;

  setUp(() {
    status = 200;
    client = AuthClient(
      MockClient((request) async {
        seen = request;
        return http.Response('{}', status);
      }),
    );
    AuthClient.onUnauthorized = null;
  });

  test('protected backend call carries the Bearer token', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'abc.def.ghi'});
    await client.get(Uri.parse(AppUrls.driverProfile('9876543210')));
    expect(seen.headers['Authorization'], 'Bearer abc.def.ghi');
    expect(seen.headers.containsKey('x-access-token'), isFalse);
  });

  test('legacy token keys are still read', () async {
    SharedPreferences.setMockInitialValues({'token': 't1'});
    await client.post(Uri.parse(AppUrls.verifyDl), body: '{}');
    expect(seen.headers['Authorization'], 'Bearer t1');
  });

  test('send-otp and verify-otp are public: no token attached', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'abc'});
    await client.post(Uri.parse(AppUrls.sendOtp), body: '{}');
    expect(seen.headers.containsKey('Authorization'), isFalse);
    await client.post(Uri.parse(AppUrls.verifyOtp), body: '{}');
    expect(seen.headers.containsKey('Authorization'), isFalse);
  });

  test('third-party hosts never receive the token', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'abc'});
    await client.get(Uri.parse('https://router.project-osrm.org/route'));
    expect(seen.headers.containsKey('Authorization'), isFalse);
  });

  test('401 clears the token and triggers login once', () async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'abc',
      'isLoggedIn': true,
      'user_phone': '9876543210',
    });
    var calls = 0;
    AuthClient.onUnauthorized = () async => calls++;
    status = 401;
    await Future.wait([
      client.get(Uri.parse(AppUrls.driverTrips('9876543210'))),
      client.get(Uri.parse(AppUrls.driverEarnings('9876543210'))),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(await TokenStore.read(), '');
    expect(calls, 1);
  });

  test('403 does not log the driver out', () async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'abc',
      'isLoggedIn': true,
    });
    var calls = 0;
    AuthClient.onUnauthorized = () async => calls++;
    status = 403;
    await client.get(Uri.parse(AppUrls.driverTrips('9876543210')));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(await TokenStore.read(), 'abc');
    expect(calls, 0);
  });

  test('bypass test account is never logged out', () async {
    SharedPreferences.setMockInitialValues({
      'user_phone': '9999999999',
      'isLoggedIn': true,
    });
    var calls = 0;
    AuthClient.onUnauthorized = () async => calls++;
    status = 401;
    await client.get(Uri.parse(AppUrls.driverTrips('9999999999')));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(calls, 0);
  });
}
