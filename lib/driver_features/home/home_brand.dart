import 'dart:math' as math;

import 'package:flutter/material.dart';

LinearGradient homeBrandWash(bool female, double opacity) {
  const degrees = 286.17;
  final radians = degrees * math.pi / 180;
  final dx = math.sin(radians);
  final dy = -math.cos(radians);
  final colors = female
      ? const [Color(0xFFE85AAD), Color(0xFFBA2879), Color(0xFF6B1848)]
      : const [Color(0xFF0F3FBF), Color(0xFF61217E), Color(0xFF40105F)];
  return LinearGradient(
    begin: Alignment(-dx, -dy),
    end: Alignment(dx, dy),
    colors: [for (final color in colors) color.withValues(alpha: opacity)],
    stops: const [0, 0.5, 1],
  );
}
