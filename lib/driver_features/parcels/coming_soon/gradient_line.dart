import 'package:flutter/material.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/coming_soon_text.dart';

class GradientLine extends StatelessWidget {
  final String text;
  final double size;
  const GradientLine(this.text, {super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment(0.96, 0.28),
        end: Alignment(-0.96, -0.28),
        stops: [0.0, 0.3942, 1.0],
        colors: [Color(0xFFBA2879), Color(0xFF61217E), Color(0xFF0F3FBF)],
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Inter(
          fontSize: size,
          fontWeight: FontWeight.w800,
          height: 1.15,
          color: Colors.white,
        ),
      ),
    );
  }
}
