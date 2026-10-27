part of 'package:rider_app/driver_features/onboarding/screens/verify_otp_screen.dart';

class _OtpBoxContent extends StatelessWidget {
  const _OtpBoxContent({
    required this.char,
    required this.showCursor,
    required this.cursorBeforeDigit,
  });

  final String char;
  final bool showCursor;
  final bool cursorBeforeDigit;

  @override
  Widget build(BuildContext context) {
    final digit = Text(
      char,
      style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
    );
    if (!showCursor) return digit;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (cursorBeforeDigit && char.isNotEmpty) const _OtpCursor(),
        if (char.isNotEmpty) digit,
        if (!cursorBeforeDigit) const _OtpCursor(),
      ],
    );
  }
}
