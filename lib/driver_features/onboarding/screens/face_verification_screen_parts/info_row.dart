part of 'package:rider_app/driver_features/onboarding/screens/face_verification_screen.dart';

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w(333),
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
            child: Image.asset(icon, width: context.w(18), height: context.w(18), fit: BoxFit.contain),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.regular.copyWith(fontSize: 13, height: 1.2, color: context.themed(light: Colors.black, dark: context.torkk.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}
