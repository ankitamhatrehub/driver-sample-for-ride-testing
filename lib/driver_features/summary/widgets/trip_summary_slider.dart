import 'package:flutter/material.dart';

class TripSummarySlider extends StatefulWidget {
  final bool completing;
  final VoidCallback onAction;

  const TripSummarySlider({
    super.key,
    required this.completing,
    required this.onAction,
  });

  @override
  State<TripSummarySlider> createState() => _TripSummarySliderState();
}

class _TripSummarySliderState extends State<TripSummarySlider> {
  double _dragOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        const thumbWidth = 52.0;
        final maxDrag = maxWidth - thumbWidth;

        return Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF0C1B4D),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Center(
                child: Text(
                  widget.completing
                      ? 'Processing...'
                      : 'Slide to Finish the Ride',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Positioned(
                left: _dragOffset,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (widget.completing) return;
                    setState(() {
                      _dragOffset = (_dragOffset + details.delta.dx).clamp(
                        0.0,
                        maxDrag,
                      );
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragOffset > maxDrag * 0.65) {
                      setState(() => _dragOffset = maxDrag);
                      widget.onAction();
                      Future.delayed(const Duration(milliseconds: 600), () {
                        if (mounted) setState(() => _dragOffset = 0.0);
                      });
                    } else {
                      setState(() => _dragOffset = 0.0);
                    }
                  },
                  onTap: () {
                    if (widget.completing) return;
                    widget.onAction();
                  },
                  child: Container(
                    width: thumbWidth,
                    height: thumbWidth,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D4ED8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
