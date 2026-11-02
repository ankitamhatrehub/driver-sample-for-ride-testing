import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Bottom drawer displayed during active navigation showing dynamic GPS ETA,
/// instructions, and quick chat access.
class NavigationEtaDrawer extends StatelessWidget {
  final String etaText;
  final String instructionText;
  final VoidCallback onTap;
  final VoidCallback onChat;

  const NavigationEtaDrawer({
    super.key,
    required this.etaText,
    required this.instructionText,
    required this.onTap,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: context.torkk.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.format_list_bulleted_rounded,
                  color: context.torkk.textBody,
                  size: 24,
                ),
                Column(
                  children: [
                    Text(
                      etaText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: context.torkk.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      instructionText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.torkk.textSecondary,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onChat,
                  child: Image.asset(
                    'assets/chat_icon.png',
                    width: 22,
                    height: 22,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
