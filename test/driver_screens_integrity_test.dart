// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:rider_app/driver_features/routes/driver_routes.dart';
// import 'package:rider_app/driver_features/rides/widgets/navigation_slider_button.dart';
// import 'package:rider_app/driver_features/rides/widgets/navigation_bottom_nav.dart';
// import 'package:rider_app/driver_features/rides/widgets/navigation_ride_card.dart';
// import 'package:rider_app/driver_features/summary/widgets/trip_summary_slider.dart';
// import 'package:rider_app/driver_features/onboarding/legacy/screens/steps/ocr_progress_step.dart';
// import 'package:rider_app/driver_features/onboarding/legacy/screens/steps/complete_profile_step.dart';
// import 'package:rider_app/driver_features/onboarding/legacy/screens/steps/biometric_setup_step.dart';
// import 'package:rider_app/driver_features/onboarding/legacy/screens/steps/confirm_details_step.dart';

// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();

//   group('Driver Routes & Screen Instantiation Integrity', () {
//     test('All registered routes instantiate without error', () {
//       final routes = DriverRoutes.routes;
//       expect(routes.isNotEmpty, true);

//       for (final entry in routes.entries) {
//         expect(entry.key, isNotEmpty);
//         expect(entry.value, isNotNull);
//       }
//     });
//   });

//   group('Modular Extracted Navigation Widgets Test', () {
//     testWidgets('NavigationBottomNav renders without crashing', (tester) async {
//       await tester.pumpWidget(
//         const MaterialApp(
//           home: Scaffold(
//             bottomNavigationBar: NavigationBottomNav(driverPhotoUrl: ''),
//           ),
//         ),
//       );
//       expect(find.byType(NavigationBottomNav), findsOneWidget);
//     });

//     testWidgets('NavigationSliderButton renders with custom text', (tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: NavigationSliderButton(
//               isDrop: false,
//               isProcessing: false,
//               onAction: () {},
//             ),
//           ),
//         ),
//       );
//       expect(find.text('Slide to Start the Ride'), findsOneWidget);
//     });

//     testWidgets('NavigationRideCard renders ride info correctly', (tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: NavigationRideCard(
//               ride: {
//                 'customer_name': 'Test User',
//                 'estimated_fare': 120.0,
//                 'pickup_address': 'Test Pickup Point',
//                 'drop_address': 'Test Drop Point',
//               },
//               isAccept: true,
//               isDrop: false,
//               currentPosition: null,
//               onNavigate: () {},
//               onChat: () {},
//               onCall: () {},
//               onLocationTap: ({
//                 required String title,
//                 required String address,
//                 required String distanceText,
//                 required Color color,
//                 double? lat,
//                 double? lng,
//               }) {},
//               sliderButton: const SizedBox(key: Key('test_slider')),
//             ),
//           ),
//         ),
//       );

//       expect(find.text('Test User'), findsOneWidget);
//       expect(find.text('₹ 120.00'), findsOneWidget);
//       expect(find.text('Test Pickup Point'), findsOneWidget);
//       expect(find.text('Test Drop Point'), findsOneWidget);
//       expect(find.byKey(const Key('test_slider')), findsOneWidget);
//     });

//     testWidgets('TripSummarySlider renders with action label', (tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: TripSummarySlider(
//               completing: false,
//               onAction: () {},
//             ),
//           ),
//         ),
//       );
//       expect(find.text('Slide to Finish the Ride'), findsOneWidget);
//     });
//   });

//   group('Modular Extracted Onboarding Step Widgets Test', () {
//     testWidgets('OcrProgressStep renders animation and title', (tester) async {
//       await tester.pumpWidget(
//         const MaterialApp(
//           home: Scaffold(
//             body: OcrProgressStep(
//               primaryColor: Color(0xFF1D4ED8),
//               ocrProgress: 0.75,
//               documentType: 'Aadhaar',
//             ),
//           ),
//         ),
//       );
//       expect(find.text('Extracting Data...'), findsOneWidget);
//       expect(find.text('75%'), findsOneWidget);
//     });

//     testWidgets('CompleteProfileStep renders input fields', (tester) async {
//       final phoneCtrl = TextEditingController(text: '9999999999');
//       final emailCtrl = TextEditingController(text: 'driver@test.com');

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: CompleteProfileStep(
//               primaryColor: const Color(0xFF1D4ED8),
//               phoneController: phoneCtrl,
//               emailController: emailCtrl,
//               agreedToTerms: true,
//               onAgreedChanged: (_) {},
//               onContinue: () {},
//             ),
//           ),
//         ),
//       );

//       expect(find.text('Complete Your Profile'), findsOneWidget);
//       expect(find.text('Emergency Contact Phone'), findsOneWidget);
//       expect(find.text('Email (Optional)'), findsOneWidget);
//     });

//     testWidgets('BiometricSetupStep renders fingerprint setup options', (tester) async {
//       tester.view.physicalSize = const Size(1080, 1920);
//       tester.view.devicePixelRatio = 1.0;
//       addTearDown(() => tester.view.resetPhysicalSize());

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: SizedBox(
//               height: 1000,
//               child: BiometricSetupStep(
//                 primaryColor: const Color(0xFF1D4ED8),
//                 hasFingerprint: true,
//                 hasFaceId: false,
//                 onSetupBiometrics: (_) {},
//                 onSkip: () {},
//               ),
//             ),
//           ),
//         ),
//       );

//       expect(find.text('Enable Biometric Login'), findsOneWidget);
//       expect(find.text('Skip for now'), findsOneWidget);
//     });

//     testWidgets('ConfirmDetailsStep renders verified badge and details', (tester) async {
//       tester.view.physicalSize = const Size(1080, 1920);
//       tester.view.devicePixelRatio = 1.0;
//       addTearDown(() => tester.view.resetPhysicalSize());

//       final nameCtrl = TextEditingController(text: 'Test Driver');
//       final phoneCtrl = TextEditingController(text: '9876543210');
//       final dobCtrl = TextEditingController(text: '01/01/1990');
//       final aadhaarCtrl = TextEditingController(text: '1234 5678 9012');
//       final dlCtrl = TextEditingController(text: 'DL1420110012345');
//       final rcCtrl = TextEditingController(text: 'DL01AB1234');
//       final pucCtrl = TextEditingController(text: 'PUC123456');
//       final marksCtrl = TextEditingController(text: 'Pass');
//       final insuranceCtrl = TextEditingController(text: 'INS987654');
//       final bankNameCtrl = TextEditingController(text: 'SBI');
//       final bankAccCtrl = TextEditingController(text: '1234567890');
//       final upiCtrl = TextEditingController(text: 'driver@upi');

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: SizedBox(
//               height: 1200,
//               child: ConfirmDetailsStep(
//                 primaryColor: const Color(0xFF1D4ED8),
//                 nameController: nameCtrl,
//                 phoneController: phoneCtrl,
//                 dobController: dobCtrl,
//                 selectedVehicleType: 'Bike',
//                 selectedGender: 'Male',
//                 aadhaarNumberController: aadhaarCtrl,
//                 dlNumberController: dlCtrl,
//                 rcNumberController: rcCtrl,
//                 pucNumberController: pucCtrl,
//                 pucTotalMarksController: marksCtrl,
//                 insuranceNumberController: insuranceCtrl,
//                 faceMatchStatus: 'MATCHED',
//                 faceMatchScore: 98.5,
//                 bankNameController: bankNameCtrl,
//                 bankAccountNumberController: bankAccCtrl,
//                 upiIdController: upiCtrl,
//                 onConfirm: () {},
//               ),
//             ),
//           ),
//         ),
//       );

//       expect(find.text('Confirm Your Details'), findsOneWidget);
//       expect(find.text('Test Driver'), findsWidgets);
//     });
//   });
// }
