import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/driver_features/profile/screens/driver_profile_screen.dart';
import 'package:rider_app/service/driver_api_service.dart';

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

  Future<void> _downloadStatement() async {
    final prefs = await SharedPreferences.getInstance();
    final phone =
        prefs.getString('phone') ?? prefs.getString('user_phone') ?? '';
    final name = prefs.getString('user_name') ?? 'Driver Partner';

    final StringBuffer csvBuffer = StringBuffer();
    csvBuffer.writeln('TORKK DRIVER EARNINGS STATEMENT');
    csvBuffer.writeln('Driver Name: $name');
    csvBuffer.writeln('Phone: $phone');
    csvBuffer.writeln(
      'Generated Date: ${DateTime.now().toString().split('.')[0]}',
    );
    csvBuffer.writeln('');
    csvBuffer.writeln(
      'Trip ID,Customer,Amount (INR),Payment Mode,Date & Time,Status',
    );

    double totalEarnings = 0.0;

    if (_recentTrips.isNotEmpty) {
      for (var trip in _recentTrips) {
        if (trip is! Map) continue;
        final id = trip['id'] ?? trip['ride_id'] ?? 'N/A';
        final customer = (trip['customer_name'] ?? trip['name'] ?? 'Passenger')
            .toString()
            .replaceAll(',', ' ');
        final amount =
            (trip['earnings'] ??
                    trip['driver_earnings'] ??
                    trip['fare'] ??
                    trip['amount'] as num?)
                ?.toDouble() ??
            0.0;
        final mode = (trip['payment_method'] ?? trip['payment_mode'] ?? 'Cash')
            .toString();
        final date =
            (trip['created_at'] ?? trip['date'] ?? DateTime.now().toString())
                .toString()
                .replaceAll(',', ' ');
        final status = (trip['status'] ?? 'Completed').toString();
        totalEarnings += amount;

        csvBuffer.writeln(
          '$id,$customer,₹ ${amount.toStringAsFixed(2)},$mode,$date,$status',
        );
      }
    } else {
      csvBuffer.writeln('No transaction records found for this period.');
    }

    csvBuffer.writeln('');
    csvBuffer.writeln(
      'TOTAL EARNINGS,,₹ ${totalEarnings.toStringAsFixed(2)},,,',
    );

    final statementText = csvBuffer.toString();

    try {
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      final fileName =
          'TORKK_Statement_${phone.isNotEmpty ? phone : "Driver"}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(statementText);

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  'Statement Saved',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Earnings statement CSV has been downloaded to your device storage:',
                  style: TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: SelectableText(
                    file.path,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Share.shareXFiles([
                    XFile(file.path),
                  ], text: 'TORKK Driver Earnings Statement');
                },
                child: const Text('Share File'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        await Share.share(
          statementText,
          subject: 'TORKK Driver Earnings Statement - $phone',
        );
      }
    }
  }

  Widget _buildBar(String day, double heightFraction, double amount) {
    const maxBarHeight = 130.0;
    final barHeight = (maxBarHeight * heightFraction).clamp(24.0, maxBarHeight);
    final hasAmount = amount > 0;

    return Tooltip(
      message: '$day: ₹ ${amount.toStringAsFixed(2)}',
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$day Earnings: ₹ ${amount.toStringAsFixed(2)}'),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF2E1065),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (hasAmount)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '₹${amount.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 26,
              height: barHeight,
              decoration: BoxDecoration(
                color: hasAmount
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(6),
                boxShadow: hasAmount
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatementItem({
    required Widget iconBadge,
    required String amount,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconBadge,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        amount,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFE2E8F0),
          indent: 82,
          endIndent: 20,
        ),
      ],
    );
  }

  Widget _buildGreenRupeeBadge() {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        color: Color(0xFF22C55E),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '₹',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showStatementDetails(
    String title,
    String amount,
    String subtitle, {
    Map<String, dynamic>? trip,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Statement Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'COMPLETED',
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.profilePhotoUrl ?? _cachedPhotoUrl;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

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
                                      errorBuilder: (_, error, stackTrace) => const Icon(
                                        Icons.person,
                                        color: Color(0xFF64748B),
                                      ),
                                    )
                                  : Image.file(
                                      File(photo),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, error, stackTrace) => const Icon(
                                        Icons.person,
                                        color: Color(0xFF64748B),
                                      ),
                                    ))
                            : const Icon(
                                Icons.person,
                                color: Color(0xFF64748B),
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
                        children: const [
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
                                    color: Color(0xFF64748B),
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
