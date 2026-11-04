import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/common/widgets/ai_chat_button.dart';

OnboardingSession get _session => OnboardingSession.instance;

void goDashboard(BuildContext context) {
  final female = _session.gender == AppStrings.genderFemale;
  context.go(female ? AppRoutes.dashboardFemale : AppRoutes.dashboardMale);
}

void leaveOnboardingStep(BuildContext context, String self, String fallback) {
  if (_session.returnToReview && _session.reviewEntry == self) {
    _session.returnToReview = false;
    _session.reviewEntry = '';
    context.go(AppRoutes.review);
    return;
  }
  context.go(fallback);
}

void openFromReview(BuildContext context, String path) {
  _session.returnToReview = true;
  _session.reviewEntry = path;
  context.go(path);
}

void showOnboardingSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void openAiChat(BuildContext context) {
  openAiChatScreen(context);
}
