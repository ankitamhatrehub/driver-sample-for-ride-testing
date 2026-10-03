import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A gradient-styled elevated button used throughout the app.
///
/// Renders an indigo-to-deep-indigo gradient by default. Fully customizable
/// via [gradient], [borderRadius], [padding], and [elevation].
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
    this.elevation = 0,
    this.width = double.infinity,
    this.boxShadow,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Gradient? gradient;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final double? width;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: gradient ??
              const LinearGradient(
                colors: AppColors.primaryGradient,
              ),
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: padding,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: elevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
