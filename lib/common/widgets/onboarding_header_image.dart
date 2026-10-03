import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/asset_constants.dart';
import '../utils/screen_utils.dart';

/// Curved onboarding illustration.
///
/// Figma frame: 569×418, offset top -85 and left -91, bottom radius 281.01,
/// fill #EFF6FD.
class OnboardingHeaderImage extends StatelessWidget {
  const OnboardingHeaderImage({super.key});

  static const double _width = 569;
  static const double _height = 418;
  static const double _top = -85;
  static const double _left = -91;
  static const double _bottomRadius = 281.01;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.h(_height + _top),
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: context.h(_top),
              left: context.w(_left),
              width: context.w(_width),
              height: context.h(_height),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(context.r(_bottomRadius)),
                  bottomRight: Radius.circular(context.r(_bottomRadius)),
                ),
                child: ColoredBox(
                  color: AppColors.onboardingHeader,
                  child: Image.asset(
                    AppAssets.onboardingImage,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
