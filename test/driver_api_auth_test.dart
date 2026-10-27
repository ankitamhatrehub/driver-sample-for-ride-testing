import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/service/driver_api_service.dart';

void main() {
  test('auth headers carry the token saved by OTP verification', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'abc.def.ghi'});
    final headers = await DriverApiService.authHeaders();
    expect(headers['Authorization'], 'Bearer abc.def.ghi');
    expect(headers['token'], 'abc.def.ghi');
    expect(headers['x-access-token'], 'abc.def.ghi');
    expect(headers['Content-Type'], 'application/json');
  });

  test(
    'falls back to token / access_token, and omits auth when none',
    () async {
      SharedPreferences.setMockInitialValues({'token': 't1'});
      expect(await DriverApiService.savedToken(), 't1');
      SharedPreferences.setMockInitialValues({'access_token': 't2'});
      expect(await DriverApiService.savedToken(), 't2');
      SharedPreferences.setMockInitialValues({});
      final headers = await DriverApiService.authHeaders();
      expect(headers.containsKey('Authorization'), isFalse);
    },
  );
}
