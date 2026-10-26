import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

TextStyle coinsTitle() => AppTypography.bold.copyWith(
  fontSize: 18,
  height: 1.25,
  letterSpacing: -0.3,
);

TextStyle coinsMuted(BuildContext context) => AppTypography.regular.copyWith(
  fontSize: 13,
  height: 1.35,
  color: context.torkk.textSecondary,
);
