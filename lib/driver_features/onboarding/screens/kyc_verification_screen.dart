import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/onboarding_info_banner.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/driver_features/onboarding/widgets/kyc_status_row.dart';

class KycVerificationScreen extends StatelessWidget {
  final bool aadhaarVerified;
  final bool dlVerified;
  final bool rcVerified;
  final bool vehiclePhotosVerified;
  final bool faceVerified;
  final bool bankVerified;
  final bool profileSubmitted;
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onAadhaarTap;
  final VoidCallback onDlTap;
  final VoidCallback onRcTap;
  final VoidCallback onVehiclePhotosTap;
  final VoidCallback onFaceTap;
  final VoidCallback onBankTap;
  final VoidCallback onProfileTap;

  const KycVerificationScreen({
    super.key,
    required this.aadhaarVerified,
    required this.dlVerified,
    required this.rcVerified,
    required this.vehiclePhotosVerified,
    required this.faceVerified,
    required this.bankVerified,
    required this.profileSubmitted,
    required this.onBack,
    required this.onHelp,
    required this.onAadhaarTap,
    required this.onDlTap,
    required this.onRcTap,
    required this.onVehiclePhotosTap,
    required this.onFaceTap,
    required this.onBankTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = _items();

    return OnboardingStepScaffold(
      title: AppStrings.kycVerification,
      subtitle: AppStrings.kycSubtitle,
      onBack: onBack,
      onHelp: onHelp,
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(
                context.w(28),
                context.h(30),
                context.w(28),
                context.h(12),
              ),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: context.h(18)),
              itemBuilder: (context, index) => KycStatusRow(
                title: items[index].title,
                status: items[index].status,
                onTap: items[index].onTap,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: context.w(28), right: context.w(28), bottom: context.h(50)),
            child: const OnboardingInfoBanner(message: AppStrings.kycActivateHint),
          ),
        ],
      ),
    );
  }

  List<_KycItem> _items() {
    final done = [
      aadhaarVerified,
      dlVerified,
      rcVerified,
      vehiclePhotosVerified,
      faceVerified,
      bankVerified,
      profileSubmitted,
    ];
    final nextIndex = done.indexWhere((item) => !item);

    KycItemStatus statusFor(int index) {
      if (done[index]) return KycItemStatus.verified;
      if (index == nextIndex) return KycItemStatus.pending;
      return KycItemStatus.notStarted;
    }

    return [
      _KycItem(AppStrings.kycAadhaarPan, statusFor(0), onAadhaarTap),
      _KycItem(AppStrings.kycDrivingLicense, statusFor(1), onDlTap),
      _KycItem(AppStrings.kycVehicleRc, statusFor(2), onRcTap),
      _KycItem(AppStrings.kycVehiclePhotos, statusFor(3), onVehiclePhotosTap),
      _KycItem(AppStrings.kycFaceVerification, statusFor(4), onFaceTap),
      _KycItem(AppStrings.kycBankDetails, statusFor(5), onBankTap),
      _KycItem(AppStrings.kycProfileReview, statusFor(6), onProfileTap),
    ];
  }
}

class _KycItem {
  const _KycItem(this.title, this.status, this.onTap);

  final String title;
  final KycItemStatus status;
  final VoidCallback onTap;
}
