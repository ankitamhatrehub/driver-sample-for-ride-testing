import 'package:flutter/material.dart';
import 'package:rider_app/common/widgets/custom_text_field.dart';
import 'package:rider_app/common/widgets/bouncing_widget.dart';

class CompleteProfileStep extends StatelessWidget {
  final Color primaryColor;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final bool agreedToTerms;
  final ValueChanged<bool?> onAgreedChanged;
  final VoidCallback onContinue;

  const CompleteProfileStep({
    super.key,
    required this.primaryColor,
    required this.phoneController,
    required this.emailController,
    required this.agreedToTerms,
    required this.onAgreedChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Complete Your Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: primaryColor,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: primaryColor,
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            labelText: 'Emergency Contact Phone',
            controller: phoneController,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            labelText: 'Email (Optional)',
            controller: emailController,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: agreedToTerms,
                activeColor: primaryColor,
                onChanged: onAgreedChanged,
              ),
              Expanded(
                child: Text(
                  'I agree to Terms & Conditions and Privacy Policy',
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          BouncingWidget(
            onTap: agreedToTerms ? onContinue : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: agreedToTerms ? primaryColor : Colors.grey,
                borderRadius: BorderRadius.circular(16),
                boxShadow: agreedToTerms
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: const Center(
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
