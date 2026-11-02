import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/onboarding/dl_licence_text.dart';
import 'package:rider_app/common/widgets/app_text_field.dart';
import 'package:rider_app/common/widgets/onboarding_info_banner.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class AadhaarManualScreen extends StatefulWidget {
  const AadhaarManualScreen({
    super.key,
    required this.aadhaarController,
    required this.isLoading,
    required this.onBack,
    required this.onVerify,
  });

  final TextEditingController aadhaarController;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onVerify;

  @override
  State<AadhaarManualScreen> createState() => _AadhaarManualScreenState();
}

class _AadhaarManualScreenState extends State<AadhaarManualScreen> {
  String? _frontPath;
  String? _backPath;
  bool _reading = false;

  bool get _ready =>
      _frontPath != null &&
      _backPath != null &&
      widget.aadhaarController.text.trim().length == 12;

  Future<void> _pick({required bool front}) async {
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
      _reading = true;
      if (front) {
        _frontPath = photo.path;
        widget.aadhaarController.clear();
      } else {
        _backPath = photo.path;
      }
    });
    try {
      final text = await readDrivingLicenceText(photo.path);
      final match = RegExp(r'\d{4}\s?\d{4}\s?\d{4}').firstMatch(text);
      final number = match?.group(0)?.replaceAll(RegExp(r'\s'), '') ?? '';
      if (!mounted) return;
      if (number.length == 12 &&
          (front || widget.aadhaarController.text.isEmpty)) {
        widget.aadhaarController.text = number;
      }
    } catch (_) {
      // The photo stays. The driver can type the number.
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.aadhaarVerification,
      onBack: widget.onBack,
      body: Padding(
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
              AppStrings.uploadYourAadhaar,
              style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2),
            ),
            SizedBox(height: context.h(10)),
            Row(
              children: [
                Expanded(
                  child: _SideTile(
                    label: AppStrings.frontSide,
                    icon: Icons.description_outlined,
                    path: _frontPath,
                    reading:
                        _reading && _frontPath != null && _backPath == null,
                    onTap: () => _pick(front: true),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: _SideTile(
                    label: AppStrings.backSide,
                    icon: Icons.badge_outlined,
                    path: _backPath,
                    reading: false,
                    onTap: () => _pick(front: false),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(18)),
            Text(
              '${AppStrings.aadhaarCardNumber} *',
              style: AppTypography.regular.copyWith(fontSize: 13),
            ),
            SizedBox(height: context.h(8)),
            AppTextField(
              controller: widget.aadhaarController,
              hintText: AppStrings.aadhaarCardNumber,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 12,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: context.h(12)),
            OnboardingInfoBanner(message: AppStrings.aadhaarGovHint),
            const Spacer(),
            UnifiedButton(
              label: AppStrings.verifyAadhaar,
              enabled: _ready,
              isLoading: widget.isLoading,
              onPressed: widget.onVerify,
            ),
          ],
        ),
      ),
    );
  }
}

class _SideTile extends StatelessWidget {
  const _SideTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.path,
    this.reading = false,
  });

  final String label;
  final IconData icon;
  final String? path;
  final bool reading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = context.r(16);
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashPainter(radius: radius),
        child: Container(
          height: context.h(132),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.adaptiveTint(const Color(0xFFFAF5FF)),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: reading
              ? const CircularProgressIndicator(color: AppColors.primary)
              : path == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: context.legible(AppColors.primary),
                      size: context.w(28),
                    ),
                    SizedBox(height: context.h(8)),
                    Text(
                      label,
                      style: AppTypography.bold.copyWith(
                        color: context.torkk.textPrimary,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      AppStrings.tapToUpload,
                      style: AppTypography.regular.copyWith(
                        fontSize: 12,
                        color: context.torkk.textSecondary,
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(radius - 2),
                  child: Image.file(
                    File(path!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD8B4FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
