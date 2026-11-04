import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/wallet/payouts/payout_mock.dart';
import 'package:rider_app/driver_features/wallet/payouts/withdraw_screen.dart';
import 'package:rider_app/driver_features/wallet/screens/bank_account_screen.dart';
import 'package:rider_app/driver_features/wallet/screens/transaction_history_screen.dart';
import 'package:rider_app/driver_features/wallet/wallet_format.dart';

/// Payouts home: balance, withdraw, quick links and recent payout history.
/// Figures come from [PayoutMock] until the payout APIs are ready.
class PayoutsScreen extends StatelessWidget {
  const PayoutsScreen({super.key});

  void _open(BuildContext context, Widget screen, {String? name}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => screen,
        settings: RouteSettings(name: name),
      ),
    );
  }

  void _withdraw(BuildContext context) => _open(
    context,
    const WithdrawScreen(balance: PayoutMock.availableBalance),
    name: 'withdraw',
  );

  void _history(BuildContext context) =>
      _open(context, const TransactionHistoryScreen());

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.payouts,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(24),
        ),
        children: [
          _BalanceCard(onWithdraw: () => _withdraw(context)),
          SizedBox(height: context.h(14)),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'This Week',
                  value: rupees(PayoutMock.thisWeek),
                  icon: Icons.calendar_month_rounded,
                  color: profileAccent(context),
                ),
              ),
              SizedBox(width: context.w(12)),
              Expanded(
                child: _StatCard(
                  label: 'Pending Payouts',
                  value: rupees(PayoutMock.pendingPayouts),
                  icon: Icons.pending_actions_rounded,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(14)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Action(
                'Statement',
                Icons.swap_horiz_rounded,
                const Color(0xFF0891B2),
                () => _history(context),
              ),
              _Action(
                'Settlement',
                Icons.arrow_circle_right_outlined,
                const Color(0xFF2563EB),
                () => _history(context),
              ),
              _Action(
                'Withdraw',
                Icons.credit_card_rounded,
                const Color(0xFFDC2626),
                () => _withdraw(context),
              ),
              _Action(
                'Bank\nAccount',
                Icons.account_balance_rounded,
                const Color(0xFF7C3AED),
                () => _open(context, const BankAccountScreen()),
              ),
            ],
          ),
          SizedBox(height: context.h(36)),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Payout Transaction History',
                  style: AppTypography.bold.copyWith(
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _history(context),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  'view all',
                  style: AppTypography.regular.copyWith(
                    fontSize: 13,
                    color: context.torkk.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(14)),
          Text(
            'Today , 12 June',
            style: AppTypography.bold.copyWith(fontSize: 14),
          ),
          SizedBox(height: context.h(10)),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: context.torkk.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < PayoutMock.today.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: context.torkk.border),
                  _EntryRow(entry: PayoutMock.today[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.onWithdraw});

  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    final pink = accent == AppColors.femalePink;
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.w(16),
        context.h(12),
        context.w(16),
        context.h(12),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(22)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pink
              ? const [Color(0xFFBA2879), Color(0xFF6B1848)]
              : const [Color(0xFF1E40AF), Color(0xFF61217E), Color(0xFF9D2F7B)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: AppTypography.bold.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              Container(
                width: context.w(34),
                height: context.w(34),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.r(10)),
                ),
                child: CustomPaint(
                  size: Size(context.w(18), context.w(18)),
                  painter: _SlimWalletPainter(const Color(0xFF334155)),
                ),
              ),
            ],
          ),
          Text(
            rupees(PayoutMock.availableBalance, decimals: 0),
            style: AppTypography.bold.copyWith(
              fontSize: 30,
              height: 1.15,
              letterSpacing: -0.8,
              color: Colors.white,
            ),
          ),
          Text(
            'Available to withdraw',
            style: AppTypography.regular.copyWith(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: context.h(8)),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          SizedBox(height: context.h(10)),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(14)),
            child: InkWell(
              onTap: onWithdraw,
              borderRadius: BorderRadius.circular(context.r(14)),
              child: SizedBox(
                height: context.h(38),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Withdraw Money',
                      style: AppTypography.bold.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(width: context.w(8)),
                    Icon(
                      Icons.north_east_rounded,
                      size: context.w(16),
                      color: const Color(0xFF1E293B),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(12),
        vertical: context.h(9),
      ),
      decoration: BoxDecoration(
        color: context.torkk.surface,
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
                  label,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    color: context.torkk.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(context.w(5)),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(context.r(8)),
                ),
                child: Icon(icon, size: context.w(14), color: color),
              ),
            ],
          ),
          SizedBox(height: context.h(6)),
          Text(value, style: AppTypography.bold.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(this.label, this.icon, this.color, this.onTap);

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: context.w(72),
        child: Column(
          children: [
            Container(
              width: context.w(56),
              height: context.w(56),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.r(16)),
              ),
              child: Icon(icon, color: color, size: context.w(26)),
            ),
            SizedBox(height: context.h(8)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.bold.copyWith(fontSize: 12, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final PayoutEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(14),
        vertical: context.h(14),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(40),
            height: context.w(40),
            decoration: BoxDecoration(
              color: context.torkk.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppColors.slate400,
              size: context.w(22),
            ),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: AppTypography.bold.copyWith(fontSize: 14),
                ),
                Text(
                  entry.time,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    color: context.torkk.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '- ${rupees(entry.amount)}',
            style: AppTypography.bold.copyWith(
              fontSize: 14,
              color: const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin-line wallet icon (Material's own wallet glyph is too heavy here).
class _SlimWalletPainter extends CustomPainter {
  const _SlimWalletPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;
    final body = RRect.fromLTRBR(
      0.5,
      h * 0.2,
      w - 0.5,
      h - 0.5,
      Radius.circular(w * 0.18),
    );
    canvas.drawRRect(body, paint);
    // Flap on top.
    final flap = Path()
      ..moveTo(w * 0.15, h * 0.2)
      ..lineTo(w * 0.7, h * 0.02)
      ..lineTo(w * 0.8, h * 0.2);
    canvas.drawPath(flap, paint);
    // Clasp.
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.62,
        h * 0.46,
        w - 0.5,
        h * 0.76,
        Radius.circular(w * 0.1),
      ),
      paint,
    );
    canvas.drawCircle(Offset(w * 0.76, h * 0.61), 0.7, paint);
  }

  @override
  bool shouldRepaint(_SlimWalletPainter old) => old.color != color;
}
