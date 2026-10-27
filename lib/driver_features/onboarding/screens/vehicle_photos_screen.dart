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
import 'package:rider_app/common/theme/torkk_colors.dart';

part 'vehicle_photos_screen_parts/camera_action.dart';
part 'vehicle_photos_screen_parts/photo_result_card.dart';
part 'vehicle_photos_screen_parts/type_chip.dart';
part 'vehicle_photos_screen_sections.dart';

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
            KycRequiredLabel(AppStrings.registrationNumber),
            SizedBox(height: context.h(8)),
            AppTextField(controller: _numberController),
            SizedBox(height: context.h(14)),
            KycRequiredLabel(AppStrings.vehicleModel),
            SizedBox(height: context.h(8)),
            AppTextField(controller: _modelController),
            SizedBox(height: context.h(14)),
            KycRequiredLabel(AppStrings.vehicleType),
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
            OnboardingInfoBanner(message: AppStrings.vehicleDocsWillBeVerified),
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
                          color: context.adaptiveTint(const Color(0xFFE2E8F0)),
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
                  OnboardingInfoBanner(message: AppStrings.captureFrontHint),
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

}

