import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

// --- FAQ SCREEN ---
class DriverFaqScreen extends StatelessWidget {
  const DriverFaqScreen({super.key});

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.torkk.border),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: context.torkk.textPrimary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 13,
                color: context.torkk.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.surfaceMuted,
      appBar: AppBar(
        title: const Text(
          'FAQs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.torkk.background,
        foregroundColor: context.themed(
          light: Colors.black,
          dark: context.torkk.textPrimary,
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Top Driver FAQs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: context.torkk.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildFaqItem(
            context,
            'How do I add or update my Driving License / RC?',
            'Navigate to the Partner Profile screen in the side drawer. Tap "Add" or "Edit" on the specific document tile. Provide the updated details and tap "Save" to refresh.',
          ),
          _buildFaqItem(
            context,
            'How do I change the route/path on the map?',
            'While on a ride, look at the bottom control sheet on the Map screen. You can select between "Show Full Route" (Pickup ➔ Drop overview) or "Show Current Navigation" path.',
          ),
          _buildFaqItem(
            context,
            'How are High Priority rides highlighted?',
            'High Priority rides requested by customers will show a prominent orange "PRIORITY" badge directly on the driver request card in your active rides screen.',
          ),
          _buildFaqItem(
            context,
            'How do I download my earnings statement?',
            'Go to your Wallet screen from the sidebar or profile screen. In the grid, tap the "Download Statement" block. It will process and download a PDF representation of your earnings.',
          ),
          _buildFaqItem(
            context,
            'How long do Cashout Settlements take?',
            'Requesting a cashout transfers your current wallet balance directly to your registered bank account or UPI ID. It typically processes within 1 to 2 business hours.',
          ),
        ],
      ),
    );
  }
}
