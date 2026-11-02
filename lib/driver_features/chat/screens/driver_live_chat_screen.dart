import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/service/driver_api_service.dart';

class _ChatMessage {
  const _ChatMessage({
    required this.isUser,
    required this.text,
    this.isError = false,
  });
  final bool isUser;
  final String text;
  final bool isError;
}

/// Chat with Lui, the AI support assistant.
///
/// History: GET /api/chat/{conversation_id}/history
/// Send:    POST /api/chat/message
class DriverLiveChatScreen extends StatefulWidget {
  const DriverLiveChatScreen({super.key});

  @override
  State<DriverLiveChatScreen> createState() => _DriverLiveChatScreenState();
}

class _DriverLiveChatScreenState extends State<DriverLiveChatScreen> {
  static const _accent = Color(0xFF4F46E5);
  static const _accentSoft = Color(0xFF818CF8);
  static const _prefsKey = 'ai_chat_conversation_id';
  static const _welcome = _ChatMessage(
    isUser: false,
    text:
        'Hello Partner! I am Lui, your AI Support Assistant. How can I help you regarding the application today?',
  );

  final List<_ChatMessage> _messages = [];
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String _conversationId = '';
  bool _loadingHistory = true;
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Random v4 UUID, used when the driver has no conversation yet.
  static String _newUuid() {
    final rnd = Random.secure();
    final b = List<int>.generate(16, (_) => rnd.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    String hex(int from, int to) => b
        .sublist(from, to)
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_prefsKey) ?? '';
    if (id.isEmpty) {
      id = _newUuid();
      await prefs.setString(_prefsKey, id);
    }
    _conversationId = id;
    debugPrint('AI_CHAT_SCREEN_01 | conversation_id=$id');
    try {
      final history = await DriverApiService.fetchChatHistory(id);
      final parsed = history
          .whereType<Map>()
          .map(_fromJson)
          .whereType<_ChatMessage>()
          .toList();
      debugPrint(
        'AI_CHAT_SCREEN_02 | history items=${history.length} parsed=${parsed.length}',
      );
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(parsed.isEmpty ? [_welcome] : parsed);
        _loadingHistory = false;
      });
    } catch (e) {
      debugPrint('AI_CHAT_SCREEN_03 | history failed: $e');
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..add(_welcome);
        _loadingHistory = false;
      });
    }
    _scrollToBottom();
  }

  /// One history item. The backend may call the fields role/sender and
  /// message/content/text, so all of them are accepted.
  static _ChatMessage? _fromJson(Map item) {
    final text =
        (item['message'] ??
                item['content'] ??
                item['text'] ??
                item['body'] ??
                '')
            .toString()
            .trim();
    if (text.isEmpty) return null;
    final role =
        (item['role'] ??
                item['sender'] ??
                item['sender_type'] ??
                item['from'] ??
                '')
            .toString()
            .toLowerCase();
    final isUser =
        role == 'user' ||
        role == 'driver' ||
        role == 'customer' ||
        role == 'human' ||
        item['is_user'] == true;
    return _ChatMessage(isUser: isUser, text: text);
  }

  /// The AI reply out of the POST response body.
  static String? _replyFrom(dynamic body) {
    if (body is String) return body.trim().isEmpty ? null : body.trim();
    if (body is! Map) return null;
    for (final key in const [
      'reply',
      'response',
      'answer',
      'ai_message',
      'assistant_message',
      'message',
      'text',
      'content',
    ]) {
      final v = body[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is Map) {
        final inner = _replyFrom(v);
        if (inner != null) return inner;
      }
    }
    final data = body['data'];
    return data == null ? null : _replyFrom(data);
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _typing || _loadingHistory) return;
    _messageController.clear();
    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text));
      _typing = true;
    });
    _scrollToBottom();
    try {
      final body = await DriverApiService.sendChatMessage(
        conversationId: _conversationId,
        message: text,
      );
      final reply = _replyFrom(body);
      debugPrint('AI_CHAT_SCREEN_04 | reply=$reply');
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            isUser: false,
            text:
                reply ??
                'Sorry, I could not understand the reply. Please try again.',
            isError: reply == null,
          ),
        );
      });
    } catch (e) {
      debugPrint('AI_CHAT_SCREEN_05 | send failed: $e');
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            isUser: false,
            text: e.toString().replaceFirst('Exception: ', ''),
            isError: true,
          ),
        );
      });
    } finally {
      if (mounted) setState(() => _typing = false);
      _scrollToBottom();
    }
  }

  // ---------------------------------------------------------------- UI

  Widget _avatar({double size = 34}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accentSoft, _accent],
        ),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.45),
            blurRadius: size * 0.45,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    final t = context.torkk;
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: t.surface,
          border: Border(bottom: BorderSide(color: t.border)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: t.textPrimary,
                  ),
                ),
                _avatar(size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lui',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: t.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'AI Support Assistant',
                            style: TextStyle(
                              fontSize: 12,
                              color: t.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bubble(BuildContext context, _ChatMessage msg) {
    final t = context.torkk;
    final isUser = msg.isUser;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 18),
    );
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.75 : 0.68),
      ),
      decoration: BoxDecoration(
        gradient: isUser
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6366F1), _accent],
              )
            : null,
        color: isUser
            ? null
            : (msg.isError ? const Color(0x1ADC2626) : t.surface),
        borderRadius: radius,
        border: isUser
            ? null
            : Border.all(
                color: msg.isError ? const Color(0x55DC2626) : t.border,
              ),
        boxShadow: [
          BoxShadow(
            color: isUser
                ? _accent.withValues(alpha: 0.25)
                : const Color(0x0F000000),
            blurRadius: isUser ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        msg.text,
        style: TextStyle(
          color: isUser ? Colors.white : t.textPrimary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[_avatar(), const SizedBox(width: 8)],
          Flexible(child: bubble),
        ],
      ),
    );
  }

  Widget _typingIndicator(BuildContext context) {
    final t = context.torkk;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          _avatar(size: 28),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border),
            ),
            child: Text(
              'Lui is typing...',
              style: TextStyle(
                color: t.textSecondary,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar(BuildContext context) {
    final t = context.torkk;
    final enabled = !_typing && !_loadingHistory;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.border)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: t.surfaceMuted,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: t.border),
                  ),
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    style: TextStyle(color: t.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ask Lui anything...',
                      hintStyle: TextStyle(color: t.textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: enabled ? _sendMessage : null,
                child: AnimatedOpacity(
                  opacity: enabled ? 1 : 0.5,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_accentSoft, _accent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      appBar: _appBar(context),
      body: Column(
        children: [
          Expanded(
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator(color: _accent))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        _bubble(context, _messages[index]),
                  ),
          ),
          if (_typing) _typingIndicator(context),
          _inputBar(context),
        ],
      ),
    );
  }
}
