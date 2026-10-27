part of 'package:rider_app/driver_features/onboarding/screens/face_verification_screen.dart';

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(18)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: context.w(34),
            height: context.w(34),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: Icon(icon, color: iconColor, size: context.w(18)),
          ),
          SizedBox(width: context.w(14)),
          Expanded(
            child: Text(
              text,
              style: AppTypography.regular.copyWith(
                fontSize: 14,
                height: 1.35,
                color: context.torkk.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
