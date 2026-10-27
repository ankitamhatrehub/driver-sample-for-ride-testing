import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/wallet/models/wallet_txn.dart';
import 'package:rider_app/driver_features/wallet/screens/transaction_details_screen.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key, this.showEmpty = false});

  final bool showEmpty;

  static const _today = [
    WalletTxn(kind: 'Ride', time: '10:24 pm', amount: '+₹520.00', parcel: false),
    WalletTxn(kind: 'Parcel', time: '10:24 pm', amount: '+₹520.00', parcel: true),
    WalletTxn(kind: 'Parcel', time: '10:24 pm', amount: '+₹520.00', parcel: true),
  ];

  static const _yesterday = [
    WalletTxn(kind: 'Ride', time: '10:24 pm', amount: '+₹520.00', parcel: false),
    WalletTxn(kind: 'Parcel', time: '10:24 pm', amount: '+₹520.00', parcel: true),
    WalletTxn(kind: 'Parcel', time: '10:24 pm', amount: '+₹520.00', parcel: true),
    WalletTxn(kind: 'Parcel', time: '10:24 pm', amount: '+₹520.00', parcel: true),
  ];

  @override
  Widget build(BuildContext context) {
    if (showEmpty) return const _EmptyTransactions();
    return ProfilePage(
      title: AppStrings.transactionHistory,
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
        children: [
          _section(context, 'Today , 12 June', _today),
          SizedBox(height: context.h(14)),
          _section(context, 'Yesterday , 12 June', _yesterday),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<WalletTxn> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary)),
        SizedBox(height: context.h(8)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.r(16)),
            border: Border.all(color: context.torkk.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) Divider(height: 1, color: context.torkk.border),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => TransactionDetailsScreen(txn: items[i])),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(12)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: context.w(16),
                          backgroundColor: context.adaptiveTint(const Color(0xFFF1F5F9)),
                          child: Icon(Icons.person, color: AppColors.slate400, size: context.w(16)),
                        ),
                        SizedBox(width: context.w(10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('User', style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                              Text('${items[i].kind}  ·  ${items[i].time}', style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary)),
                            ],
                          ),
                        ),
                        Text(items[i].amount, style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF16A34A))),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.transactionHistory,
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(16)),
        child: SizedBox(
          width: double.infinity,
          height: context.h(48),
          child: FilledButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            style: FilledButton.styleFrom(
              backgroundColor: profileAccent(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
            ),
            child: Text('Back to Home', style: AppTypography.bold.copyWith(fontSize: 15, height: 1, color: Theme.of(context).colorScheme.onPrimary)),
          ),
        ),
      ),
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            width: context.w(120),
            height: context.w(120),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: context.w(78),
                  height: context.w(96),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.r(16)),
                    border: Border.all(color: profileAccent(context), width: 1.4),
                  ),
                  child: Icon(Icons.notes_rounded, color: const Color(0xFFCBD5E1), size: context.w(28)),
                ),
                Positioned(
                  top: context.h(18),
                  right: context.w(18),
                  child: const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 18),
                ),
                Positioned(
                  right: context.w(8),
                  bottom: context.h(16),
                  child: const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 22),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(16)),
          Text('No Transactions yet', style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2, letterSpacing: -0.3)),
          SizedBox(height: context.h(6)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(36)),
            child: Text(
              'Your transaction will appear here after you complete rides , parcels  or make any wallet activity.',
              textAlign: TextAlign.center,
              style: AppTypography.regular.copyWith(fontSize: 13, height: 1.4, color: context.torkk.textSecondary),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
