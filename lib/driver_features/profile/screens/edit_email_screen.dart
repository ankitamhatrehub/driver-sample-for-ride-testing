import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/service/driver_api_service.dart';

/// Shows the current email and lets the driver set a new one.
/// Pops with the new email on success.
class EditEmailScreen extends StatefulWidget {
  const EditEmailScreen({super.key, required this.currentEmail});

  final String currentEmail;

  @override
  State<EditEmailScreen> createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _controller = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _controller.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }
    if (email.toLowerCase() == widget.currentEmail.toLowerCase()) {
      setState(() => _error = 'This is already your email');
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      print('Updating email to: $email');
      await DriverApiService.updateEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email updated successfully')),
      );
      Navigator.of(context).pop(email);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.emailAddress,
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New email',
              style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary),
            ),
            SizedBox(height: context.h(6)),
            TextField(
              controller: _controller,
              enabled: !_saving,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                hintText: 'Enter new email address',
                errorText: _error,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.r(12)),
                ),
              ),
            ),
            SizedBox(height: context.h(14)),
            UnifiedButton(
              label: AppStrings.edit,
              icon: Icons.edit,
              iconAtEnd: true,
              isLoading: _saving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(28), context.h(30), context.w(28), context.h(20)),
        children: [
          ProfileMenuCard(
            items: [
              ProfileValueRow(
                icon: Icons.mail_outline,
                label: 'Current email',
                value: widget.currentEmail.isEmpty ? 'Not added' : widget.currentEmail,
                trailing: const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
