import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/common/widgets/onboarding_header_image.dart';
import 'package:rider_app/driver_features/onboarding/screens/welcome_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('keeps the phone field above the keyboard', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    final phoneController = TextEditingController();
    addTearDown(phoneController.dispose);

    Future<void> pumpScreen({required bool keyboardOpen}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              viewInsets: EdgeInsets.only(bottom: keyboardOpen ? 320 : 0),
            ),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              body: WelcomeScreen(
                phoneController: phoneController,
                termsAccepted: false,
                onTermsChanged: (_) {},
                onContinue: () {},
                isLoading: false,
                keyboardOpen: keyboardOpen,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpScreen(keyboardOpen: false);
    final fullHeaderHeight = tester
        .getSize(find.byType(OnboardingHeaderImage))
        .height;

    await pumpScreen(keyboardOpen: true);
    expect(find.byType(OnboardingHeaderImage), findsOneWidget);
    expect(
      tester.getSize(find.byType(OnboardingHeaderImage)).height,
      lessThan(fullHeaderHeight),
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    final fieldRect = tester.getRect(find.byType(TextField));
    expect(fieldRect.bottom, lessThanOrEqualTo(844 - 320));
    expect(
      tester.getTopLeft(find.text('Continue')).dy - fieldRect.bottom,
      lessThan(80),
    );
  });
}
