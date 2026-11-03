import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/service/emergency_contacts_api_service.dart';

/// Form to add one emergency contact. Pops with `true` once saved.
class DriverEmergencyContactScreen extends StatefulWidget {
  const DriverEmergencyContactScreen({super.key});

  @override
  State<DriverEmergencyContactScreen> createState() =>
      _DriverEmergencyContactScreenState();
}

class _DriverEmergencyContactScreenState
    extends State<DriverEmergencyContactScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _nameError;
  String? _phoneError;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    setState(() {
      _nameError = name.isEmpty ? 'Enter a name' : null;
      _phoneError = phone.length != 10 ? 'Enter a valid 10 digit number' : null;
    });
    if (_nameError != null || _phoneError != null) return;

    setState(() => _saving = true);
    try {
      final contacts = await EmergencyContactsApiService.fetch();
      contacts.add({'name': name, 'phone': phone});
      await EmergencyContactsApiService.save(contacts);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Emergency contact added')));
      Navigator.of(context).pop(true);
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

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    String? error,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    String? prefixText,
    TextCapitalization capitalization = TextCapitalization.words,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.regular.copyWith(
              fontSize: 12,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(6)),
          TextField(
            controller: controller,
            enabled: !_saving,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            textCapitalization: capitalization,
            onChanged: (_) {
              if (error != null) {
                setState(() {
                  _nameError = null;
                  _phoneError = null;
                });
              }
            },
            decoration: InputDecoration(
              hintText: hint,
              prefixText: prefixText,
              errorText: error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.r(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Add Emergency Contact',
      subtitle: 'Whom you would contact in an emergency',
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(16),
        ),
        child: UnifiedButton(
          label: 'Save Contact',
          isLoading: _saving,
          onPressed: _save,
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(20),
        ),
        children: [
          _field('Name', _nameCtrl, hint: 'Enter name', error: _nameError),
          _field(
            'Mobile number',
            _phoneCtrl,
            hint: 'Enter mobile number',
            error: _phoneError,
            prefixText: '+91 ',
            keyboardType: TextInputType.phone,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
        ],
      ),
    );
  }
}
