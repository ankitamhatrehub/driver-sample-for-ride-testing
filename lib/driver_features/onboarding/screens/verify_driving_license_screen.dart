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
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/document_validation_screen.dart';
import 'package:rider_app/common/widgets/app_text_field.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

part 'verify_driving_license/dashed_border_painter.dart';
part 'verify_driving_license/digilocker_card.dart';
part 'verify_driving_license/licence_sketch.dart';
part 'verify_driving_license/preview_tile.dart';
part 'verify_driving_license/upload_tile.dart';
part 'verify_driving_license_screen_pages.dart';

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
    final prefs = await SharedPreferences.getInstance();
    // Same phone the driver logged in with (saved after OTP verify).
    final savedPhone = prefs.getString('user_phone') ?? '';
    final phone = (savedPhone.isNotEmpty ? savedPhone : OnboardingSession.instance.phone.text)
        .replaceAll(' ', '')
        .replaceAll('-', '');
    if (idNumber.isEmpty || phone.isEmpty) {
      _go(_DlPage.rejected);
      return;
    }
    setState(() => _verifying = true);
    try {
      final details = await verifyDrivingLicence(idNumber: idNumber, phone: phone);
      print('Verification successful: name=${details.name}, licenseNumber=${_mask(details.licenseNumber)}, dob=${details.dob}, vehicleClass=${details.vehicleClass}, validity=${details.validity}');
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

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 16, now.month, now.day),
    );
    if (picked == null) return;
    final dd = picked.day.toString().padLeft(2, '0');
    final mm = picked.month.toString().padLeft(2, '0');
    setState(() => _dobController.text = '$dd-$mm-${picked.year}');
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
            // _DigilockerCard(
            //   selected: _useDigilocker,
            //   onTap: () => setState(() => _useDigilocker = true),
            // ),
            // SizedBox(height: context.h(16)),
            // Text(
            //   AppStrings.orWord,
            //   style: AppTypography.regular.copyWith(color: context.torkk.textSecondary, fontSize: 12),
            // ),
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

}

