import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/profile/widgets/vehicle_header.dart';
import 'package:rider_app/service/driver_api_service.dart';

class VehicleInformationScreen extends StatefulWidget {
  const VehicleInformationScreen({super.key});

  @override
  State<VehicleInformationScreen> createState() =>
      _VehicleInformationScreenState();
}

class _VehicleInformationScreenState extends State<VehicleInformationScreen> {
  String _vehicleModel = '';
  String _vehicleType = '';
  String _vehicleNumber = '';
  String _licenseNumber = '';
  String _registrationNumber = '';
  String _insuranceExpiry = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// First non-empty value for any of [keys] across the profile and the
  /// objects it may nest the vehicle under.
  static String _pick(List<Map> sources, List<String> keys) {
    for (final source in sources) {
      for (final key in keys) {
        final v = source[key];
        if (v != null &&
            v.toString().trim().isNotEmpty &&
            v.toString() != 'null') {
          return v.toString().trim();
        }
      }
    }
    return '';
  }

  static String _titleCase(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone') ?? '';
    // Local values from onboarding show first, the API fills in over them.
    if (mounted) {
      setState(() {
        _vehicleType = _titleCase(prefs.getString('vehicle_type') ?? '');
        _licenseNumber = prefs.getString('driving_licence_number') ?? '';
        _registrationNumber = prefs.getString('rc_number') ?? '';
      });
    }
    if (phone.isEmpty) return;
    try {
      final profile = await DriverApiService.fetchProfile(phone);
      debugPrint('VEHICLE_SCREEN_01 | profile response=$profile');
      final sources = <Map>[profile];
      for (final key in const [
        'driver',
        'data',
        'profile',
        'vehicle',
        'vehicle_details',
      ]) {
        final nested = profile[key];
        if (nested is Map) sources.add(nested);
      }
      final type = _pick(sources, ['vehicle_type', 'type']);
      final model = _pick(sources, [
        'vehicle_model',
        'model',
        'vehicle_name',
        'vehicle_make',
      ]);
      final number = _pick(sources, [
        'vehicle_number',
        'vehicle_no',
        'registration_number',
        'plate_number',
      ]);
      final license = _pick(sources, [
        'driving_licence_number',
        'driving_license_number',
        'license_number',
        'dl_number',
      ]);
      final rc = _pick(sources, [
        'rc_number',
        'registration_certificate_number',
      ]);
      final insurance = _pick(sources, [
        'insurance_expiry_date',
        'insurance_expiry',
        'insurance_valid_till',
      ]);
      debugPrint(
        'VEHICLE_SCREEN_02 | type=$type model=$model number=$number license=$license rc=$rc insurance=$insurance',
      );
      if (!mounted) return;
      setState(() {
        if (type.isNotEmpty) _vehicleType = _titleCase(type);
        _vehicleModel = model;
        _vehicleNumber = number;
        if (license.isNotEmpty) _licenseNumber = license;
        if (rc.isNotEmpty) _registrationNumber = rc;
        _insuranceExpiry = insurance;
      });
    } catch (e) {
      debugPrint('VEHICLE_SCREEN_03 | load failed: $e');
    }
  }

  static String _show(String value) => value.isEmpty ? '-' : value;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.vehicleInformation,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(12),
          context.w(20),
          context.h(12),
        ),
        children: [
          VehicleHeader(title: _vehicleType),
          SizedBox(height: context.h(12)),
          ProfileMenuCard(
            items: [
              ProfileValueRow(
                icon: Icons.two_wheeler_outlined,
                label: AppStrings.vehicleModel,
                value: _show(_vehicleModel),
              ),
              ProfileValueRow(
                icon: Icons.directions_car_outlined,
                label: AppStrings.vehicleType,
                value: _show(_vehicleType),
              ),
            ],
          ),
          SizedBox(height: context.h(12)),
          ProfileMenuCard(
            items: [
              ProfileValueRow(
                icon: Icons.article_outlined,
                label: AppStrings.vehicleNumber,
                value: _show(_vehicleNumber),
              ),
              ProfileValueRow(
                icon: Icons.article_outlined,
                label: AppStrings.licenseNumber,
                value: _show(_licenseNumber),
              ),
              ProfileValueRow(
                icon: Icons.vpn_key_outlined,
                label: AppStrings.registrationNumber,
                value: _show(_registrationNumber),
              ),
            ],
          ),
          SizedBox(height: context.h(12)),
          ProfileMenuCard(
            items: [
              ProfileValueRow(
                icon: Icons.article_outlined,
                label: AppStrings.insuranceExpiryDate,
                value: _show(_insuranceExpiry),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
