part of 'package:rider_app/driver_features/onboarding/screens/face_verification_screen.dart';

class _IconInfoRow extends StatelessWidget {
  const _IconInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: context.h(58),
      padding: EdgeInsets.symmetric(horizontal: context.w(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(32),
            height: context.w(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.adaptiveTint(const Color(0xFFFAF5FF)),
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
            child: Icon(
              icon,
              color: context.legible(AppColors.primary),
              size: context.w(16),
            ),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Text(
              text,
              style: AppTypography.regular.copyWith(
                fontSize: 13,
                height: 1.2,
                color: context.torkk.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
