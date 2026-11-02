import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

// --- DRIVER DOCUMENTS SCREEN (Figma Docs) ---
class DriverDocumentsScreen extends StatefulWidget {
  const DriverDocumentsScreen({super.key});

  @override
  State<DriverDocumentsScreen> createState() => _DriverDocumentsScreenState();
}

class _DriverDocumentsScreenState extends State<DriverDocumentsScreen> {
  String _aadhaarNumber = '';
  String _dlNumber = '';
  String _rcNumber = '';

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _aadhaarNumber = prefs.getString('aadhaar_number') ?? '';
        _dlNumber = prefs.getString('driving_licence_number') ?? '';
        _rcNumber = prefs.getString('rc_number') ?? '';
      });
    }
  }

  Widget _buildDocItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final textColor = context.torkk.textPrimary;
    final subTextColor = context.torkk.textSecondary;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right_rounded, color: textColor, size: 26),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: context.torkk.border,
          indent: 24,
          endIndent: 24,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = context.torkk.textPrimary;

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
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Documents',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Uploaded Documents',
                style: TextStyle(
                  fontSize: 13,
                  color: context.torkk.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDocItem(
              context,
              title: 'Aadhar Card',
              subtitle: _aadhaarNumber.isNotEmpty
                  ? _aadhaarNumber
                  : 'See your Aadhar Card',
              onTap: () {},
            ),
            _buildDocItem(
              context,
              title: 'Drivers Licence',
              subtitle: _dlNumber.isNotEmpty
                  ? _dlNumber
                  : 'See your Drivers Licence',
              onTap: () {},
            ),
            _buildDocItem(
              context,
              title: 'RC',
              subtitle: _rcNumber.isNotEmpty ? _rcNumber : 'See your RC',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
