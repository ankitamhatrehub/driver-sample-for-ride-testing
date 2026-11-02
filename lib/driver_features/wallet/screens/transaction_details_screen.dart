import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/wallet/models/wallet_txn.dart';
import 'package:rider_app/service/driver_api_service.dart';

class TransactionDetailsScreen extends StatefulWidget {
  const TransactionDetailsScreen({super.key, required this.txn});

  final WalletTxn txn;

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  bool _loading = true;
  Map<String, dynamic> _data = {};

  WalletTxn get txn => widget.txn;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (txn.id.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final data = await DriverApiService.fetchTransactionDetails(txn.id);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching transaction details: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _pick(List<String> keys) {
    for (final k in keys) {
      final v = _data[k];
      if (v != null && v.toString().trim().isNotEmpty)
        return v.toString().trim();
    }
    return '';
  }

  String _orDash(String v) => v.isEmpty ? '-' : v;

  String _money(String raw) {
    final n = double.tryParse(raw);
    if (n == null) return raw.isEmpty ? '-' : raw;
    return '₹${n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(2)}';
  }

  String _dateTime() {
    final d =
        DateTime.tryParse(
          _pick(['created_at', 'date', 'timestamp', 'completed_at']),
        )?.toLocal() ??
        txn.date;
    if (d == null) return '-';
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month - 1]} , ${h12.toString().padLeft(2, '0')}:$m ${d.hour >= 12 ? 'pm' : 'am'}';
  }

  String _titleCase(String v) =>
      v.isEmpty ? v : v[0].toUpperCase() + v.substring(1).toLowerCase();

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ProfilePage(
        title: 'Transaction Details',
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final name = _pick([
      'customer_name',
      'user_name',
      'passenger_name',
      'name',
    ]);
    final amountRaw = _pick(['amount', 'total', 'fare', 'earning', 'earnings']);
    final vehicle = _pick(['vehicle_type', 'vehicle', 'seats']);
    final kindText = txn.parcel
        ? 'Parcel'
        : (vehicle.isEmpty ? 'Ride' : 'Ride • $vehicle');
    final pickup = _pick(['pickup_address', 'pickup', 'from']);
    final drop = _pick(['drop_address', 'drop', 'to']);
    final distance = _pick(['distance_km', 'distance']);
    final duration = _pick(['duration_mins', 'duration', 'duration_minutes']);
    final status = _pick(['status', 'transaction_status']);
    final payment = _pick(['payment_method', 'payment_mode', 'payment_status']);

    final route = [pickup, drop].where((e) => e.isNotEmpty).join('  →  ');
    final meta = [
      if (distance.isNotEmpty) '$distance km',
      if (duration.isNotEmpty) '$duration mins',
    ].join('  •  ');
    final paidText = payment.toLowerCase() == 'cash'
        ? AppStrings.paidCash
        : _orDash(_titleCase(payment));

    return ProfilePage(
      title: 'Transaction Details',
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(20),
        ),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: context.w(18),
                backgroundColor: context.adaptiveTint(const Color(0xFFF1F5F9)),
                child: Icon(
                  Icons.person,
                  color: AppColors.slate400,
                  size: context.w(18),
                ),
              ),
              SizedBox(width: context.w(10)),
              Expanded(
                child: Text(
                  name.isEmpty ? txn.name : name,
                  style: AppTypography.bold.copyWith(
                    fontSize: 16,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Text(
                _money(amountRaw),
                style: AppTypography.bold.copyWith(
                  fontSize: 18,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(8)),
          Text(
            kindText,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              color: context.torkk.textPrimary,
            ),
          ),
          if (route.isNotEmpty) ...[
            SizedBox(height: context.h(8)),
            Text(route, style: AppTypography.regular.copyWith(fontSize: 13)),
          ],
          if (meta.isNotEmpty) ...[
            SizedBox(height: context.h(4)),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: context.w(14),
                  color: AppColors.slate400,
                ),
                SizedBox(width: context.w(4)),
                Text(
                  meta,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    color: context.torkk.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: context.h(16)),
          Text(
            'Transaction Details',
            style: AppTypography.regular.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.h(8)),
          Container(
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: context.torkk.border),
            ),
            child: Column(
              children: [
                _line(
                  context,
                  'Status',
                  _orDash(_titleCase(status)),
                  valueColor:
                      status.toLowerCase() == 'completed' ||
                          status.toLowerCase() == 'success'
                      ? const Color(0xFF16A34A)
                      : null,
                ),
                _line(
                  context,
                  'Transaction ID',
                  _orDash(
                    _pick(['transaction_id', 'txn_id', 'id']).isEmpty
                        ? txn.id
                        : _pick(['transaction_id', 'txn_id', 'id']),
                  ),
                ),
                _line(
                  context,
                  'Transaction Type',
                  _orDash(
                    _pick(['type', 'transaction_type']).isEmpty
                        ? (txn.parcel ? 'Parcel Earnings' : 'Ride Earnings')
                        : _titleCase(_pick(['type', 'transaction_type'])),
                  ),
                ),
                _line(context, 'Amount', _money(amountRaw)),
                _line(context, 'Data & Time', _dateTime()),
                _line(
                  context,
                  'Job Reference',
                  _orDash(
                    _pick([
                      'job_reference',
                      'reference',
                      'ride_id',
                      'booking_id',
                    ]),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(12)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: context.torkk.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.paymentStatus,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    color: context.torkk.textSecondary,
                  ),
                ),
                SizedBox(height: context.h(2)),
                Text(
                  paidText,
                  style: AppTypography.bold.copyWith(
                    fontSize: 15,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.regular.copyWith(
                fontSize: 13,
                color: context.torkk.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? context.legible(AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
