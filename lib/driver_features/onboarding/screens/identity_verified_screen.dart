import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

class IdentityVerifiedScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const IdentityVerifiedScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.w(24), context.h(48), context.w(24), context.h(16)),
          child: Column(
            children: [
              Image.asset(
                AppAssets.verifiedIcon,
                width: context.w(96),
                height: context.w(96),
              ),
              SizedBox(height: context.h(16)),
              Text(
                AppStrings.identityVerified,
                style: AppTypography.bold.copyWith(fontSize: 22, height: 1.2),
              ),
              SizedBox(height: context.h(8)),
              Text(
                AppStrings.identityVerifiedSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.regular.copyWith(color: AppColors.secondaryTextColor, fontSize: 14),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.verified, color: AppColors.green600, size: context.w(18)),
                  SizedBox(width: context.w(8)),
                  Expanded(
                    child: Text(
                      AppStrings.documentsSecurelyVerified,
                      style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.green700),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(16)),
              UnifiedButton(label: AppStrings.continueAction, onPressed: onContinue),
            ],
          ),
        ),
      ),
    );
  }
}
