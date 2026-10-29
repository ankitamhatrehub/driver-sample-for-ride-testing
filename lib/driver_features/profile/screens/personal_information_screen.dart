import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/screens/edit_email_screen.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/service/driver_api_service.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  String _name = '';
  String _gender = '';
  String _driverId = '';
  String _phone = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone') ?? '';
    if (mounted) {
      setState(() {
        _phone = phone;
        _name = prefs.getString('user_name') ?? '';
        _gender = prefs.getString('user_gender') ?? '';
      });
    }
    if (phone.isEmpty) return;
    try {
      final profile = await DriverApiService.fetchProfile(phone);
      String pick(List<String> keys) {
        for (final k in keys) {
          final v = profile[k];
          if (v != null && v.toString().trim().isNotEmpty) {
            return v.toString().trim();
          }
        }
        return '';
      }

      if (!mounted) return;
      setState(() {
        _name = pick(['name']).isNotEmpty ? pick(['name']) : _name;
        _gender = pick(['gender']).isNotEmpty ? pick(['gender']) : _gender;
        _driverId = pick(['driver_id', 'id']);
        _phone = pick(['phone', 'mobile']).isNotEmpty
            ? pick(['phone', 'mobile'])
            : _phone;
        _email = pick(['email']);
      });
    } catch (e) {
      debugPrint('Error loading personal information: $e');
    }
  }

  Future<void> _editEmail() async {
    final updated = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => EditEmailScreen(currentEmail: _email)),
    );
    if (updated != null && mounted) setState(() => _email = updated);
  }

  @override
  Widget build(BuildContext context) {
    final lock = Icon(
      Icons.lock_outline_rounded,
      color: AppColors.slate400,
      size: context.w(18),
    );
    return ProfilePage(
      title: AppStrings.personalInformation,
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(28), context.h(30), context.w(28), context.h(20)),
        children: [
          ProfileMenuCard(
            items: [
              ProfileValueRow(icon: Icons.person_outline, label: AppStrings.name, value: _name, trailing: lock),
              ProfileValueRow(icon: Icons.person_outline, label: AppStrings.gender, value: _gender, trailing: lock),
              ProfileValueRow(icon: Icons.badge_outlined, label: AppStrings.driversId, value: _driverId, trailing: lock),
              ProfileValueRow(icon: Icons.phone_outlined, label: AppStrings.mobileNumber, value: _phone, trailing: lock),
              ProfileValueRow(
                icon: Icons.mail_outline,
                label: AppStrings.emailAddress,
                value: _email,
                onTap: _editEmail,
                trailing: Icon(
                  Icons.edit_outlined,
                  color: AppColors.slate400,
                  size: context.w(18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
