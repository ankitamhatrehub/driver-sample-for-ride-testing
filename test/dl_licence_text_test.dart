// import 'package:flutter_test/flutter_test.dart';
// import 'package:rider_app/driver_features/onboarding/dl_licence_text.dart';

// void main() {
//   final today = DateTime(2026, 9, 30);

//   test('reads the licence number and the labelled date of birth', () {
//     const card = '''
// INDIAN UNION DRIVING LICENCE
// DL No: UP20 20150000000
// Date of Birth: 15/08/1992
// Valid Till: 14-08-2032
// ''';

//     final fields = parseDrivingLicenceText(card, today: today);

//     expect(fields.licenseNumber, 'UP2020150000000');
//     expect(fields.dob, '15-08-1992');
//   });

//   test('fixes digit lookalikes in the numeric part of the licence number', () {
//     final fields = parseDrivingLicenceText('MH0I2OI5OOO1234', today: today);

//     expect(fields.licenseNumber, 'MH0120150001234');
//   });

//   test('ignores a future expiry when the birth label is missing', () {
//     final fields = parseDrivingLicenceText('Issue 01-06-2018 Valid 01-06-2038 DOB missing 02-02-1990', today: today);

//     expect(fields.dob, '02-02-1990');
//   });
// }
