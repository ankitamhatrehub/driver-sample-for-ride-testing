import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider_app/app/theme/theme_bloc.dart';
import 'package:rider_app/app/theme/theme_event.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/driver_details_screen.dart';
import 'package:rider_app/driver_features/onboarding/pages/page_helpers.dart';

OnboardingSession get _session => OnboardingSession.instance;

class DriverDetailsPage extends StatelessWidget {
  const DriverDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        return DriverDetailsScreen(
          nameController: _session.name,
          dobController: _session.dob,
          emailController: _session.email,
          gender: _session.gender,
          photoPath: _session.photoPath,
          onGenderChanged: (value) {
            _session.gender = value;
            context.read<ThemeBloc>().add(
              AccentChanged(isPink: value == AppStrings.genderFemale),
            );
            _session.touch();
          },
          onPhotoPicked: (path) {
            _session.photoPath = path;
            _session.touch();
          },
          onBack: () => leaveOnboardingStep(context, AppRoutes.driverDetails, AppRoutes.kyc),
          onContinue: () {
            _session.returnToReview = false;
            _session.reviewEntry = '';
            context.go(AppRoutes.review);
          },
        );
      },
    );
  }
}
