part of 'package:rider_app/driver_features/onboarding/screens/verify_driving_license_screen.dart';

extension _VerifyDrivingLicenseScreenStatePages on _VerifyDrivingLicenseScreenState {
  Widget _digilockerVerified(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.w(24), context.h(36), context.w(24), context.h(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  AppAssets.verifiedIcon,
                  width: context.w(96),
                  height: context.w(96),
                ),
              ),
              SizedBox(height: context.h(16)),
              Center(
                child: Text(
                  AppStrings.drivingLicenceVerified,
                  style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
                ),
              ),
              SizedBox(height: context.h(8)),
              Text(
                AppStrings.drivingLicenceVerifiedSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.regular.copyWith(color: context.torkk.textSecondary, fontSize: 14),
              ),
              const Spacer(),
              UnifiedButton(label: AppStrings.continueAction, onPressed: widget.onFinished),
            ],
          ),
        ),
      ),
    );
  }

  Widget _manualForm(BuildContext context) {
    print('Manual form page: _licenseController=${_licenseController.text}, _dobController=${_dobController.text}, _expiryController=${_expiryController.text}');
    return OnboardingStepScaffold(
      title: AppStrings.drivingLicenseTitle,
      onBack: () => _go(_DlPage.choose),
      onHelp: widget.onHelp,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(8), context.w(24), context.h(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.preview, style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2)),
            SizedBox(height: context.h(10)),
            Row(
              children: [
                Expanded(
                  child: _PreviewTile(
                    imagePath: _frontPath,
                    onRetake: () => _pickLicenceSide(front: true),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: _PreviewTile(
                    imagePath: _backPath,
                    onRetake: () => _pickLicenceSide(front: false),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(18)),
            Text('${AppStrings.licenseNumber} *', style: AppTypography.regular.copyWith(fontSize: 13)),
            SizedBox(height: context.h(8)),
            AppTextField(controller: _licenseController, hintText: AppStrings.licenseNumber),
            SizedBox(height: context.h(14)),
            // Text('${AppStrings.dateOfBirth} *', style: AppTypography.regular.copyWith(fontSize: 13)),
            // SizedBox(height: context.h(8)),
            // Stack(
            //   alignment: Alignment.centerRight,
            //   children: [
            //     AppTextField(controller: _dobController, hintText: AppStrings.dobFormatHint),
            //     IconButton(
            //       onPressed: _pickDob,
            //       icon: Icon(Icons.calendar_today_outlined, size: context.w(18), color: context.torkk.textSecondary),
            //     ),
            //   ],
            // ),
            // SizedBox(height: context.h(14)),
            // Text('${AppStrings.expiryDate} *', style: AppTypography.regular.copyWith(fontSize: 13)),
            // SizedBox(height: context.h(8)),
            // Stack(
            //   alignment: Alignment.centerRight,
            //   children: [
            //     AppTextField(controller: _expiryController, hintText: AppStrings.expiryDate),
            //     IconButton(
            //       onPressed: _pickExpiry,
            //       icon: Icon(Icons.calendar_today_outlined, size: context.w(18), color: context.torkk.textSecondary),
            //     ),
            //   ],
            // ),
            SizedBox(height: context.h(14)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(8)),
              decoration: BoxDecoration(
                color: context.adaptiveTint(const Color(0xFFFFF7ED)),
                borderRadius: BorderRadius.circular(context.r(20)),
                border: Border.all(color: const Color(0xFFFDBA74)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: context.legible(AppColors.amber600), size: context.w(16)),
                  SizedBox(width: context.w(6)),
                  Text(
                    AppStrings.verificationPending,
                    style: AppTypography.regular.copyWith(color: context.legible(AppColors.amber700), fontSize: 13),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(24)),
            UnifiedButton(
              label:
               AppStrings.continueAction,
              isLoading: _verifying,
              onPressed: _verifyReadLicence,
            ),
          ],
        ),
      ),
    );
  }

  Widget _verified(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.drivingLicenseTitle,
      onBack: () => _go(_DlPage.manualForm),
      onHelp: widget.onHelp,
      body: Padding(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(48), context.w(24), context.h(16)),
        child: Column(
          children: [
            const _LicenceSketch(badgeIcon: Icons.check, badgeColor: AppColors.green600),
            SizedBox(height: context.h(28)),
            Text(
              AppStrings.drivingLicenseVerifiedManual,
              textAlign: TextAlign.center,
              style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
            ),
            SizedBox(height: context.h(8)),
            Text(
              AppStrings.drivingLicenseVerifiedManualSubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.regular.copyWith(color: context.torkk.textSecondary, fontSize: 14, height: 1.4),
            ),
            const Spacer(),
            UnifiedButton(label: AppStrings.continueAction, onPressed: widget.onFinished),
          ],
        ),
      ),
    );
  }

  Widget _rejected(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.drivingLicenseTitle,
      onBack: () => _go(_DlPage.manualForm),
      onHelp: widget.onHelp,
      body: Padding(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(36), context.w(24), context.h(16)),
        child: Column(
          children: [
            const _LicenceSketch(badgeIcon: Icons.close, badgeColor: AppColors.error),
            SizedBox(height: context.h(28)),
            Text(
              AppStrings.drivingLicenseRejected,
              textAlign: TextAlign.center,
              style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
            ),
            SizedBox(height: context.h(8)),
            Text(
              AppStrings.drivingLicenseRejectedSubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.regular.copyWith(color: context.torkk.textSecondary, fontSize: 14, height: 1.4),
            ),
            SizedBox(height: context.h(20)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.w(14)),
              decoration: BoxDecoration(
                color: context.adaptiveTint(const Color(0xFFFFF5F5)),
                borderRadius: BorderRadius.circular(context.r(14)),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.rejectionReason,
                    style: AppTypography.regular.copyWith(color: context.torkk.textSecondary, fontSize: 12),
                  ),
                  SizedBox(height: context.h(8)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info, color: context.legible(AppColors.error), size: context.w(18)),
                      SizedBox(width: context.w(8)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.documentImageUnclear,
                              style: AppTypography.bold.copyWith(color: context.torkk.textPrimary, fontSize: 14, height: 1.2),
                            ),
                            SizedBox(height: context.h(4)),
                            Text(
                              AppStrings.documentImageUnclearHint,
                              style: AppTypography.regular.copyWith(
                                color: context.torkk.textSecondary,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            UnifiedButton(label: AppStrings.fixAndResubmit, onPressed: () {
print('Resubmitting driving license verification');
              _go(_DlPage.choose);
              print('Navigated back to choose page for resubmission');
            } ),
          ],
        ),
      ),
    );
  }
}
