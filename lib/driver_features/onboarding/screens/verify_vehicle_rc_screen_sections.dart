part of 'package:rider_app/driver_features/onboarding/screens/verify_vehicle_rc_screen.dart';

extension _VerifyVehicleRcScreenStateSections on _VerifyVehicleRcScreenState {
  void _continueFromForm() {
    if (_frontPath == null ||
        _backPath == null ||
        !isRegistrationNumber(_numberController.text)) {
      _go(_RcPage.unclear);
      return;
    }
    _go(_RcPage.preview);
  }

  Widget _preview(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.verifyVehicleRc,
      subtitle: AppStrings.verifyVehicleRcSubtitle,
      onBack: () => _go(_RcPage.form),
      onHelp: widget.onHelp,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.w(24),
          context.h(8),
          context.w(24),
          context.h(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.preview,
              style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2),
            ),
            SizedBox(height: context.h(10)),
            Row(
              children: [
                Expanded(
                  child: KycPreviewCard(
                    imagePath: _frontPath,
                    onRetake: () => _pickSide(front: true),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: KycPreviewCard(
                    imagePath: _backPath,
                    onRetake: () => _pickSide(front: false),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(16)),
            KycPendingBanner(
              title: AppStrings.verificationPending,
              subtitle: AppStrings.rcReadyHint,
            ),
            SizedBox(height: context.h(24)),
            UnifiedButton(
              label: AppStrings.continueAction,
              isLoading: _verifying,
              onPressed: _verify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _extracted(BuildContext context) {
    final details = _details;
    return OnboardingStepScaffold(
      title: AppStrings.verifyVehicleRc,
      subtitle: AppStrings.verifyVehicleRcSubtitle,
      onBack: () => _go(_RcPage.preview),
      onHelp: widget.onHelp,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.w(24),
          context.h(8),
          context.w(24),
          context.h(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KycRequiredLabel(AppStrings.registrationNumber),
            SizedBox(height: context.h(8)),
            AppTextField(controller: _numberController),
            SizedBox(height: context.h(16)),
            KycRequiredLabel(AppStrings.rcDocument),
            SizedBox(height: context.h(8)),
            _UploadedFile(path: _frontPath, onReplace: () => _go(_RcPage.form)),
            SizedBox(height: context.h(16)),
            KycRequiredLabel(AppStrings.vehicleDetails),
            SizedBox(height: context.h(8)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.r(12)),
                border: Border.all(color: context.torkk.border),
              ),
              child: Column(
                children: [
                  if ((details?.registrationNumber ?? _numberController.text)
                      .trim()
                      .isNotEmpty)
                    KycDetailRow(
                      icon: Icons.badge_outlined,
                      label: AppStrings.vehicleNumber,
                      value:
                          (details?.registrationNumber ??
                                  _numberController.text)
                              .trim(),
                    ),
                  if ((details?.model ?? '').isNotEmpty)
                    KycDetailRow(
                      icon: Icons.directions_car_outlined,
                      label: AppStrings.vehicleModel,
                      value: details!.model,
                    ),
                  if ((details?.vehicleType ?? '').isNotEmpty)
                    KycDetailRow(
                      icon: Icons.two_wheeler_outlined,
                      label: AppStrings.vehicleType,
                      value: details!.vehicleType,
                    ),
                ],
              ),
            ),
            SizedBox(height: context.h(14)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.w(12)),
              decoration: BoxDecoration(
                color: context.adaptiveTint(const Color(0xFFF0FDF4)),
                borderRadius: BorderRadius.circular(context.r(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: context.legible(AppColors.green600),
                    size: context.w(16),
                  ),
                  SizedBox(width: context.w(8)),
                  Expanded(
                    child: Text(
                      AppStrings.rcExtractedHint,
                      style: AppTypography.regular.copyWith(
                        fontSize: 12,
                        color: context.legible(AppColors.green600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(24)),
            UnifiedButton(
              label: AppStrings.continueAction,
              onPressed: widget.onFinished,
            ),
          ],
        ),
      ),
    );
  }
}
