import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/onboarding/widgets/kyc_status_row.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class DocumentKycScreen extends StatelessWidget {
  const DocumentKycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const done = [true, true, false, false, false, false, false];
    final nextIndex = done.indexWhere((item) => !item);
    KycItemStatus statusFor(int index) {
      if (done[index]) return KycItemStatus.verified;
      if (index == nextIndex) return KycItemStatus.pending;
      return KycItemStatus.notStarted;
    }

    final items = [
      (AppStrings.kycAadhaarPan, statusFor(0)),
      (AppStrings.kycDrivingLicense, statusFor(1)),
      (AppStrings.kycVehicleRc, statusFor(2)),
      (AppStrings.kycVehiclePhotos, statusFor(3)),
      (AppStrings.kycFaceVerification, statusFor(4)),
      (AppStrings.kycBankDetails, statusFor(5)),
      (AppStrings.kycProfileReview, statusFor(6)),
    ];

    return ProfilePage(
      title: AppStrings.documentKyc,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          context.w(28),
          context.h(30),
          context.w(28),
          context.h(20),
        ),
        itemCount: items.length,
        separatorBuilder: (context, index) => SizedBox(height: context.h(18)),
        itemBuilder: (context, index) => KycStatusRow(
          title: items[index].$1,
          status: items[index].$2,
        ),
      ),
    );
  }
}
