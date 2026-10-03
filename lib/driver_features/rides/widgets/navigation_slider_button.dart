import 'package:flutter/material.dart';

class NavigationSliderButton extends StatefulWidget {
  final bool isDrop;
  final bool isProcessing;
  final VoidCallback onAction;

  const NavigationSliderButton({
    super.key,
    required this.isDrop,
    required this.isProcessing,
    required this.onAction,
  });

  @override
  State<NavigationSliderButton> createState() => _NavigationSliderButtonState();
}

class _NavigationSliderButtonState extends State<NavigationSliderButton> {
  double _dragOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    final label = widget.isDrop
        ? 'Slide to Finish the Ride'
        : 'Slide to Start the Ride';

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
                  widget.isProcessing ? 'Processing...' : label,
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
                    if (widget.isProcessing) return;
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
                    if (widget.isProcessing) return;
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
