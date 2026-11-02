part of 'package:rider_app/driver_features/earnings/screens/driver_earnings_screen.dart';

extension _DriverEarningsScreenStateSections on _DriverEarningsScreenState {
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
                Text(
                  'Earnings statement CSV has been downloaded to your device storage:',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: context.torkk.textBody,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.torkk.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: SelectableText(
                    file.path,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.torkk.textPrimary,
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
                  foregroundColor: onColorFor(const Color(0xFF2563EB)),
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
                    ? context.torkk.surface
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
                          color: context.torkk.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.torkk.textSecondary,
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
        Divider(
          height: 1,
          thickness: 1,
          color: context.torkk.border,
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
        backgroundColor: context.torkk.surface,
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
                  color: context.torkk.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.torkk.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      amount,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: context.torkk.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.torkk.textSecondary,
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.torkk.textSecondary,
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
                    foregroundColor: onColorFor(const Color(0xFF4F46E5)),
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
}
