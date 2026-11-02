import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/onboarding/widgets/live_face_camera.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

part 'face_verification_screen_parts/check_row.dart';
part 'face_verification_screen_parts/icon_info_row.dart';
part 'face_verification_screen_parts/info_row.dart';
part 'face_verification_screen_parts/spin_ring_painter.dart';
part 'face_verification_screen_parts/success_line.dart';
part 'face_verification_screen_parts/verify_step.dart';
part 'face_verification_screen_parts/verifying_face.dart';
part 'face_verification_screen_parts/verifying_face_state.dart';
part 'face_verification_screen_sections.dart';

enum _FacePage {
  intro,
  beforeStart,
  allowCamera,
  capture,
  verifying,
  verified,
  failed,
}

class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({
    super.key,
    required this.onBack,
    required this.onFinished,
  });

  final VoidCallback onBack;
  final VoidCallback onFinished;

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  _FacePage _page = _FacePage.intro;
  String? _selfiePath;

  void _go(_FacePage page) => setState(() => _page = page);

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _FacePage.intro => _intro(context),
      _FacePage.beforeStart => _before(context),
      _FacePage.allowCamera => _allowCamera(context),
      _FacePage.capture => LiveFaceCamera(
        onCaptured: (file) {
          setState(() => _selfiePath = file.path);
          _go(_FacePage.verifying);
        },
      ),
      _FacePage.verifying => _VerifyingFace(
        selfiePath: _selfiePath,
        onFinished: () => _go(_FacePage.verified),
      ),
      _FacePage.verified => _verified(context),
      _FacePage.failed => _failed(context),
    };
  }

  Widget _intro(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.verifyYourIdentity,
      onBack: widget.onBack,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(24),
          context.h(12),
          context.w(24),
          context.h(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: context.h(50)),
            Image.asset(
              AppAssets.verifyIdentity,
              width: context.w(112),
              height: context.w(136),
              fit: BoxFit.contain,
            ),
            SizedBox(height: context.h(20)),
            Text(
              AppStrings.verifyYourIdentity,
              style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
            ),
            SizedBox(height: context.h(6)),
            Text(
              AppStrings.verifyIdentitySubtitle,
              style: AppTypography.regular.copyWith(
                fontSize: 12,
                color: context.torkk.textSecondary,
              ),
            ),
            SizedBox(height: context.h(40)),
            _InfoRow(
              icon: AppAssets.personCheckIcon,
              text: AppStrings.identityRealPerson,
            ),
            SizedBox(height: context.h(12)),
            _InfoRow(
              icon: AppAssets.documentIcon,
              text: AppStrings.identityRequired,
            ),
            SizedBox(height: context.h(12)),
            _InfoRow(icon: AppAssets.timeIcon, text: AppStrings.identityQuick),
            SizedBox(height: context.h(28)),
            UnifiedButton(
              label: AppStrings.startFaceVerification,
              onPressed: () => setState(() => _page = _FacePage.beforeStart),
            ),
          ],
        ),
      ),
    );
  }

  Widget _before(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.verifyYourIdentity,
      onBack: () => setState(() => _page = _FacePage.intro),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(24),
          context.h(40),
          context.w(24),
          context.h(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.beforeYouStart,
              style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
            ),
            SizedBox(height: context.h(4)),
            Text(
              AppStrings.beforeYouStartSubtitle,
              style: AppTypography.regular.copyWith(
                fontSize: 14,
                color: context.torkk.textSecondary,
              ),
            ),
            SizedBox(height: context.h(24)),
            _CheckRow(
              icon: Icons.center_focus_strong,
              background: const Color(0xFFE7F8F1),
              iconColor: const Color(0xFF10B981),
              text: AppStrings.faceInFrame,
            ),
            _CheckRow(
              icon: Icons.wb_sunny_outlined,
              background: const Color(0xFFFFF6EB),
              iconColor: const Color(0xFFF59E0B),
              text: AppStrings.faceVisible,
            ),
            _CheckRow(
              icon: Icons.do_not_disturb_on_outlined,
              background: const Color(0xFFFFF1F2),
              iconColor: const Color(0xFFEF4444),
              text: AppStrings.removeCoverings,
            ),
            _CheckRow(
              icon: Icons.lightbulb_outline,
              background: const Color(0xFFFFF7ED),
              iconColor: const Color(0xFFF59E0B),
              text: AppStrings.wellLit,
            ),
            const Spacer(),
            UnifiedButton(
              label: AppStrings.continueAction,
              onPressed: () => _go(_FacePage.allowCamera),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StepState { done, active, waiting }
