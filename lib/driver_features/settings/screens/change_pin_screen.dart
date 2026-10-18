import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/app_snackbar.dart';
import 'package:rider_app/common/widgets/app_text_field.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

import '../../../common/constants/string_constants.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    final currentPin = _current.text.trim();
    final newPin = _next.text.trim();
    final confirmPin = _confirm.text.trim();

    if (currentPin.length != 4) {
      setState(() => _errorMessage = 'Please enter your current 4-digit PIN');
      return;
    }

    if (newPin.length != 4) {
      setState(() => _errorMessage = 'Please enter a new 4-digit PIN');
      return;
    }

    if (newPin != confirmPin) {
      setState(() => _errorMessage = 'New PIN and Confirm PIN do not match');
      return;
    }

    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('account_pin') ?? '';

    if (savedPin.isNotEmpty && savedPin != currentPin) {
      setState(() {
        _loading = false;
        _errorMessage = 'Incorrect current PIN. Please try again.';
      });
      return;
    }

    await prefs.setString('account_pin', newPin);

    if (mounted) {
      AppSnackBar.showSuccess(
        context,
        title: 'PIN Changed',
        message: 'Your account PIN has been updated successfully.',
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.changePin,
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(16), context.w(20), context.h(20)),
        children: [
          Text(AppStrings.currentPin, style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
          SizedBox(height: context.h(8)),
          AppTextField(
            controller: _current,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            hasError: _errorMessage != null && _current.text.length != 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: context.h(16)),
          Text(AppStrings.newPin, style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
          SizedBox(height: context.h(8)),
          AppTextField(
            controller: _next,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: context.h(16)),
          Text('Confirm New PIN', style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
          SizedBox(height: context.h(8)),
          AppTextField(
            controller: _confirm,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          if (_errorMessage != null) ...[
            SizedBox(height: context.h(14)),
            Row(
              children: [
                Icon(Icons.error_outline_rounded, color: AppColors.error, size: context.w(18)),
                SizedBox(width: context.w(8)),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: AppTypography.regular.copyWith(color: AppColors.error, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: context.h(28)),
          UnifiedButton(
            label: 'Save PIN',
            isLoading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
