part of 'package:rider_app/driver_features/onboarding/screens/face_verification_screen.dart';

class _SpinRingPainter extends CustomPainter {
  const _SpinRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final track = Paint()
      ..color = const Color(0xFFEDE9FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final arc = Paint()
      ..color = const Color(0xFF7C3AED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(2), 0, math.pi * 2, false, track);
    canvas.drawArc(rect.deflate(2), -math.pi / 2, math.pi * 0.42, false, arc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
