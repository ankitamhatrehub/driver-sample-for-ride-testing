import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/welcome_screen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = OnboardingSession.instance;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: ListenableBuilder(
        listenable: session,
        builder: (context, _) {
          return WelcomeScreen(
            phoneController: session.phone,
            termsAccepted: session.termsAccepted,
            onTermsChanged: (value) {
              session.termsAccepted = value;
              session.touch();
            },
            isLoading: session.loading,
            keyboardOpen: keyboardOpen,
            onContinue: () async {
              final error = await session.sendOtp();
              if (!context.mounted) return;
              if (error != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error)));
              }
              context.go(AppRoutes.otp);
            },
          );
        },
      ),
    );
  }
}
