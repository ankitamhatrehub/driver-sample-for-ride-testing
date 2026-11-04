import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/wallet/payouts/payout_widgets.dart';
import 'package:rider_app/driver_features/wallet/payouts/withdraw_result_screens.dart';
import 'package:rider_app/driver_features/wallet/wallet_format.dart';

/// Pick an amount (typed or with the 25/50/75/100% chips) and withdraw it.
class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key, required this.balance});

  final double balance;

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  static const _percents = [25, 50, 75, 100];

  late final TextEditingController _controller;
  int? _selected = 50;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.balance * 0.5));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _format(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  double get _amount => double.tryParse(_controller.text.trim()) ?? 0;

  bool get _valid => _amount > 0 && _amount <= widget.balance;

  String? get _error {
    if (_controller.text.isEmpty || _amount == 0) return null;
    if (_amount > widget.balance) {
      return 'Maximum withdraw is ${rupees(widget.balance)}';
    }
    return null;
  }

  void _pick(int percent) {
    setState(() {
      _selected = percent;
      _controller.text = _format(widget.balance * percent / 100);
    });
  }

  void _withdraw() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WithdrawProcessingScreen(amount: _amount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return ProfilePage(
      title: 'Withdraw',
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(16),
        ),
        child: PayoutButton(
          label: 'Withdraw',
          onTap: _valid ? _withdraw : null,
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(16),
          context.w(20),
          context.h(20),
        ),
        children: [
          Container(
            padding: EdgeInsets.all(context.w(16)),
            decoration: BoxDecoration(
              color: context.torkk.surfaceMuted,
              borderRadius: BorderRadius.circular(context.r(20)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: context.w(44),
                      height: context.w(44),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(context.r(12)),
                      ),
                      child: Icon(
                        Icons.account_balance_rounded,
                        color: accent,
                        size: context.w(24),
                      ),
                    ),
                    SizedBox(width: context.w(12)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Balance',
                          style: AppTypography.bold.copyWith(fontSize: 16),
                        ),
                        Text(
                          rupees(widget.balance),
                          style: AppTypography.regular.copyWith(
                            fontSize: 13,
                            color: context.torkk.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: context.h(28)),
                IntrinsicWidth(
                  child: TextField(
                    controller: _controller,
                    autofocus: false,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setState(() => _selected = null),
                    style: AppTypography.bold.copyWith(
                      fontSize: 34,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      prefixText: '₹',
                      prefixStyle: AppTypography.bold.copyWith(fontSize: 34),
                      border: const UnderlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(height: context.h(10)),
                Text(
                  _error ?? 'Maximum Withdraw ${rupees(widget.balance)}',
                  style: AppTypography.regular.copyWith(
                    fontSize: 13,
                    color: _error != null
                        ? const Color(0xFFDC2626)
                        : context.torkk.textPrimary,
                  ),
                ),
                SizedBox(height: context.h(28)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final p in _percents)
                      GestureDetector(
                        onTap: () => _pick(p),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(16),
                            vertical: context.h(9),
                          ),
                          decoration: BoxDecoration(
                            color: _selected == p
                                ? accent
                                : context.torkk.surface,
                            borderRadius: BorderRadius.circular(context.r(20)),
                            border: Border.all(
                              color: _selected == p
                                  ? accent
                                  : context.torkk.border,
                            ),
                          ),
                          child: Text(
                            '$p%',
                            style: AppTypography.bold.copyWith(
                              fontSize: 13,
                              color: _selected == p
                                  ? Colors.white
                                  : context.torkk.textPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: context.h(12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
