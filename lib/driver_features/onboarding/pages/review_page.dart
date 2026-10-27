import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/review_details_screen.dart';
import 'package:rider_app/driver_features/onboarding/pages/page_helpers.dart';

OnboardingSession get _session => OnboardingSession.instance;

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
              openFromReview(context, AppRoutes.driverDetails),
          onEditKyc: () => openFromReview(context, AppRoutes.kyc),
          onEditVehicle: () =>
              openFromReview(context, AppRoutes.vehicleDetails),
          onEditBank: () => openFromReview(context, AppRoutes.kycBank),
          onSubmit: () async {
            final error = await _session.submitApplication();
            if (!context.mounted) return;
            if (error != null) showOnboardingSnack(context, error);
            context.go(AppRoutes.applicationStatus);
          },
        );
      },
    );
  }
}
