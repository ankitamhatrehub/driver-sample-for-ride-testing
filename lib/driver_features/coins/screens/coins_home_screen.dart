import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/coins/widgets/coin_tiles.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

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
      title: 'Torkk Coin',
      onBack: onBack,
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(28), context.h(28), context.w(28), context.h(20)),
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
                  colors: [Color(0xFF0F3FBF), Color(0xFF61217E), Color(0xFFBA2879)],
                ),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Image.asset(AppAssets.rewardCoins, width: context.w(52), height: context.w(52)),
                  SizedBox(width: context.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Coin Balance',
                          style: AppTypography.regular.copyWith(fontSize: 13, color: Colors.white70),
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
              const Expanded(
                child: CoinMoneyCard(label: 'Total Earned', value: '+ ₹680.00', color: Color(0xFF16A34A)),
              ),
              SizedBox(width: context.w(10)),
              const Expanded(
                child: CoinMoneyCard(label: 'Total Redeemed', value: '₹3,420.00', color: Color(0xFFEF4444)),
              ),
            ],
          ),
          SizedBox(height: context.h(16)),
          Container(
            padding: EdgeInsets.all(context.w(16)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Scratch Card',
                        style: AppTypography.regular.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: context.w(8), vertical: context.h(3)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(context.r(9999)),
                      ),
                      child: Text(
                        'Job Id : #33435',
                        style: AppTypography.regular.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(4)),
                Text(
                  'Complete eligible jobs to get scratch cards and win exciting rewards.',
                  style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500),
                ),
                SizedBox(height: context.h(4)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.w(16)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.r(14)),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF), Color(0xFFF3E8FF)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(AppAssets.giftCard, width: context.w(60), height: context.w(60)),
                          SizedBox(width: context.w(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You have 1 Scratch Card!',
                                  style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Scratch now and see what you win.',
                                  style: AppTypography.regular.copyWith(fontSize: 11, color: AppColors.slate500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.h(22)),
                      Padding(
                        padding: EdgeInsets.only(top: context.h(8)),
                        child: UnifiedButton(label: 'View', onPressed: onView,  backgroundColor: const Color(0xFF0F3FBF),),
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
            label: 'Coin History',
            onTap: onHistory,
          ),
          SizedBox(height: context.h(10)),
          CoinLinkRow(
            icon: Icons.help_outline_rounded,
            color: const Color(0xFFEF4444),
            background: const Color(0xFFFEE2E2),
            label: 'How to Earn Coins',
            onTap: onHowTo,
          ),
        ],
      ),
    );
  }
}
