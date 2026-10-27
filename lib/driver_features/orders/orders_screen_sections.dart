part of 'package:rider_app/driver_features/orders/orders_screen.dart';

extension _OrdersScreenStateSections on _OrdersScreenState {
  Widget _coinsBanner(BuildContext context) {
    final coins = _coinsEarned();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        gradient: const LinearGradient(
          colors: [Color(0xFFBA2879), Color(0xFF61217E), Color(0xFF0F3FBF)],
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
}
