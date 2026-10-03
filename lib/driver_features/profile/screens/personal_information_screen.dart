import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_edit_button.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.personalInformation,
      bottom: const ProfileEditButton(),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(28), context.h(30), context.w(28), context.h(20)),
        children: const [
          ProfileMenuCard(
            items: [
              ProfileValueRow(icon: Icons.person_outline, label: AppStrings.name, value: 'Rahul'),
              ProfileValueRow(icon: Icons.person_outline, label: AppStrings.gender, value: 'Male'),
              ProfileValueRow(icon: Icons.badge_outlined, label: AppStrings.driversId, value: '6767676767'),
              ProfileValueRow(icon: Icons.phone_outlined, label: AppStrings.mobileNumber, value: '6767676767'),
              ProfileValueRow(icon: Icons.mail_outline, label: AppStrings.emailAddress, value: 'User@gmail.com'),
            ],
          ),
        ],
      ),
    );
  }
}
