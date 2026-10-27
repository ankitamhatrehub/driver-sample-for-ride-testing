part of 'package:rider_app/driver_features/onboarding/screens/face_verification_screen.dart';

class _SuccessLine extends StatelessWidget {
  const _SuccessLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(18), left: context.w(16)),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.green600, size: context.w(18)),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Text(text, style: AppTypography.regular.copyWith(fontSize: 14, color: context.torkk.textPrimary)),
          ),
        ],
      ),
    );
  }
}
