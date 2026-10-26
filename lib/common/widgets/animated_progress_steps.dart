import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class ProgressStep {
  const ProgressStep({required this.title, this.subtitle});

  final String title;
  final String? subtitle;
}

/// Steps that complete one after another. [onCompleted] runs only after the last step finishes.
class AnimatedProgressSteps extends StatefulWidget {
  const AnimatedProgressSteps({
    super.key,
    required this.steps,
    required this.onCompleted,
    this.stepDuration = const Duration(milliseconds: 1100),
  });

  final List<ProgressStep> steps;
  final VoidCallback onCompleted;
  final Duration stepDuration;

  @override
  State<AnimatedProgressSteps> createState() => _AnimatedProgressStepsState();
}

class _AnimatedProgressStepsState extends State<AnimatedProgressSteps>
    with SingleTickerProviderStateMixin {
  int _done = 0;
  Timer? _timer;
  Timer? _finish;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _timer = Timer.periodic(widget.stepDuration, (_) => _advance());
  }

  void _advance() {
    if (!mounted) return;
    final next = _done + 1;
    setState(() => _done = next);
    if (next < widget.steps.length) return;
    _timer?.cancel();
    _finish = Timer(const Duration(milliseconds: 450), () {
      if (mounted) widget.onCompleted();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _finish?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < widget.steps.length; i++)
          _ProgressStepRow(
            step: widget.steps[i],
            done: i < _done,
            active: i == _done && _done < widget.steps.length,
            last: i == widget.steps.length - 1,
            pulse: _pulse,
          ),
      ],
    );
  }
}

class _ProgressStepRow extends StatelessWidget {
  const _ProgressStepRow({
    required this.step,
    required this.done,
    required this.active,
    required this.last,
    required this.pulse,
  });

  final ProgressStep step;
  final bool done;
  final bool active;
  final bool last;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final titleColor = done || active
        ? context.torkk.textPrimary
        : AppColors.slate400;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.w(32),
          child: Column(
            children: [
              SizedBox(
                width: context.w(32),
                height: context.w(32),
                child: Center(child: _marker(context)),
              ),
              if (!last)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  width: 2,
                  height: context.h(56),
                  color: done ? AppColors.green600 : context.torkk.border,
                ),
            ],
          ),
        ),
        SizedBox(width: context.w(14)),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: context.h(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTypography.bold.copyWith(
                    fontSize: 13,
                    height: 1.2,
                    letterSpacing: -0.2,
                    color: titleColor,
                  ),
                ),
                if (step.subtitle != null) ...[
                  SizedBox(height: context.h(4)),
                  Text(
                    step.subtitle!,
                    style: AppTypography.regular.copyWith(
                      fontSize: 11,
                      height: 1.3,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _marker(BuildContext context) {
    if (done) {
      return Container(
        width: context.w(24),
        height: context.w(24),
        decoration: const BoxDecoration(
          color: AppColors.green600,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, color: Colors.white, size: context.w(15)),
      );
    }
    if (active) {
      return AnimatedBuilder(
        animation: pulse,
        builder: (context, child) {
          final scale = 0.92 + (pulse.value * 0.08);
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: context.w(28),
          height: context.w(28),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.adaptiveTint(Color(0xFFDCFCE7)),
            shape: BoxShape.circle,
          ),
          child: Container(
            width: context.w(14),
            height: context.w(14),
            decoration: const BoxDecoration(
              color: Color(0xFF86EFAC),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return Container(
      width: context.w(22),
      height: context.w(22),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.slate300, width: 2),
      ),
    );
  }
}
