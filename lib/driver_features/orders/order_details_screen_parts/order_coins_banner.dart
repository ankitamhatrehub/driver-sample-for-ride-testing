part of 'package:rider_app/driver_features/orders/order_details_screen.dart';

class OrderCoinsBanner extends StatelessWidget {
  const OrderCoinsBanner({super.key, required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(14),
        vertical: context.h(12),
      ),
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
            child: Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: context.w(18),
            ),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.ordersYouEarnedCoins} $coins ${AppStrings.ordersCoins}',
                  style: AppTypography.bold.copyWith(
                    fontSize: 14,
                    height: 1.2,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  AppStrings.ordersCoinsHint,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    height: 1.3,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white,
            size: context.w(20),
          ),
        ],
      ),
    );
  }
}
