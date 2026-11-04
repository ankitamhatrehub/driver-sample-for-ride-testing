import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rider_app/common/widgets/ai_chat_button.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/service/driver_api_service.dart';
import 'package:rider_app/driver_features/profile/screens/driver_support_screen.dart';
import 'package:rider_app/driver_features/chat/screens/driver_customer_chat_screen.dart';
import '../widgets/trip_summary_slider.dart';
import '../widgets/report_customer_dialog.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
part 'driver_trip_summary_screen_sections.dart';

class DriverTripSummaryScreen extends StatefulWidget {
  final int rideId;
  final String driverPhone;
  final double estimatedFare;
  final String customerName;
  final String customerPhone;

  const DriverTripSummaryScreen({
    super.key,
    required this.rideId,
    required this.driverPhone,
    required this.estimatedFare,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  State<DriverTripSummaryScreen> createState() =>
      _DriverTripSummaryScreenState();
}

class _DriverTripSummaryScreenState extends State<DriverTripSummaryScreen> {
  bool _loading = true;
  bool _completing = false;
  String _paymentMethod = 'cash'; // 'cash' or 'upi'
  String _transactionId = '';
  String _upiId = '';
  bool _paymentConfirmed = false;
  bool _tripCompletedOnBackend = false;
  double _actualEarnings = 0.0;
  double _customerRating = 5.0;
  String _driverPhotoUrl = '';
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDriverPhoto();
    _checkPaymentStatus();
  }

  Future<void> _loadDriverPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final photo =
        prefs.getString('driver_profile_photo') ??
        prefs.getString('profile_photo_url') ??
        '';
    if (mounted && photo.isNotEmpty) {
      setState(() => _driverPhotoUrl = photo);
    }
  }

  Future<void> _notifyPaymentMethod(String method) async {
    setState(() => _paymentMethod = method);
    try {
      await DriverApiService.setPaymentMethod(
        rideId: widget.rideId,
        driverPhone: widget.driverPhone,
        paymentMethod: method,
      );
    } catch (e) {
      debugPrint('[TRIP_SUMMARY] setPaymentMethod error: $e');
    }
  }

  Future<void> _checkPaymentStatus() async {
    setState(() => _loading = true);
    try {
      final response = await DriverApiService.fetchRideDetailResponse(
        rideId: widget.rideId,
        driverPhone: widget.driverPhone,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Detail is wrapped as {status, ride: {...}}.
        final data = body is Map && body['ride'] is Map ? body['ride'] : body;
        final txnId = data['transaction_id'] ?? '';
        final upi = data['upi_id'] ?? '';
        final savedMethod = (data['payment_method'] ?? '')
            .toString()
            .toLowerCase();
        setState(() {
          _transactionId = txnId;
          _upiId = upi;
          if (txnId.isNotEmpty && txnId.toString().toUpperCase() != 'CASH') {
            _paymentMethod = 'upi';
            _paymentConfirmed = true;
          } else if (savedMethod == 'cash' || savedMethod == 'upi') {
            _paymentMethod = savedMethod;
          }
          _loading = false;
        });
        // Default selection is Cash — tell customer immediately so Pay Now is hidden.
        if (!_paymentConfirmed) {
          _notifyPaymentMethod(_paymentMethod);
        }
      } else {
        setState(() => _loading = false);
        _notifyPaymentMethod(_paymentMethod);
      }
    } catch (e) {
      debugPrint('[TRIP_SUMMARY] Error checking payment: $e');
      setState(() => _loading = false);
      _notifyPaymentMethod(_paymentMethod);
    }
  }

  Future<void> _completeTrip() async {
    setState(() => _completing = true);
    try {
      final earnings = await DriverApiService.completeRide(
        rideId: widget.rideId,
        driverPhone: widget.driverPhone,
        paymentMethod: _paymentMethod,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('driver_is_online', true);
      setState(() {
        _actualEarnings = earnings;
        _tripCompletedOnBackend = true;
        _completing = false;
      });
    } catch (e) {
      debugPrint('[TRIP_SUMMARY] Complete trip error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete ride: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _completing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_tripCompletedOnBackend) {
      // SCREENSHOT 3 RIGHT: RidePayment
      final upiAddress = _upiId.isNotEmpty
          ? _upiId
          : '${widget.driverPhone}@ptsbi';
      return Scaffold(
        floatingActionButton: const AiChatButton(size: 48),
        backgroundColor: context.torkk.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Close icon on left, "Need Help?" on right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        context.go(AppRoutes.home);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: 28,
                        color: context.torkk.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DriverSupportScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Need Help?',
                        style: TextStyle(
                          color: context.torkk.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Payment & Ask for Cash
                Text(
                  'Payment',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: context.torkk.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ask for Cash',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.torkk.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Giant Fare: ₹ 72.98
                Text(
                  '₹ ${widget.estimatedFare.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: context.torkk.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 14),

                // Divider
                Divider(color: context.torkk.border, thickness: 1.2),
                const SizedBox(height: 14),

                // UPI ID & Show Scanner
                Text(
                  'UPI ID',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: context.torkk.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Show Scanner',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.torkk.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // Centered QR Code
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.torkk.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.torkk.border),
                    ),
                    child: Image.network(
                      AppUrls.upiQrCode(
                        upiAddress: upiAddress,
                        customerName: widget.customerName,
                        amount: widget.estimatedFare,
                      ),
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stackTrace) => Icon(
                        Icons.qr_code_2_rounded,
                        size: 160,
                        color: context.torkk.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    upiAddress,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.torkk.textPrimary,
                    ),
                  ),
                ),

                const Spacer(),

                // Slide to Finish the Ride slider
                _buildPaymentSlider(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    }

    // SCREENSHOT 4: RideFeedback
    final customerInitial = widget.customerName.isNotEmpty
        ? widget.customerName[0].toUpperCase()
        : 'M';
    final firstName = widget.customerName.split(' ').first;

    return Scaffold(
      floatingActionButton: const AiChatButton(size: 48),
      body: Stack(
        children: [
          // Map Background
          Positioned.fill(
            child: Container(
              color: context.torkk.surfaceMuted,
              child: Image.asset(
                'assets/welcome_car_city.png',
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) =>
                    Container(color: const Color(0xFFCBD5E1)),
              ),
            ),
          ),

          // Top Floating Bar (Menu, FINISH, Driver Avatar)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF334155),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'ONLINE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.legible(Color(0xFF2563EB)),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: _driverPhotoUrl.isNotEmpty
                        ? Image.network(
                            _driverPhotoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, error, stackTrace) => Icon(
                              Icons.person,
                              color: context.torkk.textBody,
                            ),
                          )
                        : Icon(Icons.person, color: context.torkk.textBody),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Modal Sheet: RideFeedback
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: context.torkk.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Inner White Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: context.torkk.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.torkk.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Passenger Row
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFF1D4ED8),
                                child: Text(
                                  customerInitial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.customerName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: context.torkk.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          '+4 ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: context.torkk.textSecondary,
                                          ),
                                        ),
                                        Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: Color(0xFFF59E0B),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DriverCustomerChatScreen(
                                        customerName: widget.customerName,
                                        customerPhone: widget.customerPhone,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 18,
                                    color: context.torkk.textBody,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  if (widget.customerPhone.isNotEmpty) {
                                    launchUrl(
                                      Uri.parse('tel:${widget.customerPhone}'),
                                    );
                                  }
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.phone_outlined,
                                    size: 18,
                                    color: context.torkk.textBody,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  showReportCustomerDialog(
                                    context: context,
                                    driverPhone: widget.driverPhone,
                                    customerPhone: widget.customerPhone,
                                  );
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                    color: Colors.red.shade50,
                                  ),
                                  child: const Icon(
                                    Icons.report_problem_outlined,
                                    size: 18,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Trip Earnings Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: context.adaptiveTint(
                                const Color(0xFFF0FDF4),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Trip Earnings',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: context.legible(
                                          Color(0xFF166534),
                                        ),
                                      ),
                                    ),
                                    if (_transactionId.isNotEmpty)
                                      Text(
                                        'Txn: $_transactionId',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: context.legible(
                                            Color(0xFF15803D),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Text(
                                  '₹${(_actualEarnings > 0 ? _actualEarnings : widget.estimatedFare).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: context.legible(Color(0xFF15803D)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Leave a review for Junaid
                          Text(
                            'Leave a Review for $firstName',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: context.torkk.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'How was $firstName?',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.torkk.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Review input box
                          Container(
                            height: 70,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFCBD5E1,
                              ).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: _reviewController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Write feedback...',
                                hintStyle: TextStyle(
                                  color: context.torkk.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 5 Large Stars Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(
                              () => _customerRating = starIndex.toDouble(),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              _customerRating >= starIndex
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 40,
                              color: _customerRating >= starIndex
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),

                    // Dedicated Submit Feedback Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _finishAndGoHome,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D4ED8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Submit Feedback',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
