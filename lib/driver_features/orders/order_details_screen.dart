import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

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

  Widget _summary(BuildContext context, Color accent) {
    final status = _statusOf(trip);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(context.w(14), context.h(14), context.w(14), context.h(14)),
      decoration: BoxDecoration(
        color: context.torkk.surfaceMuted,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: context.w(36),
                height: context.w(36),
                decoration: BoxDecoration(
                  color: _parcel ? context.adaptiveTint(Color(0xFFFEF3C7)) : accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.r(10)),
                ),
                child: Icon(
                  _parcel ? Icons.inventory_2_rounded : Icons.directions_car_filled_rounded,
                  color: _parcel ? const Color(0xFFF59E0B) : accent,
                  size: context.w(18),
                ),
              ),
              SizedBox(width: context.w(10)),
              Text(
                _orderCode(trip),
                style: AppTypography.bold.copyWith(fontSize: 15, height: 1.2, letterSpacing: -0.2),
              ),
              SizedBox(width: context.w(8)),
              _chip(context, status.$1, status.$2),
            ],
          ),
          SizedBox(height: context.h(10)),
          Text(
            _parcel
                ? '${trip['item_category'] ?? 'Documents'} • ${trip['item_weight'] ?? '1 kg (Small)'}'
                : '${trip['vehicle_type'] ?? AppStrings.ordersRide} • ${trip['passenger_count'] ?? 4} Seater',
            style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textPrimary),
          ),
          SizedBox(height: context.h(10)),
          Text(
            _timeLabel(trip),
            style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary),
          ),
          SizedBox(height: context.h(2)),
          Text(
            '${trip['pickup_address'] ?? ''}  →  ${trip['drop_address'] ?? ''}',
            style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textPrimary),
          ),
          SizedBox(height: context.h(6)),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: context.w(14), color: AppColors.slate400),
              SizedBox(width: context.w(4)),
              Text(
                '${trip['distance_km'] ?? 4.2} km  •  ${trip['duration_mins'] ?? 18} mins',
                style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _customer(BuildContext context, Color accent) {
    return Row(
      children: [
        CircleAvatar(
          radius: context.w(20),
          backgroundColor: context.adaptiveTint(const Color(0xFFF1F5F9)),
          child: Icon(Icons.person, color: AppColors.slate400, size: context.w(22)),
        ),
        SizedBox(width: context.w(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (trip['customer_name'] ?? '').toString(),
                style: AppTypography.bold.copyWith(fontSize: 15, height: 1.2, letterSpacing: -0.2),
              ),
              if (!_parcel)
                Row(
                  children: [
                    Icon(Icons.people_alt_outlined, size: context.w(14), color: AppColors.slate400),
                    SizedBox(width: context.w(4)),
                    Text(
                      '${trip['passengers'] ?? trip['passenger_count'] ?? 4} ${AppStrings.passengers}',
                      style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary),
                    ),
                    SizedBox(width: context.w(8)),
                    _countPill(context, Icons.thumb_up_alt_rounded, '${trip['likes'] ?? 2}', const Color(0xFF16A34A)),
                    SizedBox(width: context.w(6)),
                    _countPill(context, Icons.thumb_down_alt_rounded, '${trip['dislikes'] ?? 1}', const Color(0xFFEF4444)),
                  ],
                ),
            ],
          ),
        ),
        _roundAction(context, accent, Icons.chat_bubble_rounded),
        SizedBox(width: context.w(8)),
        _roundAction(context, accent, Icons.call_rounded),
      ],
    );
  }

  Widget _rateRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(36),
            height: context.w(36),
            decoration: BoxDecoration(
              color: context.adaptiveTint(const Color(0xFFFEF3C7)),
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: Icon(Icons.star_rounded, color: context.legible(Color(0xFFF59E0B)), size: context.w(20)),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.rateReceiver,
                  style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2, letterSpacing: -0.2),
                ),
                Text(
                  AppStrings.rateReceiverHint,
                  style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: context.w(20)),
        ],
      ),
    );
  }

  Widget _fareCard(BuildContext context) {
    final rows = [
      (AppStrings.fair, '₹${_money(trip['base_fare'], 68)}', false),
      (AppStrings.additionalWaitingCharge, '+ ₹${_money(trip['waiting_charge'], 8)}', false),
      (AppStrings.discountCoins, '- ₹${_money(trip['discount'], 10)}', true),
      (AppStrings.taxes, '+ ₹${_money(trip['taxes'], 0)}', false),
      (AppStrings.otherCharges, '+ ₹${_money(trip['other_charges'], 0)}', false),
    ];
    return Container(
      padding: EdgeInsets.fromLTRB(context.w(14), context.h(8), context.w(14), context.h(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(
        children: [
          for (final row in rows)
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(8)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.$1,
                      style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary),
                    ),
                  ),
                  Text(
                    row.$2,
                    style: AppTypography.regular.copyWith(
                      fontSize: 13,
                      color: row.$3 ? const Color(0xFFEF4444) : context.legible(AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          Divider(height: 1, color: context.torkk.border),
          Padding(
            padding: EdgeInsets.only(top: context.h(12)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.totalFair,
                    style: AppTypography.bold.copyWith(fontSize: 15, height: 1.2, letterSpacing: -0.2),
                  ),
                ),
                Text(
                  '₹${_money(trip['total_fare'], 64)}',
                  style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2, letterSpacing: -0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(14)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.paymentStatus,
            style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary),
          ),
          SizedBox(height: context.h(2)),
          Text(
            (trip['payment_label'] ?? AppStrings.paidCash).toString(),
            style: AppTypography.bold.copyWith(fontSize: 15, height: 1.2, letterSpacing: -0.2),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(8), vertical: context.h(2)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.r(8)),
      ),
      child: Text(
        label,
        style: AppTypography.regular.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _roundAction(BuildContext context, Color color, IconData icon) {
    return Container(
      width: context.w(36),
      height: context.w(36),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: context.w(16)),
    );
  }

  Widget _countPill(BuildContext context, IconData icon, String count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(6), vertical: context.h(2)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.r(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.w(12), color: color),
          SizedBox(width: context.w(2)),
          Text(
            count,
            style: AppTypography.regular.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class OrderCoinsBanner extends StatelessWidget {
  const OrderCoinsBanner({super.key, required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFDB2777)]),
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
