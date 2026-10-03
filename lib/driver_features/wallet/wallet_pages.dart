import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  int _range = 0;

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    const ranges = ['Day', 'Week', 'Month'];
    return ProfilePage(
      title: 'Earnings',
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
        children: [
          Container(
            padding: EdgeInsets.all(context.w(4)),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(context.r(14)),
            ),
            child: Row(
              children: [
                for (var i = 0; i < ranges.length; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _range = i),
                      child: Container(
                        height: context.h(36),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _range == i ? accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(context.r(10)),
                        ),
                        child: Text(
                          ranges[i],
                          style: AppTypography.regular.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _range == i ? Colors.white : AppColors.slate500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: context.h(14)),
          Row(
            children: [
              Icon(Icons.chevron_left_rounded, color: AppColors.slate400, size: context.w(22)),
              Expanded(
                child: Text(
                  _range == 0 ? 'Today, 12 Jan 2024' : _range == 1 ? 'This Week' : 'January 2024',
                  textAlign: TextAlign.center,
                  style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: context.w(22)),
            ],
          ),
          SizedBox(height: context.h(14)),
          Container(
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: const Color(0xFFE8EDF5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Earnings", style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500)),
                      Text('₹680.00', style: AppTypography.bold.copyWith(fontSize: 22, height: 1.2, letterSpacing: -0.4)),
                    ],
                  ),
                ),
                Icon(Icons.star_rounded, color: const Color(0xFFF472B6), size: context.w(22)),
              ],
            ),
          ),
          SizedBox(height: context.h(12)),
          _group(context, const [
            _EarnRow(Icons.directions_car_filled_rounded, Color(0xFF7C3AED), Color(0xFFF3E8FF), 'Ride Earnings', '8 trips', '₹520.00'),
            _EarnRow(Icons.inventory_2_rounded, Color(0xFFF59E0B), Color(0xFFFEF3C7), 'Parcel Earnings', '2 delivers', '₹520.00'),
            _EarnRow(Icons.star_rounded, Color(0xFFDB2777), Color(0xFFFCE7F3), 'Bonus/Incentives', '', '₹520.00'),
          ]),
          SizedBox(height: context.h(12)),
          _group(context, const [
            _EarnRow(Icons.nightlight_round, Color(0xFF7C3AED), Color(0xFFF3E8FF), 'Night Charges', '10:00 am - 5:00 am', '₹520.00'),
            _EarnRow(Icons.access_time_filled_rounded, Color(0xFFF59E0B), Color(0xFFFEF3C7), 'Waiting Charges', 'after 5 mins of waiting', '₹520.00'),
            _EarnRow(Icons.two_wheeler_rounded, Color(0xFFF59E0B), Color(0xFFFEF3C7), 'Fair / km Plan(Bike)', 'Standard Plan', '₹520.00'),
          ]),
        ],
      ),
    );
  }

  Widget _group(BuildContext context, List<_EarnRow> rows) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(12)),
              child: Row(
                children: [
                  Container(
                    width: context.w(36),
                    height: context.w(36),
                    decoration: BoxDecoration(color: rows[i].background, borderRadius: BorderRadius.circular(context.r(10))),
                    child: Icon(rows[i].icon, color: rows[i].color, size: context.w(18)),
                  ),
                  SizedBox(width: context.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rows[i].title, style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                        if (rows[i].subtitle.isNotEmpty)
                          Text(rows[i].subtitle, style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500)),
                      ],
                    ),
                  ),
                  Text(rows[i].amount, style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EarnRow {
  const _EarnRow(this.icon, this.color, this.background, this.title, this.subtitle, this.amount);
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String subtitle;
  final String amount;
}

class WalletTxn {
  const WalletTxn({
    required this.kind,
    required this.time,
    required this.amount,
    required this.parcel,
  });

  final String kind;
  final String time;
  final String amount;
  final bool parcel;
}

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
      title: 'Transaction History',
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
        Text(title, style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500)),
        SizedBox(height: context.h(8)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.r(16)),
            border: Border.all(color: const Color(0xFFE8EDF5)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
                          backgroundColor: const Color(0xFFF1F5F9),
                          child: Icon(Icons.person, color: AppColors.slate400, size: context.w(16)),
                        ),
                        SizedBox(width: context.w(10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('User', style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                              Text('${items[i].kind}  ·  ${items[i].time}', style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500)),
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
      title: 'Transaction History',
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
            child: Text('Back to Home', style: AppTypography.bold.copyWith(fontSize: 15, height: 1, color: Colors.white)),
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
              style: AppTypography.regular.copyWith(fontSize: 13, height: 1.4, color: AppColors.slate500),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

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
                backgroundColor: const Color(0xFFF1F5F9),
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
            style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.textPrimary),
          ),
          SizedBox(height: context.h(8)),
          Text('Sector 62, Noida  →  DLF Mall of India', style: AppTypography.regular.copyWith(fontSize: 13)),
          SizedBox(height: context.h(4)),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: context.w(14), color: AppColors.slate400),
              SizedBox(width: context.w(4)),
              Text('4.2 km  •  18 mins', style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500)),
            ],
          ),
          SizedBox(height: context.h(16)),
          Text('Transaction Details', style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: context.h(8)),
          Container(
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: const Color(0xFFE8EDF5)),
            ),
            child: Column(
              children: [
                _line('Status', 'Completed', valueColor: const Color(0xFF16A34A)),
                _line('Transaction ID', '47323683678'),
                _line('Transaction Type', txn.parcel ? 'Parcel Earnings' : 'Ride Earnings'),
                _line('Amount', '₹120'),
                _line('Data & Time', '12 jan , 02:34 am'),
                _line('Job Reference', '#564646'),
              ],
            ),
          ),
          SizedBox(height: context.h(12)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: const Color(0xFFE8EDF5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.paymentStatus, style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500)),
                SizedBox(height: context.h(2)),
                Text(AppStrings.paidCash, style: AppTypography.bold.copyWith(fontSize: 15, height: 1.2, letterSpacing: -0.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500))),
          Text(value, style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class BankAccountScreen extends StatelessWidget {
  const BankAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Bank Account',
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
        children: [
          Text('Primary Bank Account', style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500)),
          SizedBox(height: context.h(8)),
          Container(
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: const Color(0xFFE8EDF5)),
            ),
            child: Row(
              children: [
                Container(
                  width: context.w(36),
                  height: context.w(36),
                  decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(context.r(10))),
                  child: Icon(Icons.account_balance_outlined, color: profileAccent(context), size: context.w(18)),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(12)),
          Row(
            children: [
              Icon(Icons.lock_outline, size: context.w(14), color: const Color(0xFF16A34A)),
              SizedBox(width: context.w(6)),
              Text('Your Bank details are safe and secure with us', style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500)),
            ],
          ),
        ],
      ),
    );
  }
}

class PayoutsScreen extends StatelessWidget {
  const PayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfilePage(title: 'Payouts', child: SizedBox.shrink());
  }
}
