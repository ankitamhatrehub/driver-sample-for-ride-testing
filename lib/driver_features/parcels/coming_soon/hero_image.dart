
import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Hero image from `assets/coming_soon/`. The artwork is not bundled in every
/// build, so a missing file shows a neutral icon instead of throwing.
class HeroImage extends StatelessWidget {
  const HeroImage(this.name, {required this.height, required this.fallback});

  final String name;
  final double height;
  final IconData fallback;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/coming_soon/$name.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        height: height,
        child: Icon(
          fallback,
          size: height * 0.5,
          color: context.torkk.textDisabled,
        ),
      ),
    );
  }
}
