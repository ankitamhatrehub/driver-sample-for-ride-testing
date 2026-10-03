import 'package:flutter/material.dart';

// --- FAQ SCREEN ---
class DriverFaqScreen extends StatelessWidget {
  const DriverFaqScreen({super.key});

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'FAQs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Top Driver FAQs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildFaqItem(
            'How do I add or update my Driving License / RC?',
            'Navigate to the Partner Profile screen in the side drawer. Tap "Add" or "Edit" on the specific document tile. Provide the updated details and tap "Save" to refresh.',
          ),
          _buildFaqItem(
            'How do I change the route/path on the map?',
            'While on a ride, look at the bottom control sheet on the Map screen. You can select between "Show Full Route" (Pickup ➔ Drop overview) or "Show Current Navigation" path.',
          ),
          _buildFaqItem(
            'How are High Priority rides highlighted?',
            'High Priority rides requested by customers will show a prominent orange "PRIORITY" badge directly on the driver request card in your active rides screen.',
          ),
          _buildFaqItem(
            'How do I download my earnings statement?',
            'Go to your Wallet screen from the sidebar or profile screen. In the grid, tap the "Download Statement" block. It will process and download a PDF representation of your earnings.',
          ),
          _buildFaqItem(
            'How long do Cashout Settlements take?',
            'Requesting a cashout transfers your current wallet balance directly to your registered bank account or UPI ID. It typically processes within 1 to 2 business hours.',
          ),
        ],
      ),
    );
  }
}
