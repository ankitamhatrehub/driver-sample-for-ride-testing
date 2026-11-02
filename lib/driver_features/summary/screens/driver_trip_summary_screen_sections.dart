part of 'package:rider_app/driver_features/summary/screens/driver_trip_summary_screen.dart';

extension _DriverTripSummaryScreenStateSections
    on _DriverTripSummaryScreenState {
  void _finishAndGoHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('driver_is_online', true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip completed and feedback submitted!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
    context.go(AppRoutes.home);
  }

  Widget _buildPaymentSlider() {
    return TripSummarySlider(completing: _completing, onAction: _completeTrip);
  }
}
