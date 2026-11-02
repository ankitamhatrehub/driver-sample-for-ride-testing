part of 'package:rider_app/driver_features/onboarding/screens/bank_payout_screen.dart';

class _BankStep extends StatelessWidget {
  const _BankStep({
    required this.label,
    required this.done,
    required this.active,
    this.note,
    this.last = false,
  });

  final String label;
  final String? note;
  final bool done;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? AppColors.green600
        : (active ? AppColors.primary : AppColors.slate300);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              done
                  ? Icons.check_circle
                  : (active ? Icons.circle : Icons.circle_outlined),
              color: color,
              size: context.w(18),
            ),
            if (!last)
              Container(
                width: 2,
                height: context.h(36),
                color: done ? AppColors.green600 : AppColors.slate200,
              ),
          ],
        ),
        SizedBox(width: context.w(10)),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: context.h(1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.regular.copyWith(
                    fontSize: 13,
                    fontWeight: active || done
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: done || active
                        ? context.legible(AppColors.textPrimary)
                        : context.legible(AppColors.secondaryTextColor),
                  ),
                ),
                if (note != null)
                  Text(
                    note!,
                    style: AppTypography.regular.copyWith(
                      fontSize: 12,
                      color: context.torkk.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
