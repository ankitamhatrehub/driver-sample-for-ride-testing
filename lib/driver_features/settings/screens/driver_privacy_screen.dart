import 'package:flutter/material.dart';
import 'package:rider_app/common/widgets/ai_chat_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

// --- PRIVACY SCREEN (Figma Settings -> Privacy) ---
class DriverPrivacyScreen extends StatelessWidget {
  const DriverPrivacyScreen({super.key});

  Widget _buildPrivacyItem({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
  }) {
    final textColor = context.torkk.textPrimary;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: textColor, size: 26),
              ],
            ),
          ),
        ),
        Divider(height: 1, thickness: 1, color: context.torkk.border),
      ],
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password'),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Enter new password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password updated successfully!'),
                  backgroundColor: Color(0xFF1D4ED8),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPinDialog(BuildContext context) {
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Set Security PIN'),
        content: TextField(
          controller: pinCtrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Enter 4-digit PIN',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Security PIN set successfully!'),
                  backgroundColor: Color(0xFF1D4ED8),
                ),
              );
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = context.torkk.textPrimary;

    return Scaffold(
      floatingActionButton: const AiChatButton(size: 48),
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
              decoration: BoxDecoration(
                color: context.themed(
                  light: const Color(0xFF475569),
                  dark: context.torkk.surfaceMuted,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: context.themed(
                  light: Colors.white,
                  dark: context.torkk.textPrimary,
                ),
                size: 20,
              ),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 24),
              _buildPrivacyItem(
                context: context,
                title: 'Password',
                onTap: () => _showPasswordDialog(context),
              ),
              _buildPrivacyItem(
                context: context,
                title: 'Set PIN',
                onTap: () => _showPinDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
