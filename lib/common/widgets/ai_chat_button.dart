import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/chat/screens/driver_live_chat_screen.dart';

/// Opens the AI assistant chat screen.
void openAiChatScreen(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const DriverLiveChatScreen()),
  );
}

/// Frosted circle with a soft gradient orb and sparkle icon. Same look as the
/// AI button beside the bottom nav bar; use it anywhere the AI chat is opened.
class AiChatButton extends StatelessWidget {
  const AiChatButton({super.key, required this.size, this.onTap});

  final double size;

  /// Defaults to opening the AI chat screen.
  final VoidCallback? onTap;

  static LinearGradient _gradient(BuildContext context, double opacity) {
    const degrees = 286.17;
    final radians = degrees * math.pi / 180;
    final dx = math.sin(radians);
    final dy = -math.cos(radians);
    final female =
        Theme.of(context).colorScheme.primary == AppColors.femalePink;
    final colors = female
        ? const [Color(0xFFE85AAD), Color(0xFFBA2879), Color(0xFF6B1848)]
        : const [Color(0xFF0F3FBF), Color(0xFF61217E), Color(0xFF40105F)];
    return LinearGradient(
      begin: Alignment(-dx, -dy),
      end: Alignment(dx, dy),
      colors: [for (final color in colors) color.withValues(alpha: opacity)],
      stops: const [0, 0.5, 1],
    );
  }

  @override
  Widget build(BuildContext context) {
    final orb = size * 0.68;
    return GestureDetector(
      onTap: onTap ?? () => openAiChatScreen(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x0F000000)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: context.torkk.surface,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Wide, faint glow, then the feathered orb on top of it.
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                    child: Container(
                      width: orb,
                      height: orb,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _gradient(context, 0.65),
                      ),
                    ),
                  ),
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                    child: Container(
                      width: orb * 0.82,
                      height: orb * 0.82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _gradient(context, 0.95),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: size * 0.3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
