import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/home/home_brand.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class HomeStatusCard extends StatelessWidget {
  const HomeStatusCard({
    super.key,
    required this.isOnline,
    required this.onToggle,
    required this.female,
    this.locationLabel = '',
    this.onUpdateLocation,
  });

  final bool isOnline;
  final VoidCallback onToggle;
  final bool female;
  final String locationLabel;
  final VoidCallback? onUpdateLocation;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDarkTheme;
    final statusColor = isOnline
        ? context.torkk.statusOnline
        : context.torkk.statusOffline;
    // Dark mode: the green / red wash is lightened toward white so it reads
    // soft instead of heavy.
    final washColor = Color.lerp(statusColor, Colors.white, 0.35)!;
    return Container(
      padding: EdgeInsets.all(context.w(14)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(24)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Dark mode: status-colored glow fading into the surface.
          colors: dark
              ? [washColor.withValues(alpha: 0.32), context.torkk.surface]
              : isOnline
              ? [
                  context.adaptiveTint(Color(0xFFF8F6FE)),
                  context.adaptiveTint(Color(0x82CEE9DC)),
                ]
              : [
                  context.adaptiveTint(Color(0xFFF8F6FE)),
                  context.adaptiveTint(Color(0xFFFEF6F7)),
                ],
        ),
        border: Border.all(
          color: dark
              ? washColor.withValues(alpha: 0.45)
              : female
              ? const Color(0xB2FBCFE8)
              : const Color(0xB2F3E8FF),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0x0D000000),
            offset: dark ? const Offset(0, 3) : const Offset(0, 1),
            blurRadius: dark ? 10 : 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: context.w(28),
                height: context.w(28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: dark
                      ? statusColor.withValues(alpha: 0.16)
                      : isOnline
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: context.w(12),
                  height: context.w(12),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: context.w(8)),
              Expanded(child: _statusTitle(context)),
              SizedBox(width: context.w(10)),
              GestureDetector(
                onTap: onToggle,
                child: _AvailabilitySwitch(online: isOnline),
              ),
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
                color: context.torkk.textSecondary,
              ),
            ),
          ),
          if (isOnline && onUpdateLocation != null) ...[
            SizedBox(height: context.h(12)),
            Divider(
              height: 1,
              thickness: 1,
              color: context.torkk.textSecondary.withValues(alpha: 0.2),
            ),
            SizedBox(height: context.h(12)),
            _locationRow(context),
          ],
        ],
      ),
    );
  }

  Widget _locationRow(BuildContext context) {
    final place = locationLabel.trim();
    final tint = context.isDarkTheme
        ? (female ? AppColors.femalePink : AppColors.maleBlue)
        : Theme.of(context).colorScheme.primary;
    // White outline icon in dark mode; light mode keeps the theme color
    // because white would vanish on the light card.
    final iconColor = context.isDarkTheme ? Colors.white : tint;
    return Row(
      children: [
        Container(
          width: context.w(32),
          height: context.w(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.r(8)),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Icon(
            Icons.location_on_rounded,
            color: iconColor,
            size: context.w(16),
          ),
        ),
        SizedBox(width: context.w(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   AppStrings.currentLocation,
              //   style: AppTypography.regular.copyWith(
              //     fontSize: 11,
              //     color: context.torkk.textSecondary,
              //   ),
              // ),
              if (place.isNotEmpty)
                Text(
                  place,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bold.copyWith(
                    fontSize: 14,
                    height: 1.3,
                    letterSpacing: -0.2,
                    color: context.torkk.textPrimary,
                  ),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onUpdateLocation,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(12),
              vertical: context.h(7),
            ),
            decoration: BoxDecoration(
              gradient: homeBrandWash(female, 1),
              borderRadius: BorderRadius.circular(context.r(20)),
              boxShadow: [
                BoxShadow(
                  color: tint.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.my_location_rounded,
                  size: context.w(14),
                  color: Colors.white,
                ),
                SizedBox(width: context.w(6)),
                Text(
                  AppStrings.updateLocation,
                  style: AppTypography.bold.copyWith(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusTitle(BuildContext context) {
    final parts =
        (isOnline ? AppStrings.youAreOnline : AppStrings.youAreOffline).split(
          ' ',
        );
    final lead = parts.first;
    final word = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final style = AppTypography.bold.copyWith(
      fontSize: 20,
      height: 25 / 20,
      letterSpacing: -0.5,
    );
    if (context.isDarkTheme) {
      // Dark mode: one plain white line, no gradient word.
      return Text(
        isOnline ? AppStrings.youAreOnline : AppStrings.youAreOffline,
        style: style.copyWith(color: Colors.white),
      );
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$lead ',
            style: style.copyWith(color: context.torkk.textPrimary),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  homeBrandWash(female, 1).createShader(bounds),
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
    final dark = context.isDarkTheme;
    // Dark mode: deep track with a brighter knob of the same hue.
    final track = !dark
        ? (online ? context.torkk.statusOnline : context.torkk.statusOffline)
        : (online ? const Color(0xFF1F4A33) : const Color(0xFF4A2326));
    final knob = !dark
        ? Colors.white
        : (online ? const Color(0xFF6FCF97) : const Color(0xFFE0868A));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: context.w(44),
      height: context.h(22),
      padding: EdgeInsets.all(context.h(3)),
      decoration: BoxDecoration(
        color: track,
        borderRadius: BorderRadius.circular(context.r(9999)),
        border: Border.all(
          color: dark ? knob.withValues(alpha: 0.8) : const Color(0x99FFFFFF),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1.51),
            blurRadius: 3.02,
          ),
        ],
      ),
      child: Align(
        alignment: online ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: context.h(16),
          height: context.h(16),
          decoration: BoxDecoration(color: knob, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
