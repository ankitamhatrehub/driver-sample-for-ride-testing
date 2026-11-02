import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class SelectVehicleScreen extends StatefulWidget {
  final String selectedVehicle;
  final bool isLoading;
  final VoidCallback? onBack;
  final VoidCallback onHelp;
  final ValueChanged<String> onSelected;
  final VoidCallback onContinue;

  const SelectVehicleScreen({
    super.key,
    required this.selectedVehicle,
    required this.isLoading,
    this.onBack,
    required this.onHelp,
    required this.onSelected,
    required this.onContinue,
  });

  @override
  State<SelectVehicleScreen> createState() => _SelectVehicleScreenState();
}

class _SelectVehicleScreenState extends State<SelectVehicleScreen> {
  bool _showError = false;

  static final List<_VehicleOption> _vehicles = [
    _VehicleOption(
      'Cab',
      AppStrings.vehicleCab,
      AppStrings.fourWheeler,
      AppAssets.cab,
    ),
    _VehicleOption(
      'Cab EV',
      AppStrings.vehicleEvCab,
      AppStrings.fourWheeler,
      AppAssets.evCab,
    ),
    _VehicleOption(
      'Cab XL',
      AppStrings.vehicleXlCab,
      AppStrings.fourWheeler,
      AppAssets.xlCab,
    ),
    _VehicleOption(
      'Auto',
      AppStrings.vehicleAuto,
      AppStrings.threeWheeler,
      AppAssets.auto,
    ),
    _VehicleOption(
      'Bike',
      AppStrings.vehicleBike,
      AppStrings.twoWheeler,
      AppAssets.bike,
    ),
  ];

  void _select(_VehicleOption vehicle) {
    setState(() => _showError = false);
    widget.onSelected(vehicle.value);
  }

  void _continue() {
    if (widget.selectedVehicle.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.onBack == null
            ? null
            : IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: context.themed(
                    light: Colors.black,
                    dark: context.torkk.textPrimary,
                  ),
                  size: 20,
                ),
                onPressed: widget.onBack,
              ),
        titleSpacing: widget.onBack == null ? context.w(20) : 0,
        centerTitle: false,
        toolbarHeight: context.h(64),
        backgroundColor: context.torkk.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppStrings.selectVehicleCategory,
          style: AppTypography.bold.copyWith(fontSize: 20, height: 1.15),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: context.w(16)),
            child: GestureDetector(
              onTap: widget.onHelp,
              child: Image.asset(
                AppAssets.helpButton,
                width: context.w(40),
                height: context.w(40),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.chooseVehicleType,
              style: AppTypography.bold.copyWith(
                color: context.torkk.textPrimary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            SizedBox(height: context.h(20)),
            Expanded(
              child: GridView.builder(
                itemCount: _vehicles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: context.h(12),
                  crossAxisSpacing: context.w(12),
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, index) {
                  final vehicle = _vehicles[index];
                  return _VehicleCard(
                    vehicle: vehicle,
                    selected: widget.selectedVehicle == vehicle.value,
                    onTap: () => _select(vehicle),
                  );
                },
              ),
            ),
            if (_showError) ...[
              SizedBox(height: context.h(8)),
              Row(
                children: [
                  Icon(
                    Icons.info,
                    color: context.legible(AppColors.error),
                    size: context.w(18),
                  ),
                  SizedBox(width: context.w(8)),
                  Expanded(
                    child: Text(
                      AppStrings.selectVehicleError,
                      style: AppTypography.regular.copyWith(
                        color: context.legible(AppColors.error),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: context.h(12)),
            UnifiedButton(
              label: AppStrings.continueAction,
              isLoading: widget.isLoading,
              onPressed: _continue,
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleOption {
  const _VehicleOption(this.value, this.label, this.subtitle, this.image);

  final String value;
  final String label;
  final String subtitle;
  final String image;
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  final _VehicleOption vehicle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(12),
            vertical: context.h(12),
          ),
          decoration: BoxDecoration(
            color: selected
                ? context.adaptiveTint(const Color(0xFFF6F3FB))
                : context.torkk.surface,
            borderRadius: BorderRadius.circular(context.r(16)),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.fieldBorder,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Expanded(
              //   child: Image.asset(
              //     vehicle.image,
              //     fit: BoxFit.contain,
              //     errorBuilder: (context, error, stackTrace) => Icon(
              //       Icons.directions_car_rounded,
              //       size: context.w(40),
              //       color: AppColors.secondaryTextColor,
              //     ),
              //   ),
              // ),
              SizedBox(
                width: context.w(100),
                height: context.h(85),
                child: Transform.scale(
                  scale: vehicle.value == 'Bike' ? 1.7 : 1.1,
                  child: Image.asset(
                    vehicle.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.directions_car_rounded,
                      size: context.w(40),
                      color: context.torkk.textSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.h(8)),
              Text(
                vehicle.label,
                style: AppTypography.bold.copyWith(fontSize: 15, height: 1.2),
              ),
              SizedBox(height: context.h(2)),
              Text(
                vehicle.subtitle,
                style: AppTypography.regular.copyWith(
                  fontSize: 12,
                  height: 1.2,
                  color: context.torkk.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
