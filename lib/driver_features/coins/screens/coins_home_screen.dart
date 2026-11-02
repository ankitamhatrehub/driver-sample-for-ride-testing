import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/coins/widgets/coin_tiles.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

import '../../../common/constants/string_constants.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class CoinsHomeScreen extends StatelessWidget {
  const CoinsHomeScreen({
    super.key,
    required this.onBack,
    required this.onHistory,
    required this.onHowTo,
    required this.onView,
  });

  final VoidCallback onBack;
  final VoidCallback onHistory;
  final VoidCallback onHowTo;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.torkkCoin,
      onBack: onBack,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(28),
          context.h(28),
          context.w(28),
          context.h(20),
        ),
        children: [
          GestureDetector(
            onTap: onHistory,
            child: Container(
              padding: EdgeInsets.all(context.w(14)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.r(16)),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF0F3FBF),
                    Color(0xFF61217E),
                    Color(0xFFBA2879),
                  ],
                ),
                border: Border.all(color: context.torkk.border),
              ),
              child: Row(
                children: [
                  Image.asset(
                    AppAssets.rewardCoins,
                    width: context.w(52),
                    height: context.w(52),
                  ),
                  SizedBox(width: context.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.yourCoinBalance,
                          style: AppTypography.regular.copyWith(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '1,240',
                          style: AppTypography.bold.copyWith(
                            fontSize: 28,
                            height: 1.1,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
          SizedBox(height: context.h(34)),
          Row(
            children: [
              Expanded(
                child: CoinMoneyCard(
                  label: AppStrings.totalEarned,
                  value: '+ ₹680.00',
                  color: const Color(0xFF16A34A),
                ),
              ),
              SizedBox(width: context.w(10)),
              Expanded(
                child: CoinMoneyCard(
                  label: AppStrings.totalRedeemed,
                  value: '₹3,420.00',
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(16)),
          Container(
            padding: EdgeInsets.all(context.w(16)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: context.torkk.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.scratchCard,
                        style: AppTypography.regular.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(8),
                        vertical: context.h(3),
                      ),
                      decoration: BoxDecoration(
                        color: context.adaptiveTint(const Color(0xFFECFDF5)),
                        borderRadius: BorderRadius.circular(context.r(9999)),
                      ),
                      child: Text(
                        'Job Id : #33435',
                        style: AppTypography.regular.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.legible(Color(0xFF16A34A)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(4)),
                Text(
                  AppStrings.completeEligibleJobs,
                  style: AppTypography.regular.copyWith(
                    fontSize: 13,
                    color: context.torkk.textSecondary,
                  ),
                ),
                SizedBox(height: context.h(4)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.w(16)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.r(14)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.adaptiveTint(Color(0xFFEEF2FF)),
                        context.adaptiveTint(Color(0xFFF5F3FF)),
                        context.adaptiveTint(Color(0xFFF3E8FF)),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            AppAssets.giftCard,
                            width: context.w(60),
                            height: context.w(60),
                          ),
                          SizedBox(width: context.w(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.youHaveScratchCard,
                                  style: AppTypography.regular.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  AppStrings.scratchNowSeeWhatYouWin,
                                  style: AppTypography.regular.copyWith(
                                    fontSize: 11,
                                    color: context.torkk.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.h(22)),
                      Padding(
                        padding: EdgeInsets.only(top: context.h(8)),
                        child: UnifiedButton(
                          label: AppStrings.view,
                          onPressed: onView,
                          backgroundColor: const Color(0xFF0F3FBF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(12)),
          CoinLinkRow(
            icon: Icons.toll_rounded,
            color: const Color(0xFFF59E0B),
            background: const Color(0xFFFEF3C7),
            label: AppStrings.coinHistory,
            onTap: onHistory,
          ),
          SizedBox(height: context.h(10)),
          CoinLinkRow(
            icon: Icons.help_outline_rounded,
            color: const Color(0xFFEF4444),
            background: const Color(0xFFFEE2E2),
            label: AppStrings.howToEarnCoins,
            onTap: onHowTo,
          ),
        ],
      ),
    );
  }
}
