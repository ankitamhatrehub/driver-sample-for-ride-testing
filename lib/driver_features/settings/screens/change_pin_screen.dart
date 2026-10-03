import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/app_text_field.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _submit(String value) async {
    if (value.length != 4 || _current.text.length != 4) return;
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getString('account_pin') ?? '') != _current.text) return;
    await prefs.setString('account_pin', value);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Change Pin',
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(16), context.w(20), context.h(20)),
        children: [
          Text('Current Pin', style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
          SizedBox(height: context.h(8)),
          AppTextField(
            controller: _current,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: context.h(16)),
          Text('New Pin', style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
          SizedBox(height: context.h(8)),
          AppTextField(
            controller: _next,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: _submit,
          ),
        ],
      ),
    );
  }
}
