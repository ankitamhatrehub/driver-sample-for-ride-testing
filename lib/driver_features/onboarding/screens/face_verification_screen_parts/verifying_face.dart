part of 'package:rider_app/driver_features/onboarding/screens/face_verification_screen.dart';

class _VerifyingFace extends StatefulWidget {
  const _VerifyingFace({required this.selfiePath, required this.onFinished});

  final String? selfiePath;
  final VoidCallback onFinished;

  @override
  State<_VerifyingFace> createState() => _VerifyingFaceState();
}
