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
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
        children: const [
          ProfileAccordion(sections: [
            ProfileSection('General Terms', 'These terms apply to every driver using the Torkk platform.'),
          ]),
          ProfileAccordion(sections: [
            ProfileSection('Special Terms', 'Ride and parcel requests can have extra terms shown before you accept.'),
          ]),
          ProfileAccordion(sections: [
            ProfileSection('General Terms', 'You must keep your documents and vehicle details up to date.'),
            ProfileSection('Platform', 'Torkk assigns requests based on your location and vehicle type.'),
            ProfileSection('General Covenants', 'You agree to follow traffic rules and treat customers fairly.'),
            ProfileSection('Registration', 'One driver account is allowed for each mobile number.'),
          ]),
          ProfileAccordion(sections: [
            ProfileSection('Use of Information Collected', 'Account information is used to operate trips, support, and payouts.'),
          ]),
          ProfileAccordion(sections: [
            ProfileSection('How and when we disclose information to third parties', 'Trip details are shared with the customer for that request only.'),
          ]),
          ProfileAccordion(sections: [
            ProfileSection('Third parties providing services', 'Map, payment, and verification providers support the services in the app.'),
          ]),
        ],
      ),
    );
  }
}
