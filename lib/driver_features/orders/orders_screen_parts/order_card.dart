part of 'package:rider_app/driver_features/orders/orders_screen.dart';

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
    final fare =
        trip['driver_earnings'] ?? trip['fare'] ?? trip['estimated_fare'];
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
                  color: parcel
                      ? context.adaptiveTint(Color(0xFFFFFBEB))
                      : context.adaptiveTint(Color(0xFFFAF5FF)),
                  borderRadius: BorderRadius.circular(context.r(12)),
                ),
                child: Icon(
                  parcel
                      ? Icons.inventory_2_rounded
                      : Icons.directions_car_filled_rounded,
                  color: parcel ? const Color(0xFFF59E0B) : accent,
                  size: context.w(20),
                ),
              ),
              SizedBox(width: context.w(12)),
              Text(
                _orderCode(trip),
                style: AppTypography.bold.copyWith(
                  fontSize: 15,
                  height: 1.2,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(width: context.w(8)),
              _StatusChip(
                label: _statusLabel(trip, tab),
                color: _statusColor(tab),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.slate400,
                size: context.w(20),
              ),
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
                        style: AppTypography.bold.copyWith(
                          fontSize: 16,
                          height: 1.2,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        AppStrings.ordersOnline,
                        style: AppTypography.regular.copyWith(
                          fontSize: 12,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.h(10)),
            child: Divider(height: 1, color: context.torkk.border),
          ),
          Text(
            _timeLabel(trip),
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(4)),
          Text(
            _route(trip),
            style: AppTypography.regular.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.torkk.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeLines(
    BuildContext context,
    Map<String, dynamic> trip,
    bool parcel,
  ) {
    if (parcel) {
      final type = (trip['item_category'] ?? trip['parcel_type'] ?? 'Documents')
          .toString();
      final weight = (trip['item_weight'] ?? '1 kg (Small)').toString();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.parcelType,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              height: 1.3,
              color: context.torkk.textSecondary,
            ),
          ),
          Text(
            '$type • $weight',
            style: AppTypography.bold.copyWith(
              fontSize: 14,
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
        ],
      );
    }
    return Text(
      _subtitle(trip, false),
      style: AppTypography.regular.copyWith(
        fontSize: 13,
        height: 1.3,
        color: context.torkk.textSecondary,
      ),
    );
  }
}
