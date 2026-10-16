import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

class ProfileEditButton extends StatelessWidget {
  const ProfileEditButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.w(20),
        context.h(8),
        context.w(20),
        context.h(16),
      ),
      child: UnifiedButton(
        label: AppStrings.edit,
        icon: Icons.edit,
        iconAtEnd: true,
        backgroundColor: const Color(0xFF0F3FBF),
        onPressed: () {},
      ),
    );
  }
}
