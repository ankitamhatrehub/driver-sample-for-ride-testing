import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/common/utils/translations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider_app/app/theme/theme_bloc.dart';
import 'package:rider_app/app/theme/theme_event.dart';
import 'package:rider_app/driver_features/onboarding/aadhaar_verification_flow.dart';
import 'package:rider_app/driver_features/onboarding/digilocker_launch.dart';
import 'package:rider_app/driver_features/onboarding/kyc_resume.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/application_status_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/bank_payout_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/driver_details_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/face_verification_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/kyc_verification_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/review_details_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/select_vehicle_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/vehicle_insurance_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/vehicle_photos_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/verify_driving_license_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/verify_otp_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/verify_vehicle_rc_screen.dart';
import 'package:rider_app/common/widgets/app_splash_screen.dart';
import 'package:rider_app/driver_features/chat/screens/driver_live_chat_screen.dart';

OnboardingSession get _session => OnboardingSession.instance;

void goDashboard(BuildContext context) {
  final female = _session.gender == AppStrings.genderFemale;
  context.go(female ? AppRoutes.dashboardFemale : AppRoutes.dashboardMale);
}

void _leave(BuildContext context, String self, String fallback) {
  if (_session.returnToReview && _session.reviewEntry == self) {
    _session.returnToReview = false;
    _session.reviewEntry = '';
    context.go(AppRoutes.review);
    return;
  }
  context.go(fallback);
}

void _openFromReview(BuildContext context, String path) {
  _session.returnToReview = true;
  _session.reviewEntry = path;
  context.go(path);
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void _openAiChat(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const DriverLiveChatScreen()));
}

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

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              if (context.mounted && error != null) _snack(context, error);
            },
            onVerify: () async {
              if (_session.otp.text.isEmpty) {
                _snack(context, AppTranslations.tr('enter_verification_code'));
                return;
              }
              final result = await _session.verifyOtp();
              if (!context.mounted) return;
              if (result.message != null) _snack(context, result.message!);
              if (result.openDashboard) {
                goDashboard(context);
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

class VehiclePage extends StatelessWidget {
  const VehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        return SelectVehicleScreen(
          selectedVehicle: _session.vehicleType,
          isLoading: _session.loading,
          onBack: _session.returnToReview
              ? () =>
                    _leave(context, AppRoutes.vehicleDetails, AppRoutes.welcome)
              : null,
          onHelp: () => _openAiChat(context),
          onSelected: (value) {
            _session.vehicleType = value;
            _session.touch();
          },
          onContinue: () async {
            await _session.saveVehicle();
            if (!context.mounted) return;
            _leave(context, AppRoutes.vehicleDetails, AppRoutes.kyc);
          },
        );
      },
    );
  }
}

class KycPage extends StatelessWidget {
  const KycPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        return KycVerificationScreen(
          aadhaarVerified: _session.aadhaarVerified,
          dlVerified: _session.dlVerified,
          rcVerified: _session.rcVerified,
          vehiclePhotosVerified: _session.photosVerified,
          faceVerified: _session.faceVerified,
          bankVerified: _session.bankVerified,
          profileSubmitted: false,
          onBack: () =>
              _leave(context, AppRoutes.kyc, AppRoutes.vehicleDetails),
          onHelp: () => _openAiChat(context),
          onAadhaarTap: () => context.go(AppRoutes.kycAadhaar),
          onDlTap: () => context.go(AppRoutes.kycDrivingLicence),
          onRcTap: () => context.go(AppRoutes.kycRc),
          onVehiclePhotosTap: () => context.go(AppRoutes.kycPhotos),
          onFaceTap: () => context.go(AppRoutes.kycFace),
          onBankTap: () => context.go(AppRoutes.kycBank),
          onProfileTap: () => context.go(AppRoutes.driverDetails),
        );
      },
    );
  }
}

class AadhaarPage extends StatelessWidget {
  const AadhaarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        return AadhaarVerificationFlow(
          isLoading: _session.loading,
          aadhaarController: _session.aadhaar,
          onBack: () => context.go(AppRoutes.kyc),
          onHelp: () => _openAiChat(context),
          onStartDigilocker: () async {
            final error = await launchDigilocker(context);
            if (context.mounted && error != null) _snack(context, error);
          },
          onSubmitUpload: () async {
            final error = await _session.verifyAadhaar();
            if (!context.mounted) return;
            if (error != null) {
              _snack(context, error);
              return;
            }
            _snack(context, 'Aadhaar Verified successfully!');
            context.go(AppRoutes.kyc);
          },
          onVerified: () {
            _session.playDigilockerSuccess = false;
            _session.touch();
            context.go(AppRoutes.kyc);
          },
          alreadyVerified:
              _session.aadhaarVerified && !_session.playDigilockerSuccess,
          playSuccess: _session.playDigilockerSuccess,
          onSuccessPlayed: () {
            _session.playDigilockerSuccess = false;
            _session.touch();
          },
        );
      },
    );
  }
}

class DrivingLicencePage extends StatelessWidget {
  const DrivingLicencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return VerifyDrivingLicenseScreen(
      onBack: () => context.go(AppRoutes.kyc),
      onHelp: () => _openAiChat(context),
      onFinished: () async {
        final prefs = await SharedPreferences.getInstance();
        final number = prefs.getString('driving_licence_number') ?? '';
        if (number.isNotEmpty) _session.dlNumber.text = number;
        _session.dlVerified = true;
        _session.rememberKyc();
        if (context.mounted) context.go(AppRoutes.kyc);
      },
    );
  }
}

class VehicleRcPage extends StatelessWidget {
  const VehicleRcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VerifyVehicleRcScreen(
      onBack: () => context.go(AppRoutes.kyc),
      onHelp: () => _openAiChat(context),
      onFinished: () async {
        final prefs = await SharedPreferences.getInstance();
        final number = prefs.getString('rc_number') ?? '';
        if (number.isNotEmpty) _session.rcNumber.text = number;
        _session.rcVerified = true;
        _session.rememberKyc();
        if (context.mounted) context.go(AppRoutes.kycPhotos);
      },
    );
  }
}

class VehiclePhotosPage extends StatelessWidget {
  const VehiclePhotosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VehiclePhotosScreen(
      onBack: () => context.go(AppRoutes.kyc),
      onHelp: () => _openAiChat(context),
      onFinished: () {
        _session.photosVerified = true;
        _session.rememberKyc();
        context.go(AppRoutes.kycInsurance);
      },
    );
  }
}

class VehicleInsurancePage extends StatelessWidget {
  const VehicleInsurancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return VehicleInsuranceScreen(
      onBack: () => context.go(AppRoutes.kycPhotos),
      onHelp: () => _openAiChat(context),
      onSkip: () => context.go(AppRoutes.kyc),
    );
  }
}

class FacePage extends StatelessWidget {
  const FacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FaceVerificationScreen(
      onBack: () => context.go(AppRoutes.kyc),
      onFinished: () {
        _session.faceVerified = true;
        _session.rememberKyc();
        context.go(AppRoutes.kyc);
      },
    );
  }
}

class BankPage extends StatelessWidget {
  const BankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BankPayoutScreen(
      onBack: () => _leave(context, AppRoutes.kycBank, AppRoutes.kyc),
      onHelp: () => _openAiChat(context),
      onFinished: (details) {
        _session.rememberBank(details);
        _session.bankVerified = true;
        _session.rememberKyc();
        _leave(context, AppRoutes.kycBank, AppRoutes.kyc);
      },
    );
  }
}

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
          onBack: () => _leave(context, AppRoutes.driverDetails, AppRoutes.kyc),
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

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  void initState() {
    super.initState();
    _session.loadSavedDocuments();
  }

  String _vehicleLabel(String value) {
    switch (value) {
      case 'Cab EV':
        return AppStrings.vehicleEvCab;
      case 'Cab XL':
        return AppStrings.vehicleXlCab;
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _session,
        _session.name,
        _session.email,
        _session.aadhaar,
        _session.dlNumber,
        _session.rcNumber,
        _session.bankHolder,
        _session.bankAccount,
        _session.bankIfsc,
        _session.bankName,
      ]),
      builder: (context, _) {
        return ReviewDetailsScreen(
          gender: _session.gender,
          name: _session.name.text.trim(),
          email: _session.email.text.trim(),
          bankName: _session.bankName.text.trim(),
          aadhaarNumber: _session.aadhaar.text.trim(),
          panNumber: _session.panNumber.trim(),
          licenceNumber: _session.dlNumber.text.trim(),
          vehicleType: _session.vehicleChosen
              ? _vehicleLabel(_session.vehicleType)
              : '',
          registrationNumber: _session.rcNumber.text.trim(),
          photosUploaded: _session.photosVerified,
          faceVerified: _session.faceVerified,
          accountHolder: _session.bankHolder.text.trim(),
          accountNumber: _session.bankAccount.text.trim(),
          ifsc: _session.bankIfsc.text.trim(),
          personalDone: _session.name.text.trim().isNotEmpty,
          kycDone: _session.aadhaarVerified,
          vehicleDone: _session.vehicleChosen,
          bankDone: _session.bankVerified,
          isLoading: _session.loading,
          onBack: () => context.go(AppRoutes.driverDetails),
          onEditPersonal: () =>
              _openFromReview(context, AppRoutes.driverDetails),
          onEditKyc: () => _openFromReview(context, AppRoutes.kyc),
          onEditVehicle: () =>
              _openFromReview(context, AppRoutes.vehicleDetails),
          onEditBank: () => _openFromReview(context, AppRoutes.kycBank),
          onSubmit: () async {
            final error = await _session.submitApplication();
            if (!context.mounted) return;
            if (error != null) _snack(context, error);
            context.go(AppRoutes.applicationStatus);
          },
        );
      },
    );
  }
}

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
          onGoHome: () => goDashboard(context),
          onResubmit: () => context.go(AppRoutes.kyc),
          onMakeCorrections: () => context.go(AppRoutes.review),
        );
      },
    );
  }
}
