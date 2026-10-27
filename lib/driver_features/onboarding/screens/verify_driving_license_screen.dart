import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/onboarding/dl_licence_text.dart';
import 'package:rider_app/driver_features/onboarding/dl_verification_api.dart';
import 'package:rider_app/driver_features/onboarding/screens/document_validation_screen.dart';
import 'package:rider_app/common/widgets/app_text_field.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

enum _DlPage { choose, digilockerVerified, manualForm, unclear, manualVerified, rejected }

/// Driving licence step. The screens live here, not in the old onboarding controller.
class VerifyDrivingLicenseScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onFinished;

  const VerifyDrivingLicenseScreen({
    super.key,
    required this.onBack,
    required this.onHelp,
    required this.onFinished,
  });

  @override
  State<VerifyDrivingLicenseScreen> createState() => _VerifyDrivingLicenseScreenState();
}

class _VerifyDrivingLicenseScreenState extends State<VerifyDrivingLicenseScreen> {
  _DlPage _page = _DlPage.choose;
  bool _useDigilocker = false;
  bool _frontUploaded = false;
  bool _backUploaded = false;
  bool _readingFront = false;
  bool _readingBack = false;
  bool _verifying = false;
  String? _frontPath;
  String? _backPath;
  final _licenseController = TextEditingController();
  final _dobController = TextEditingController();
  final _expiryController = TextEditingController();

  @override
  void dispose() {
    _licenseController.dispose();
    _dobController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  /// Debug trace for the DL flow. Numbers are masked so logs carry no full ID.
  static String _mask(String v) =>
      v.length <= 4 ? '***' : '${v.substring(0, 2)}***${v.substring(v.length - 2)}';

  void _log(String message) => debugPrint('[DL] $message');

  void _go(_DlPage page) {
    _log('page: ${_page.name} -> ${page.name}');
    setState(() => _page = page);
  }

  Future<void> _pickLicenceSide({required bool front}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.torkk.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(context.r(16)))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera_outlined, color: context.legible(AppColors.primary)),
                title: Text(AppStrings.camera, style: AppTypography.bold.copyWith(fontSize: 15)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_outlined, color: context.legible(AppColors.primary)),
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
      _useDigilocker = false;
      if (front) {
        _frontPath = photo.path;
        _frontUploaded = true;
        _readingFront = true;
        _licenseController.clear();
        _dobController.clear();
        _expiryController.clear();
      } else {
        _backPath = photo.path;
        _backUploaded = true;
        _readingBack = true;
      }
    });
    try {
      final text = await readDrivingLicenceText(photo.path);
      final fields = parseDrivingLicenceText(text);
      if (!mounted) return;
      setState(() {
        if (fields.licenseNumber.isNotEmpty && (front || _licenseController.text.trim().isEmpty)) {
          _licenseController.text = fields.licenseNumber;
        }
        if (fields.dob.isNotEmpty && (front || _dobController.text.trim().isEmpty)) {
          _dobController.text = fields.dob;
        }
        if (_licenseController.text.trim().isNotEmpty || _dobController.text.trim().isNotEmpty) {
          _page = _DlPage.manualForm;
        } else {
          _page = _DlPage.unclear;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _page = _DlPage.unclear);
    } finally {
      if (mounted) {
        setState(() {
          _readingFront = false;
          _readingBack = false;
        });
      }
    }
  }

  Future<void> _verifyReadLicence() async {
    print('Verifying read licence: _licenseController=${_licenseController.text}, _dobController=${_dobController.text}');
    final idNumber = _licenseController.text.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final dob = normalizeDob(_dobController.text);
    print('Normalized values: idNumber=${_mask(idNumber)}, dob=$dob');
    if (!RegExp(r'^[A-Z]{2}\d{13}$').hasMatch(idNumber) || dob == null) {
      _go(_DlPage.rejected);
      return;
    }
    setState(() => _verifying = true);
    try {
      final details = await verifyDrivingLicence(idNumber: idNumber, dob: dob);
      print('Verification successful: name=${details.name}, licenseNumber=${_mask(details.licenseNumber)}, dob=${details.dob}, vehicleClass=${details.vehicleClass}, validity=${details.validity}');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('driving_licence_number', details.licenseNumber);
      if (!mounted) return;
      setState(() {
        _verifying = false;
        if (details.validity.isNotEmpty) _expiryController.text = details.validity;
        _page = _DlPage.manualVerified;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _page = _DlPage.rejected;
      });
    }
  }

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    setState(() {
      _expiryController.text = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _DlPage.choose => _choose(context),
      _DlPage.digilockerVerified => _digilockerVerified(context),
      _DlPage.manualForm => _manualForm(context),
      _DlPage.unclear => DocumentValidationScreen(
          title: AppStrings.documentUnclear,
          message: AppStrings.documentUnclearHint,
          onBack: () => _go(_DlPage.choose),
          onHelp: widget.onHelp,
          onRetake: () => _go(_DlPage.choose),
        ),
      _DlPage.manualVerified => _verified(context),
      _DlPage.rejected => _rejected(context),
    };
  }

  Widget _choose(BuildContext context) {
    print('Choose page: _useDigilocker=$_useDigilocker, _frontUploaded=$_frontUploaded, _backUploaded=$_backUploaded');
    return OnboardingStepScaffold(
      title: AppStrings.verifyDrivingLicence,
      subtitle: AppStrings.verifyDrivingLicenceSubtitle,
      onBack: widget.onBack,
      onHelp: widget.onHelp,
      body: Padding(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(8), context.w(24), context.h(16)),
        child: Column(
          children: [
            _DigilockerCard(
              selected: _useDigilocker,
              onTap: () => setState(() => _useDigilocker = true),
            ),
            SizedBox(height: context.h(16)),
            Text(
              AppStrings.orWord,
              style: AppTypography.regular.copyWith(color: context.torkk.textSecondary, fontSize: 12),
            ),
            SizedBox(height: context.h(16)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.uploadDrivingLicense,
                style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2),
              ),
            ),
            SizedBox(height: context.h(12)),
            Row(
              children: [
                Expanded(
                  child: _UploadTile(
                    label: AppStrings.frontSide,
                    icon: Icons.description_outlined,
                    imagePath: _frontPath,
                    reading: _readingFront,
                    onTap: () => _pickLicenceSide(front: true),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: _UploadTile(
                    label: AppStrings.backSide,
                    icon: Icons.badge_outlined,
                    imagePath: _backPath,
                    reading: _readingBack,
                    onTap: () => _pickLicenceSide(front: false),
                  ),
                ),
              ],
            ),
            const Spacer(),
            UnifiedButton(
              label: AppStrings.continueAction,
              enabled: _useDigilocker || (_frontUploaded && _backUploaded),
              onPressed: () {
                print('Continue pressed: _useDigilocker=$_useDigilocker, _frontUploaded=$_frontUploaded, _backUploaded=$_backUploaded');
                if (_useDigilocker) {
                  print('Using Digilocker for verification');
                  _go(_DlPage.digilockerVerified);
                } else if (_frontUploaded && _backUploaded) {
                 print('Proceeding to manual form for verification');
                  _go(_DlPage.manualForm);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

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
            Text('${AppStrings.expiryDate} *', style: AppTypography.regular.copyWith(fontSize: 13)),
            SizedBox(height: context.h(8)),
            Stack(
              alignment: Alignment.centerRight,
              children: [
                AppTextField(controller: _expiryController, hintText: AppStrings.expiryDate),
                IconButton(
                  onPressed: _pickExpiry,
                  icon: Icon(Icons.calendar_today_outlined, size: context.w(18), color: context.torkk.textSecondary),
                ),
              ],
            ),
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

class _DigilockerCard extends StatelessWidget {
  const _DigilockerCard({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(context.w(14)),
        decoration: BoxDecoration(
          color: context.adaptiveTint(const Color(0xFFF6F3FB)),
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(color: selected ? AppColors.primary : AppColors.fieldBorder, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: context.w(40),
              height: context.w(40),
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Icon(Icons.cloud_upload_outlined, color: Colors.white, size: context.w(22)),
            ),
            SizedBox(width: context.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.verifyWithDigilocker,
                    style: AppTypography.bold.copyWith(color: context.torkk.textPrimary, fontSize: 14, height: 1.2),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    AppStrings.verifyWithDigilockerSubtitle,
                    style: AppTypography.regular.copyWith(
                      fontSize: 12,
                      height: 1.3,
                      color: context.torkk.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.legible(AppColors.primary), size: context.w(20)),
          ],
        ),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
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
            color: context.adaptiveTint(const Color(0xFFFAF5FF)),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: reading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : imagePath == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: context.legible(AppColors.primary), size: context.w(28)),
                    SizedBox(height: context.h(10)),
                    Text(label, style: AppTypography.bold.copyWith(color: context.torkk.textPrimary, fontSize: 13, height: 1.2)),
                    SizedBox(height: context.h(2)),
                    Text(
                      AppStrings.tapToUpload,
                      style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary),
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
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
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

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.onRetake, this.imagePath});

  final String? imagePath;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: context.h(80),
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.torkk.surfaceMuted,
            borderRadius: BorderRadius.circular(context.r(12)),
            border: Border.all(color: context.torkk.border),
          ),
          child: imagePath == null
              ? Icon(Icons.badge_outlined, color: AppColors.slate300, size: context.w(32))
              : Image.file(File(imagePath!), fit: BoxFit.cover),
        ),
        TextButton.icon(
          onPressed: onRetake,
          icon: Icon(Icons.refresh, size: context.w(16), color: context.legible(AppColors.primary)),
          label: Text(AppStrings.retake, style: AppTypography.regular.copyWith(color: context.legible(AppColors.primary), fontSize: 13)),
        ),
      ],
    );
  }
}

class _LicenceSketch extends StatelessWidget {
  const _LicenceSketch({required this.badgeIcon, required this.badgeColor});

  final IconData badgeIcon;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.w(168),
      height: context.w(120),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: context.w(150),
            height: context.w(100),
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              color: context.adaptiveTint(const Color(0xFFF3F0FF)),
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: const Color(0xFFE4DDF3)),
            ),
            child: Row(
              children: [
                Container(
                  width: context.w(36),
                  height: context.w(36),
                  decoration: const BoxDecoration(color: Color(0xFFE7E0F4), shape: BoxShape.circle),
                  child: Icon(Icons.person, color: const Color(0xFFB7A8D6), size: context.w(22)),
                ),
                SizedBox(width: context.w(10)),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _line(context, 1),
                      SizedBox(height: context.h(6)),
                      _line(context, 0.72),
                      SizedBox(height: context.h(6)),
                      _line(context, 0.5),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: context.w(28),
              height: context.w(28),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(badgeIcon, color: Colors.white, size: context.w(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, double widthFactor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: context.h(6),
          decoration: BoxDecoration(color: const Color(0xFFE4DDF3), borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
