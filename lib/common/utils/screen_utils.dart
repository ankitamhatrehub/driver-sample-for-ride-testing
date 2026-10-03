import 'package:flutter/widgets.dart';

/// Responsive sizing based on a 390×844 design frame.
///
/// Call these from a widget that already has a [BuildContext]. Scales are
/// clamped so text and spacing stay readable on very small and very large phones.
class ScreenUtils {
  ScreenUtils._();

  static const double designWidth = 390;
  static const double designHeight = 844;
  static const double _minScale = 0.85;
  static const double _maxScale = 1.2;

  static double widthScale(BuildContext context) {
    return (MediaQuery.sizeOf(context).width / designWidth).clamp(
      _minScale,
      _maxScale,
    );
  }

  static double heightScale(BuildContext context) {
    return (MediaQuery.sizeOf(context).height / designHeight).clamp(
      _minScale,
      _maxScale,
    );
  }

  static double w(BuildContext context, num value) => value * widthScale(context);

  static double h(BuildContext context, num value) => value * heightScale(context);

  static double sp(BuildContext context, num value) => value * widthScale(context);

  static double r(BuildContext context, num value) => value * widthScale(context);
}

extension ScreenContext on BuildContext {
  double w(num value) => ScreenUtils.w(this, value);

  double h(num value) => ScreenUtils.h(this, value);

  double sp(num value) => ScreenUtils.sp(this, value);

  double r(num value) => ScreenUtils.r(this, value);
}
