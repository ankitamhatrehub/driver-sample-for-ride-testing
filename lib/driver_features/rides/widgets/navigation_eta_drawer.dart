import 'package:flutter/material.dart';

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
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
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
                const Icon(
                  Icons.format_list_bulleted_rounded,
                  color: Color(0xFF334155),
                  size: 24,
                ),
                Column(
                  children: [
                    Text(
                      etaText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      instructionText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
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
