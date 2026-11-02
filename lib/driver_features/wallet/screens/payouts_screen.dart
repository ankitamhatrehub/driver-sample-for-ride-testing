import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class PayoutsScreen extends StatelessWidget {
  const PayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.payouts,
      child: const SizedBox.shrink(),
    );
  }
}
