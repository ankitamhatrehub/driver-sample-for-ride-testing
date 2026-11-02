import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/driver_features/profile/screens/driver_profile_screen.dart';
import 'package:rider_app/service/driver_api_service.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
part 'driver_earnings_screen_sections.dart';

// --- DRIVER EARNINGS SCREEN ---
class DriverEarningsScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final String? profilePhotoUrl;

  const DriverEarningsScreen({super.key, this.onClose, this.profilePhotoUrl});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  List<dynamic> _recentTrips = [];
  String? _cachedPhotoUrl;
  Map<String, double> _dailyEarnings = {
    'Su': 0.0,
    'Mo': 0.0,
    'Tu': 0.0,
    'We': 0.0,
    'Th': 0.0,
    'Fr': 0.0,
    'Sa': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    final prefs = await SharedPreferences.getInstance();
    final photo =
        prefs.getString('profile_photo') ??
        prefs.getString('profile_photo_url');
    if (photo != null && photo.isNotEmpty) {
      _cachedPhotoUrl = photo;
    }
    final phone =
        prefs.getString('phone') ?? prefs.getString('user_phone') ?? '';
    if (phone.isEmpty) return;
    try {
      final data = await DriverApiService.fetchEarnings(phone);
      final trips = (data['recent_trips'] as List<dynamic>?) ?? [];

      Map<String, double> weekMap = {
        'Su': 0.0,
        'Mo': 0.0,
        'Tu': 0.0,
        'We': 0.0,
        'Th': 0.0,
        'Fr': 0.0,
        'Sa': 0.0,
      };

      for (var trip in trips) {
        if (trip is! Map) continue;
        final amount =
            (trip['earnings'] ??
                    trip['driver_earnings'] ??
                    trip['fare'] ??
                    trip['amount'] as num?)
                ?.toDouble() ??
            0.0;
        final dateStr =
            trip['created_at']?.toString() ?? trip['date']?.toString() ?? '';
        if (dateStr.isNotEmpty) {
          final dt = DateTime.tryParse(dateStr);
          if (dt != null) {
            final dayKey = [
              'Su',
              'Mo',
              'Tu',
              'We',
              'Th',
              'Fr',
              'Sa',
            ][dt.weekday % 7];
            weekMap[dayKey] = (weekMap[dayKey] ?? 0.0) + amount;
          }
        }
      }

      final todayAmt = (data['today_earnings'] as num?)?.toDouble() ?? 0.0;
      final todayKey = [
        'Su',
        'Mo',
        'Tu',
        'We',
        'Th',
        'Fr',
        'Sa',
      ][DateTime.now().weekday % 7];
      if (todayAmt > 0 && (weekMap[todayKey] ?? 0) == 0) {
        weekMap[todayKey] = todayAmt;
      }

      if (mounted) {
        setState(() {
          _recentTrips = trips;
          _dailyEarnings = weekMap;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.profilePhotoUrl ?? _cachedPhotoUrl;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = context.torkk.textPrimary;

    final days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    double maxEarning = _dailyEarnings.values.fold(
      0.0,
      (prev, curr) => curr > prev ? curr : prev,
    );
    if (maxEarning <= 0) maxEarning = 100.0;

    final barFractions = days.map((d) {
      final val = _dailyEarnings[d] ?? 0.0;
      return (val / maxEarning).clamp(0.18, 1.0);
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP BAR (Close Button, Earnings Title, Profile Avatar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: widget.onClose ?? () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF475569),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Text(
                    'Earnings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DriverProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2563EB),
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: photo != null && photo.isNotEmpty
                            ? (photo.startsWith('http')
                                  ? Image.network(
                                      photo,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, error, stackTrace) =>
                                          Icon(
                                            Icons.person,
                                            color: context.torkk.textSecondary,
                                          ),
                                    )
                                  : Image.file(
                                      File(photo),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, error, stackTrace) =>
                                          Icon(
                                            Icons.person,
                                            color: context.torkk.textSecondary,
                                          ),
                                    ))
                            : Icon(
                                Icons.person,
                                color: context.torkk.textSecondary,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // WEEKLY EARNINGS BAR CHART CARD
            Container(
              width: double.infinity,
              height: 220,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A8A), // Deep navy
                    Color(0xFF2E1065), // Indigo purple
                    Color(0xFF3B0764), // Dark plum
                    Color(0xFF1E1B4B), // Midnight
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  return _buildBar(
                    days[i],
                    barFractions[i],
                    _dailyEarnings[days[i]] ?? 0.0,
                  );
                }),
              ),
            ),

            const SizedBox(height: 14),

            // SECTION HEADER: "Statements"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Statements',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    onPressed: _downloadStatement,
                    icon: Icon(
                      Icons.file_download_outlined,
                      color: textColor,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),

            // STATEMENTS LIST
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadEarnings,
                child: _recentTrips.isEmpty
                    ? ListView(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: Color(0xFF94A3B8),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No statements or transactions found',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: context.torkk.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Completed ride earnings will appear here.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.only(top: 4, bottom: 24),
                        children: _recentTrips.map((trip) {
                          if (trip is! Map) return const SizedBox.shrink();
                          final amount =
                              (trip['earnings'] ??
                                      trip['driver_earnings'] ??
                                      trip['fare'] ??
                                      trip['amount'] as num?)
                                  ?.toDouble() ??
                              0.0;
                          final mode =
                              (trip['payment_method'] ??
                                      trip['payment_mode'] ??
                                      'Cash')
                                  .toString();
                          final isCash = mode.toLowerCase().contains('cash');
                          final dateStr =
                              (trip['created_at'] ?? trip['date'] ?? '')
                                  .toString();
                          String customer =
                              (trip['customer_name'] ??
                                      trip['user_name'] ??
                                      trip['passenger_name'] ??
                                      '')
                                  .toString()
                                  .trim();
                          if (customer.isEmpty) {
                            final rawName = (trip['name'] ?? '')
                                .toString()
                                .trim();
                            final lower = rawName.toLowerCase();
                            if (rawName.isNotEmpty &&
                                !lower.contains('marg') &&
                                !lower.contains('nagar') &&
                                !lower.contains('delhi') &&
                                !lower.contains('road') &&
                                !lower.contains('street') &&
                                !lower.contains('india')) {
                              customer = rawName;
                            } else {
                              customer = 'Passenger';
                            }
                          }

                          return _buildStatementItem(
                            iconBadge: _buildGreenRupeeBadge(),
                            amount: '₹ ${amount.toStringAsFixed(2)}',
                            subtitle: isCash
                                ? 'Received Cash ($customer)'
                                : 'Received via $mode ($customer)',
                            onTap: () => _showStatementDetails(
                              isCash ? 'Cash Payment' : 'Online Payment',
                              '₹ ${amount.toStringAsFixed(2)}',
                              'Ride payment from $customer ${dateStr.isNotEmpty ? "• $dateStr" : ""}',
                              trip: Map<String, dynamic>.from(trip),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
