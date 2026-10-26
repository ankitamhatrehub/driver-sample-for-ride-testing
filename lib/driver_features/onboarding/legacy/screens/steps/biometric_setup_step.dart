import 'package:flutter/material.dart';
import 'package:rider_app/common/widgets/bouncing_widget.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class BiometricSetupStep extends StatelessWidget {
  final Color primaryColor;
  final bool hasFingerprint;
  final bool hasFaceId;
  final void Function(String type) onSetupBiometrics;
  final VoidCallback onSkip;

  const BiometricSetupStep({
    super.key,
    required this.primaryColor,
    required this.hasFingerprint,
    required this.hasFaceId,
    required this.onSetupBiometrics,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.security_rounded, size: 84, color: primaryColor),
          ),
          const SizedBox(height: 40),
          Text(
            'Enable Biometric Login',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: context.torkk.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Secure your account with Fingerprint or Face ID',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: context.themed(light: Colors.blueGrey.shade500, dark: context.torkk.textSecondary),
              height: 1.4,
            ),
          ),
          const Spacer(),
          if (hasFingerprint)
            BouncingWidget(
              onTap: () => onSetupBiometrics('fingerprint'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Use Fingerprint',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          if (hasFaceId)
            BouncingWidget(
              onTap: () => onSetupBiometrics('face'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: hasFingerprint ? context.torkk.surface : primaryColor,
                  border: Border.all(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Use Face ID',
                    style: TextStyle(
                      color: hasFingerprint ? primaryColor : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip for now',
              style: TextStyle(
                color: Colors.blueGrey.shade400,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class BiometricVerifyStep extends StatefulWidget {
  final Color primaryColor;
  final VoidCallback onVerified;

  const BiometricVerifyStep({
    super.key,
    required this.primaryColor,
    required this.onVerified,
  });

  @override
  State<BiometricVerifyStep> createState() => _BiometricVerifyStepState();
}

class _BiometricVerifyStepState extends State<BiometricVerifyStep> {
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _startVerification();
  }

  void _startVerification() {
    if (!_verifying) {
      _verifying = true;
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) {
          widget.onVerified();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: 1.2),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOutSine,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.face_retouching_natural_rounded,
                  size: 76,
                  color: widget.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'Verify to Continue',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.torkk.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use your biometric to access your account',
              style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Text(
              'Verifying...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.themed(light: Colors.blueGrey, dark: context.torkk.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
