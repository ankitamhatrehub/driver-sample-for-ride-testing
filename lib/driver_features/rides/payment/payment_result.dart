import 'package:rider_app/common/constants/string_constants.dart';

/// What the driver collected for a ride. Shown on the Ride Completed screen.
class RidePaymentResult {
  const RidePaymentResult({
    required this.total,
    required this.upi,
    required this.cash,
    required this.change,
    required this.outstanding,
  });

  final double total;
  final double upi;
  final double cash;
  final double change;
  final double outstanding;

  /// Short label for how the rider paid.
  String get label {
    final parts = <String>[
      if (upi > 0) AppStrings.payMethodUpi,
      if (cash > 0) AppStrings.payMethodCash,
    ];
    final base = parts.isEmpty
        ? AppStrings.payUnpaid
        : '${AppStrings.payPaid} ${parts.join(' + ')}';
    return outstanding > 0
        ? '$base · ${AppStrings.payDue('₹${outstanding.round()}')}'
        : base;
  }
}
