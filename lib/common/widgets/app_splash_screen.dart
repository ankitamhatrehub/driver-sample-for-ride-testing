import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/asset_constants.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Full-screen splash. Stays up for [duration], then calls [onFinished].
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
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SizedBox.expand(
        child: Image.asset(
          AppAssets.splashScreen,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}
