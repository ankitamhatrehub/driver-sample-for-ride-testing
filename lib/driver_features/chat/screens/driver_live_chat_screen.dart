import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

// --- LIVE CHAT SCREEN USING GEMINI API ---
class DriverLiveChatScreen extends StatefulWidget {
  const DriverLiveChatScreen({super.key});

  @override
  State<DriverLiveChatScreen> createState() => _DriverLiveChatScreenState();
}

class _DriverLiveChatScreenState extends State<DriverLiveChatScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          'Hello Partner! I am your AI Support Assistant. How can I help you regarding the application today?',
    },
  ];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _typing = false;

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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _typing = true;
    });
    _scrollToBottom();

    try {
      final uri = Uri.parse(
        AppUrls.geminiGenerateContent(AppUrls.geminiApiKey),
      );

      final contents = [];

      contents.add({
        'role': 'user',
        'parts': [
          {
            'text':
                'SYSTEM INSTRUCTION: You are the helpful BlackOriginX Driver Support Assistant. You assist taxi and delivery drivers using our mobile app. The application features include: '
                '- Profile Verification: Uploading Aadhaar, Driving License, RC, Vehicle Insurance, and PUC. All can be added or updated dynamically directly inside the "Partner Profile" screen. '
                '- Onboarding flow steps: OTP Verification, Aadhaar Upload & OCR, DL Upload & OCR, RC Upload & OCR, PUC Upload & OCR, Vehicle Insurance Upload & OCR, Selfie Face Match, Bank Details verification. '
                '- Ride-wise and Wallet Earnings: Shows daily, weekly, monthly, and all-time earnings. Drivers can cash out. '
                '- Navigation Toggle: Toggle between "Show Full Route" and "Show Current Navigation" on the map screen. '
                '- High Priority Rides: Rides requested by customers with high priority have a bold orange "PRIORITY" badge on the request card. '
                '- Trip History: Tabbed views for "Completed" and "Cancelled" rides. Tap the "i" info icon next to any ride to view the invoice details. '
                'Answer driver queries concisely based on this knowledge.',
          },
        ],
      });
      contents.add({
        'role': 'model',
        'parts': [
          {
            'text':
                'Understood. I will act as the BlackOriginX Driver Support Assistant and answer queries concisely based on this knowledge.',
          },
        ],
      });

      for (final msg in _messages) {
        contents.add({
          'role': msg['isUser'] == true ? 'user' : 'model',
          'parts': [
            {'text': msg['text']},
          ],
        });
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'contents': contents}),
      );

      if (response.statusCode == 200) {
        final respJson = jsonDecode(response.body);
        if (respJson['candidates'] != null &&
            (respJson['candidates'] as List).isNotEmpty) {
          final reply =
              respJson['candidates'][0]['content']['parts'][0]['text'];
          if (mounted) {
            setState(() {
              _messages.add({'isUser': false, 'text': reply.trim()});
            });
          }
        } else {
          throw Exception('No content candidate returned');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'text':
                'Sorry, I am facing an issue connecting. Please try again later.',
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _typing = false;
        });
      }
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4F46E5);
    return Scaffold(
      backgroundColor: context.torkk.surfaceMuted,
      appBar: AppBar(
        title: const Text(
          'Live AI Chat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.torkk.background,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
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
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? primaryColor : context.torkk.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottomRight: isUser
                            ? Radius.zero
                            : const Radius.circular(16),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : context.themed(light: Colors.black87, dark: context.torkk.textPrimary),
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_typing)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'AI Assistant is typing...',
                  style: TextStyle(
                    color: context.torkk.textSecondary,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            color: context.torkk.surface,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: context.torkk.border),
                        ),
                        filled: true,
                        fillColor: context.torkk.surfaceMuted,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send_rounded, color: primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- SUPPORT SCREENS MOVED TO lib/driver/screens/support/ ---


