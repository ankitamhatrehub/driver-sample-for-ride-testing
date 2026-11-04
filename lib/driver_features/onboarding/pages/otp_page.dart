import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/common/utils/translations.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/verify_otp_screen.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/onboarding/pages/page_helpers.dart';

OnboardingSession get _session => OnboardingSession.instance;

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      resizeToAvoidBottomInset: true,
      body: ListenableBuilder(
        listenable: _session,
        builder: (context, _) {
          return VerifyOtpScreen(
            otpController: _session.otp,
            otpFocusNode: _session.otpFocus,
            phoneController: _session.phone,
            otpCountdown: _session.otpCountdown,
            isLoading: _session.loading,
            incorrectOtp: _session.otpError,
            announceOtpSent: _session.announceOtp,
            onOtpSentAnnounced: () {
              _session.announceOtp = false;
              _session.touch();
            },
            onBack: () {
              _session.clearOtp();
              context.go(AppRoutes.welcome);
            },
            onDismissError: () {
              _session.otpError = false;
              _session.touch();
            },
            onChangeNumber: () {
              _session.clearOtp();
              context.go(AppRoutes.welcome);
            },
            onResendOtp: () async {
              _session.clearOtp();
              final error = await _session.sendOtp();
              if (context.mounted && error != null) {
                showOnboardingSnack(context, error);
              }
            },
            onVerify: () async {
              if (_session.otp.text.isEmpty) {
                showOnboardingSnack(
                  context,
                  AppTranslations.tr('enter_verification_code'),
                );
                return;
              }
              print('Verifying OTP: ${_session.otp.text}');
              final result = await _session.verifyOtp();
              print('OTP verification result: $result');
              if (!context.mounted) return;
              if (result.message != null) {
                showOnboardingSnack(context, result.message!);
              }
              if (result.openDashboard) {
                // Location check, then home (Coming Soon outside Delhi NCR).
                await openHomeIfServiceable(context);
                // To open home without the location check (testing outside
                // Delhi NCR): comment the line above and uncomment this one.
                // goDashboard(context);
              } else if (result.openVehicle) {
                context.go(AppRoutes.vehicleDetails);
              }
            },
          );
        },
      ),
    );
  }
}
