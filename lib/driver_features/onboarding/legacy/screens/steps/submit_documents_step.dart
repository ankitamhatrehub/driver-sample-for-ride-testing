import 'package:flutter/material.dart';
import '../../../../../common/widgets/bouncing_widget.dart';

class SubmitDocumentsStep extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onDigilockerTap;
  final VoidCallback onAadharTap;
  final VoidCallback onDlTap;
  final VoidCallback onRcTap;
  final bool isAadharCompleted;
  final bool isDlCompleted;
  final bool isRcCompleted;
  final String? title;
  final String? sectionTitle;

  const SubmitDocumentsStep({
    super.key,
    required this.onBack,
    required this.onContinue,
    required this.onDigilockerTap,
    required this.onAadharTap,
    required this.onDlTap,
    required this.onRcTap,
    this.isAadharCompleted = false,
    this.isDlCompleted = false,
    this.isRcCompleted = false,
    this.title,
    this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAllCompleted =
        isAadharCompleted && isDlCompleted && isRcCompleted;
    final String displayTitle = title ??
        (isAllCompleted ? 'All Set to Drive!' : 'KYC Verification');
    final String displaySectionTitle = sectionTitle ??
        (isAllCompleted ? 'Submitted Documents' : 'Required Documents');

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              const SizedBox(height: 8),
              // 4-Step Progress Indicator
              Row(
                children: List.generate(4, (index) {
                  final isFilled = isAllCompleted ? true : (index == 0);
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8.0 : 0.0),
                      decoration: BoxDecoration(
                        color: isFilled
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 36),

              // Title
              Text(
                displayTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  height: 1.1,
                  letterSpacing: -0.4,
                ),
              ),

              // Subtitle (Shown only when KYC is pending)
              if (!isAllCompleted) ...[
                const SizedBox(height: 8),
                const Text(
                  'Required for Torkk operations in your city.\nWe\'ll verify most details automatically',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),

                // DigiLocker Card
                BouncingWidget(
                  onTap: onDigilockerTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFF2563EB),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 44,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset(
                            'assets/digilocker.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Icon(
                                Icons.cloud_done_rounded,
                                color: Color(0xFF2563EB),
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Automatically Fill\nfrom Digilocker',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Recommended',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE5E7EB), height: 1),
              const SizedBox(height: 24),

              // Section Title (Required Documents vs Submitted Documents)
              Text(
                displaySectionTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),

              // Document 1: Aadhar Card
              _buildDocItem(
                title: 'Aadhar Card',
                subtitle: 'Submit Aadhar Card Number',
                isCompleted: isAadharCompleted,
                onTap: onAadharTap,
              ),

              // Document 2: Driving License
              _buildDocItem(
                title: 'Driving License',
                subtitle: 'Submit your DL Number',
                isCompleted: isDlCompleted,
                onTap: onDlTap,
              ),

              // Document 3: RC
              _buildDocItem(
                title: 'RC',
                subtitle: 'Submit your Vehicle RC',
                isCompleted: isRcCompleted,
                onTap: onRcTap,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),

        // Bottom Action Button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: BouncingWidget(
            onTap: onContinue,
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
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocItem({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                isCompleted
                    ? Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      )
                    : const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
              ],
            ),
          ),
        ),
        const Divider(color: Color(0xFFE5E7EB), height: 1),
      ],
    );
  }
}

// Figma-accurate KYC FAQ Bottom Sheet
class KycFaqBottomSheet extends StatefulWidget {
  const KycFaqBottomSheet({super.key});

  @override
  State<KycFaqBottomSheet> createState() => _KycFaqBottomSheetState();
}

class _KycFaqBottomSheetState extends State<KycFaqBottomSheet> {
  final List<bool> _expanded = [true, true, true, true];

  final List<Map<String, String>> _faqItems = [
    {
      'q': 'What documents are required for KYC?',
      'a':
          'Aadhaar Card, Driving Licence (DL), and Vehicle Registration Certificate (RC) are required to complete KYC.',
    },
    {
      'q': 'How does DigiLocker verification work?',
      'a':
          'DigiLocker securely fetches your available document details and automatically fills them in, making the KYC process faster and easier.',
    },
    {
      'q': 'Can I submit my documents manually?',
      'a':
          'Yes. If you don\'t want to use DigiLocker or your documents aren\'t available there, you can enter the required details manually.',
    },
    {
      'q': 'What if my KYC verification fails?',
      'a':
          'Check that all document details are correct, valid, and match your official records. If the issue continues, contact Torkk Support.',
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
                              fontSize: 15,
                              color: Color(0xFF4B5563),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        const Divider(color: Color(0xFFE5E7EB), height: 1),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Bottom Continue Button
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
