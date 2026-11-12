import 'package:flutter/material.dart';

/// A static, QR-looking code (finder squares + seeded modules). Placeholder
/// until the real payment QR comes from the backend.
class StaticQrPainter extends CustomPainter {
  StaticQrPainter(this.seed);

  final String seed;
  static const _n = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _n;
    final dark = Paint()..color = Colors.black;
    var state = seed.codeUnits.fold<int>(
      7,
      (a, b) => (a * 31 + b) & 0x7fffffff,
    );
    bool inEye(int x, int y) =>
        (x < 8 && y < 8) || (x >= _n - 8 && y < 8) || (x < 8 && y >= _n - 8);

    for (var y = 0; y < _n; y++) {
      for (var x = 0; x < _n; x++) {
        if (inEye(x, y)) continue;
        state = (state * 1103515245 + 12345) & 0x7fffffff;
        if ((state >> 16) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell + 0.4, cell + 0.4),
            dark,
          );
        }
      }
    }
    void eye(int ox, int oy) {
      final o = Offset(ox * cell, oy * cell);
      canvas.drawRect(Rect.fromLTWH(o.dx, o.dy, cell * 7, cell * 7), dark);
      canvas.drawRect(
        Rect.fromLTWH(o.dx + cell, o.dy + cell, cell * 5, cell * 5),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(o.dx + cell * 2, o.dy + cell * 2, cell * 3, cell * 3),
        dark,
      );
    }

    eye(0, 0);
    eye(_n - 7, 0);
    eye(0, _n - 7);
  }

  @override
  bool shouldRepaint(covariant StaticQrPainter old) => old.seed != seed;
}
