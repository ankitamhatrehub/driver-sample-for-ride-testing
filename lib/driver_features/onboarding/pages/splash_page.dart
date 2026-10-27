import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider_app/app/theme/theme_bloc.dart';
import 'package:rider_app/app/theme/theme_event.dart';
import 'package:rider_app/driver_features/onboarding/kyc_resume.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/common/widgets/app_splash_screen.dart';

OnboardingSession get _session => OnboardingSession.instance;

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  Future<void> _next(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;
    if (prefs.getBool('isLoggedIn') == true) {
      final gender = prefs.getString('user_gender') ?? AppStrings.genderMale;
      context.read<ThemeBloc>().add(
        AccentChanged(isPink: gender == AppStrings.genderFemale),
      );
      _session.gender = gender;
      context.go(
        gender == AppStrings.genderFemale
            ? AppRoutes.dashboardFemale
            : AppRoutes.dashboardMale,
      );
      return;
    }
    final where = await KycResume.destination();
    final phone = await KycResume.savedPhone();
    if (phone.isNotEmpty) _session.phone.text = phone;
    await _session.loadProgress();
    if (!context.mounted) return;
    switch (where) {
      case KycResumeDestination.kyc:
        _session.vehicleChosen = true;
        context.go(AppRoutes.kyc);
      case KycResumeDestination.vehicle:
        context.go(AppRoutes.vehicleDetails);
      case KycResumeDestination.otp:
        context.go(AppRoutes.otp);
      case KycResumeDestination.none:
        context.go(AppRoutes.language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSplashScreen(onFinished: () => _next(context));
  }
}
