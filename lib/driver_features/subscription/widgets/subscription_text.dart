import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

TextStyle subscriptionTitle() =>
    AppTypography.bold.copyWith(fontSize: 20, height: 1.2, letterSpacing: -0.3);

TextStyle subscriptionMuted(BuildContext context) => AppTypography.regular
    .copyWith(fontSize: 14, height: 1.35, color: context.torkk.textPrimary);
