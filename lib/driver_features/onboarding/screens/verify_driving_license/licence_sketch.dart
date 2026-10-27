part of 'package:rider_app/driver_features/onboarding/screens/verify_driving_license_screen.dart';

class _LicenceSketch extends StatelessWidget {
  const _LicenceSketch({required this.badgeIcon, required this.badgeColor});

  final IconData badgeIcon;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.w(168),
      height: context.w(120),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: context.w(150),
            height: context.w(100),
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              color: context.adaptiveTint(const Color(0xFFF3F0FF)),
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: const Color(0xFFE4DDF3)),
            ),
            child: Row(
              children: [
                Container(
                  width: context.w(36),
                  height: context.w(36),
                  decoration: const BoxDecoration(color: Color(0xFFE7E0F4), shape: BoxShape.circle),
                  child: Icon(Icons.person, color: const Color(0xFFB7A8D6), size: context.w(22)),
                ),
                SizedBox(width: context.w(10)),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _line(context, 1),
                      SizedBox(height: context.h(6)),
                      _line(context, 0.72),
                      SizedBox(height: context.h(6)),
                      _line(context, 0.5),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: context.w(28),
              height: context.w(28),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(badgeIcon, color: Colors.white, size: context.w(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, double widthFactor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: context.h(6),
          decoration: BoxDecoration(color: const Color(0xFFE4DDF3), borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
