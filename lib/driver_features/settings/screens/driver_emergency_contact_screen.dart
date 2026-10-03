import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- EMERGENCY CONTACT SCREEN ---
class DriverEmergencyContactScreen extends StatefulWidget {
  const DriverEmergencyContactScreen({super.key});

  @override
  State<DriverEmergencyContactScreen> createState() =>
      _DriverEmergencyContactScreenState();
}

class _DriverEmergencyContactScreenState
    extends State<DriverEmergencyContactScreen> {
  final TextEditingController _pNameCtrl = TextEditingController();
  final TextEditingController _pPhoneCtrl = TextEditingController();
  final TextEditingController _pRelationCtrl = TextEditingController();

  final TextEditingController _sNameCtrl = TextEditingController();
  final TextEditingController _sPhoneCtrl = TextEditingController();
  final TextEditingController _sRelationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _pNameCtrl.dispose();
    _pPhoneCtrl.dispose();
    _pRelationCtrl.dispose();
    _sNameCtrl.dispose();
    _sPhoneCtrl.dispose();
    _sRelationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _pNameCtrl.text = prefs.getString('emergency_p_name') ?? '';
        _pPhoneCtrl.text = prefs.getString('emergency_p_phone') ?? '';
        _pRelationCtrl.text = prefs.getString('emergency_p_relation') ?? '';

        _sNameCtrl.text = prefs.getString('emergency_s_name') ?? '';
        _sPhoneCtrl.text = prefs.getString('emergency_s_phone') ?? '';
        _sRelationCtrl.text = prefs.getString('emergency_s_relation') ?? '';
      });
    }
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergency_p_name', _pNameCtrl.text.trim());
    await prefs.setString('emergency_p_phone', _pPhoneCtrl.text.trim());
    await prefs.setString('emergency_p_relation', _pRelationCtrl.text.trim());

    await prefs.setString('emergency_s_name', _sNameCtrl.text.trim());
    await prefs.setString('emergency_s_phone', _sPhoneCtrl.text.trim());
    await prefs.setString('emergency_s_relation', _sRelationCtrl.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency contacts saved successfully!'),
          backgroundColor: Color(0xFF1D4ED8),
        ),
      );
    }
  }

  Widget _buildInputField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    String hint = '',
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final fillColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0).withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(
                color: Color(0xFF1D4ED8),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF475569),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emergency Contact',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Whom you would contact in emergency',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),

              // PRIMARY CONTACT
              Text(
                'Primary Contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 14),
              _buildInputField(context, 'Name', _pNameCtrl),
              _buildInputField(context, 'Mobile Number', _pPhoneCtrl),
              _buildInputField(context, 'Relation', _pRelationCtrl),

              const SizedBox(height: 16),

              // SECONDARY CONTACT
              Text(
                'Secondary Contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 14),
              _buildInputField(context, 'Name', _sNameCtrl),
              _buildInputField(context, 'Mobile Number', _sPhoneCtrl),
              _buildInputField(context, 'Relation', _sRelationCtrl),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveContacts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Save Contacts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
