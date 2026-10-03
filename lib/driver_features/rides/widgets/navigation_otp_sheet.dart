import 'package:flutter/material.dart';

void showRideOtpBottomSheet({
  required BuildContext context,
  String? rideCode,
  String? subtitle,
  required void Function(String otp) onVerify,
}) {
  final otpController = TextEditingController();
  String? errorText;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final text = otpController.text;
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 14,
              bottom: MediaQuery.of(context).viewInsets.bottom + 28,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle ?? 'Ask the Passenger for OTP',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                if ((rideCode ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Test tip: passenger ride code is $rideCode',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                // 4 OTP Boxes with exact Figma specs (width: 70, height: 56, radius: 24px, border-width: 1px, opacity: 0.4)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (index) {
                        final char = index < text.length ? text[index] : '';
                        final isFilled = char.isNotEmpty;

                        return Opacity(
                          opacity: isFilled ? 1.0 : 0.4,
                          child: Container(
                            width: 70,
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isFilled
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isFilled
                                    ? const Color(0xFF1142BC)
                                    : const Color(0xFF94A3B8),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              char,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    Opacity(
                      opacity: 0.0,
                      child: TextField(
                        controller: otpController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        onChanged: (val) {
                          setSheetState(() {
                            errorText = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (otpController.text.length < 4) {
                        setSheetState(() {
                          errorText = 'Please enter 4-digit OTP';
                        });
                        return;
                      }
                      Navigator.pop(sheetContext);
                      onVerify(otpController.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1142BC),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
