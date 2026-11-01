import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_accordion.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.termsConditions,
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
                AppStrings.generalTerms,
                AppStrings.generalTermsDescription,
              ),
            ],
          ),
          ProfileAccordion(
            sections: [
              ProfileSection(
                AppStrings.specialTerms,
                AppStrings.specialTermsDescription,
              ),
            ],
          ),
          ProfileAccordion(
            sections: [
              ProfileSection(
                AppStrings.generalTerms,
                AppStrings.documentsVehicleDetailsDescription,
              ),
              ProfileSection(
                AppStrings.platform,
                AppStrings.platformDescription,
              ),
              ProfileSection(
                AppStrings.generalCovenants,
                AppStrings.generalCovenantsDescription,
              ),
              ProfileSection(
                AppStrings.registration,
                AppStrings.registrationDescription,
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
                AppStrings.discloseInformationToThirdParties,
                AppStrings.discloseInformationToThirdPartiesDescription,
              ),
            ],
          ),
          ProfileAccordion(
            sections: [
              ProfileSection(
                AppStrings.thirdPartiesProvidingServices,
                AppStrings.thirdPartiesProvidingServicesDescription,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
