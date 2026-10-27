part of 'package:rider_app/driver_features/parcels/parcel_flow_screen.dart';

class _ParcelOtpBoxes extends StatefulWidget {
  const _ParcelOtpBoxes({required this.controller, required this.focusNode, required this.length});

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;

  @override
  State<_ParcelOtpBoxes> createState() => _ParcelOtpBoxesState();
}
