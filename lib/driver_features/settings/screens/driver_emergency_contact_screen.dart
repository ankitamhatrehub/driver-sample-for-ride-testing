import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

/// SharedPreferences key holding the saved emergency contacts (JSON list of
/// `{name, phone, relation}` maps).
const String emergencyContactsKey = 'emergency_contacts';

Future<List<Map<String, String>>> loadEmergencyContacts() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(emergencyContactsKey);
  if (raw == null) return [];
  return (jsonDecode(raw) as List)
      .map((e) => Map<String, String>.from(e as Map))
      .toList();
}

Future<void> saveEmergencyContacts(List<Map<String, String>> contacts) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(emergencyContactsKey, jsonEncode(contacts));
}

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
  final _relationCtrl = TextEditingController();
  String? _nameError;
  String? _phoneError;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _relationCtrl.dispose();
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
    final contacts = await loadEmergencyContacts();
    contacts.add({
      'name': name,
      'phone': phone,
      'relation': _relationCtrl.text.trim(),
    });
    await saveEmergencyContacts(contacts);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Emergency contact added')));
    Navigator.of(context).pop(true);
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
          _field('Relation', _relationCtrl, hint: 'e.g. Sister'),
        ],
      ),
    );
  }
}
