import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class AboutTorkkScreen extends StatelessWidget {
  const AboutTorkkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.aboutTorkk,
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(16), context.w(24), context.h(24)),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.r(18)),
              child: Image.asset(AppAssets.appIcon, width: context.w(72), height: context.w(72), fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: context.h(16)),
          Text(
            'Smarter rides for',
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(fontSize: 20, height: 1.25, letterSpacing: -0.3),
          ),
          const _GradientLine('a better tomorrow.'),
          SizedBox(height: context.h(12)),
          Text(
            'Torkk is a modern ride-hailing platform built to make everyday travel simple, safe and reliable. We connect you with trusted drivers, so you can move freely, wherever life takes you.',
            textAlign: TextAlign.center,
            style: AppTypography.regular.copyWith(fontSize: 13, height: 1.45, color: AppColors.slate500),
          ),
          SizedBox(height: context.h(22)),
          Text(
            'Our Mission',
            style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: context.h(8)),
          const _InfoCard(
            title: 'To make mobility simple, safe and accessible for everyone.',
            body: "We're on a mission to build a cleaner, safer and more connected world — one ride at a time.",
          ),
          SizedBox(height: context.h(16)),
          Text(
            'Area of Operation',
            style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: context.h(8)),
          const _InfoCard(
            title: 'Delhi NCR',
            body: 'Delhi, Gurugram, Noida, Ghaziabad, Faridabad (subject to service availability)',
          ),
          SizedBox(height: context.h(16)),
          Row(
            children: [
              const Expanded(
                child: _FactCard(icon: Icons.calendar_today_outlined, value: '2026', label: 'Founded'),
              ),
              SizedBox(width: context.w(12)),
              const Expanded(
                child: _FactCard(icon: Icons.apartment_rounded, value: 'Gurgaon', label: 'Headquarters'),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
        style: AppTypography.bold.copyWith(fontSize: 20, height: 1.25, letterSpacing: -0.3, color: Colors.white),
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
        border: Border.all(color: const Color(0xFFE8EDF5)),
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
            style: AppTypography.regular.copyWith(fontSize: 12, height: 1.4, color: AppColors.slate500),
          ),
        ],
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({required this.icon, required this.value, required this.label});

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
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(context.r(12)),
          ),
          child: Icon(icon, color: const Color(0xFF7C3AED), size: context.w(20)),
        ),
        SizedBox(height: context.h(8)),
        Text(value, style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2)),
        Text(
          label,
          style: AppTypography.regular.copyWith(fontSize: 11, color: AppColors.slate500),
        ),
      ],
    );
  }
}
