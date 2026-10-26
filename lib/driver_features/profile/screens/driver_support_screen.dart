import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

// --- HELP TAB: CHAT SUPPORT SCREEN (Figma Help) ---
class DriverSupportScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const DriverSupportScreen({super.key, this.onClose});

  @override
  State<DriverSupportScreen> createState() => _DriverSupportScreenState();
}

class _DriverSupportScreenState extends State<DriverSupportScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? customText]) {
    final text = (customText ?? _controller.text).trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'text': text, 'isUser': true});
      if (customText == null) _controller.clear();
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'text':
                'Thank you for reaching out! Our support team is assisting you.',
            'isUser': false,
          });
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = context.torkk.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BACK BUTTON & BLUE CHAT HEADER BANNER
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed:
                      widget.onClose ?? () => Navigator.maybePop(context),
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 36,
                    color: textColor,
                  ),
                ),
              ),
            ),
            // BLUE BANNER HEADER (#0F4CBA)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              color: const Color(0xFF0F4CBA),
              child: Row(
                children: [
                  // Torkk Logo Circle Badge
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1E3A8A),
                          Color(0xFF3B82F6),
                          Color(0xFF9333EA),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'TORKK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Chat Support',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // CHAT MESSAGES LIST
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 40,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0F4CBA,
                                ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.support_agent_rounded,
                                size: 48,
                                color: Color(0xFF0F4CBA),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'How can we help you?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Type a message below to start chatting with TORKK Support.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.torkk.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg['isUser'] == true;

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.72,
                            ),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF0F4CBA)
                                  : (context.themed(light: const Color(0xFFE5E7EB), dark: context.torkk.surfaceMuted)),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: Radius.circular(isUser ? 18 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 18),
                              ),
                            ),
                            child: Text(
                              msg['text'] ?? '',
                              style: TextStyle(
                                color: isUser
                                    ? Colors.white
                                    : (context.themed(light: const Color(0xFF1F2937), dark: context.torkk.textPrimary)),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // BOTTOM INPUT BAR (Figma exact match)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              color: bgColor,
              child: Row(
                children: [
                  // Circular (+) Button (Grey fill #D9DCE1)
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.themed(light: const Color(0xFFD9DCE1), dark: context.torkk.surfaceMuted),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: context.themed(light: const Color(0xFF4B5563), dark: context.torkk.textBody),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Grey Pill Input Bar (#D9DCE1) with Send button inside right
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.only(left: 16, right: 5),
                      decoration: BoxDecoration(
                        color: context.themed(light: const Color(0xFFD9DCE1), dark: context.torkk.surface),
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              onSubmitted: (_) => _sendMessage(),
                              style: TextStyle(
                                fontSize: 14,
                                color: context.themed(light: const Color(0xFF1F2937), dark: context.torkk.textPrimary),
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                filled: false,
                                fillColor: Colors.transparent,
                                hintText: 'Send new message',
                                hintStyle: TextStyle(
                                  color: context.themed(light: const Color(0xFF4B5563), dark: context.torkk.textSecondary),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _sendMessage(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F4CBA),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
