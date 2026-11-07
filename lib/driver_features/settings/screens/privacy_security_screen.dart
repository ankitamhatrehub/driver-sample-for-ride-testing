import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/widgets/app_snackbar.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/settings/screens/change_pin_screen.dart';
import 'package:rider_app/driver_features/settings/screens/set_pin_screen.dart';

import '../../../common/constants/string_constants.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/widgets/app_switch.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _showProfile = false;
  bool _shareLocation = true;
  bool _hasPin = false;

  // App lock (Face / Fingerprint, or the phone's screen lock as fallback).
  final LocalAuthentication _auth = LocalAuthentication();
  bool _appLock = false;
  bool _lockSupported = false;
  String _lockLabel = 'App Lock';
  String _detectedMethod = 'pattern'; // what this phone offers
  bool _lockFailed = false; // last Face/Fingerprint check was not recognised
  bool _lockBusy = false; // phone's Face/Fingerprint prompt is showing
  // How the user unlocks: 'face' | 'fingerprint' | 'biometric' | 'pattern'.
  // Decides the icon once the lock is on.
  String _lockMethod = 'pattern';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _showProfile = prefs.getBool('show_profile_to_driver') ?? false;
      _shareLocation = prefs.getBool('location_sharing') ?? true;
      _hasPin = (prefs.getString('account_pin') ?? '').length == 4;
      _appLock = prefs.getBool('app_lock_enabled') ?? false;
      _lockMethod = prefs.getString('app_lock_method') ?? 'pattern';
    });
    _checkLockSupport();
  }

  /// Face lock where the phone has face unlock (iOS Face ID etc.), fingerprint
  /// where it has that, otherwise the phone's own screen lock (PIN / pattern).
  Future<void> _checkLockSupport() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final types = await _auth.getAvailableBiometrics();
      if (!mounted) return;
      setState(() {
        _lockSupported = supported;
        // iOS reports face / fingerprint exactly. Android only says
        // strong / weak (it cannot tell face from fingerprint), so any other
        // biometric is treated as a generic 'biometric'.
        final hasFace = types.contains(BiometricType.face);
        final hasFinger = types.contains(BiometricType.fingerprint);
        final hasOther = types.any(
          (t) => t != BiometricType.face && t != BiometricType.fingerprint,
        );
        _detectedMethod = hasFace && !hasFinger && !hasOther
            ? 'face'
            : hasFinger && !hasFace && !hasOther
            ? 'fingerprint'
            : types.isNotEmpty
            ? 'biometric'
            : 'pattern';
        _lockLabel = switch (_detectedMethod) {
          'face' => 'Face Lock',
          'fingerprint' => 'Fingerprint Lock',
          'biometric' =>
            hasFace && hasFinger ? 'Face / Fingerprint Lock' : 'Biometric Lock',
          _ => 'App Lock',
        };
      });
    } on PlatformException {
      if (mounted) setState(() => _lockSupported = false);
    }
  }

  /// Plain lock while the feature is off; once on, the icon shows how the
  /// user unlocks (face / fingerprint / pattern or PIN).
  IconData get _lockIcon {
    if (!_appLock) return Icons.lock_outline_rounded;
    switch (_lockMethod) {
      case 'face':
        return Icons.face_unlock_outlined;
      case 'fingerprint':
      case 'biometric':
        return Icons.fingerprint_rounded;
      default:
        return Icons.pattern_rounded;
    }
  }

  /// Short animated confirmation after the phone's own Face / Fingerprint
  /// prompt closes: green + pop when verified, red + shake when not.
  Future<void> _showResult(bool ok) async {
    final nav = Navigator.of(context, rootNavigator: true);
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (_, _, _) => _LockResultDialog(
        success: ok,
        icon: _detectedIcon,
        label: ok ? 'Verified' : 'Not recognised',
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (nav.mounted && nav.canPop()) nav.pop();
  }

  IconData get _detectedIcon {
    switch (_detectedMethod) {
      case 'face':
        return Icons.face_unlock_outlined;
      case 'fingerprint':
      case 'biometric':
        return Icons.fingerprint_rounded;
      default:
        return Icons.pattern_rounded;
    }
  }

  Future<void> _toggleAppLock(bool enable) async {
    if (_lockBusy) return;
    if (!_lockSupported) {
      AppSnackBar.showInfo(
        context,
        title: 'Not available',
        message:
            'Set up a screen lock or Face/Fingerprint unlock in your phone settings first.',
      );
      return;
    }
    // Confirm it's really the owner before turning the lock on or off.
    // iOS shows the system Face ID permission the first time (text comes from
    // NSFaceIDUsageDescription in Info.plist), then the Face ID scan itself.
    setState(() => _lockBusy = true);
    try {
      final ok = await _auth.authenticate(
        localizedReason: enable
            ? 'Verify it\'s you to turn on $_lockLabel for Torkk'
            : 'Verify it\'s you to turn off $_lockLabel for Torkk',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Unlock Torkk',
            biometricHint: 'Use your face or fingerprint',
            biometricNotRecognized: 'Not recognised, try again',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(cancelButton: 'Cancel'),
        ],
        options: const AuthenticationOptions(stickyAuth: true),
      );
      if (!mounted) return;
      setState(() => _lockFailed = !ok);
      await _showResult(ok);
      if (!ok || !mounted) return;
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => _lockFailed = true);
      await _showResult(false);
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        title: 'Could not verify',
        message: e.message ?? 'Please try again.',
      );
      return;
    } finally {
      if (mounted) setState(() => _lockBusy = false);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', enable);
    if (enable) await prefs.setString('app_lock_method', _detectedMethod);
    if (mounted) {
      setState(() {
        _appLock = enable;
        if (enable) _lockMethod = _detectedMethod;
      });
    }
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _openPin() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPin = (prefs.getString('account_pin') ?? '').length == 4;
    if (!mounted) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => hasPin ? const ChangePinScreen() : const SetPinScreen(),
      ),
    );
    if (result == true) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return ProfilePage(
      title: AppStrings.privacyPolicy,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(20),
        ),
        children: [
          Material(
            color: context.adaptiveTint(const Color(0xFFF5F3FF)),
            borderRadius: BorderRadius.circular(context.r(16)),
            child: InkWell(
              onTap: _openPin,
              borderRadius: BorderRadius.circular(context.r(16)),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(14),
                  vertical: context.h(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: context.w(40),
                      height: context.w(40),
                      decoration: BoxDecoration(
                        color: context.torkk.surface,
                        borderRadius: BorderRadius.circular(context.r(12)),
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: accent,
                        size: context.w(20),
                      ),
                    ),
                    SizedBox(width: context.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.setChangePin,
                            style: AppTypography.bold.copyWith(
                              color: context.torkk.textPrimary,
                              fontSize: 14,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            _hasPin
                                ? 'PIN is active. Tap to change PIN'
                                : AppStrings.secureAccountPin,
                            style: AppTypography.regular.copyWith(
                              fontSize: 12,
                              color: context.torkk.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.slate400,
                      size: context.w(22),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(12)),
          _PrivacySwitch(
            icon: _lockIcon,
            iconColor: _lockFailed
                ? const Color(0xFFEF4444)
                : _appLock
                ? const Color(0xFF22C55E)
                : null,
            title: _lockLabel,
            subtitle: _lockSupported
                ? 'Ask for Face / Fingerprint or phone lock when opening the app'
                : 'Set up a screen lock on your phone to use this',
            value: _appLock,
            onChanged: _toggleAppLock,
          ),
          SizedBox(height: context.h(18)),
          Text(
            AppStrings.privacySettings,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(10)),
          _PrivacySwitch(
            icon: Icons.person_outline_rounded,
            title: AppStrings.showMyProfileToDriver,
            subtitle: AppStrings.showMyProfileToDriverSubtitle,
            value: _showProfile,
            onChanged: (value) {
              setState(() => _showProfile = value);
              _save('show_profile_to_driver', value);
            },
          ),
          SizedBox(height: context.h(12)),
          _PrivacySwitch(
            icon: Icons.location_on_outlined,
            title: AppStrings.locationSharing,
            subtitle: AppStrings.locationSharingSubtitle,
            value: _shareLocation,
            onChanged: (value) {
              setState(() => _shareLocation = value);
              _save('location_sharing', value);
            },
          ),
        ],
      ),
    );
  }
}

class _PrivacySwitch extends StatelessWidget {
  const _PrivacySwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.iconColor,
  });

  final Color? iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(12),
        vertical: context.h(12),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(40),
            height: context.w(40),
            decoration: BoxDecoration(
              color: context.torkk.surfaceMuted,
              borderRadius: BorderRadius.circular(context.r(12)),
            ),
            child: Icon(
              icon,
              color: iconColor ?? context.torkk.textSecondary,
              size: context.w(20),
            ),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2),
                ),
                Text(
                  subtitle,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    height: 1.3,
                    color: context.torkk.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AppSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Animated card: icon pops in with a ring and a tick (success), or shakes
/// with a red cross (failure).
class _LockResultDialog extends StatefulWidget {
  const _LockResultDialog({
    required this.success,
    required this.icon,
    required this.label,
  });

  final bool success;
  final IconData icon;
  final String label;

  @override
  State<_LockResultDialog> createState() => _LockResultDialogState();
}

class _LockResultDialogState extends State<_LockResultDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.success
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);
    return Center(
      child: Material(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(context.r(24)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(36),
            vertical: context.h(28),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              final pop = Curves.elasticOut.transform(t.clamp(0.0, 1.0));
              final shake = widget.success
                  ? 0.0
                  : math.sin(t * math.pi * 7) * 10 * (1 - t);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: Offset(shake, 0),
                    child: Transform.scale(
                      scale: widget.success ? 0.5 + 0.5 * pop : 1.0,
                      child: SizedBox(
                        width: context.w(96),
                        height: context.w(96),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.expand(
                              child: CircularProgressIndicator(
                                value: widget.success ? t : 1,
                                strokeWidth: 4,
                                color: color,
                                backgroundColor: color.withValues(alpha: 0.15),
                              ),
                            ),
                            Icon(
                              widget.icon,
                              size: context.w(44),
                              color: color,
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Transform.scale(
                                scale: pop,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.success
                                        ? Icons.check_rounded
                                        : Icons.close_rounded,
                                    size: context.w(18),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(16)),
                  Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Text(
                      widget.label,
                      style: AppTypography.bold.copyWith(
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
