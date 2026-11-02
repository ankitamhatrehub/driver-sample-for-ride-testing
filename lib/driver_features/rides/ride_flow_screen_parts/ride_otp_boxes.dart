part of 'package:rider_app/driver_features/rides/ride_flow_screen.dart';

class _RideOtpBoxes extends StatefulWidget {
  const _RideOtpBoxes({
    required this.controller,
    required this.focusNode,
    required this.length,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;

  @override
  State<_RideOtpBoxes> createState() => _RideOtpBoxesState();
}
