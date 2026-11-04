import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/onboarding/dl_licence_text.dart';
import 'package:rider_app/driver_features/onboarding/rc_plate_text.dart';
import 'package:rider_app/driver_features/onboarding/rc_verification_api.dart';
import 'package:rider_app/driver_features/onboarding/screens/document_validation_screen.dart';
import 'package:rider_app/driver_features/onboarding/widgets/kyc_form_widgets.dart';
import 'package:rider_app/common/widgets/app_text_field.dart';
import 'package:rider_app/common/widgets/onboarding_info_banner.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

part 'verify_vehicle_rc_screen_parts/dashed_border_painter.dart';
part 'verify_vehicle_rc_screen_parts/rc_upload_tile.dart';
part 'verify_vehicle_rc_screen_sections.dart';

enum _RcPage { form, unclear, preview, extracted }

class VerifyVehicleRcScreen extends StatefulWidget {
  const VerifyVehicleRcScreen({
    super.key,
    required this.onBack,
    required this.onHelp,
    required this.onFinished,
  });

  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onFinished;

  @override
  State<VerifyVehicleRcScreen> createState() => _VerifyVehicleRcScreenState();
}

class _VerifyVehicleRcScreenState extends State<VerifyVehicleRcScreen> {
  _RcPage _page = _RcPage.form;
  bool _readingFront = false;
  bool _readingBack = false;
  bool _verifying = false;
  String? _frontPath;
  String? _backPath;
  VehicleRcDetails? _details;
  final _numberController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _go(_RcPage page) => setState(() => _page = page);

  Future<void> _pickSide({required bool front}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.torkk.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(16)),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_camera_outlined,
                  color: context.legible(AppColors.primary),
                ),
                title: Text(
                  AppStrings.camera,
                  style: AppTypography.bold.copyWith(fontSize: 15),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_outlined,
                  color: context.legible(AppColors.primary),
                ),
                title: Text(
                  AppStrings.gallery,
                  style: AppTypography.bold.copyWith(fontSize: 15),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
    if (source == null) return;
    final photo = await ImagePicker().pickImage(
      source: source,
      imageQuality: 90,
    );
    if (photo == null || !mounted) return;
    setState(() {
      if (front) {
        _frontPath = photo.path;
        _readingFront = true;
        _numberController.clear();
      } else {
        _backPath = photo.path;
        _readingBack = true;
      }
    });
    try {
      final text = await readDrivingLicenceText(photo.path);
      final number = parseRegistrationNumber(text);
      if (!mounted) return;
      setState(() {
        if (number != null &&
            (front || _numberController.text.trim().isEmpty)) {
          _numberController.text = number;
        }
        if (_numberController.text.trim().isEmpty) _page = _RcPage.unclear;
      });
    } catch (_) {
      if (!mounted) return;
      if (_numberController.text.trim().isEmpty) {
        setState(() => _page = _RcPage.unclear);
      }
    } finally {
      if (mounted) {
        setState(() {
          _readingFront = false;
          _readingBack = false;
        });
      }
    }
  }

  Future<void> _verify() async {
    final number = parseRegistrationNumber(_numberController.text);
    if (number == null) {
      _go(_RcPage.unclear);
      return;
    }
    setState(() => _verifying = true);
    try {
      final details = await verifyVehicleRc(idNumber: number);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rc_number', details.registrationNumber);
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _details = details;
        _numberController.text = details.registrationNumber;
        _page = _RcPage.extracted;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _page = _RcPage.unclear;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _RcPage.form => _form(context),
      _RcPage.unclear => DocumentValidationScreen(
        title: AppStrings.documentUnclear,
        message: AppStrings.documentUnclearHint,
        onBack: () => _go(_RcPage.form),
        onHelp: widget.onHelp,
        onRetake: () => _go(_RcPage.form),
      ),
      _RcPage.preview => _preview(context),
      _RcPage.extracted => _extracted(context),
    };
  }

  Widget _form(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.verifyVehicleRc,
      subtitle: AppStrings.verifyVehicleRcSubtitle,
      onBack: widget.onBack,
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
            AppTextField(
              controller: _numberController,
              hintText: AppStrings.registrationNumber,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: context.h(16)),
            KycRequiredLabel(AppStrings.rcDocument),
            SizedBox(height: context.h(4)),
            Text(
              AppStrings.rcDocumentHint,
              style: AppTypography.regular.copyWith(
                fontSize: 12,
                color: context.torkk.textSecondary,
              ),
            ),
            SizedBox(height: context.h(10)),
            Row(
              children: [
                Expanded(
                  child: _RcUploadTile(
                    label: AppStrings.frontSide,
                    icon: Icons.description_outlined,
                    imagePath: _frontPath,
                    reading: _readingFront,
                    onTap: () => _pickSide(front: true),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: _RcUploadTile(
                    label: AppStrings.backSide,
                    icon: Icons.badge_outlined,
                    imagePath: _backPath,
                    reading: _readingBack,
                    onTap: () => _pickSide(front: false),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(14)),
            OnboardingInfoBanner(message: AppStrings.rcClearHint),
            SizedBox(height: context.h(24)),
            UnifiedButton(
              label: AppStrings.continueAction,
              enabled:
                  _frontPath != null &&
                  _backPath != null &&
                  _numberController.text.trim().isNotEmpty,
              onPressed: _continueFromForm,
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadedFile extends StatelessWidget {
  const _UploadedFile({required this.onReplace, this.path});

  final String? path;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    final file = path == null ? null : File(path!);
    final name = path == null ? '' : path!.split(Platform.pathSeparator).last;
    final size = file == null || !file.existsSync()
        ? ''
        : _sizeLabel(file.lengthSync());
    return Row(
      children: [
        Container(
          width: context.w(48),
          height: context.w(36),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.torkk.surfaceMuted,
            borderRadius: BorderRadius.circular(context.r(6)),
            border: Border.all(color: context.torkk.border),
          ),
          child: path == null
              ? Icon(
                  Icons.badge_outlined,
                  size: context.w(18),
                  color: AppColors.slate400,
                )
              : Image.file(File(path!), fit: BoxFit.cover),
        ),
        SizedBox(width: context.w(10)),
        Icon(
          Icons.check_circle,
          color: AppColors.green600,
          size: context.w(16),
        ),
        SizedBox(width: context.w(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.rcDocument,
                style: AppTypography.bold.copyWith(fontSize: 13, height: 1.2),
              ),
              if (name.isNotEmpty)
                Text(
                  name,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    color: context.torkk.textSecondary,
                  ),
                ),
              if (size.isNotEmpty)
                Text(
                  '$size • ${AppStrings.rcUploaded}',
                  style: AppTypography.regular.copyWith(
                    fontSize: 11,
                    color: context.torkk.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onReplace,
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                size: context.w(14),
                color: context.legible(AppColors.primary),
              ),
              SizedBox(width: context.w(4)),
              Text(
                AppStrings.replaceAction,
                style: AppTypography.bold.copyWith(
                  fontSize: 13,
                  color: context.legible(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _sizeLabel(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
