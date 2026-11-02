import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../common/widgets/bouncing_widget.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class DocumentEntryStep extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onDigilockerTap;
  final VoidCallback onCameraTap;
  final String title;
  final String? subtitle;
  final String input1Hint;
  final TextEditingController input1Controller;
  final String? input2Hint;
  final TextEditingController? input2Controller;
  final String? imagePath;
  final int stepIndex; // 2: Aadhaar (segments 1 & 2 green), 3: DL, 4: RC

  const DocumentEntryStep({
    super.key,
    required this.onBack,
    required this.onContinue,
    required this.onDigilockerTap,
    required this.onCameraTap,
    required this.title,
    this.subtitle,
    required this.input1Hint,
    required this.input1Controller,
    this.input2Hint,
    this.input2Controller,
    this.imagePath,
    this.stepIndex = 2,
  });

  @override
  Widget build(BuildContext context) {
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
                  final isFilled = index < stepIndex;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
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

              const SizedBox(height: 20),

              // Guide Banner / Uploaded Image Container
              GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.torkk.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: imagePath != null
                          ? context.legible(Color(0xFF2563EB))
                          : const Color(0xFFE2E8F0),
                      width: imagePath != null ? 2 : 1,
                    ),
                    image: DecorationImage(
                      image: imagePath != null
                          ? FileImage(File(imagePath!)) as ImageProvider
                          : const AssetImage('assets/kyc_guide_banner.png'),
                      fit: BoxFit.cover,
                      alignment: imagePath != null
                          ? Alignment.center
                          : const Alignment(0, -0.55),
                    ),
                  ),
                  child: imagePath != null
                      ? Stack(
                          children: [
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Change Photo',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 24),

              // Title & Subtitle
              Text(
                title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: context.torkk.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: context.torkk.textSecondary,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ],

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
                    color: context.torkk.surface,
                    border: Border.all(
                      color: context.legible(Color(0xFF2563EB)),
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
                          color: context.adaptiveTint(const Color(0xFFEFF6FF)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          'assets/digilocker.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.cloud_done_rounded,
                              color: context.legible(Color(0xFF2563EB)),
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Automatically Fill\nfrom Digilocker',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.torkk.textPrimary,
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

              const SizedBox(height: 20),

              // Or Divider
              Row(
                children: [
                  Expanded(child: Divider(color: context.torkk.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Or',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: context.torkk.border)),
                ],
              ),

              const SizedBox(height: 20),

              // Input 1 Field Label
              Text(
                input1Hint,
                style: TextStyle(
                  color: context.torkk.textBody,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: input1Controller,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.torkk.textPrimary,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFE5E7EB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.legible(Color(0xFF2563EB)),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),

              // Input 2 Field (if available)
              if (input2Hint != null && input2Controller != null) ...[
                const SizedBox(height: 18),
                Text(
                  input2Hint!,
                  style: TextStyle(
                    color: context.torkk.textBody,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: input2Controller,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.torkk.textPrimary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFE5E7EB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: context.legible(Color(0xFF2563EB)),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),

        // Bottom Continue Button
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
}

// Figma-accurate Aadhaar FAQ Bottom Sheet
class AadhaarFaqBottomSheet extends StatefulWidget {
  const AadhaarFaqBottomSheet({super.key});

  @override
  State<AadhaarFaqBottomSheet> createState() => _AadhaarFaqBottomSheetState();
}

class _AadhaarFaqBottomSheetState extends State<AadhaarFaqBottomSheet> {
  final List<bool> _expanded = [true, true, true, true];

  final List<Map<String, String>> _faqItems = [
    {
      'q': 'How can I submit my Aadhaar Card?',
      'a':
          'Use DigiLocker for instant automatic verification, or enter your 12-digit Aadhaar Card Number manually.',
    },
    {
      'q': 'Is DigiLocker verification safe?',
      'a':
          'Yes, DigiLocker is a Government of India platform that ensures secure, encrypted document verification.',
    },
    {
      'q': 'Where can I find my Aadhaar Number?',
      'a':
          'Your 12-digit Aadhaar Number is printed on the front of your physical Aadhaar card or e-Aadhaar PDF.',
    },
    {
      'q': 'Why is my Aadhaar verification failing?',
      'a':
          'Ensure your Aadhaar is linked to your active mobile number for OTP verification, or check if manual entries are correct.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.torkk.surface,
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
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: context.torkk.textPrimary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: context.torkk.textPrimary,
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
                  Text(
                    'FAQ',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: context.torkk.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_faqItems.length, (index) {
                    final item = _faqItems[index];
                    final isExpanded = _expanded[index];
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
                              children: [
                                Expanded(
                                  child: Text(
                                    item['q']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: context.torkk.textPrimary,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: context.torkk.textSecondary,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded) ...[
                          Text(
                            item['a']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.torkk.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Divider(color: context.torkk.border, height: 1),
                      ],
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Figma-accurate DL FAQ Bottom Sheet
class DlFaqBottomSheet extends StatefulWidget {
  const DlFaqBottomSheet({super.key});

  @override
  State<DlFaqBottomSheet> createState() => _DlFaqBottomSheetState();
}

class _DlFaqBottomSheetState extends State<DlFaqBottomSheet> {
  final List<bool> _expanded = [true, true, true, true];

  final List<Map<String, String>> _faqItems = [
    {
      'q': 'How can I submit my Driving Licence?',
      'a':
          'Use DigiLocker to automatically fetch your DL details, or enter your DL Number and Date of Birth manually.',
    },
    {
      'q': 'Is DigiLocker mandatory?',
      'a':
          'No. DigiLocker is recommended for faster verification, but you can also submit your dl number',
    },
    {
      'q': 'Where can I find my DL Number?',
      'a':
          'Your DL Number is printed on your Driving Licence. Enter it exactly as shown.',
    },
    {
      'q': 'Why is my DL not being verified?',
      'a':
          'Check that your DL Number and Date of Birth match your official records. If the issue continues, contact Torkk Support.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.torkk.surface,
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
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: context.torkk.textPrimary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: context.torkk.textPrimary,
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
                  Text(
                    'FAQ',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: context.torkk.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Solution to frequent asked questions',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.torkk.textSecondary,
                    ),
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
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: context.torkk.textPrimary,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isOpen
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: context.torkk.textPrimary,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isOpen) ...[
                          Text(
                            item['a']!,
                            style: TextStyle(
                              fontSize: 15,
                              color: context.torkk.textBody,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        Divider(color: context.torkk.border, height: 1),
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

// Figma-accurate RC FAQ Bottom Sheet
class RcFaqBottomSheet extends StatefulWidget {
  const RcFaqBottomSheet({super.key});

  @override
  State<RcFaqBottomSheet> createState() => _RcFaqBottomSheetState();
}

class _RcFaqBottomSheetState extends State<RcFaqBottomSheet> {
  final List<bool> _expanded = [true, true, true, true];

  final List<Map<String, String>> _faqItems = [
    {
      'q': 'How can I submit my RC details?',
      'a':
          'Use DigiLocker to automatically fetch your vehicle details, or enter your RC Number manually.',
    },
    {
      'q': 'Is DigiLocker mandatory?',
      'a':
          'No. DigiLocker is recommended, but you can also submit your RC Number manually.',
    },
    {
      'q': 'Where can I find my RC Number?',
      'a':
          'Your RC Number is available on your Vehicle Registration Certificate. Enter it exactly as shown.',
    },
    {
      'q': 'Why is my RC not being verified?',
      'a':
          'Check that your RC Number is correct and matches your official vehicle records. If the issue continues, contact Torkk Support.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.torkk.surface,
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
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: context.torkk.textPrimary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: context.torkk.textPrimary,
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
                  Text(
                    'FAQ',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: context.torkk.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Solution to frequent asked questions',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.torkk.textSecondary,
                    ),
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
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: context.torkk.textPrimary,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isOpen
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: context.torkk.textPrimary,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isOpen) ...[
                          Text(
                            item['a']!,
                            style: TextStyle(
                              fontSize: 15,
                              color: context.torkk.textBody,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        Divider(color: context.torkk.border, height: 1),
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
