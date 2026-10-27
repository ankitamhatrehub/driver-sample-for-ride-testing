part of 'package:rider_app/driver_features/onboarding/screens/verify_otp_screen.dart';

class _OtpBoxes extends StatefulWidget {
  const _OtpBoxes({
    required this.value,
    required this.length,
    required this.hasError,
    required this.controller,
    required this.focusNode,
  });

  final String value;
  final int length;
  final bool hasError;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}
