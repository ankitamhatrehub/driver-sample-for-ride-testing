import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/application_status_screen.dart';
import 'package:rider_app/driver_features/onboarding/pages/page_helpers.dart';

OnboardingSession get _session => OnboardingSession.instance;

class ApplicationStatusPage extends StatelessWidget {
  const ApplicationStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        return ApplicationStatusScreen(
          gender: _session.gender,
          submittedAt: _session.submittedAt ?? DateTime.now(),
          outcome: _session.outcome,
          onBack: () => context.go(AppRoutes.review),
          // Location check, then home. To skip the check (testing outside
          // Delhi NCR): comment this line and uncomment the one below it.
          onGoHome: () => openHomeIfServiceable(context),
          // onGoHome: () => goDashboard(context),
          onResubmit: () => context.go(AppRoutes.kyc),
          onMakeCorrections: () => context.go(AppRoutes.review),
        );
      },
    );
  }
}
