import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

part 'order_details_screen_parts/order_coins_banner.dart';
part 'order_details_screen_sections.dart';

/// Ride or parcel details opened from an order card.
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.trip});

  final Map<String, dynamic> trip;

  bool get _parcel =>
      trip['is_parcel'] == true || trip['service_type']?.toString().toLowerCase() == 'parcel';

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
              padding: EdgeInsets.fromLTRB(context.w(8), context.h(4), context.w(16), 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back_ios_new, size: 18, color: context.torkk.textPrimary),
                  ),
                  Text(
                    _parcel ? AppStrings.parcelDetails : AppStrings.rideDetails,
                    style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2, letterSpacing: -0.4),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(24)),
                children: [
                  _summary(context, accent),
                  SizedBox(height: context.h(16)),
                  _customer(context, accent),
                  SizedBox(height: context.h(14)),
                  _rateRow(context),
                  SizedBox(height: context.h(18)),
                  Text(
                    AppStrings.fairDetails,
                    style: AppTypography.bold.copyWith(fontSize: 16, height: 1.2, letterSpacing: -0.3),
                  ),
                  SizedBox(height: context.h(10)),
                  _fareCard(context),
                  SizedBox(height: context.h(14)),
                  _paymentCard(context),
                  SizedBox(height: context.h(16)),
                  const OrderCoinsBanner(coins: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

(String, Color) _statusOf(Map<String, dynamic> trip) {
  final status = (trip['status'] ?? '').toString().toLowerCase();
  if (status == 'cancelled' || status == 'canceled' || status == 'rejected') {
    return (AppStrings.ordersCancelled, AppColors.error);
  }
  if (status == 'scheduled') return (AppStrings.ordersScheduled, const Color(0xFFF59E0B));
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
  return fallback.toString();
}
