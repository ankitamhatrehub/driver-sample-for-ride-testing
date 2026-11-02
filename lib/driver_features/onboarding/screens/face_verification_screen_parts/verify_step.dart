part of 'package:rider_app/driver_features/onboarding/screens/face_verification_screen.dart';

class _VerifyStep extends StatelessWidget {
  const _VerifyStep({
    required this.label,
    required this.state,
    this.last = false,
  });

  final String label;
  final _StepState state;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final done = state == _StepState.done;
    final active = state == _StepState.active;
    final color = done || active ? AppColors.green600 : AppColors.slate300;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (active)
              Container(
                width: context.w(18),
                height: context.w(18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.adaptiveTint(Color(0xFFD1FAE5)),
                ),
                child: Container(
                  width: context.w(8),
                  height: context.w(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green600,
                  ),
                ),
              )
            else
              Icon(
                done ? Icons.check_circle : Icons.circle_outlined,
                color: color,
                size: context.w(18),
              ),
            if (!last)
              Container(
                width: 2,
                height: context.h(22),
                color: done ? AppColors.green600 : AppColors.slate200,
              ),
          ],
        ),
        SizedBox(width: context.w(10)),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: context.h(1)),
            child: Text(
              label,
              style: AppTypography.regular.copyWith(
                fontSize: 14,
                fontWeight: done || active ? FontWeight.w700 : FontWeight.w400,
                color: done || active
                    ? context.legible(AppColors.textPrimary)
                    : context.legible(AppColors.secondaryTextColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
