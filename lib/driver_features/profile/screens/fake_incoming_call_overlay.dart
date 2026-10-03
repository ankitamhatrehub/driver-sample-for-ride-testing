import 'dart:async';
import 'package:flutter/material.dart';

// --- FAKE INCOMING CALL OVERLAY SCREEN ---
class FakeIncomingCallOverlay extends StatefulWidget {
  const FakeIncomingCallOverlay({super.key});

  @override
  State<FakeIncomingCallOverlay> createState() =>
      _FakeIncomingCallOverlayState();
}

class _FakeIncomingCallOverlayState extends State<FakeIncomingCallOverlay> {
  bool _callAnswered = false;
  int _seconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _answerCall() {
    setState(() {
      _callAnswered = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  String _formatDuration() {
    final min = (_seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: _callAnswered
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const CircleAvatar(
                    radius: 64,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person_rounded,
                      size: 72,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Security Operations',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(),
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const Spacer(),
                  // End Call Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 64),
                    child: FloatingActionButton(
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.call_end, color: Colors.white),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const CircleAvatar(
                    radius: 64,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.security, size: 72, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Security Operations',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Torkk Safety Check',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 48,
                      right: 48,
                      bottom: 64,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Decline
                        Column(
                          children: [
                            FloatingActionButton(
                              heroTag: 'decline_fake_call',
                              onPressed: () => Navigator.pop(context),
                              backgroundColor: Colors.red,
                              child: const Icon(
                                Icons.call_end,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Decline',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        // Accept
                        Column(
                          children: [
                            FloatingActionButton(
                              heroTag: 'accept_fake_call',
                              onPressed: _answerCall,
                              backgroundColor: Colors.green,
                              child: const Icon(
                                Icons.call,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Accept',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
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
    );
  }
}

