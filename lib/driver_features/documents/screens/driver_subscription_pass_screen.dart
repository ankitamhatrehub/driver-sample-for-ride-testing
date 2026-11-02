import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

// --- DRIVER SUBSCRIPTION PASS SCREEN (Coming Soon) ---
class DriverSubscriptionPassScreen extends StatelessWidget {
  const DriverSubscriptionPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = context.torkk.background;
    final textColor = context.torkk.textPrimary;
    final subTextColor = context.torkk.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Top Left Close Button
            Positioned(
              top: 16,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: context.themed(
                      light: const Color(0xFF475569),
                      dark: context.torkk.surface,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            // Center Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Blue Circle Badge with White Diagonal Line
                    Container(
                      width: 86,
                      height: 86,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1D4ED8),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Transform.rotate(
                          angle: -0.785, // -45 degrees diagonal bar
                          child: Container(
                            width: 36,
                            height: 6,
                            decoration: BoxDecoration(
                              color: context.torkk.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This feature is coming in next update',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: subTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
