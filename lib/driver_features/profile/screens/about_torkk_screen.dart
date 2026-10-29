import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutTorkkScreen extends StatelessWidget {
  const AboutTorkkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.aboutTorkk,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(24),
          context.h(16),
          context.w(24),
          context.h(24),
        ),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.r(18)),
              child: Image.asset(
                AppAssets.appIcon,
                width: context.w(72),
                height: context.w(72),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: context.h(16)),
          Text(
            'Smarter rides for',
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(
              fontSize: 20,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
          const _GradientLine('a better tomorrow.'),
          SizedBox(height: context.h(12)),
          Text(
            'Torkk is a modern rihalo platform built to make everyday travel simple, safe and reliable. We connect you with trusted drivers, so you can move freely, wherever life takes you.',
            textAlign: TextAlign.center,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              height: 1.45,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(22)),
          Text(
            'Our Mission',
            style: AppTypography.regular.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.h(8)),
          const _InfoCard(
            title: 'To make mobility simple, safe and accessible for everyone.',
            body:
                "We're on a mission to build a cleaner, safer and more connected world — one ride at a time.",
          ),
          SizedBox(height: context.h(16)),
          Text(
            'Area of Operation',
            style: AppTypography.regular.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.h(8)),
          const _InfoCard(
            title: 'Delhi NCR',
            body:
                'Delhi, Gurugram, Noida, Ghaziabad, Faridabad (subject to service availability)',
          ),
          SizedBox(height: context.h(16)),
          Row(
            children: [
              const Expanded(
                child: _FactCard(
                  icon: Icons.calendar_today_outlined,
                  value: '2026',
                  label: 'Founded',
                ),
              ),
              SizedBox(width: context.w(12)),
              const Expanded(
                child: _FactCard(
                  icon: Icons.apartment_rounded,
                  value: 'Delhi NCR',
                  label: 'Headquarters',
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(30)),
          InkWell(
            onTap: () {
              var url = Uri.parse(
                'https://www.instagram.com/torkkapp?exln=cjVzZ3I3bnlxNXZy',
              );

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
          ), //color blue , tab  pe @torkkapp link attached krni he
        ],
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

class _GradientLine extends StatelessWidget {
  const _GradientLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.bold.copyWith(
          fontSize: 20,
          height: 1.25,
          letterSpacing: -0.3,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.w(14)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bold.copyWith(fontSize: 13, height: 1.35),
          ),
          SizedBox(height: context.h(4)),
          Text(
            body,
            style: AppTypography.regular.copyWith(
              fontSize: 12,
              height: 1.4,
              color: context.torkk.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: context.w(44),
          height: context.w(44),
          decoration: BoxDecoration(
            color: context.adaptiveTint(const Color(0xFFF5F3FF)),
            borderRadius: BorderRadius.circular(context.r(12)),
          ),
          child: Icon(
            icon,
            color: context.legible(Color(0xFF7C3AED)),
            size: context.w(20),
          ),
        ),
        SizedBox(height: context.h(8)),
        Text(
          value,
          style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2),
        ),
        Text(
          label,
          style: AppTypography.regular.copyWith(
            fontSize: 11,
            color: context.torkk.textSecondary,
          ),
        ),
      ],
    );
  }
}
