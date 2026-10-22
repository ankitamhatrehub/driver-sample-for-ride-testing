import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_pages.dart';
import 'package:rider_app/driver_features/onboarding/widgets/kyc_status_row.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows a lock instead of a chevron for not-started status', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KycStatusRow(
            title: 'Driving Licence',
            status: KycItemStatus.notStarted,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('KYC help action opens the existing AI chat', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: KycPage()));

    await tester.tap(find.byTooltip('Help'));
    await tester.pumpAndSettle();
    expect(find.text('Live AI Chat'), findsOneWidget);
  });
}
