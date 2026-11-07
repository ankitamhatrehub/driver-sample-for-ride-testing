import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';

/// "Get updates on Instagram" row: Instagram logo + blue text, opens the
/// @torkkapp profile on tap. Shared by About Torkk and the Coming Soon screen.
class InstagramLink extends StatelessWidget {
  const InstagramLink({super.key});

  static const _url =
      'https://www.instagram.com/torkkapp?exln=cjVzZ3I3bnlxNXZy';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        var url = Uri.parse(_url);

        launchUrl(url);
      },
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InstagramLogo(size: context.w(22)),
            SizedBox(width: context.w(8)),
            Text(
              "Get updates on Instagram",
              style: AppTypography.caption(
                color: Colors.blue,
              ).copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstagramLogo extends StatelessWidget {
  const _InstagramLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _InstagramPainter());
  }
}

class _InstagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final bounds = Offset.zero & size;

    // Gradient rounded-square background (Instagram brand gradient).
    final bg = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.6, 1.0),
        radius: 1.6,
        colors: [
          Color(0xFFFEDA75),
          Color(0xFFFA7E1E),
          Color(0xFFD62976),
          Color(0xFF962FBF),
          Color(0xFF4F5BD5),
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(bounds);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, Radius.circular(s * 0.28)),
      bg,
    );

    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.075;

    // Camera body.
    final body = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: s * 0.58,
      height: s * 0.58,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(s * 0.17)),
      stroke,
    );
    // Lens.
    canvas.drawCircle(size.center(Offset.zero), s * 0.14, stroke);
    // Flash dot.
    canvas.drawCircle(
      Offset(s * 0.68, s * 0.32),
      s * 0.04,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
