import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/screens/sos_screen.dart';

/// The red SOS circle. Opens the SOS screen.
class SosCircleButton extends StatelessWidget {
  const SosCircleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const SosScreen())),
      child: Container(
        width: context.w(56),
        height: context.w(56),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFEF4444),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          'SOS',
          style: AppTypography.bold.copyWith(
            fontSize: 13,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// A full-width bottom sheet with the SOS button sitting just above it on the
/// right. The sheet sizes itself to its content, and the SOS button follows its
/// top edge, so it stays exactly above the sheet whatever the height.
class SheetWithSos extends StatelessWidget {
  const SheetWithSos({super.key, required this.sheet, this.showSos = true});

  final Widget sheet;
  final bool showSos;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSos)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: context.w(16),
                bottom: context.h(12),
              ),
              child: const SosCircleButton(),
            ),
          ),
        sheet,
      ],
    );
  }
}
