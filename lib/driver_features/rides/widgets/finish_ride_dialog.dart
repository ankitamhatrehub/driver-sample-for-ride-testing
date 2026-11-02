import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Confirmation dialog shown before completing the trip and collecting fare.
class FinishRideDialog extends StatelessWidget {
  final bool isGoingToPickup;
  final String estimatedFare;
  final VoidCallback onConfirm;

  const FinishRideDialog({
    super.key,
    required this.isGoingToPickup,
    required this.estimatedFare,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Finish Ride?',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        isGoingToPickup
            ? 'Are you sure you want to finish and complete this trip now?'
            : 'Complete ride and collect payment of ₹$estimatedFare?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: context.themed(
                light: Colors.grey,
                dark: context.torkk.textSecondary,
              ),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text('Confirm Finish'),
        ),
      ],
    );
  }
}
