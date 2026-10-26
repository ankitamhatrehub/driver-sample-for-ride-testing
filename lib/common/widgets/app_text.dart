import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class AppHeading extends StatelessWidget {
  const AppHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: context.sp(28),
        fontWeight: FontWeight.bold,
        color: context.torkk.textPrimary,
        height: 1.2,
        letterSpacing: -0.5,
      ),
    );
  }
}

class AppSubtitle extends StatelessWidget {
  const AppSubtitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.torkk.textSecondary,
        fontSize: context.sp(14),
        height: 1.4,
      ),
    );
  }
}

class AppCaption extends StatelessWidget {
  const AppCaption(
    this.text, {
    super.key,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: context.sp(11),
        color: AppColors.slate400,
      ),
    );
  }
}
