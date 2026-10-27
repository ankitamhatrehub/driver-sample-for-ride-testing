import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/app_typography.dart';

TextStyle Inter({
  double? fontSize,
  FontWeight? fontWeight,
  double? height,
  Color? color,
}) => TextStyle(
  fontFamily: AppTypography.fontFamily,
  fontSize: fontSize,
  fontWeight: fontWeight,
  height: height,
  color: color,
);
