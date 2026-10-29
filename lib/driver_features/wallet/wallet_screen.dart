import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/coins/screens/coins_screen.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/subscription/screens/subscription_screen.dart';
import 'package:rider_app/driver_features/parcels/coming_soon_screen.dart';
import 'package:rider_app/driver_features/wallet/wallet_pages.dart';

import '../../common/constants/string_constants.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.walletEarning,
      onBack: onBack,
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
        children: [
          const _BalanceCard(),
          SizedBox(height: context.h(12)),
          Row(
            children: [
              Expanded(child: _statCard(context, "Today's Earnings", '₹680.00', Icons.account_balance_wallet_outlined, const Color(0xFFF59E0B))),
              SizedBox(width: context.w(10)),
              Expanded(child: _statCard(context, 'This Week', '₹3,420.00', Icons.calendar_today_outlined, const Color(0xFFF59E0B))),
            ],
          ),
          SizedBox(height: context.h(18)),
          _actions(context),
          SizedBox(height: context.h(18)),
          Text(AppStrings.activePlan, style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: context.h(8)),
          _activePlan(context),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: EdgeInsets.all(context.w(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary))),
              Icon(icon, size: context.w(16), color: iconColor),
            ],
          ),
          SizedBox(height: context.h(6)),
          Text(value, style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2, letterSpacing: -0.3)),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    final items = [
      _Action(Icons.description_outlined, const Color(0xFF7C3AED), const Color(0xFFF3E8FF), AppStrings.transactionHistory, () => _open(context, const TransactionHistoryScreen())),
      _Action(Icons.account_balance_outlined, const Color(0xFF7C3AED), const Color(0xFFF3E8FF), AppStrings.payouts, () => _open(context, const PayoutsScreen())),
      _Action(Icons.account_balance_rounded, const Color(0xFFDB2777), const Color(0xFFFCE7F3), AppStrings.BankAccount, () => _open(context, const BankAccountScreen())),
      _Action(Icons.credit_card_rounded, const Color(0xFFDB2777), const Color(0xFFFCE7F3), AppStrings.rechargeSubscription, () => _open(context, const ComingSoonScreen())), // coming soon for now
      // Previous navigation: () => _open(context, const SubscriptionScreen())
      _Action(Icons.currency_rupee_rounded, const Color(0xFF7C3AED), const Color(0xFFF3E8FF), AppStrings.earnings, () => _open(context, const EarningsScreen())),
      _Action(Icons.toll_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7), AppStrings.torkkCoins, () => _open(context, const CoinsScreen())),
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.72,
      mainAxisSpacing: context.h(8),
      children: [for (final item in items) _actionTile(context, item)],
    );
  }

  Widget _actionTile(BuildContext context, _Action item) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: context.w(48),
            height: context.w(48),
            decoration: BoxDecoration(color: item.background, borderRadius: BorderRadius.circular(context.r(16))),
            child: Icon(item.icon, color: item.color, size: context.w(22)),
          ),
          SizedBox(height: context.h(6)),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: AppTypography.regular.copyWith(fontSize: 11, height: 1.2, color: context.torkk.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _activePlan(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context, const SubscriptionScreen()),
      child: Container(
        padding: EdgeInsets.all(context.w(12)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(color: context.torkk.border),
        ),
        child: Row(
          children: [
            Container(
              width: context.w(36),
              height: context.w(36),
              decoration: BoxDecoration(color: context.adaptiveTint(const Color(0xFFF3E8FF)), borderRadius: BorderRadius.circular(context.r(10))),
              child: Icon(Icons.confirmation_number_outlined, color: context.legible(Color(0xFF7C3AED)), size: context.w(18)),
            ),
            SizedBox(width: context.w(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.standardDriverPlan, style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(AppStrings.perMonth, style: AppTypography.bold.copyWith(fontSize: 13, height: 1.3, letterSpacing: -0.2)),
                  Text(AppStrings.validTill24Aug, style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: context.w(20)),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(20)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFBA2879), Color(0xFF61217E), Color(0xFF0F3FBF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(AppStrings.availableCash, style: AppTypography.regular.copyWith(fontSize: 13, color: Colors.white70))),
              Container(
                width: context.w(32),
                height: context.w(32),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(context.r(10))),
                child: Icon(Icons.show_chart_rounded, color: Colors.white, size: context.w(16)),
              ),
            ],
          ),
          Text('₹1,840', style: AppTypography.bold.copyWith(fontSize: 28, height: 1.2, color: Colors.white, letterSpacing: -0.6)),
          Text('12 rides', style: AppTypography.regular.copyWith(fontSize: 12, color: Colors.white70)),
          SizedBox(height: context.h(14)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(10)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(context.r(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(AppStrings.todaysCompletedJobs, style: AppTypography.regular.copyWith(fontSize: 13, color: Colors.white)),
                ),
                Text('12', style: AppTypography.bold.copyWith(fontSize: 16, height: 1, color: Colors.white)),
                SizedBox(width: context.w(8)),
                Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: context.w(18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Action {
  const _Action(this.icon, this.color, this.background, this.label, this.onTap);
  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final VoidCallback onTap;
}
