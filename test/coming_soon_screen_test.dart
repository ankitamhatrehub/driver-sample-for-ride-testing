// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:rider_app/common/theme/theme.dart';
// import 'package:rider_app/common/theme/torkk_colors.dart';
// import 'package:rider_app/driver_features/parcels/coming_soon_screen.dart';

// double contrast(Color a, Color b) {
//   final la = a.computeLuminance() + 0.05;
//   final lb = b.computeLuminance() + 0.05;
//   return la > lb ? la / lb : lb / la;
// }

// void main() {
//   setUp(() => SharedPreferences.setMockInitialValues({}));

//   for (final dark in [false, true]) {
//     testWidgets('renders without bundled artwork (dark: $dark)', (
//       tester,
//     ) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           themeMode: dark ? ThemeMode.dark : ThemeMode.light,
//           theme: AppTheme.getTheme(isPink: false),
//           darkTheme: AppTheme.getTheme(isPink: false, isDark: true),
//           home: const ComingSoonScreen(),
//         ),
//       );
//       await tester.pumpAndSettle();

//       expect(tester.takeException(), isNull);
//       expect(find.text('Notify me when Torkk launches'), findsOneWidget);

//       final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
//       expect(
//         scaffold.backgroundColor,
//         dark ? TorkkColors.dark.background : Colors.white,
//       );

//       final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
//       final fill = button.style!.backgroundColor!.resolve({})!;
//       final label = button.style!.foregroundColor!.resolve({})!;
//       expect(contrast(fill, label), greaterThan(4.5));
//     });
//   }
// }
