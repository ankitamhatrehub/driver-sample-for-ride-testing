import 'package:flutter/material.dart';

import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/authentication_failed_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/connect_digilocker_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/connecting_digilocker_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/document_not_found_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/identity_verified_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/permission_denied_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/aadhaar_manual_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/pan_verification_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/verification_failed_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/verify_aadhaar_screen.dart';

enum AadhaarFlowPage {
  choose,
  digilocker,
  pan,
  aadhaarManual,
  connecting,
  verified,
  verificationFailed,
  documentNotFound,
  permissionDenied,
  authFailed,
}

/// Switches between the Aadhaar screens. Each page is its own screen file.
class AadhaarVerificationFlow extends StatefulWidget {
  final bool isLoading;
  final TextEditingController aadhaarController;
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onStartDigilocker;
  final VoidCallback onSubmitUpload;
  final VoidCallback onVerified;
  final bool alreadyVerified;
  final bool playSuccess;
  final VoidCallback onSuccessPlayed;

  const AadhaarVerificationFlow({
    super.key,
    required this.isLoading,
    required this.aadhaarController,
    required this.onBack,
    required this.onHelp,
    required this.onStartDigilocker,
    required this.onSubmitUpload,
    required this.onVerified,
    this.alreadyVerified = false,
    this.playSuccess = false,
    this.onSuccessPlayed = _noop,
  });

  static void _noop() {}

  @override
  State<AadhaarVerificationFlow> createState() => AadhaarVerificationFlowState();
}

class AadhaarVerificationFlowState extends State<AadhaarVerificationFlow> {
  late AadhaarFlowPage _page;
  bool _ticking = false;

  @override
  void initState() {
    super.initState();
    _page = widget.alreadyVerified ? AadhaarFlowPage.verified : AadhaarFlowPage.choose;
  }

  @override
  void didUpdateWidget(AadhaarVerificationFlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playSuccess && !oldWidget.playSuccess) {
      _page = AadhaarFlowPage.connecting;
      _ticking = true;
    }
  }

  void show(AadhaarFlowPage page) => setState(() => _page = page);

  void _openDigilocker() => show(AadhaarFlowPage.digilocker);

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      AadhaarFlowPage.choose => VerifyAadhaarScreen(
          onBack: widget.onBack,
          onHelp: widget.onHelp,
          onContinueDigilocker: _openDigilocker,
          onUploadManually: () => show(AadhaarFlowPage.aadhaarManual),
        ),
      AadhaarFlowPage.digilocker => ConnectDigilockerScreen(
          isLoading: widget.isLoading,
          onBack: () => show(AadhaarFlowPage.choose),
          onHelp: widget.onHelp,
          onContinue: () {
            show(AadhaarFlowPage.connecting);
            widget.onStartDigilocker();
          },
        ),
      AadhaarFlowPage.aadhaarManual => AadhaarManualScreen(
          aadhaarController: widget.aadhaarController,
          isLoading: widget.isLoading,
          onBack: () => show(AadhaarFlowPage.choose),
          onVerify: () => show(AadhaarFlowPage.pan),
        ),
      AadhaarFlowPage.pan => PanVerificationScreen(
          onBack: () => show(AadhaarFlowPage.aadhaarManual),
          onVerify: (pan) {
            OnboardingSession.instance.rememberPan(pan);
            widget.onSubmitUpload();
          },
        ),
      AadhaarFlowPage.connecting => ConnectingDigilockerScreen(
          onBack: () => show(AadhaarFlowPage.digilocker),
          ticking: _ticking,
          onTickingFinished: () {
            setState(() {
              _ticking = false;
              _page = AadhaarFlowPage.verified;
            });
            widget.onSuccessPlayed();
          },
        ),
      AadhaarFlowPage.verified => IdentityVerifiedScreen(onContinue: widget.onVerified),
      AadhaarFlowPage.verificationFailed => VerificationFailedScreen(
          onBack: _openDigilocker,
          onHelp: widget.onHelp,
          onRetry: _openDigilocker,
        ),
      AadhaarFlowPage.documentNotFound => DocumentNotFoundScreen(
          onBack: _openDigilocker,
          onHelp: widget.onHelp,
          onTryAgain: _openDigilocker,
        ),
      AadhaarFlowPage.permissionDenied => PermissionDeniedScreen(
          onBack: _openDigilocker,
          onHelp: widget.onHelp,
          onTryAgain: _openDigilocker,
        ),
      AadhaarFlowPage.authFailed => AuthenticationFailedScreen(
          onBack: _openDigilocker,
          onHelp: widget.onHelp,
          onTryAgain: _openDigilocker,
          onUseAnotherMethod: () => show(AadhaarFlowPage.aadhaarManual),
        ),
    };
  }
}
