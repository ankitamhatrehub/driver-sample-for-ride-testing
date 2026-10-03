import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/home/home_brand.dart';

class HomeStatusCard extends StatelessWidget {
  const HomeStatusCard({
    super.key,
    required this.isOnline,
    required this.onToggle,
    required this.female,
  });

  final bool isOnline;
  final VoidCallback onToggle;
  final bool female;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.h(148),
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(24)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOnline
              ? const [Color(0xFFF8F6FE), Color(0x82CEE9DC)]
              : const [Color(0xFFF8F6FE), Color(0xFFFEF6F7)],
        ),
        border: Border.all(color: female ? const Color(0xB2FBCFE8) : const Color(0xB2F3E8FF)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: context.w(28),
                height: context.w(28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isOnline ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: context.w(12),
                  height: context.w(12),
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: context.w(8)),
              Flexible(child: _statusTitle(context)),
            ],
          ),
          SizedBox(height: context.h(3.4)),
          Padding(
            padding: EdgeInsets.only(left: context.w(36)),
            child: Text(
              isOnline ? AppStrings.readyForRequests : AppStrings.goOnlineHint,
              style: AppTypography.regular.copyWith(
                fontSize: 13,
                height: 1.35,
                color: AppColors.slate500,
              ),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onToggle,
              child: _AvailabilitySwitch(online: isOnline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusTitle(BuildContext context) {
    final parts = (isOnline ? AppStrings.youAreOnline : AppStrings.youAreOffline).split(' ');
    final lead = parts.first;
    final word = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final style = AppTypography.bold.copyWith(fontSize: 20, height: 25 / 20, letterSpacing: -0.5);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$lead ', style: style.copyWith(color: AppColors.textPrimary)),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: ShaderMask(
              shaderCallback: (bounds) => homeBrandWash(female, 1).createShader(bounds),
              child: Text(word, style: style.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilitySwitch extends StatelessWidget {
  const _AvailabilitySwitch({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: context.w(69.57),
      height: context.h(30.25),
      padding: EdgeInsets.fromLTRB(context.w(6.05), context.h(3.02), context.w(6.05), context.h(3.02)),
      decoration: BoxDecoration(
        color: online ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(context.r(9999)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1.51), blurRadius: 3.02),
        ],
      ),
      child: Align(
        alignment: online ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: context.h(24),
          height: context.h(24),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
