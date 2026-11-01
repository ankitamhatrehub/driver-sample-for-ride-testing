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
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(20),
        ),
        children: [
          ProfileAccordion(
            sections: [
              ProfileSection(
                AppStrings.overview,
                AppStrings.privacyOverviewDescription,
              ),
              ProfileSection(
                AppStrings.privacyPolicy,
                _kycAnswer,
                readMore: true,
              ),
              ProfileSection(
                AppStrings.userAcceptance,
                AppStrings.userAcceptanceDescription,
              ),
              ProfileSection(
                AppStrings.definitions,
                AppStrings.definitionsDescription,
              ),
            ],
          ),
          ProfileAccordion(
            sections: [
              ProfileSection(
                AppStrings.informationCollectedQuestion,
                AppStrings.informationCollectedDescription,
              ),
            ],
          ),
          ProfileAccordion(
            sections: [
              ProfileSection(
                AppStrings.useOfInformationCollected,
                AppStrings.useOfInformationCollectedDescription,
              ),
            ],
          ),
          ProfileAccordion(
            sections: [
              ProfileSection(
                AppStrings.thirdPartyDisclosure,
                AppStrings.thirdPartyDisclosureDescription,
              ),
            ],
          ),
          ProfileAccordion(
            sections: [
              ProfileSection(
                AppStrings.thirdPartyServices,
                AppStrings.thirdPartyServicesDescription,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
