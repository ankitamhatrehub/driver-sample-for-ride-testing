import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/service/driver_chat_websocket_service.dart';

// --- DRIVER-CUSTOMER IN-APP CHAT SCREEN ---
class DriverCustomerChatScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;

  const DriverCustomerChatScreen({
    super.key,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  State<DriverCustomerChatScreen> createState() =>
      _DriverCustomerChatScreenState();
}

class _DriverCustomerChatScreenState extends State<DriverCustomerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DriverChatWebSocketService _wsService = DriverChatWebSocketService();
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  final List<Map<String, String>> _messages = [
    {'sender': 'driver', 'text': 'I’ve arrived'},
    {'sender': 'driver', 'text': 'Where are you?'},
    {'sender': 'driver', 'text': 'Didn’t reach the location?'},
    {'sender': 'customer', 'text': 'Coming'},
  ];

  @override
  void initState() {
    super.initState();
    _initWebSocket();
  }

  Future<void> _initWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final phone =
        prefs.getString('user_phone') ?? prefs.getString('phone') ?? '';
    _wsService.connect(driverPhone: phone, rideId: 'chat_active');

    _wsSub = _wsService.messageStream.listen((msg) {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': msg['sender']?.toString() ?? 'customer',
            'text': msg['text']?.toString() ?? '',
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _wsService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _wsService.sendMessage(sender: 'driver', text: text, rideId: 'chat_active');

    setState(() {
      _messages.add({'sender': 'driver', 'text': text});
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.customerName.isNotEmpty
        ? widget.customerName[0].toUpperCase()
        : 'C';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.customerName.isNotEmpty ? widget.customerName : 'Customer',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isDriver = msg['sender'] == 'driver';

                return Align(
                  alignment: isDriver
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDriver
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: isDriver
                            ? const Radius.circular(4)
                            : const Radius.circular(20),
                        bottomLeft: !isDriver
                            ? const Radius.circular(4)
                            : const Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(
                        color: isDriver
                            ? Colors.white
                            : const Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: Colors.white),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF0F172A),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Send new message',
                                hintStyle: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          GestureDetector(
                            onTap: _sendMessage,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1D4ED8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.near_me_rounded,
                                color: Colors.white,
                                size: 18,
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
          ),
        ],
      ),
    );
  }
}

