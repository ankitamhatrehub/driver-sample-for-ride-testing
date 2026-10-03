import 'package:flutter/material.dart';

/// Animated accept ride button featuring a 20-second timeout countdown
/// and left-to-right filling blue progress bar.
class TimedAcceptRideButton extends StatefulWidget {
  final int rideId;
  final int timeoutSeconds;
  final VoidCallback onAccept;
  final VoidCallback onTimeout;

  const TimedAcceptRideButton({
    super.key,
    required this.rideId,
    this.timeoutSeconds = 20,
    required this.onAccept,
    required this.onTimeout,
  });

  @override
  State<TimedAcceptRideButton> createState() => _TimedAcceptRideButtonState();
}

class _TimedAcceptRideButtonState extends State<TimedAcceptRideButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timeoutSeconds),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTimeout();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.stop();
        widget.onAccept();
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF0B1E5B), // Unfilled Dark Navy background
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D4ED8).withAlpha(89),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              // Animated Blue Fill from Left to Right
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _animation.value,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF2563EB),
                            Color(0xFF1D4ED8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Centered Accept Ride Text & Countdown Badge
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Accept Ride',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        final remaining =
                            (widget.timeoutSeconds * (1.0 - _animation.value))
                                .ceil();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${remaining}s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
