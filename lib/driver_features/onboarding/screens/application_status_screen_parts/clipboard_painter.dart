part of 'package:rider_app/driver_features/onboarding/screens/application_status_screen.dart';

class _ClipboardPainter extends CustomPainter {
  const _ClipboardPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.2,
        size.width * 0.7,
        size.height * 0.72,
      ),
      Radius.circular(size.width * 0.1),
    );
    canvas.drawRRect(body, stroke);

    final clip = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.24,
        size.height * 0.08,
        size.width * 0.38,
        size.height * 0.16,
      ),
      Radius.circular(size.width * 0.04),
    );
    canvas.drawRRect(clip, stroke);

    final hole = Paint()..color = color;
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.32 + i * 0.11), size.height * 0.16),
        size.width * 0.02,
        hole,
      );
    }

    final line = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.4 + i * 0.14);
      canvas.drawLine(
        Offset(size.width * 0.22, y),
        Offset(size.width * (i == 2 ? 0.42 : 0.58), y),
        line,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ClipboardPainter oldDelegate) =>
      oldDelegate.color != color;
}
