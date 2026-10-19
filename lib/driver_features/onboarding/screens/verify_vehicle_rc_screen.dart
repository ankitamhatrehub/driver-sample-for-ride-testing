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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(context.r(16)))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
                title: Text(AppStrings.camera, style: AppTypography.bold.copyWith(fontSize: 15)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_outlined, color: AppColors.primary),
                title: Text(AppStrings.gallery, style: AppTypography.bold.copyWith(fontSize: 15)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
    if (source == null) return;
    final photo = await ImagePicker().pickImage(source: source, imageQuality: 90);
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
        if (number != null && (front || _numberController.text.trim().isEmpty)) {
          _numberController.text = number;
        }
        if (_numberController.text.trim().isEmpty) _page = _RcPage.unclear;
      });
    } catch (_) {
      if (!mounted) return;
      if (_numberController.text.trim().isEmpty) setState(() => _page = _RcPage.unclear);
    } finally {
      if (mounted) {
        setState(() {
          _readingFront = false;
          _readingBack = false;
        });
      }
    }
  }

  void _continueFromForm() {
    if (_frontPath == null || _backPath == null || !isRegistrationNumber(_numberController.text)) {
      _go(_RcPage.unclear);
      return;
    }
    _go(_RcPage.preview);
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
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(8), context.w(24), context.h(16)),
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
              style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.secondaryTextColor),
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
              enabled: _frontPath != null && _backPath != null && _numberController.text.trim().isNotEmpty,
              onPressed: _continueFromForm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.verifyVehicleRc,
      subtitle: AppStrings.verifyVehicleRcSubtitle,
      onBack: () => _go(_RcPage.form),
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
                Expanded(child: KycPreviewCard(imagePath: _frontPath, onRetake: () => _pickSide(front: true))),
                SizedBox(width: context.w(12)),
                Expanded(child: KycPreviewCard(imagePath: _backPath, onRetake: () => _pickSide(front: false))),
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
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(8), context.w(24), context.h(16)),
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
                border: Border.all(color: AppColors.fieldBorder),
              ),
              child: Column(
                children: [
                  if ((details?.registrationNumber ?? _numberController.text).trim().isNotEmpty)
                    KycDetailRow(
                      icon: Icons.badge_outlined,
                      label: AppStrings.vehicleNumber,
                      value: (details?.registrationNumber ?? _numberController.text).trim(),
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
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(context.r(12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.green600, size: context.w(16)),
                  SizedBox(width: context.w(8)),
                  Expanded(
                    child: Text(
                      AppStrings.rcExtractedHint,
                      style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.green600),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(24)),
            UnifiedButton(label: AppStrings.continueAction, onPressed: widget.onFinished),
          ],
        ),
      ),
    );
  }
}

class _RcUploadTile extends StatelessWidget {
  const _RcUploadTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.imagePath,
    this.reading = false,
  });

  final String label;
  final IconData icon;
  final String? imagePath;
  final bool reading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = context.r(16);
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(color: const Color(0xFFD8B4FE), radius: radius),
        child: Container(
          height: context.h(148),
          padding: EdgeInsets.symmetric(horizontal: context.w(8), vertical: context.h(16)),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF5FF),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: reading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : imagePath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: AppColors.primary, size: context.w(28)),
                        SizedBox(height: context.h(10)),
                        Text(label, style: AppTypography.bold.copyWith(fontSize: 13, height: 1.2)),
                        SizedBox(height: context.h(2)),
                        Text(
                          AppStrings.tapToUpload,
                          style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.secondaryTextColor),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(radius - 2),
                      child: Image.file(File(imagePath!), fit: BoxFit.cover, width: double.infinity),
                    ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _UploadedFile extends StatelessWidget {
  const _UploadedFile({required this.onReplace, this.path});

  final String? path;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    final file = path == null ? null : File(path!);
    final name = path == null ? '' : path!.split(Platform.pathSeparator).last;
    final size = file == null || !file.existsSync() ? '' : _sizeLabel(file.lengthSync());
    return Row(
      children: [
        Container(
          width: context.w(48),
          height: context.w(36),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.fieldFill,
            borderRadius: BorderRadius.circular(context.r(6)),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: path == null
              ? Icon(Icons.badge_outlined, size: context.w(18), color: AppColors.slate400)
              : Image.file(File(path!), fit: BoxFit.cover),
        ),
        SizedBox(width: context.w(10)),
        Icon(Icons.check_circle, color: AppColors.green600, size: context.w(16)),
        SizedBox(width: context.w(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.rcDocument, style: AppTypography.bold.copyWith(fontSize: 13, height: 1.2)),
              if (name.isNotEmpty)
                Text(name, style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.secondaryTextColor)),
              if (size.isNotEmpty)
                Text(
                  '$size • ${AppStrings.rcUploaded}',
                  style: AppTypography.regular.copyWith(fontSize: 11, color: AppColors.secondaryTextColor),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onReplace,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: context.w(14), color: AppColors.primary),
              SizedBox(width: context.w(4)),
              Text(AppStrings.replaceAction, style: AppTypography.bold.copyWith(fontSize: 13, color: AppColors.primary)),
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
