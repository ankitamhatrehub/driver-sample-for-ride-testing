import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

// --- CALL SUPPORT SCREEN ---
class DriverCallSupportScreen extends StatelessWidget {
  const DriverCallSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      appBar: AppBar(
        title: const Text(
          'Call Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.torkk.background,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: Colors.green,
                  size: 72,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Speak to Support Representative',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.torkk.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Our Partner Support hotline is available 24/7 to resolve operations and billing inquiries.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.torkk.textSecondary),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: context.torkk.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.torkk.border),
                ),
                child: Text(
                  '+1 (800) 555-0199',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: context.torkk.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Simulating telephone dialer initiation...',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.call, color: Colors.white),
                  label: const Text(
                    'Call Helpline Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: onColorFor(Colors.green),
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
