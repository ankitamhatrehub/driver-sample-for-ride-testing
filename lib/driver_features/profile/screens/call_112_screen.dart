import 'package:flutter/material.dart';

// --- CALL 112 SCREEN (Emergency Dialing UI) ---
class Call112Screen extends StatefulWidget {
  const Call112Screen({super.key});

  @override
  State<Call112Screen> createState() => _Call112ScreenState();
}

class _Call112ScreenState extends State<Call112Screen> {
  bool _isMuted = false;
  bool _isSpeaker = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                "112",
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 40),

              // Large Avatar Circle
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 6),
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 110, color: Colors.white),
                ),
              ),
              const Spacer(),

              // Speaker & Mute Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                    child: Container(
                      width: 90,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isSpeaker
                            ? Colors.white
                            : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: _isSpeaker ? Colors.black : Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => setState(() => _isMuted = !_isMuted),
                    child: Container(
                      width: 90,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isMuted
                            ? Colors.white
                            : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.mic_off_rounded,
                        color: _isMuted ? Colors.black : Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Red End Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "End",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
