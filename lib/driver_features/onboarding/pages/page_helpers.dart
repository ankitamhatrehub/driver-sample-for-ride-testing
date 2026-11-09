import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/common/widgets/ai_chat_button.dart';
import 'package:rider_app/driver_features/parcels/coming_soon_screen.dart';
import 'package:rider_app/service/location_availability_service.dart';
import 'package:rider_app/service/location_permission_flow.dart';

OnboardingSession get _session => OnboardingSession.instance;

void goDashboard(BuildContext context) {
  final female = _session.gender == AppStrings.genderFemale;
  context.go(female ? AppRoutes.dashboardFemale : AppRoutes.dashboardMale);
}

/// Every way into the home screen goes through here (after OTP, on app launch
/// when already logged in, after the application is approved).
///
/// Torkk only runs in Delhi NCR for now, so this first asks the backend if
/// service is live at the driver's location. If not, the Coming Soon screen
/// (with "Notify me") is shown and this returns true; the home screen is not
/// opened. Otherwise it opens home and returns false.
Future<bool> openHomeIfServiceable(BuildContext context) async {
  // The App Store review account is not in Delhi NCR; never block it.
  // On app launch the session is empty, so fall back to the saved login.
  var phone = _session.phone.text.replaceAll(' ', '');
  if (phone.isEmpty) {
    phone =
        (await SharedPreferences.getInstance()).getString('user_phone') ?? '';
  }
  var blocked = false;
  if (phone != '9999999999') {
    // Disclosure screen first, then the OS prompt (foreground only here; the
    // background step is offered later, when the driver goes online).
    if (!context.mounted) return false;
    await LocationPermissionFlow.ensure(context);
    if (!context.mounted) return false;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    final availability = await LocationAvailabilityService.check();
    if (!context.mounted) return false;
    Navigator.of(context, rootNavigator: true).pop();
    if (availability != null && availability.comingSoon) {
      blocked = true;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ComingSoonScreen(
            latitude: availability.latitude,
            longitude: availability.longitude,
          ),
        ),
      );
    }
  }
  if (blocked || !context.mounted) return blocked;
  goDashboard(context);
  return false;
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
