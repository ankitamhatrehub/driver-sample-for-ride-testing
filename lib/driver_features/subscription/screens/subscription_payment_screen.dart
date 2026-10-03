import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/subscription/models/subscription_plan.dart';
import 'package:rider_app/driver_features/subscription/widgets/payment_method_tile.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_page.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_plan_card.dart';

class SubscriptionPaymentScreen extends StatelessWidget {
  const SubscriptionPaymentScreen({
    super.key,
    required this.plan,
    required this.method,
    required this.onMethod,
    required this.onPay,
    required this.onBack,
  });

  final SubscriptionPlan plan;
  final PayMethod method;
  final ValueChanged<PayMethod> onMethod;
  final VoidCallback onPay;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Payment',
      onBack: onBack,
      bottom: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: context.w(14), color: const Color(0xFF16A34A)),
              SizedBox(width: context.w(10)),
              Text(
                'Your Bank details are safe and secure with us',
                style: AppTypography.regular.copyWith(
                  fontSize: 11,
                  height: 1.35,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(8)),
          SubscriptionButton(label: 'Pay ₹ ${plan.price}', onTap: onPay),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(12)),
        children: [
          SubscriptionPlanCard(
            name: plan.name.replaceAll(' - ', '- '),
            subtitle: plan.validity,
            trailing: Text(
              '₹ ${plan.price}',
              style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2, letterSpacing: -0.3),
            ),
          ),
          SizedBox(height: context.h(22)),
          Text(
            'Select Payment Method',
            style: AppTypography.regular.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: context.h(6)),
          PaymentMethodTile(
            method: PayMethod.upi,
            selected: method == PayMethod.upi,
            title: 'UPI',
            subtitle: 'Select using any UPI app',
            asset: AppAssets.upi,
            onTap: onMethod,
          ),
          PaymentMethodTile(
            method: PayMethod.card,
            selected: method == PayMethod.card,
            title: 'Debit/Credit Card',
            subtitle: 'Visa, Master Card, Rupay',
            icon: Icons.credit_card_rounded,
            onTap: onMethod,
          ),
          PaymentMethodTile(
            method: PayMethod.wallet,
            selected: method == PayMethod.wallet,
            title: 'Wallet',
            subtitle: 'Torkk wallet balance ( ₹ 320 )',
            asset: AppAssets.walletCoins,
            onTap: onMethod,
          ),
        ],
      ),
    );
  }
}
