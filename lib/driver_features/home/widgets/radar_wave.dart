import 'package:flutter/material.dart';

/// Radar wave animation widget displayed during the online state.
class RadarWave extends StatefulWidget {
  const RadarWave({super.key});

  @override
  State<RadarWave> createState() => _RadarWaveState();
}

class _RadarWaveState extends State<RadarWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 90 * _controller.value,
              height: 90 * _controller.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF10B981,
                ).withValues(alpha: 1 - _controller.value),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF10B981),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.wifi_tethering_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        );
      },
    );
  }
}
