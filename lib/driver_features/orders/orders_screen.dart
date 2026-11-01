import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider_app/app/theme/theme_bloc.dart';
import 'package:rider_app/service/driver_api_service.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/orders/order_details_screen.dart';
import 'package:rider_app/driver_features/rides/scheduled_ride_screen.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

part 'orders_screen_parts/order_card.dart';
part 'orders_screen_parts/status_chip.dart';
part 'orders_screen_sections.dart';

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
    final tab = _tab;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await DriverApiService.fetchOrders(type: tab.name);
      if (!mounted || tab != _tab) return;
      setState(() {
        _trips = orders;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || tab != _tab) return;
      setState(() {
        _trips = [];
        _loading = false;
        _error = AppStrings.ordersLoadFailed;
      });
    }
  }

  void _selectTab(_OrderTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
    _load();
  }

  List<Map<String, dynamic>> get _visible {
    final query = _search.text.trim().toLowerCase();
    return _trips.where((trip) {
      if (_kind == 'ride' && _isParcel(trip)) return false;
      if (_kind == 'parcel' && !_isParcel(trip)) return false;
      if (query.isEmpty) return true;
      final blob =
          '${trip['id']} ${trip['pickup_address']} ${trip['drop_address']} ${trip['customer_name']}'
              .toLowerCase();
      return blob.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final visible = _visible;
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(8),
                context.h(4),
                context.w(16),
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: context.torkk.textPrimary,
                    ),
                  ),
                  Text(
                    AppStrings.navOrders,
                    style: AppTypography.bold.copyWith(
                      fontSize: 20,
                      height: 1.2,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(20),
                context.h(8),
                context.w(20),
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      style: AppTypography.regular.copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: AppStrings.ordersSearchHint,
                        hintStyle: AppTypography.regular.copyWith(
                          fontSize: 14,
                          color: AppColors.slate400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.slate400,
                        ),
                        filled: true,
                        fillColor: context.torkk.surfaceMuted,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: context.h(12),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.r(14)),
                          borderSide: BorderSide(color: context.torkk.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.r(14)),
                          borderSide: BorderSide(color: context.torkk.border),
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
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _error!,
                            style: AppTypography.regular.copyWith(
                              color: context.torkk.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: _load,
                            child: Text(AppStrings.retry),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          context.w(20),
                          context.h(8),
                          context.w(20),
                          context.h(12),
                        ),
                        children: [
                          if (visible.isEmpty)
                            _emptyState(context, accent)
                          else
                            ..._grouped(context, accent, visible),
                          SizedBox(height: context.h(16)),
                          // _coinsBanner(context),
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
      itemBuilder: (context) => [
        PopupMenuItem(value: 'all', child: Text(AppStrings.all)),
        PopupMenuItem(value: 'ride', child: Text(AppStrings.ordersRide)),
        PopupMenuItem(value: 'parcel', child: Text(AppStrings.ordersParcel)),
      ],
      child: Container(
        width: context.w(44),
        height: context.w(44),
        decoration: BoxDecoration(
          color: context.torkk.surfaceMuted,
          borderRadius: BorderRadius.circular(context.r(14)),
          border: Border.all(color: context.torkk.border),
        ),
        child: Icon(Icons.tune_rounded, color: context.torkk.textSecondary),
      ),
    );
  }

  /// Fixed gender brand color (blue / pink), independent of the dark theme's
  /// cream accent.
  Color _brand(BuildContext context) => context.watch<ThemeBloc>().state.isPink
      ? AppColors.femalePink
      : AppColors.maleBlue;

  Widget _emptyState(BuildContext context, Color accent) {
    accent = _brand(context);
    final icon = switch (_tab) {
      _OrderTab.current => Icons.local_shipping_outlined,
      _OrderTab.completed => Icons.task_alt_rounded,
      _OrderTab.cancelled => Icons.cancel_outlined,
      _OrderTab.scheduled => Icons.event_note_rounded,
    };
    final hint = switch (_tab) {
      _OrderTab.current => AppStrings.ordersEmptyCurrent,
      _OrderTab.completed => AppStrings.ordersEmptyCompleted,
      _OrderTab.cancelled => AppStrings.ordersEmptyCancelled,
      _OrderTab.scheduled => AppStrings.ordersEmptyScheduled,
    };
    return Padding(
      padding: EdgeInsets.only(
        top: context.h(56),
        left: context.w(24),
        right: context.w(24),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: context.w(150),
              height: context.w(150),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(
                        alpha: context.isDarkTheme ? 0.12 : 0.06,
                      ),
                    ),
                  ),
                  Container(
                    width: context.w(112),
                    height: context.w(112),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(
                        alpha: context.isDarkTheme ? 0.22 : 0.12,
                      ),
                    ),
                  ),
                  Container(
                    width: context.w(76),
                    height: context.w(76),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: context.w(38)),
                  ),
                  Positioned(
                    top: context.w(14),
                    right: context.w(20),
                    child: Icon(
                      Icons.star_rounded,
                      size: context.w(16),
                      color: accent.withValues(alpha: 0.4),
                    ),
                  ),
                  Positioned(
                    bottom: context.w(18),
                    left: context.w(16),
                    child: Icon(
                      Icons.circle,
                      size: context.w(9),
                      color: accent.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(20)),
            Text(
              AppStrings.ordersEmpty,
              textAlign: TextAlign.center,
              style: AppTypography.bold.copyWith(
                fontSize: 16,
                color: context.torkk.textPrimary,
              ),
            ),
            SizedBox(height: context.h(8)),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: AppTypography.regular.copyWith(
                fontSize: 13,
                height: 1.4,
                color: context.torkk.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs(BuildContext context, Color accent) {
    accent = _brand(context);
    final tabs = [
      (_OrderTab.current, AppStrings.ordersCurrent),
      (_OrderTab.completed, AppStrings.ordersCompleted),
      (_OrderTab.cancelled, AppStrings.ordersCancelled),
      (_OrderTab.scheduled, AppStrings.ordersScheduled),
    ];
    return Container(
      padding: EdgeInsets.all(context.w(4)),
      decoration: BoxDecoration(
        color: context.torkk.surfaceMuted,
        borderRadius: BorderRadius.circular(context.r(14)),
      ),
      child: Row(
        children: [
          for (final tab in tabs)
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTab(tab.$1),
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

  List<Widget> _grouped(
    BuildContext context,
    Color accent,
    List<Map<String, dynamic>> trips,
  ) {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final trip in trips) {
      groups.putIfAbsent(_dateLabel(trip), () => []).add(trip);
    }
    final widgets = <Widget>[];
    for (final entry in groups.entries) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top: context.h(8), bottom: context.h(8)),
          child: Text(
            entry.key,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              color: context.torkk.textSecondary,
            ),
          ),
        ),
      );
      for (final trip in entry.value) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: context.h(14)),
            child: _OrderCard(
              trip: trip,
              accent: accent,
              tab: _tab,
              onTap: () {
                final scheduledRide =
                    _tab == _OrderTab.scheduled && !_isParcel(trip);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => scheduledRide
                        ? const ScheduledRideScreen()
                        : OrderDetailsScreen(trip: trip),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
    return widgets;
  }

  int _coinsEarned() => _visible.fold<int>(
    0,
    (sum, t) => sum + (t['coins'] is num ? (t['coins'] as num).round() : 0),
  );
}

bool _isParcel(Map<String, dynamic> trip) {
  return trip['is_parcel'] == true ||
      trip['service_type']?.toString().toLowerCase() == 'parcel';
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
    final type = (trip['item_category'] ?? trip['parcel_type'] ?? 'Documents')
        .toString();
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

DateTime? _when(Map<String, dynamic> trip) {
  final raw =
      trip['scheduled_at'] ??
      trip['created_at'] ??
      trip['date'] ??
      trip['completed_at'];
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
  const months = [
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
  final label = trip['date_label']?.toString() ?? '';
  if (label.isNotEmpty) return label;
  final when = _when(trip);
  if (when == null) return '';
  final now = DateTime.now();
  final text = '${when.day} ${months[when.month - 1]} ${when.year}';
  final today =
      when.year == now.year && when.month == now.month && when.day == now.day;
  return today ? 'Today, $text' : text;
}
