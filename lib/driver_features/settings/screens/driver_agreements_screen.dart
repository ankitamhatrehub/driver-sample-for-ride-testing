import 'package:flutter/material.dart';
import 'package:rider_app/common/widgets/ai_chat_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

// --- AGREEMENTS SCREEN (Figma Settings -> Agreements) ---
class DriverAgreementsScreen extends StatelessWidget {
  const DriverAgreementsScreen({super.key});

  Widget _buildAgreementItem({
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

  void _showDocumentViewer(
    BuildContext context,
    String title,
    String contentText,
  ) {
    final textColor = context.torkk.textPrimary;
    final sheetBg = context.torkk.surface;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.themed(
                    light: Colors.grey.shade300,
                    dark: context.torkk.border,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  contentText,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: context.torkk.textBody,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  foregroundColor: onColorFor(
                    context.brandColor,
                  ),
                  backgroundColor: context.brandColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'I Understand & Accept',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
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
                'Agreements',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 24),
              _buildAgreementItem(
                context: context,
                title: 'Terms and Conditions',
                onTap: () => _showDocumentViewer(
                  context,
                  'Terms and Conditions',
                  'Welcome to Torkk Mobility. By accessing or using our driver partner platform, you agree to comply with all terms and rules laid out in this service agreement. Drivers must maintain valid licences, vehicle insurance, and adhere to traffic regulations at all times.',
                ),
              ),
              _buildAgreementItem(
                context: context,
                title: 'Privacy Policy',
                onTap: () => _showDocumentViewer(
                  context,
                  'Privacy Policy',
                  'Your privacy is critical to Torkk. We collect location, trip details, and account info solely for trip dispatch, safety, payout processing, and service improvements. Your personal information is encrypted and never sold to third parties.',
                ),
              ),
              _buildAgreementItem(
                context: context,
                title: 'Driver Agreement',
                onTap: () => _showDocumentViewer(
                  context,
                  'Driver Agreement',
                  'This Driver Partner Agreement defines the independent contract relationship between Torkk and the driver partner. You maintain full flexibility regarding your operating hours, trips accepted, and earnings payouts.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
