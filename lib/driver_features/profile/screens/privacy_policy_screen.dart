import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_accordion.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

const _kycAnswer =
    'KYC helps verify your identity and required documents before you can start driving with Torkk. It ensures a safe and secure platform for all drivers and users, and is required as per regulatory guidelines.';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.privacyPolicy,
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
        children: const [
          ProfileAccordion(sections: [
            ProfileSection(AppStrings.overview, 'This policy explains how Torkk collects and uses driver information.'),
            ProfileSection(AppStrings.privacyPolicy, _kycAnswer, readMore: true),
            ProfileSection('User Acceptance', 'By using the Torkk driver app you agree to this privacy policy.'),
            ProfileSection('Definitions', 'Driver means a partner registered to receive ride or parcel requests on Torkk.'),
          ]),
          ProfileAccordion(sections: [
            ProfileSection('What Information do we collect ?', 'We collect the details you submit for KYC, your vehicle, and your bank account.'),
          ]),
          ProfileAccordion(sections: [
            ProfileSection('Use of Information Collected', 'We use this information to verify you, assign requests, and pay your earnings.'),
          ]),
          ProfileAccordion(sections: [
            ProfileSection('How and when we disclose information to third parties', 'We share documents with verification partners only to complete KYC.'),
          ]),
          ProfileAccordion(sections: [
            ProfileSection('Third parties providing services', 'Payment and identity partners process data only for the service they provide to Torkk.'),
          ]),
        ],
      ),
    );
  }
}
