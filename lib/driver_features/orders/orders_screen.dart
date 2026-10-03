import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/orders/order_details_screen.dart';
import 'package:rider_app/driver_features/rides/scheduled_ride_screen.dart';

enum _OrderTab { current, completed, cancelled, scheduled }

/// Orders list: current, completed, cancelled, and scheduled rides and parcels.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _search = TextEditingController();
  _OrderTab _tab = _OrderTab.completed;
  String _kind = 'all';
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _trips = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // Temporary sample orders so the list and details screens can be reviewed.
    setState(() {
      _loading = false;
      _error = null;
      _trips = _sampleOrders();
    });
  }

  List<Map<String, dynamic>> get _visible {
    final query = _search.text.trim().toLowerCase();
    return _trips.where((trip) {
      if (_tabOf(trip) != _tab) return false;
      if (_kind == 'ride' && _isParcel(trip)) return false;
      if (_kind == 'parcel' && !_isParcel(trip)) return false;
      if (query.isEmpty) return true;
      final blob = '${trip['id']} ${trip['pickup_address']} ${trip['drop_address']} ${trip['customer_name']}'.toLowerCase();
      return blob.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final visible = _visible;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(context.w(8), context.h(4), context.w(16), 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
                  ),
                  Text(
                    AppStrings.navOrders,
                    style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2, letterSpacing: -0.4),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      style: AppTypography.regular.copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: AppStrings.ordersSearchHint,
                        hintStyle: AppTypography.regular.copyWith(fontSize: 14, color: AppColors.slate400),
                        prefixIcon: const Icon(Icons.search, color: AppColors.slate400),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: EdgeInsets.symmetric(vertical: context.h(12)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.r(14)),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.r(14)),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.w(8)),
                  _filterButton(context),
                ],
              ),
            ),
            SizedBox(height: context.h(12)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(20)),
              child: _tabs(context, accent),
            ),
            SizedBox(height: context.h(8)),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: AppTypography.regular.copyWith(color: AppColors.slate500)))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(12)),
                            children: [
                              if (visible.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: context.h(48)),
                                  child: Center(
                                    child: Text(
                                      AppStrings.ordersEmpty,
                                      style: AppTypography.regular.copyWith(color: AppColors.slate500),
                                    ),
                                  ),
                                )
                              else
                                ..._grouped(context, accent, visible),
                              SizedBox(height: context.h(16)),
                              _coinsBanner(context),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: _kind,
      onSelected: (value) => setState(() => _kind = value),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'all', child: Text('All')),
        PopupMenuItem(value: 'ride', child: Text(AppStrings.ordersRide)),
        PopupMenuItem(value: 'parcel', child: Text(AppStrings.ordersParcel)),
      ],
      child: Container(
        width: context.w(44),
        height: context.w(44),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(context.r(14)),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Icon(Icons.tune_rounded, color: AppColors.slate500),
      ),
    );
  }

  Widget _tabs(BuildContext context, Color accent) {
    const tabs = [
      (_OrderTab.current, AppStrings.ordersCurrent),
      (_OrderTab.completed, AppStrings.ordersCompleted),
      (_OrderTab.cancelled, AppStrings.ordersCancelled),
      (_OrderTab.scheduled, AppStrings.ordersScheduled),
    ];
    return Container(
      padding: EdgeInsets.all(context.w(4)),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(context.r(14)),
      ),
      child: Row(
        children: [
          for (final tab in tabs)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = tab.$1),
                child: Container(
                  height: context.h(36),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _tab == tab.$1 ? accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(context.r(10)),
                  ),
                  child: Text(
                    tab.$2,
                    style: AppTypography.regular.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _tab == tab.$1 ? Colors.white : AppColors.slate500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _grouped(BuildContext context, Color accent, List<Map<String, dynamic>> trips) {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final trip in trips) {
      groups.putIfAbsent(_dateLabel(trip), () => []).add(trip);
    }
    final widgets = <Widget>[];
    for (final entry in groups.entries) {
      widgets.add(Padding(
        padding: EdgeInsets.only(top: context.h(8), bottom: context.h(8)),
        child: Text(entry.key, style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500)),
      ));
      for (final trip in entry.value) {
        widgets.add(Padding(
          padding: EdgeInsets.only(bottom: context.h(14)),
          child: _OrderCard(
            trip: trip,
            accent: accent,
            tab: _tab,
            onTap: () {
              final scheduledRide = trip['status'] == 'scheduled' && trip['is_parcel'] != true;
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => scheduledRide ? const ScheduledRideScreen() : OrderDetailsScreen(trip: trip),
                ),
              );
            },
          ),
        ));
      }
    }
    return widgets;
  }

  Widget _coinsBanner(BuildContext context) {
    final coins = _coinsEarned();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(36),
            height: context.w(36),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: Icon(Icons.card_giftcard_rounded, color: Colors.white, size: context.w(18)),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (coins > 0)
                  Text(
                    '${AppStrings.ordersYouEarnedCoins} $coins ${AppStrings.ordersCoins}',
                    style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2, color: Colors.white, letterSpacing: -0.2),
                  ),
                Text(
                  AppStrings.ordersCoinsHint,
                  style: AppTypography.regular.copyWith(fontSize: 12, height: 1.3, color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.white, size: context.w(20)),
        ],
      ),
    );
  }

  int _coinsEarned() => 200;
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.trip,
    required this.accent,
    required this.tab,
    required this.onTap,
  });

  final Map<String, dynamic> trip;
  final Color accent;
  final _OrderTab tab;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final parcel = _isParcel(trip);
    final showFare = tab == _OrderTab.current || tab == _OrderTab.completed;
    final showType = tab == _OrderTab.current || tab == _OrderTab.completed;
    final fare = trip['driver_earnings'] ?? trip['fare'] ?? trip['estimated_fare'];
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: context.w(40),
                height: context.w(40),
                decoration: BoxDecoration(
                  color: parcel ? const Color(0xFFFFFBEB) : const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(context.r(12)),
                ),
                child: Icon(
                  parcel ? Icons.inventory_2_rounded : Icons.directions_car_filled_rounded,
                  color: parcel ? const Color(0xFFF59E0B) : accent,
                  size: context.w(20),
                ),
              ),
              SizedBox(width: context.w(12)),
              Text(
                _orderCode(trip),
                style: AppTypography.bold.copyWith(fontSize: 15, height: 1.2, letterSpacing: -0.2),
              ),
              SizedBox(width: context.w(8)),
              _StatusChip(label: _statusLabel(trip, tab), color: _statusColor(tab)),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: context.w(20)),
            ],
          ),
          if (showType) ...[
            SizedBox(height: context.h(12)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _typeLines(context, trip, parcel)),
                if (showFare && fare is num)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${fare.round()}',
                        style: AppTypography.bold.copyWith(fontSize: 16, height: 1.2, letterSpacing: -0.3),
                      ),
                      Text(
                        AppStrings.ordersOnline,
                        style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate400),
                      ),
                    ],
                  ),
              ],
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.h(10)),
            child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Text(_timeLabel(trip), style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500)),
          SizedBox(height: context.h(4)),
          Text(
            _route(trip),
            style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _typeLines(BuildContext context, Map<String, dynamic> trip, bool parcel) {
    if (parcel) {
      final type = (trip['item_category'] ?? trip['parcel_type'] ?? 'Documents').toString();
      final weight = (trip['item_weight'] ?? '1 kg (Small)').toString();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.parcelType,
            style: AppTypography.regular.copyWith(fontSize: 13, height: 1.3, color: AppColors.slate500),
          ),
          Text(
            '$type • $weight',
            style: AppTypography.bold.copyWith(fontSize: 14, height: 1.3, letterSpacing: -0.2),
          ),
        ],
      );
    }
    return Text(
      _subtitle(trip, false),
      style: AppTypography.regular.copyWith(fontSize: 13, height: 1.3, color: AppColors.slate500),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(8), vertical: context.h(2)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(
        label,
        style: AppTypography.regular.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

bool _isParcel(Map<String, dynamic> trip) {
  return trip['is_parcel'] == true || trip['service_type']?.toString().toLowerCase() == 'parcel';
}

_OrderTab _tabOf(Map<String, dynamic> trip) {
  final status = (trip['status'] ?? '').toString().toLowerCase();
  if (status == 'scheduled') return _OrderTab.scheduled;
  if (status == 'cancelled' || status == 'canceled' || status == 'rejected') return _OrderTab.cancelled;
  if (status == 'completed' || status == 'complete') return _OrderTab.completed;
  return _OrderTab.current;
}

String _statusLabel(Map<String, dynamic> trip, _OrderTab tab) {
  if (tab == _OrderTab.current) return AppStrings.ordersOngoing;
  if (tab == _OrderTab.cancelled) return AppStrings.ordersCancelled;
  if (tab == _OrderTab.scheduled) return AppStrings.ordersScheduled;
  return AppStrings.ordersCompleted;
}

Color _statusColor(_OrderTab tab) {
  if (tab == _OrderTab.cancelled) return AppColors.error;
  if (tab == _OrderTab.scheduled) return const Color(0xFFF59E0B);
  if (tab == _OrderTab.current) return const Color(0xFF16A34A);
  return const Color(0xFF16A34A);
}

String _orderCode(Map<String, dynamic> trip) {
  final id = trip['order_id'] ?? trip['id'] ?? '';
  final text = id.toString();
  if (text.isEmpty) return '#ORD';
  return text.toUpperCase().startsWith('ORD') ? '#$text' : '#ORD$text';
}

String _subtitle(Map<String, dynamic> trip, bool parcel) {
  if (parcel) {
    final type = (trip['item_category'] ?? trip['parcel_type'] ?? 'Documents').toString();
    final weight = (trip['item_weight'] ?? '1 kg (Small)').toString();
    return '${AppStrings.parcelType}\n$type • $weight';
  }
  final seats = trip['passenger_count'] ?? trip['seats'];
  final vehicle = (trip['vehicle_type'] ?? AppStrings.ordersRide).toString();
  if (seats == null) return vehicle;
  return '$vehicle • $seats Seater';
}

String _route(Map<String, dynamic> trip) {
  final pickup = (trip['pickup_address'] ?? '').toString();
  final drop = (trip['drop_address'] ?? '').toString();
  if (pickup.isEmpty && drop.isEmpty) return '';
  if (drop.isEmpty) return pickup;
  if (pickup.isEmpty) return drop;
  return '$pickup  →  $drop';
}

List<Map<String, dynamic>> _sampleOrders() {
  Map<String, dynamic> order(String status, bool parcel) {
    return {
      'id': 'ORD98232',
      'is_parcel': parcel,
      'status': status,
      'vehicle_type': 'Ride',
      'passenger_count': 4,
      'item_category': 'Documents',
      'item_weight': '1 kg (Small)',
      'fare': 210,
      'created_at': '2026-09-13T14:46:00',
      'date_label': 'Today, 13 Sept 2026',
      'pickup_address': 'Sector 62, Noida',
      'drop_address': 'DLF Mall of India',
      'distance_km': 4.2,
      'duration_mins': 18,
      'customer_name': 'Rahul',
      'passengers': 4,
      'likes': 2,
      'dislikes': 1,
      'payment_label': AppStrings.paidCash,
      'base_fare': 68,
      'waiting_charge': 8,
      'discount': 10,
      'taxes': 0,
      'other_charges': 0,
      'total_fare': 64,
      'coins': 200,
    };
  }

  return [
    order('ongoing', false),
    order('completed', false),
    order('completed', true),
    order('cancelled', false),
    order('cancelled', true),
    order('scheduled', false),
    order('scheduled', true),
  ];
}

DateTime? _when(Map<String, dynamic> trip) {
  final raw = trip['scheduled_at'] ?? trip['created_at'] ?? trip['date'] ?? trip['completed_at'];
  return DateTime.tryParse(raw?.toString() ?? '');
}

String _timeLabel(Map<String, dynamic> trip) {
  final when = _when(trip);
  if (when == null) return '';
  final hour12 = when.hour % 12 == 0 ? 12 : when.hour % 12;
  final hour = hour12.toString().padLeft(2, '0');
  final minute = when.minute.toString().padLeft(2, '0');
  final suffix = when.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

String _dateLabel(Map<String, dynamic> trip) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final label = trip['date_label']?.toString() ?? '';
  if (label.isNotEmpty) return label;
  final when = _when(trip);
  if (when == null) return '';
  final now = DateTime.now();
  final text = '${when.day} ${months[when.month - 1]} ${when.year}';
  final today = when.year == now.year && when.month == now.month && when.day == now.day;
  return today ? 'Today, $text' : text;
}
