import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Bike and auto can take parcels. Cars cannot.
bool parcelAllowedForVehicle(String vehicleType) {
  final value = vehicleType.toLowerCase();
  return !value.contains('cab') && value != 'car';
}

class ParcelVehiclesScreen extends StatelessWidget {
  const ParcelVehiclesScreen({super.key, required this.onBack, required this.onStart});

  final VoidCallback onBack;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(context.w(8), context.h(4), context.w(16), 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: Icon(Icons.arrow_back_ios_new, size: 18, color: context.torkk.textPrimary),
                  ),
                  Text(
                    AppStrings.navParcel,
                    style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2, letterSpacing: -0.3),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(12)),
                children: [
                  const _ParcelBadge(),
                  SizedBox(height: context.h(16)),
                  Text(
                    AppStrings.parcelDelivery,
                    textAlign: TextAlign.center,
                    style: AppTypography.bold.copyWith(fontSize: 22, height: 1.25, letterSpacing: -0.4),
                  ),
                  SizedBox(height: context.h(6)),
                  Text(
                    AppStrings.earnByDeliveringParcels,
                    textAlign: TextAlign.center,
                    style: AppTypography.regular.copyWith(fontSize: 14, height: 1.4, color: context.torkk.textSecondary),
                  ),
                  SizedBox(height: context.h(22)),
                  Text(
                    AppStrings.yourVehicles,
                    style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2, letterSpacing: -0.2),
                  ),
                  SizedBox(height: context.h(10)),
                  _VehicleTile(
                    icon: Icons.two_wheeler_rounded,
                    title: AppStrings.vehicleBike,
                    subtitle: AppStrings.canReceiveParcelRequests,
                    enabled: true,
                    accent: accent,
                  ),
                  SizedBox(height: context.h(10)),
                  _VehicleTile(
                    icon: Icons.electric_rickshaw_rounded,
                    title: AppStrings.vehicleAuto,
                    subtitle: AppStrings.canReceiveParcelRequests,
                    enabled: true,
                    accent: accent,
                  ),
                  SizedBox(height: context.h(10)),
                  _VehicleTile(
                    icon: Icons.directions_car_filled_rounded,
                    title: AppStrings.vehicleCar,
                    subtitle: AppStrings.parcelNotAvailable,
                    enabled: false,
                    accent: accent,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(12)),
              child: SizedBox(
                width: double.infinity,
                height: context.h(52),
                child: FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
                  ),
                  child: Text(
                    AppStrings.startReceivingParcelRequests,
                    style: AppTypography.bold.copyWith(fontSize: 16, height: 1.2, color: Theme.of(context).colorScheme.onPrimary, letterSpacing: -0.2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParcelBadge extends StatelessWidget {
  const _ParcelBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AppAssets.deliveryBox,
        width: context.w(120),
        height: context.w(120),
        fit: BoxFit.contain,
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? accent : AppColors.slate400;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(14)),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(40),
            height: context.w(40),
            decoration: BoxDecoration(
              color: enabled ? accent.withValues(alpha: 0.1) : context.adaptiveTint(Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(context.r(12)),
            ),
            child: Icon(icon, color: color, size: context.w(20)),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bold.copyWith(
                    fontSize: 15,
                    height: 1.2,
                    letterSpacing: -0.2,
                    color: enabled ? context.legible(AppColors.textPrimary) : AppColors.slate400,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.regular.copyWith(fontSize: 12, height: 1.3, color: context.torkk.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
