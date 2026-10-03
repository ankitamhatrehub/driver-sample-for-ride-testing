import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/onboarding/widgets/kyc_form_widgets.dart';
import 'package:rider_app/common/widgets/app_text_field.dart';
import 'package:rider_app/common/widgets/onboarding_info_banner.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

enum _PhotoPage { details, camera, preview, wrong, action, verified }

class VehiclePhotosScreen extends StatefulWidget {
  const VehiclePhotosScreen({
    super.key,
    required this.onBack,
    required this.onHelp,
    required this.onFinished,
  });

  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onFinished;

  @override
  State<VehiclePhotosScreen> createState() => _VehiclePhotosScreenState();
}

class _VehiclePhotosScreenState extends State<VehiclePhotosScreen> {
  _PhotoPage _page = _PhotoPage.details;
  bool _front = false;
  bool _back = false;
  bool _flipped = false;
  int _shots = 0;
  String _type = '';
  final _numberController = TextEditingController();
  final _modelController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _go(_PhotoPage page) => setState(() => _page = page);

  void _capture() {
    setState(() => _shots += 1);
    if (_shots == 1) {
      _go(_PhotoPage.preview);
    } else if (_shots == 2) {
      _go(_PhotoPage.wrong);
    } else if (_shots == 3) {
      _go(_PhotoPage.action);
    } else {
      _go(_PhotoPage.verified);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _PhotoPage.details => _details(context),
      _PhotoPage.camera => _camera(context),
      _PhotoPage.preview => _preview(context),
      _PhotoPage.wrong => _wrong(context),
      _PhotoPage.action => _action(context),
      _PhotoPage.verified => _verified(context),
    };
  }

  Widget _details(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.vehicleDetails,
      onBack: widget.onBack,
      onHelp: widget.onHelp,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(8), context.w(24), context.h(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.uploadVehiclePhoto, style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2)),
            SizedBox(height: context.h(10)),
            Row(
              children: [
                Expanded(
                  child: KycUploadTile(
                    label: AppStrings.frontSide,
                    uploaded: _front,
                    onTap: () => setState(() => _front = true),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: KycUploadTile(
                    label: AppStrings.backSide,
                    uploaded: _back,
                    onTap: () => setState(() => _back = true),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(16)),
            const KycRequiredLabel(AppStrings.registrationNumber),
            SizedBox(height: context.h(8)),
            AppTextField(controller: _numberController),
            SizedBox(height: context.h(14)),
            const KycRequiredLabel(AppStrings.vehicleModel),
            SizedBox(height: context.h(8)),
            AppTextField(controller: _modelController),
            SizedBox(height: context.h(14)),
            const KycRequiredLabel(AppStrings.vehicleType),
            SizedBox(height: context.h(8)),
            Row(
              children: [
                for (final type in ['Cab', 'Auto', 'Car']) ...[
                  _TypeChip(
                    label: type,
                    selected: _type == type,
                    onTap: () => setState(() => _type = type),
                  ),
                  SizedBox(width: context.w(8)),
                ],
              ],
            ),
            SizedBox(height: context.h(14)),
            const OnboardingInfoBanner(message: AppStrings.vehicleDocsWillBeVerified),
            SizedBox(height: context.h(24)),
            UnifiedButton(
              label: AppStrings.continueAction,
              enabled: _front && _back,
              onPressed: () => _go(_PhotoPage.camera),
            ),
          ],
        ),
      ),
    );
  }

  Widget _camera(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.vehiclePhotos,
      subtitle: AppStrings.vehiclePhotosSubtitle,
      onBack: () => _go(_PhotoPage.details),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(24)),
              child: Column(
                children: [
                  Expanded(
                    child: Transform.flip(
                      flipX: _flipped,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(context.r(12)),
                          image: const DecorationImage(
                            image: AssetImage(AppAssets.cab),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(12)),
                  const OnboardingInfoBanner(message: AppStrings.captureFrontHint),
                  SizedBox(height: context.h(12)),
                ],
              ),
            ),
          ),
          Container(
            color: const Color(0xFF4B5563),
            padding: EdgeInsets.fromLTRB(context.w(28), context.h(16), context.w(28), context.h(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CameraAction(icon: Icons.photo_outlined, label: AppStrings.gallery, onTap: _capture),
                GestureDetector(
                  onTap: _capture,
                  child: Container(
                    width: context.w(64),
                    height: context.w(64),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: context.w(48),
                      height: context.w(48),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                    ),
                  ),
                ),
                _CameraAction(
                  icon: Icons.flip_camera_ios_outlined,
                  label: AppStrings.flip,
                  onTap: () => setState(() => _flipped = !_flipped),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            const OnboardingInfoBanner(message: AppStrings.captureFrontHint),
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
            Icon(Icons.cancel, color: AppColors.error, size: context.w(28)),
            SizedBox(height: context.h(16)),
            Text(AppStrings.wrongImageUploaded, style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2)),
            SizedBox(height: context.h(6)),
            Text(
              AppStrings.wrongImageHint,
              style: AppTypography.regular.copyWith(color: AppColors.secondaryTextColor, fontSize: 13),
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
              backgroundColor: failedBack ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
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
              style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.secondaryTextColor),
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

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(18), vertical: context.h(10)),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(context.r(20)),
          border: Border.all(color: selected ? AppColors.primary : AppColors.fieldBorder),
        ),
        child: Text(
          label,
          style: AppTypography.bold.copyWith(
            fontSize: 13,
            height: 1.2,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _CameraAction extends StatelessWidget {
  const _CameraAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: context.w(22)),
          SizedBox(height: context.h(4)),
          Text(label, style: AppTypography.regular.copyWith(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }
}

class _PhotoResultCard extends StatelessWidget {
  const _PhotoResultCard({required this.label, required this.failed, this.onRetake});

  final String label;
  final bool failed;
  final VoidCallback? onRetake;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(8)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                failed ? Icons.error : Icons.check_circle,
                size: context.w(14),
                color: failed ? AppColors.error : AppColors.green600,
              ),
              SizedBox(width: context.w(4)),
              Expanded(
                child: Text(label, style: AppTypography.bold.copyWith(fontSize: 11, height: 1.2)),
              ),
            ],
          ),
          Text(
            failed ? AppStrings.verificationFailedLabel : AppStrings.kycVerified,
            style: AppTypography.regular.copyWith(
              fontSize: 10,
              color: failed ? AppColors.error : AppColors.green600,
            ),
          ),
          SizedBox(height: context.h(6)),
          ClipRRect(
            borderRadius: BorderRadius.circular(context.r(8)),
            child: Image.asset(AppAssets.cab, height: context.h(72), width: double.infinity, fit: BoxFit.cover),
          ),
          if (onRetake != null) ...[
            SizedBox(height: context.h(6)),
            GestureDetector(
              onTap: onRetake,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: context.w(14), color: AppColors.primary),
                  SizedBox(width: context.w(4)),
                  Text(AppStrings.retake, style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
