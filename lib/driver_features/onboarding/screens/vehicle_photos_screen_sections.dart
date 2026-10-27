part of 'package:rider_app/driver_features/onboarding/screens/vehicle_photos_screen.dart';

extension _VehiclePhotosScreenStateSections on _VehiclePhotosScreenState {
  Widget _preview(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.vehiclePhotos,
      subtitle: AppStrings.vehiclePhotosSubtitle,
      onBack: () => _go(_PhotoPage.camera),
      body: Padding(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(8), context.w(24), context.h(16)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.r(12)),
                child: Image.asset(AppAssets.cab, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: context.h(12)),
            OnboardingInfoBanner(message: AppStrings.captureFrontHint),
            SizedBox(height: context.h(16)),
            UnifiedButton(label: AppStrings.retake, onPressed: () => _go(_PhotoPage.camera)),
          ],
        ),
      ),
    );
  }

  Widget _wrong(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.vehiclePhotos,
      subtitle: AppStrings.vehiclePhotosSubtitle,
      onBack: () => _go(_PhotoPage.camera),
      body: Padding(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(24), context.w(24), context.h(16)),
        child: Column(
          children: [
            SizedBox(height: context.h(40)),
            Icon(Icons.crop_original, size: context.w(88), color: AppColors.slate300),
            Icon(Icons.cancel, color: context.legible(AppColors.error), size: context.w(28)),
            SizedBox(height: context.h(16)),
            Text(AppStrings.wrongImageUploaded, style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2)),
            SizedBox(height: context.h(6)),
            Text(
              AppStrings.wrongImageHint,
              style: AppTypography.regular.copyWith(color: context.torkk.textSecondary, fontSize: 13),
            ),
            const Spacer(),
            UnifiedButton(label: AppStrings.retake, onPressed: () => _go(_PhotoPage.camera)),
          ],
        ),
      ),
    );
  }

  Widget _verified(BuildContext context) {
    return _result(
      context,
      title: AppStrings.vehiclePhotosVerified,
      subtitle: AppStrings.vehiclePhotosVerifiedSubtitle,
      failedBack: false,
      onBack: () => _go(_PhotoPage.camera),
      onContinue: widget.onFinished,
    );
  }

  Widget _action(BuildContext context) {
    return _result(
      context,
      title: AppStrings.actionRequiredPhotos,
      subtitle: AppStrings.actionRequiredPhotosHint,
      failedBack: true,
      onBack: () => _go(_PhotoPage.camera),
      onContinue: () => _go(_PhotoPage.camera),
    );
  }

  Widget _result(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool failedBack,
    required VoidCallback onBack,
    required VoidCallback onContinue,
  }) {
    return OnboardingStepScaffold(
      title: AppStrings.vehiclePhotos,
      onBack: onBack,
      body: Padding(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(12), context.w(24), context.h(16)),
        child: Column(
          children: [
            CircleAvatar(
              radius: context.w(28),
              backgroundColor: failedBack ? context.adaptiveTint(Color(0xFFFEE2E2)) : context.adaptiveTint(Color(0xFFD1FAE5)),
              child: Icon(
                Icons.directions_car_outlined,
                color: failedBack ? AppColors.error : AppColors.primary,
              ),
            ),
            SizedBox(height: context.h(12)),
            Text(title, textAlign: TextAlign.center, style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2)),
            SizedBox(height: context.h(6)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary),
            ),
            SizedBox(height: context.h(16)),
            Row(
              children: [
                Expanded(
                  child: _PhotoResultCard(label: AppStrings.frontPhoto, failed: false),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: _PhotoResultCard(
                    label: AppStrings.backPhoto,
                    failed: failedBack,
                    onRetake: failedBack ? () => _go(_PhotoPage.camera) : null,
                  ),
                ),
              ],
            ),
            const Spacer(),
            UnifiedButton(label: AppStrings.continueAction, onPressed: onContinue),
          ],
        ),
      ),
    );
  }
}
