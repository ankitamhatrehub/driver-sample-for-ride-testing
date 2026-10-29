import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_edit_button.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/profile/widgets/vehicle_header.dart';

class VehicleInformationScreen extends StatelessWidget {
  const VehicleInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.vehicleInformation,
     
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(12), context.w(20), context.h(12)),
        children: [
          const VehicleHeader(),
          SizedBox(height: context.h(12)),
          ProfileMenuCard(
            items: [
              ProfileValueRow(
                icon: Icons.two_wheeler_outlined,
                label: AppStrings.vehicleModel,
                value: 'Honda Activa',
              ),
              ProfileValueRow(
                icon: Icons.directions_car_outlined,
                label: AppStrings.vehicleType,
                value: 'Two Wheeler',
              ),
            ],
          ),
          SizedBox(height: context.h(12)),
          ProfileMenuCard(
            items: [
              ProfileValueRow(
                icon: Icons.article_outlined,
                label: AppStrings.vehicleNumber,
                value: 'MH12AB1234',
              ),
              ProfileValueRow(
                icon: Icons.article_outlined,
                label: AppStrings.licenseNumber,
                value: 'MH12AB1234',
              ),
              ProfileValueRow(
                icon: Icons.vpn_key_outlined,
                label: AppStrings.registrationNumber,
                value: 'Honda Activa',
              ),
            ],
          ),
          SizedBox(height: context.h(12)),
          ProfileMenuCard(
            items: [
              ProfileValueRow(
                icon: Icons.article_outlined,
                label: AppStrings.insuranceExpiryDate,
                value: 'MH12AB1234',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
