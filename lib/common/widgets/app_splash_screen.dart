import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';

/// Full-screen splash. Stays up for [duration], then calls [onFinished].
///
/// Built from widgets (logo, tagline, illustration, loader) instead of one
/// full-screen image, so it scales to any screen size.
class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({
    super.key,
    this.onFinished,
    this.duration = const Duration(seconds: 3),
  });

  final VoidCallback? onFinished;
  final Duration duration;

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  static const _bgTop = Color(0xFFF1F6FF);
  static const _bgBottom = Color(0xFFF7F9FE);
  static const _ink = Color(0xFF14142B);
  static const _purple = Color(0xFF8B2FC9);
  static const _indigo = Color(0xFF3B3FD8);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      if (!mounted) return;
      widget.onFinished?.call();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoSize = (size.width * 0.28).clamp(88.0, 130.0);
    final tagline = AppTypography.bold.copyWith(
      fontSize: (size.width * 0.07).clamp(22.0, 32.0),
      height: 1.2,
      letterSpacing: -0.5,
    );

    return Scaffold(
      backgroundColor: _bgBottom,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.85, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutBack,
                builder: (context, v, child) => Opacity(
                  opacity: v.clamp(0.0, 1.0),
                  child: Transform.scale(scale: v, child: child),
                ),
                child: Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(logoSize * 0.24),
                    boxShadow: [
                      BoxShadow(
                        color: _indigo.withValues(alpha: 0.25),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(logoSize * 0.24),
                    child: Image.asset(AppAssets.appIcon, fit: BoxFit.cover),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.035),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Earn Fair ', style: tagline.copyWith(color: _ink)),
                  ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [_purple, _indigo],
                    ).createShader(rect),
                    child: Text(
                      '. Drive Safe',
                      style: tagline.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              Image.asset(
                AppAssets.splashIllustration,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              const Spacer(flex: 2),
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  color: _purple,
                  backgroundColor: Color(0x1F8B2FC9),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Getting things ready...',
                style: AppTypography.regular.copyWith(
                  fontSize: 15,
                  color: _ink,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
