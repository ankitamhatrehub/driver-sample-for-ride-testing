import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/wallet/models/wallet_txn.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key, required this.txn});

  final WalletTxn txn;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Transaction Details',
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: context.w(18),
                backgroundColor: context.adaptiveTint(const Color(0xFFF1F5F9)),
                child: Icon(Icons.person, color: AppColors.slate400, size: context.w(18)),
              ),
              SizedBox(width: context.w(10)),
              Expanded(child: Text('User', style: AppTypography.bold.copyWith(fontSize: 16, height: 1.2, letterSpacing: -0.2))),
              Text('₹520', style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2, letterSpacing: -0.3)),
            ],
          ),
          SizedBox(height: context.h(8)),
          Text(
            txn.parcel ? 'Parcel' : 'Ride • 4 Seater',
            style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textPrimary),
          ),
          SizedBox(height: context.h(8)),
          Text('Sector 62, Noida  →  DLF Mall of India', style: AppTypography.regular.copyWith(fontSize: 13)),
          SizedBox(height: context.h(4)),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: context.w(14), color: AppColors.slate400),
              SizedBox(width: context.w(4)),
              Text('4.2 km  •  18 mins', style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary)),
            ],
          ),
          SizedBox(height: context.h(16)),
          Text('Transaction Details', style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: context.h(8)),
          Container(
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: context.torkk.border),
            ),
            child: Column(
              children: [
                _line(context, 'Status', 'Completed', valueColor: const Color(0xFF16A34A)),
                _line(context, 'Transaction ID', '47323683678'),
                _line(context, 'Transaction Type', txn.parcel ? 'Parcel Earnings' : 'Ride Earnings'),
                _line(context, 'Amount', '₹120'),
                _line(context, 'Data & Time', '12 jan , 02:34 am'),
                _line(context, 'Job Reference', '#564646'),
              ],
            ),
          ),
          SizedBox(height: context.h(12)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: context.torkk.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.paymentStatus, style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary)),
                SizedBox(height: context.h(2)),
                Text(AppStrings.paidCash, style: AppTypography.bold.copyWith(fontSize: 15, height: 1.2, letterSpacing: -0.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary))),
          Text(value, style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? context.legible(AppColors.textPrimary))),
        ],
      ),
    );
  }
}
