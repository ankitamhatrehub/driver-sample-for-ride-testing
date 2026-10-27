part of 'package:rider_app/driver_features/onboarding/screens/verify_otp_screen.dart';

extension _VerifyOtpScreenStateSections on _VerifyOtpScreenState {
  void _announceOtpSent() {
    if (!widget.announceOtpSent) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.announceOtpSent) return;
      AppSnackBar.showSuccess(
        context,
        title: AppStrings.otpSentTitle,
        message: AppStrings.otpSentMessage,
      );
      widget.onOtpSentAnnounced();
    });
  }
}
