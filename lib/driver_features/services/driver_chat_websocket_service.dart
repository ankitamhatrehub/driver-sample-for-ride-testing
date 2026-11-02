import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../common/constants/app_urls.dart';

class DriverChatWebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  bool get isConnected => _channel != null;

  void connect({required String driverPhone, String rideId = '0'}) {
    try {
      final uri = Uri.parse(
        AppUrls.chatWebSocket(phone: driverPhone, rideId: rideId),
      );

      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (data) {
          try {
            final jsonMsg = json.decode(data);
            if (jsonMsg is Map<String, dynamic>) {
              _messageController.add(jsonMsg);
            }
          } catch (_) {
            _messageController.add({
              'text': data.toString(),
              'sender': 'customer',
            });
          }
        },
        onError: (err) {
          debugPrint('[WebSocket Error] $err');
          _reconnect(driverPhone: driverPhone, rideId: rideId);
        },
        onDone: () {
          debugPrint('[WebSocket Closed]');
          _channel = null;
        },
      );
    } catch (e) {
      debugPrint('[WebSocket Exception] $e');
    }
  }

  void _reconnect({required String driverPhone, required String rideId}) {
    disconnect();
    Future.delayed(const Duration(seconds: 3), () {
      connect(driverPhone: driverPhone, rideId: rideId);
    });
  }

  void sendMessage({
    required String sender,
    required String text,
    required String rideId,
  }) {
    if (_channel != null) {
      final payload = json.encode({
        'sender': sender,
        'text': text,
        'ride_id': rideId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _channel!.sink.add(payload);
    }
  }

  void disconnect() {
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }
}
