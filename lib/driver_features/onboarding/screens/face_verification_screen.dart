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
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(12), context.w(24), context.h(16)),
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
            Text(AppStrings.verifyYourIdentity, style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2)),
            SizedBox(height: context.h(6)),
            Text(
              AppStrings.verifyIdentitySubtitle,
              style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.secondaryTextColor),
            ),
            SizedBox(height: context.h(40)),
            _InfoRow(icon: AppAssets.personCheckIcon, text: AppStrings.identityRealPerson),
            SizedBox(height: context.h(12)),
            _InfoRow(icon: AppAssets.documentIcon, text: AppStrings.identityRequired),
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
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(40), context.w(24), context.h(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.beforeYouStart, style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2)),
            SizedBox(height: context.h(4)),
            Text(
              AppStrings.beforeYouStartSubtitle,
              style: AppTypography.regular.copyWith(fontSize: 14, color: AppColors.secondaryTextColor),
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

  Widget _allowCamera(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.verifyYourIdentity,
      onBack: () => _go(_FacePage.beforeStart),
      body: Padding(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(50), context.w(24), context.h(16)),
        child: Column(
          children: [
            CircleAvatar(
              radius: context.w(45),
              backgroundColor: const Color(0xFFEDE7F6),
              child: Icon(Icons.photo_camera_outlined, color: AppColors.primary, size: context.w(32)),
            ),
            SizedBox(height: context.h(20)),
            Text(AppStrings.allowCameraAccess, style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2)),
            SizedBox(height: context.h(6)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(24)),
              child: Text(
                AppStrings.allowCameraSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.regular.copyWith(fontSize: 12, height: 1.4, color: AppColors.secondaryTextColor),
              ),
            ),
            SizedBox(height: context.h(28)),
            const _IconInfoRow(icon: Icons.shield_outlined, text: AppStrings.dataSafeSecure),
            SizedBox(height: context.h(12)),
            const _IconInfoRow(icon: Icons.lock_outline, text: AppStrings.usedOnlyForIdentity),
            SizedBox(height: context.h(12)),
            const _IconInfoRow(icon: Icons.visibility_off_outlined, text: AppStrings.photoNotStored),
            SizedBox(height: context.h(60)),
            UnifiedButton(
              label: AppStrings.allowCameraAccess,
              onPressed: () => _go(_FacePage.capture),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verified(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.w(28), context.h(48), context.w(28), context.h(16)),
          child: Column(
            children: [
              Image.asset(
                AppAssets.verifiedIcon,
                width: context.w(96),
                height: context.w(96),
              ),
              SizedBox(height: context.h(16)),
              Text(AppStrings.identityVerifiedFace, style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2)),
              SizedBox(height: context.h(6)),
              Text(
                AppStrings.identityVerifiedFaceSubtitle,
                style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.secondaryTextColor),
              ),
              SizedBox(height: context.h(50)),
              const _SuccessLine(AppStrings.identityConfirmed),
              const _SuccessLine(AppStrings.accountSecured),
              const _SuccessLine(AppStrings.completeOnboardingNow),
              const Spacer(),
              UnifiedButton(label: AppStrings.continueAction, onPressed: widget.onFinished),
            ],
          ),
        ),
      ),
    );
  }

  Widget _failed(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.w(24), context.h(48), context.w(24), context.h(16)),
          child: Column(
            children: [
              Image.asset(
                AppAssets.failedIcon,
                width: context.w(96),
                height: context.w(96),
              ),
              SizedBox(height: context.h(16)),
              Text(AppStrings.faceVerificationFailed, style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2)),
              SizedBox(height: context.h(8)),
              Text(
                AppStrings.faceVerificationFailedSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.regular.copyWith(fontSize: 14, height: 1.4, color: AppColors.secondaryTextColor),
              ),
              SizedBox(height: context.h(20)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.w(14)),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(context.r(12)),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.reason, style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2)),
                    SizedBox(height: context.h(8)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.cancel, color: AppColors.error, size: context.w(16)),
                        SizedBox(width: context.w(8)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.faceNotDetectedReason,
                                style: AppTypography.bold.copyWith(fontSize: 13, height: 1.3, color: AppColors.error),
                              ),
                              Text(
                                AppStrings.faceNotDetectedHint,
                                style: AppTypography.regular.copyWith(fontSize: 13, height: 1.35, color: AppColors.error),
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
              UnifiedButton(
                label: AppStrings.tryAgain,
                onPressed: () => _go(_FacePage.capture),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w(333),
      height: context.h(58),
      padding: EdgeInsets.symmetric(horizontal: context.w(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(32),
            height: context.w(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF5FF),
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
            child: Image.asset(icon, width: context.w(18), height: context.w(18), fit: BoxFit.contain),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.regular.copyWith(fontSize: 13, height: 1.2, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(18)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: context.w(34),
            height: context.w(34),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: Icon(icon, color: iconColor, size: context.w(18)),
          ),
          SizedBox(width: context.w(14)),
          Expanded(
            child: Text(
              text,
              style: AppTypography.regular.copyWith(
                fontSize: 14,
                height: 1.35,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconInfoRow extends StatelessWidget {
  const _IconInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: context.h(58),
      padding: EdgeInsets.symmetric(horizontal: context.w(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(32),
            height: context.w(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF5FF),
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
            child: Icon(icon, color: AppColors.primary, size: context.w(16)),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Text(
              text,
              style: AppTypography.regular.copyWith(fontSize: 13, height: 1.2, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepState { done, active, waiting }

class _VerifyingFace extends StatefulWidget {
  const _VerifyingFace({required this.selfiePath, required this.onFinished});

  final String? selfiePath;
  final VoidCallback onFinished;

  @override
  State<_VerifyingFace> createState() => _VerifyingFaceState();
}

class _VerifyingFaceState extends State<_VerifyingFace> with SingleTickerProviderStateMixin {
  static const _labels = [
    AppStrings.photoCaptured,
    AppStrings.analyzingFace,
    AppStrings.checkingLiveness,
    AppStrings.finalizingVerification,
  ];

  int _done = 0;
  Timer? _timer;
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _timer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) return;
      if (_done >= _labels.length) {
        timer.cancel();
        widget.onFinished();
        return;
      }
      setState(() => _done++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spin.dispose();
    super.dispose();
  }

  _StepState _stateFor(int index) {
    if (index < _done) return _StepState.done;
    if (index == _done) return _StepState.active;
    return _StepState.waiting;
  }

  @override
  Widget build(BuildContext context) {
    final ring = context.w(120);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.w(28), context.h(36), context.w(28), context.h(16)),
          child: Column(
            children: [
              SizedBox(
                width: ring,
                height: ring,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotationTransition(
                      turns: _spin,
                      child: CustomPaint(
                        size: Size(ring, ring),
                        painter: const _SpinRingPainter(),
                      ),
                    ),
                    CircleAvatar(
                      radius: context.w(46),
                      backgroundColor: const Color(0xFFF5F3FF),
                      backgroundImage: widget.selfiePath == null ? null : FileImage(File(widget.selfiePath!)),
                      child: widget.selfiePath == null
                          ? Icon(Icons.person, color: AppColors.primary, size: context.w(32))
                          : null,
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.h(24)),
              Text(AppStrings.verifyingYourFace, style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2)),
              SizedBox(height: context.h(6)),
              Text(
                AppStrings.verifyingFaceSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.secondaryTextColor),
              ),
              SizedBox(height: context.h(28)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < _labels.length; i++)
                        _VerifyStep(
                          label: _labels[i],
                          state: _stateFor(i),
                          last: i == _labels.length - 1,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpinRingPainter extends CustomPainter {
  const _SpinRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final track = Paint()
      ..color = const Color(0xFFEDE9FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final arc = Paint()
      ..color = const Color(0xFF7C3AED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(2), 0, math.pi * 2, false, track);
    canvas.drawArc(rect.deflate(2), -math.pi / 2, math.pi * 0.42, false, arc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VerifyStep extends StatelessWidget {
  const _VerifyStep({required this.label, required this.state, this.last = false});

  final String label;
  final _StepState state;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final done = state == _StepState.done;
    final active = state == _StepState.active;
    final color = done || active ? AppColors.green600 : AppColors.slate300;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (active)
              Container(
                width: context.w(18),
                height: context.w(18),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD1FAE5),
                ),
                child: Container(
                  width: context.w(8),
                  height: context.w(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green600,
                  ),
                ),
              )
            else
              Icon(
                done ? Icons.check_circle : Icons.circle_outlined,
                color: color,
                size: context.w(18),
              ),
            if (!last)
              Container(
                width: 2,
                height: context.h(22),
                color: done ? AppColors.green600 : AppColors.slate200,
              ),
          ],
        ),
        SizedBox(width: context.w(10)),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: context.h(1)),
            child: Text(
              label,
              style: AppTypography.regular.copyWith(
                fontSize: 14,
                fontWeight: done || active ? FontWeight.w700 : FontWeight.w400,
                color: done || active ? AppColors.textPrimary : AppColors.secondaryTextColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessLine extends StatelessWidget {
  const _SuccessLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(18), left: context.w(16)),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.green600, size: context.w(18)),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Text(text, style: AppTypography.regular.copyWith(fontSize: 14, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
