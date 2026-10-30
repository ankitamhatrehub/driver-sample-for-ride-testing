import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/service/driver_api_service.dart';

part 'order_details_screen_parts/order_coins_banner.dart';
part 'order_details_screen_sections.dart';

/// Ride or parcel details opened from an order card.
///
/// Shows the list item immediately, then merges in the full order from
/// `GET /api/driver/orders/{id}?type=ride|parcel`.
class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.trip});

  final Map<String, dynamic> trip;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Map<String, dynamic> trip = widget.trip;
  bool _loading = true;
  String? _error;

  bool get _parcel =>
      trip['is_parcel'] == true ||
      trip['service_type']?.toString().toLowerCase() == 'parcel';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.trip['id'] ?? widget.trip['order_id'];
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await DriverApiService.fetchOrderDetail(
        id: id,
        type: _parcel ? 'parcel' : 'ride',
      );
      if (!mounted) return;
      setState(() {
        trip = {...widget.trip, ...detail};
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppStrings.orderDetailsLoadFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
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
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: context.torkk.textPrimary,
                    ),
                  ),
                  Text(
                    _parcel ? AppStrings.parcelDetails : AppStrings.rideDetails,
                    style: AppTypography.bold.copyWith(
                      fontSize: 20,
                      height: 1.2,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    context.w(20),
                    context.h(8),
                    context.w(20),
                    context.h(24),
                  ),
                  children: [
                    if (_error != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: context.h(12)),
                        child: Text(
                          _error!,
                          style: AppTypography.regular.copyWith(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    _summary(context, accent),
                    SizedBox(height: context.h(16)),
                    _customer(context, accent),
                    SizedBox(height: context.h(14)),
                    _rateRow(context),
                    SizedBox(height: context.h(18)),
                    Text(
                      AppStrings.fairDetails,
                      style: AppTypography.bold.copyWith(
                        fontSize: 16,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: context.h(10)),
                    _fareCard(context),
                    SizedBox(height: context.h(14)),
                    _paymentCard(context),
                    SizedBox(height: context.h(16)),
                    OrderCoinsBanner(coins: _coins(trip)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int _coins(Map<String, dynamic> trip) {
  final value = trip['coins'];
  return value is num ? value.round() : 0;
}

(String, Color) _statusOf(Map<String, dynamic> trip) {
  final status = (trip['status'] ?? '').toString().toLowerCase();
  if (status == 'cancelled' || status == 'canceled' || status == 'rejected') {
    return (AppStrings.ordersCancelled, AppColors.error);
  }
  if (status == 'scheduled')
    return (AppStrings.ordersScheduled, const Color(0xFFF59E0B));
  if (status == 'completed' || status == 'complete') {
    return (AppStrings.ordersCompleted, const Color(0xFF16A34A));
  }
  return (AppStrings.ordersOngoing, const Color(0xFF16A34A));
}

String _orderCode(Map<String, dynamic> trip) {
  final text = (trip['order_id'] ?? trip['id'] ?? '').toString();
  if (text.isEmpty) return '#ORD';
  return text.toUpperCase().startsWith('ORD') ? '#$text' : '#ORD$text';
}

String _timeLabel(Map<String, dynamic> trip) {
  final when = DateTime.tryParse((trip['created_at'] ?? '').toString());
  if (when == null) return '';
  final hour12 = when.hour % 12 == 0 ? 12 : when.hour % 12;
  final hour = hour12.toString().padLeft(2, '0');
  final minute = when.minute.toString().padLeft(2, '0');
  final suffix = when.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

String _money(Object? value, int fallback) {
  if (value is num) return value.round().toString();
  return (int.tryParse(value?.toString() ?? '') ?? fallback).toString();
}
