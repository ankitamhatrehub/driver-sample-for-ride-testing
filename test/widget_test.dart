// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:rider_app/app/driver_app.dart';
// import 'package:rider_app/app/theme/theme_repository.dart';

// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();

//   testWidgets('Customer App onboarding smoke test', (
//     WidgetTester tester,
//   ) async {
//     SharedPreferences.setMockInitialValues({});
//     final preferences = await SharedPreferences.getInstance();
//     await tester.pumpWidget(
//       DriverApp(themeRepository: ThemeRepository(preferences)),
//     );

//     // Verify that our onboarding screen text is present.
//     expect(find.text('Torkk Rider'), findsOneWidget);
//     expect(find.text('Get Started'), findsOneWidget);
//   });
// }
