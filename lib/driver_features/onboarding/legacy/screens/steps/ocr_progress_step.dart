import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class OcrProgressStep extends StatelessWidget {
  final Color primaryColor;
  final double ocrProgress;
  final String documentType;

  const OcrProgressStep({
    super.key,
    required this.primaryColor,
    required this.ocrProgress,
    this.documentType = 'Aadhaar',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 130,
                  decoration: BoxDecoration(
                    color: context.torkk.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.credit_card_outlined,
                      size: 64,
                      color: primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                // Laser Scanner Sweep Line
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Positioned(
                      top: 10 + 110 * value,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor,
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'Extracting Data...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.torkk.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we extract details from your $documentType',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: ocrProgress,
                minHeight: 8,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(ocrProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
