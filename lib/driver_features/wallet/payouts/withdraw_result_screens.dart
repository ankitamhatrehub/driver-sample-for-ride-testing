import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/ai_chat_button.dart';
import 'package:rider_app/driver_features/wallet/payouts/payout_mock.dart';
import 'package:rider_app/driver_features/wallet/payouts/payout_widgets.dart';
import 'package:rider_app/driver_features/wallet/wallet_format.dart';

const _green = Color(0xFF16A34A);
const _orange = Color(0xFFF08A24);
const _red = Color(0xFFDC2626);

/// Closes the withdraw flow (the 'withdraw' route and everything above it).
void _backToPayouts(BuildContext context) {
  final nav = Navigator.of(context);
  nav.popUntil((route) => route.settings.name == 'withdraw' || route.isFirst);
  if (nav.canPop()) nav.pop();
}

/// Shown while the withdrawal is being confirmed. Blocks going back. With no
/// API yet it waits a moment, then moves on to the success or failed screen.
class WithdrawProcessingScreen extends StatefulWidget {
  const WithdrawProcessingScreen({super.key, required this.amount});

  final double amount;

  @override
  State<WithdrawProcessingScreen> createState() =>
      _WithdrawProcessingScreenState();
}

class _WithdrawProcessingScreenState extends State<WithdrawProcessingScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final Widget next = PayoutMock.withdrawFails
          ? WithdrawFailedScreen(amount: widget.amount)
          : WithdrawSuccessScreen(receipt: WithdrawReceipt.now(widget.amount));
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute<void>(builder: (_) => next));
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.torkk.background,
        body: SafeArea(
          child: Center(
            child: PayoutStatusHero(
              color: _orange,
              icon: Icons.hourglass_top_rounded,
              title: 'Payment Processing',
              message:
                  'Please do not close the app or go back while we confirm your payment',
              child: SizedBox(
                width: context.w(64),
                height: context.w(64),
                child: const CircularProgressIndicator(
                  color: _orange,
                  strokeWidth: 5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WithdrawSuccessScreen extends StatelessWidget {
  const WithdrawSuccessScreen({super.key, required this.receipt});

  final WithdrawReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final amount = rupees(receipt.amount, decimals: 0);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.torkk.background,
        floatingActionButton: const AiChatButton(size: 48),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.w(20),
                    context.h(48),
                    context.w(20),
                    context.h(16),
                  ),
                  children: [
                    PayoutStatusHero(
                      color: _green,
                      icon: Icons.check_rounded,
                      title: 'Withdraw Successful',
                      message:
                          'Your payment of $amount was completed successful',
                    ),
                    SizedBox(height: context.h(24)),
                    Text(
                      'Withdraw Details',
                      style: AppTypography.bold.copyWith(fontSize: 14),
                    ),
                    SizedBox(height: context.h(10)),
                    _DetailsCard(receipt: receipt, amount: amount),
                    SizedBox(height: context.h(12)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(16),
                        vertical: context.h(12),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(context.r(16)),
                        border: Border.all(color: context.torkk.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Status',
                            style: AppTypography.regular.copyWith(
                              fontSize: 12,
                              color: context.torkk.textSecondary,
                            ),
                          ),
                          SizedBox(height: context.h(2)),
                          Text(
                            'Money Debited.',
                            style: AppTypography.bold.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.w(20),
                  0,
                  context.w(20),
                  context.h(16),
                ),
                child: PayoutButton(
                  label: 'Done',
                  onTap: () => _backToPayouts(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.receipt, required this.amount});

  final WithdrawReceipt receipt;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Transaction ID', receipt.transactionId),
      ('Transaction Type', 'Withdraw'),
      ('Withdraw fee', receipt.fee == 0 ? '0' : rupees(receipt.fee)),
      ('Amount', amount),
      ('Date & Time', receipt.dateTime),
      ('Payment Method', receipt.method),
      ('Bill Paid To', receipt.paidTo),
    ];
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(16),
        vertical: context.h(12),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label(context, 'Status'),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(10),
                  vertical: context.h(3),
                ),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(context.r(20)),
                ),
                child: Text(
                  'Completed',
                  style: AppTypography.bold.copyWith(
                    fontSize: 12,
                    color: _green,
                  ),
                ),
              ),
            ],
          ),
          for (final (label, value) in rows)
            Padding(
              padding: EdgeInsets.only(top: context.h(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label(context, label),
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: AppTypography.regular.copyWith(
                        fontSize: 14,
                        color: context.torkk.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Text(
    text,
    style: AppTypography.regular.copyWith(
      fontSize: 14,
      color: context.torkk.textSecondary,
    ),
  );
}

class WithdrawFailedScreen extends StatelessWidget {
  const WithdrawFailedScreen({super.key, required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.torkk.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: PayoutStatusHero(
                    color: _red,
                    icon: Icons.priority_high_rounded,
                    title: 'Payment Failed',
                    message: 'Due to network issue',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.w(20),
                  0,
                  context.w(20),
                  context.h(16),
                ),
                child: Column(
                  children: [
                    PayoutButton(
                      label: 'Try Again',
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              WithdrawProcessingScreen(amount: amount),
                        ),
                      ),
                    ),
                    SizedBox(height: context.h(12)),
                    PayoutButton(
                      label: 'Cancel',
                      outline: true,
                      onTap: () => _backToPayouts(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
