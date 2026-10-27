part of 'package:rider_app/driver_features/onboarding/screens/verify_otp_screen.dart';

class _OtpCursorState extends State<_OtpCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _blink,
      child: Container(
        width: 1.6,
        height: context.h(22),
        color: AppColors.textPrimary,
      ),
    );
  }
}
