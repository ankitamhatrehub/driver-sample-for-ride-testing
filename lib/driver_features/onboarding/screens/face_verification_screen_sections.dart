part of 'package:rider_app/driver_features/onboarding/screens/face_verification_screen.dart';

extension _FaceVerificationScreenStateSections on _FaceVerificationScreenState {
  Widget _allowCamera(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.verifyYourIdentity,
      onBack: () => _go(_FacePage.beforeStart),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(24),
          context.h(50),
          context.w(24),
          context.h(16),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: context.w(45),
              backgroundColor: context.adaptiveTint(const Color(0xFFEDE7F6)),
              child: Icon(
                Icons.photo_camera_outlined,
                color: context.legible(AppColors.primary),
                size: context.w(32),
              ),
            ),
            SizedBox(height: context.h(20)),
            Text(
              AppStrings.allowCameraAccess,
              style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
            ),
            SizedBox(height: context.h(6)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(24)),
              child: Text(
                AppStrings.allowCameraSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.regular.copyWith(
                  fontSize: 12,
                  height: 1.4,
                  color: context.torkk.textSecondary,
                ),
              ),
            ),
            SizedBox(height: context.h(28)),
            _IconInfoRow(
              icon: Icons.shield_outlined,
              text: AppStrings.dataSafeSecure,
            ),
            SizedBox(height: context.h(12)),
            _IconInfoRow(
              icon: Icons.lock_outline,
              text: AppStrings.usedOnlyForIdentity,
            ),
            SizedBox(height: context.h(12)),
            _IconInfoRow(
              icon: Icons.visibility_off_outlined,
              text: AppStrings.photoNotStored,
            ),
            SizedBox(height: context.h(60)),
            UnifiedButton(
              label: AppStrings.allowCameraAccess,
              onPressed: () => _go(_FacePage.capture),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verified(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.w(28),
            context.h(48),
            context.w(28),
            context.h(16),
          ),
          child: Column(
            children: [
              Image.asset(
                AppAssets.verifiedIcon,
                width: context.w(96),
                height: context.w(96),
              ),
              SizedBox(height: context.h(16)),
              Text(
                AppStrings.identityVerifiedFace,
                style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
              ),
              SizedBox(height: context.h(6)),
              Text(
                AppStrings.identityVerifiedFaceSubtitle,
                style: AppTypography.regular.copyWith(
                  fontSize: 13,
                  color: context.torkk.textSecondary,
                ),
              ),
              SizedBox(height: context.h(50)),
              _SuccessLine(AppStrings.identityConfirmed),
              _SuccessLine(AppStrings.accountSecured),
              _SuccessLine(AppStrings.completeOnboardingNow),
              const Spacer(),
              UnifiedButton(
                label: AppStrings.continueAction,
                onPressed: widget.onFinished,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _failed(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.w(24),
            context.h(48),
            context.w(24),
            context.h(16),
          ),
          child: Column(
            children: [
              Image.asset(
                AppAssets.failedIcon,
                width: context.w(96),
                height: context.w(96),
              ),
              SizedBox(height: context.h(16)),
              Text(
                AppStrings.faceVerificationFailed,
                style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
              ),
              SizedBox(height: context.h(8)),
              Text(
                AppStrings.faceVerificationFailedSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.regular.copyWith(
                  fontSize: 14,
                  height: 1.4,
                  color: context.torkk.textSecondary,
                ),
              ),
              SizedBox(height: context.h(20)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.w(14)),
                decoration: BoxDecoration(
                  color: context.adaptiveTint(const Color(0xFFFEF2F2)),
                  borderRadius: BorderRadius.circular(context.r(12)),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.reason,
                      style: AppTypography.bold.copyWith(
                        color: context.torkk.textPrimary,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: context.h(8)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.cancel,
                          color: context.legible(AppColors.error),
                          size: context.w(16),
                        ),
                        SizedBox(width: context.w(8)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.faceNotDetectedReason,
                                style: AppTypography.bold.copyWith(
                                  fontSize: 13,
                                  height: 1.3,
                                  color: context.legible(AppColors.error),
                                ),
                              ),
                              Text(
                                AppStrings.faceNotDetectedHint,
                                style: AppTypography.regular.copyWith(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: context.legible(AppColors.error),
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
              UnifiedButton(
                label: AppStrings.tryAgain,
                onPressed: () => _go(_FacePage.capture),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
