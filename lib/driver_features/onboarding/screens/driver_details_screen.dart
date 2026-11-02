import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/onboarding/widgets/kyc_form_widgets.dart';
import 'package:rider_app/common/widgets/app_text_field.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Profile details after KYC. Male uses blue, Female switches the accent to pink.
class DriverDetailsScreen extends StatefulWidget {
  const DriverDetailsScreen({
    super.key,
    required this.nameController,
    required this.dobController,
    required this.emailController,
    required this.gender,
    required this.photoPath,
    required this.onGenderChanged,
    required this.onPhotoPicked,
    required this.onBack,
    required this.onContinue,
  });

  final TextEditingController nameController;
  final TextEditingController dobController;
  final TextEditingController emailController;
  final String gender;
  final String? photoPath;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onPhotoPicked;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  State<DriverDetailsScreen> createState() => _DriverDetailsScreenState();
}

class _DriverDetailsScreenState extends State<DriverDetailsScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _showError = false;

  Color get _accent => widget.gender == AppStrings.genderFemale
      ? AppColors.femalePink
      : AppColors.maleBlue;

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo == null) return;
    widget.onPhotoPicked(photo.path);
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(now.year - 80),
      lastDate: DateTime(now.year - 18),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: _accent)),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    widget.dobController.text =
        '${picked.day} ${months[picked.month - 1]} ${picked.year}';
    setState(() => _showError = false);
  }

  void _continue() {
    if (widget.nameController.text.trim().isEmpty ||
        widget.dobController.text.trim().isEmpty) {
      setState(() => _showError = true);
      return;
    }
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.torkk.background,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: context.themed(
                light: Colors.black,
                dark: context.torkk.textPrimary,
              ),
              size: 20,
            ),
            onPressed: widget.onBack,
          ),
          titleSpacing: 0,
          centerTitle: false,
          backgroundColor: context.torkk.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppStrings.driversDetails,
            style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  context.w(24),
                  context.h(8),
                  context.w(24),
                  context.h(16),
                ),
                children: [
                  Center(child: _photo()),
                  SizedBox(height: context.h(8)),
                  Center(
                    child: Text(
                      AppStrings.uploadClearPhoto,
                      style: AppTypography.regular.copyWith(
                        fontSize: 13,
                        color: context.torkk.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(22)),
                  KycRequiredLabel(AppStrings.fullName),
                  SizedBox(height: context.h(8)),
                  AppTextField(
                    controller: widget.nameController,
                    onChanged: (_) {
                      if (_showError) setState(() => _showError = false);
                    },
                  ),
                  SizedBox(height: context.h(16)),
                  KycRequiredLabel(AppStrings.gender),
                  SizedBox(height: context.h(8)),
                  Row(
                    children: [
                      _chip(AppStrings.genderMale),
                      SizedBox(width: context.w(8)),
                      _chip(AppStrings.genderFemale),
                      SizedBox(width: context.w(8)),
                      _chip(AppStrings.genderOther),
                    ],
                  ),
                  SizedBox(height: context.h(16)),
                  KycRequiredLabel(AppStrings.dateOfBirth),
                  SizedBox(height: context.h(8)),
                  _dobField(),
                  SizedBox(height: context.h(16)),
                  Text(
                    AppStrings.emailOptional,
                    style: AppTypography.regular.copyWith(
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: context.h(8)),
                  AppTextField(
                    controller: widget.emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (_showError) ...[
                    SizedBox(height: context.h(12)),
                    Text(
                      AppStrings.driverDetailsRequired,
                      style: AppTypography.regular.copyWith(
                        fontSize: 13,
                        color: context.legible(AppColors.error),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(24),
                context.h(8),
                context.w(24),
                context.h(16),
              ),
              child: UnifiedButton(
                label: AppStrings.continueToFinalReview,
                backgroundColor: _accent,
                onPressed: _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photo() {
    final path = widget.photoPath;
    return GestureDetector(
      onTap: _pickPhoto,
      child: SizedBox(
        width: context.w(96),
        height: context.w(96),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: context.w(88),
              height: context.w(88),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.12),
                image: path == null
                    ? null
                    : DecorationImage(
                        image: FileImage(File(path)),
                        fit: BoxFit.cover,
                      ),
              ),
              child: path == null
                  ? Icon(
                      Icons.person,
                      size: context.w(40),
                      color: _accent.withValues(alpha: 0.7),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: context.h(6),
              child: Container(
                width: context.w(28),
                height: context.w(28),
                decoration: BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.photo_camera,
                  color: Colors.white,
                  size: context.w(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    final selected = widget.gender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onGenderChanged(label),
        child: Container(
          height: context.h(44),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _accent : context.torkk.surface,
            borderRadius: BorderRadius.circular(context.r(12)),
            border: Border.all(
              color: selected ? _accent : AppColors.fieldBorder,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.bold.copyWith(
              fontSize: 14,
              color: selected ? Colors.white : context.torkk.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dobField() {
    return GestureDetector(
      onTap: _pickDob,
      child: Container(
        height: context.h(48),
        padding: EdgeInsets.symmetric(horizontal: context.w(16)),
        decoration: BoxDecoration(
          color: context.torkk.surfaceMuted,
          borderRadius: BorderRadius.circular(context.r(12)),
          border: Border.all(color: context.torkk.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.dobController.text,
                style: AppTypography.regular.copyWith(
                  fontSize: 14,
                  color: widget.dobController.text.isEmpty
                      ? AppColors.slate400
                      : context.torkk.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: context.w(18),
              color: AppColors.slate400,
            ),
          ],
        ),
      ),
    );
  }
}
