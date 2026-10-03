import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../common/widgets/bouncing_widget.dart';

class BankDetailsStep extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final TextEditingController accountController;
  final TextEditingController ifscController;
  final TextEditingController bankNameController;
  final TextEditingController upiController;
  final Color primaryColor;

  const BankDetailsStep({
    super.key,
    required this.onContinue,
    required this.onSkip,
    required this.accountController,
    required this.ifscController,
    required this.bankNameController,
    required this.upiController,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              const SizedBox(height: 16),
              const Text(
                'Bank Details or UPI',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  height: 1.1,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your Bank Deatils or UPI id for Payouts',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),

              _buildFieldLabel('Account Number'),
              _buildTextField(
                accountController,
                TextInputType.number,
                maxLength: 16,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),
              const SizedBox(height: 20),

              _buildFieldLabel('IFSC Code'),
              _buildTextField(
                ifscController,
                TextInputType.text,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
              const SizedBox(height: 20),

              _buildFieldLabel('Bank Name'),
              _buildTextField(bankNameController, TextInputType.text),
              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'Or',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildFieldLabel('UPI ID'),
              _buildTextField(upiController, TextInputType.emailAddress),
              const SizedBox(height: 32),
            ],
          ),
        ),

        // Action Buttons at bottom
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              BouncingWidget(
                onTap: onContinue,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D4ED8), // Figma Blue button
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      'Continue →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: onSkip,
                  child: const Text(
                    'Skip for Now',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    TextInputType keyboardType, {
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFD1D5DB).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF111827),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          counterText: '',
        ),
      ),
    );
  }
}

// Figma-accurate Payment / Bank Details FAQ Bottom Sheet
class PaymentFaqBottomSheet extends StatefulWidget {
  const PaymentFaqBottomSheet({super.key});

  @override
  State<PaymentFaqBottomSheet> createState() => _PaymentFaqBottomSheetState();
}

class _PaymentFaqBottomSheetState extends State<PaymentFaqBottomSheet> {
  final List<bool> _expanded = [true, true, true, true];

  final List<Map<String, String>> _faqItems = [
    {
      'q': 'Why do I need bank details or a UPI ID?',
      'a': 'To receive payouts from Torkk.',
    },
    {
      'q': 'What bank details do I need to provide?',
      'a': 'Account Number, IFSC Code, and Bank Name.',
    },
    {
      'q': 'Can I use UPI instead of bank details?',
      'a': 'Yes. You can provide a valid UPI ID instead.',
    },
    {
      'q': 'What if my bank details or UPI ID are not accepted?',
      'a': 'Recheck your details. If the issue continues, contact Torkk Support.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Top Bar (Back button & Chat Icon)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF111827),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFF111827),
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                children: [
                  const Text(
                    'FAQ',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Solution to frequent asked questions',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(_faqItems.length, (index) {
                    final item = _faqItems[index];
                    final isOpen = _expanded[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _expanded[index] = !_expanded[index];
                            });
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['q']!,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isOpen
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: const Color(0xFF111827),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isOpen) ...[
                          Text(
                            item['a']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const Divider(color: Color(0xFFE5E7EB), height: 1),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: BouncingWidget(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27272A),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      'Continue →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
