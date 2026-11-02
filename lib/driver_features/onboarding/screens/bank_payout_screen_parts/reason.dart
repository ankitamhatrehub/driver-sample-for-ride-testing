part of 'package:rider_app/driver_features/onboarding/screens/bank_payout_screen.dart';

class _Reason extends StatelessWidget {
  const _Reason(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.cancel,
          color: context.legible(AppColors.error),
          size: context.w(16),
        ),
        SizedBox(width: context.w(8)),
        Expanded(
          child: Text(
            text,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              color: context.legible(AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
