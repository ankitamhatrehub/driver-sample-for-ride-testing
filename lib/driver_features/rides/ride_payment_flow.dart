import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

/// What the driver collected for a ride. Shown on the Ride Completed screen.
class RidePaymentResult {
  const RidePaymentResult({
    required this.total,
    required this.upi,
    required this.cash,
    required this.change,
    required this.outstanding,
  });

  final double total;
  final double upi;
  final double cash;
  final double change;
  final double outstanding;

  /// Short label for how the rider paid.
  String get label {
    final parts = <String>[if (upi > 0) 'UPI', if (cash > 0) 'Cash'];
    final base = parts.isEmpty ? 'Unpaid' : 'Paid ${parts.join(' + ')}';
    return outstanding > 0 ? '$base · ₹${outstanding.round()} due' : base;
  }
}

enum _Step { qr, cash, adjust, review, done }

enum _Settle { wallet, cashReturned, upi }

/// Payment steps after the driver taps End Ride: collect by QR (UPI), collect
/// cash (with change / outstanding handling), review, then confirm.
///
/// The QR is a static placeholder until the payment backend is connected.
class RidePaymentFlow extends StatefulWidget {
  const RidePaymentFlow({
    super.key,
    required this.total,
    required this.earning,
    required this.riderId,
    required this.distanceLabel,
    required this.onBack,
    required this.onDone,
  });

  final double total;
  final double earning;
  final String riderId;
  final String distanceLabel;
  final VoidCallback onBack;
  final ValueChanged<RidePaymentResult> onDone;

  @override
  State<RidePaymentFlow> createState() => _RidePaymentFlowState();
}

class _RidePaymentFlowState extends State<RidePaymentFlow> {
  _Step _step = _Step.qr;
  _Step _cashBack = _Step.qr;
  Timer? _upiTimer;

  double _upi = 0;
  double _cash = 0;
  double _change = 0;
  double _outstanding = 0;

  /// Adjustment choice when the rider paid only part by UPI.
  bool _remainingByCash = true;

  final _received = TextEditingController();
  _Settle? _settle;
  bool _carryAgreed = false;

  double get _total => widget.total;
  double get _due => (_total - _upi).clamp(0, double.infinity).toDouble();
  double get _receivedAmount => double.tryParse(_received.text.trim()) ?? 0;

  @override
  void initState() {
    super.initState();
    _startWaiting();
  }

  @override
  void dispose() {
    _upiTimer?.cancel();
    _received.dispose();
    super.dispose();
  }

  /// Placeholder for the payment webhook: the QR "gets paid" after a few
  /// seconds. Replace with the real payment status once the API exists.
  void _startWaiting() {
    _upiTimer?.cancel();
    _upiTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted || _step != _Step.qr) return;
      setState(() {
        _upi = _total;
        _cash = 0;
        _change = 0;
        _outstanding = 0;
        _step = _Step.review;
      });
    });
  }

  void _openCash({required _Step back, double upi = 0}) {
    _upiTimer?.cancel();
    setState(() {
      _upi = upi;
      _cashBack = back;
      _settle = null;
      _carryAgreed = false;
      _received.text = _due.toStringAsFixed(0);
      _step = _Step.cash;
    });
  }

  void _confirmCash() {
    final received = _receivedAmount;
    setState(() {
      if (received >= _due) {
        _cash = _due;
        _change = received - _due;
        _outstanding = 0;
      } else {
        _cash = received;
        _change = 0;
        _outstanding = _due - received;
      }
      _step = _Step.review;
    });
  }

  void _back() {
    switch (_step) {
      case _Step.qr:
        _upiTimer?.cancel();
        widget.onBack();
      case _Step.cash:
        if (_cashBack == _Step.qr) {
          setState(() => _step = _Step.qr);
          _startWaiting();
        } else {
          setState(() => _step = _cashBack);
        }
      case _Step.adjust:
        setState(() => _step = _Step.qr);
        _startWaiting();
      case _Step.review:
        setState(() => _step = _Step.qr);
        _startWaiting();
      case _Step.done:
        setState(() => _step = _Step.review);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _Step.qr => _qrPage(context),
      _Step.cash => _cashPage(context),
      _Step.adjust => _adjustPage(context),
      _Step.review => _reviewPage(context),
      _Step.done => _donePage(context),
    };
  }

  // ----- shared pieces -----
  String _money(double v) => '₹${v.round()}';
  String _money2(double v) => '₹${v.toStringAsFixed(2)}';

  Widget _scaffold(
    BuildContext context, {
    String title = '',
    required Widget child,
    Widget? bottom,
  }) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(8),
                context.h(4),
                context.w(16),
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _back,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.bold.copyWith(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: context.w(48)),
                ],
              ),
            ),
            Expanded(child: child),
            if (bottom != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.w(20),
                  context.h(8),
                  context.w(20),
                  context.h(12),
                ),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }

  Widget _amountHeader(
    BuildContext context,
    String label,
    double amount, {
    String? sub,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.regular.copyWith(
            fontSize: 15,
            color: context.torkk.textPrimary,
          ),
        ),
        SizedBox(height: context.h(6)),
        Text(
          _money2(amount),
          style: AppTypography.bold.copyWith(fontSize: 32, height: 1.1),
        ),
        if (sub != null) ...[
          SizedBox(height: context.h(4)),
          Text(
            sub,
            style: AppTypography.regular.copyWith(
              fontSize: 12,
              color: context.torkk.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _qrBlock(BuildContext context, {double size = 200}) {
    return Column(
      children: [
        Container(
          width: context.w(size),
          height: context.w(size),
          padding: EdgeInsets.all(context.w(10)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(12)),
            border: Border.all(color: context.torkk.border),
          ),
          child: CustomPaint(painter: _StaticQrPainter(widget.riderId)),
        ),
        SizedBox(height: context.h(8)),
        Text(
          'Payment ID:  ${widget.riderId}',
          style: AppTypography.regular.copyWith(
            fontSize: 12,
            color: context.torkk.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.w(14),
        vertical: context.h(10),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(children: rows),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    final style = bold
        ? AppTypography.bold.copyWith(fontSize: 14)
        : AppTypography.regular.copyWith(
            fontSize: 14,
            color: context.torkk.textSecondary,
          );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(6)),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(
            value,
            style:
                (bold
                        ? AppTypography.bold
                        : AppTypography.regular.copyWith(
                            color: context.torkk.textPrimary,
                          ))
                    .copyWith(fontSize: 14, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(top: context.h(16), bottom: context.h(8)),
      child: Text(text, style: AppTypography.bold.copyWith(fontSize: 13)),
    );
  }

  Widget _choice(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final brand = context.brandColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.h(8)),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: selected ? brand : context.torkk.textDisabled,
            ),
            SizedBox(width: context.w(10)),
            Expanded(
              child: Text(
                label,
                style: AppTypography.regular.copyWith(fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- 1. Collect payment (QR) -----
  Widget _qrPage(BuildContext context) {
    return _scaffold(
      context,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(24)),
        children: [
          SizedBox(height: context.h(8)),
          _amountHeader(context, 'Total Amount', _total),
          SizedBox(height: context.h(20)),
          Center(child: _qrBlock(context, size: 220)),
          SizedBox(height: context.h(18)),
          Text(
            'Collect Payment',
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(fontSize: 22),
          ),
          SizedBox(height: context.h(10)),
          Text(
            'Scan QR Code to Pay',
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(fontSize: 15),
          ),
          SizedBox(height: context.h(4)),
          Text(
            'Customer can scan using any supported UPI app',
            textAlign: TextAlign.center,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(28)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: context.w(16),
                height: context.w(16),
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: context.w(8)),
              Text(
                'Waiting for payment confirmation...',
                style: AppTypography.regular.copyWith(fontSize: 13),
              ),
            ],
          ),
          SizedBox(height: context.h(20)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openCash(back: _Step.qr),
                  child: const Text('Collect cash'),
                ),
              ),
              SizedBox(width: context.w(10)),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _upiTimer?.cancel();
                    setState(() {
                      _upi = (_total - 50).clamp(0, _total).toDouble();
                      _remainingByCash = true;
                      _step = _Step.adjust;
                    });
                  },
                  child: const Text('Paid part by UPI'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----- 2. Cash collection -----
  Widget _cashPage(BuildContext context) {
    final received = _receivedAmount;
    final change = received > _due ? received - _due : 0.0;
    final short = received < _due ? _due - received : 0.0;
    final canConfirm =
        received > 0 &&
        (change == 0 || _settle != null) &&
        (short == 0 || _carryAgreed);
    return _scaffold(
      context,
      title: 'Payment Confirmation',
      bottom: UnifiedButton(
        label: 'Confirm Cash Collections',
        enabled: canConfirm,
        onPressed: _confirmCash,
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          SizedBox(height: context.h(8)),
          _amountHeader(
            context,
            'Total Amount Collected',
            _upi + (received > _due ? _due : received),
            sub: 'Rider ID:  ${widget.riderId}',
          ),
          _sectionTitle(context, 'Cash Collection'),
          _card(context, [
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(6)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cash Received',
                      style: AppTypography.regular.copyWith(
                        fontSize: 14,
                        color: context.torkk.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: context.w(110),
                    child: TextField(
                      controller: _received,
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        prefixText: '₹',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _row(context, 'Change Returned', _money(change)),
            _row(context, 'Cash outstanding', _money(short)),
          ]),
          SizedBox(height: context.h(10)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(4)),
            child: _row(
              context,
              'Net collection',
              _money(_upi + (received > _due ? _due : received)),
              bold: true,
            ),
          ),
          if (change > 0) ...[
            _sectionTitle(context, 'Change Settlement'),
            _choice(
              context,
              label: 'Credit ${_money(change)} to rider wallet. (Rider Agrees)',
              selected: _settle == _Settle.wallet,
              onTap: () => setState(() => _settle = _Settle.wallet),
            ),
            _choice(
              context,
              label: 'Cash returned, immediately.',
              selected: _settle == _Settle.cashReturned,
              onTap: () => setState(() => _settle = _Settle.cashReturned),
            ),
            _choice(
              context,
              label: 'Made UPI payment, immediately.',
              selected: _settle == _Settle.upi,
              onTap: () => setState(() => _settle = _Settle.upi),
            ),
            Padding(
              padding: EdgeInsets.only(top: context.h(8)),
              child: Text(
                'Rider must agree to receive change in their wallet',
                style: AppTypography.regular.copyWith(
                  fontSize: 12,
                  color: context.brandColor,
                ),
              ),
            ),
          ],
          if (short > 0) ...[
            _sectionTitle(context, 'Remaining Amount'),
            Text(
              _money(short),
              style: AppTypography.bold.copyWith(
                fontSize: 16,
                color: const Color(0xFFDC2626),
              ),
            ),
            SizedBox(height: context.h(10)),
            Text(
              'Carry remaining amount to customer wallet',
              style: AppTypography.bold.copyWith(fontSize: 13),
            ),
            Text(
              'Rider must explicitly approve this outstanding balance.',
              style: AppTypography.regular.copyWith(
                fontSize: 12,
                color: context.torkk.textSecondary,
              ),
            ),
            SizedBox(height: context.h(8)),
            InkWell(
              onTap: () => setState(() => _carryAgreed = !_carryAgreed),
              child: Row(
                children: [
                  Icon(
                    _carryAgreed
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: _carryAgreed
                        ? context.brandColor
                        : context.torkk.textDisabled,
                  ),
                  SizedBox(width: context.w(8)),
                  Expanded(
                    child: Text(
                      'Rider agrees to ${_money(short)} wallet outstanding balance',
                      style: AppTypography.regular.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ----- 3. Partial UPI: how the remaining amount was handled -----
  Widget _adjustPage(BuildContext context) {
    final remaining = _due;
    return _scaffold(
      context,
      bottom: UnifiedButton(
        label: 'Continue',
        onPressed: () {
          if (_remainingByCash) {
            _openCash(back: _Step.adjust, upi: _upi);
          } else {
            setState(() {
              _cash = 0;
              _change = 0;
              _outstanding = remaining;
              _settle = null;
              _carryAgreed = false;
              _step = _Step.review;
            });
          }
        },
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          SizedBox(height: context.h(4)),
          _amountHeader(context, 'Total Amount Collected', _upi),
          SizedBox(height: context.h(14)),
          Center(child: _qrBlock(context, size: 170)),
          SizedBox(height: context.h(16)),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Remaining Amount',
                  style: AppTypography.regular.copyWith(fontSize: 14),
                ),
              ),
              Text(
                _money(remaining),
                style: AppTypography.bold.copyWith(
                  fontSize: 15,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(10)),
          _card(context, [
            Padding(
              padding: EdgeInsets.only(top: context.h(4)),
              child: Text(
                'Payment Adjustment',
                style: AppTypography.bold.copyWith(fontSize: 14),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose how the remaining amount was handled.',
                style: AppTypography.regular.copyWith(
                  fontSize: 12,
                  color: context.torkk.textSecondary,
                ),
              ),
            ),
            SizedBox(height: context.h(6)),
            _choice(
              context,
              label: 'Cash Collected',
              selected: _remainingByCash,
              onTap: () => setState(() => _remainingByCash = true),
            ),
            _choice(
              context,
              label: 'Outstanding',
              selected: !_remainingByCash,
              onTap: () => setState(() => _remainingByCash = false),
            ),
          ]),
        ],
      ),
    );
  }

  // ----- 4. Review -----
  Widget _reviewPage(BuildContext context) {
    final collected = _upi + _cash;
    final mixed = _upi > 0 && _cash > 0;
    return _scaffold(
      context,
      title: 'Payment Confirmation',
      bottom: UnifiedButton(
        label: 'Confirm Payment Details',
        onPressed: () => setState(() => _step = _Step.done),
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          SizedBox(height: context.h(8)),
          Center(
            child: Container(
              width: context.w(84),
              height: context.w(84),
              decoration: BoxDecoration(
                color: const Color(0x1A16A34A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.paid_rounded,
                size: 42,
                color: Color(0xFF16A34A),
              ),
            ),
          ),
          SizedBox(height: context.h(12)),
          _amountHeader(
            context,
            'Total Amount Collected',
            collected,
            sub: 'Rider ID:  ${widget.riderId}',
          ),
          SizedBox(height: context.h(8)),
          if (_outstanding == 0 && _upi >= _total)
            Center(
              child: Text(
                'Payment Successful',
                style: AppTypography.regular.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ),
          _sectionTitle(context, 'Payment Details'),
          _card(context, [
            if (_upi > 0) _row(context, 'UPI Payment', _money(_upi)),
            if (_cash > 0 || _upi == 0)
              _row(context, 'Cash Payment', _money(_cash)),
            if (_change > 0) _row(context, 'Change Returned', _money(_change)),
            if (_outstanding > 0)
              _row(
                context,
                'Payment outstanding',
                _money(_outstanding),
                valueColor: const Color(0xFFDC2626),
              ),
            if (mixed || _outstanding > 0 || _change > 0)
              _row(context, 'Net collection', _money(collected), bold: true),
          ]),
          if (_outstanding == 0 && _change == 0 && !mixed && _upi == 0)
            const SizedBox.shrink(),
          if (_outstanding > 0) ...[
            _sectionTitle(context, 'Remaining Amount'),
            Text(
              _money(_outstanding),
              style: AppTypography.bold.copyWith(
                fontSize: 16,
                color: const Color(0xFFDC2626),
              ),
            ),
            SizedBox(height: context.h(8)),
            Text(
              'Carried to customer wallet as outstanding balance.',
              style: AppTypography.regular.copyWith(
                fontSize: 12,
                color: context.torkk.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ----- 5. Ride payment confirmed -----
  Widget _donePage(BuildContext context) {
    final collected = _upi + _cash;
    final method = _upi > 0 && _cash > 0
        ? 'UPI + Cash'
        : (_upi > 0 ? 'UPI' : 'Cash');
    final status = _outstanding > 0
        ? 'Outstanding'
        : (_change > 0 ? 'Change settled' : 'Settled');
    return _scaffold(
      context,
      title: 'Ride Payment',
      bottom: UnifiedButton(
        label: 'Continue',
        onPressed: () => widget.onDone(
          RidePaymentResult(
            total: _total,
            upi: _upi,
            cash: _cash,
            change: _change,
            outstanding: _outstanding,
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          SizedBox(height: context.h(8)),
          Center(
            child: Container(
              width: context.w(84),
              height: context.w(84),
              decoration: const BoxDecoration(
                color: Color(0x1A16A34A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: context.w(60),
                  height: context.w(60),
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(12)),
          Text(
            'Payment Confirm !',
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(fontSize: 18),
          ),
          SizedBox(height: context.h(4)),
          Text(
            'You have successfully collected the payment.',
            textAlign: TextAlign.center,
            style: AppTypography.regular.copyWith(
              fontSize: 12,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(8)),
          Text(
            _money2(collected),
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(fontSize: 30),
          ),
          if (_outstanding == 0)
            Text(
              'Payment Successful',
              textAlign: TextAlign.center,
              style: AppTypography.regular.copyWith(
                fontSize: 13,
                color: const Color(0xFF16A34A),
              ),
            ),
          _sectionTitle(context, 'Payment Details'),
          _card(context, [
            _row(context, 'Rider ID', widget.riderId),
            _row(context, 'Payment Method', method),
            _row(context, 'Payment Status', status),
            _row(context, 'Ride Distance', widget.distanceLabel),
          ]),
          SizedBox(height: context.h(10)),
          _card(context, [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: context.h(4)),
                child: Text(
                  'Payment Breakdown',
                  style: AppTypography.bold.copyWith(fontSize: 14),
                ),
              ),
            ),
            _row(context, 'Amount Paid', _money(collected + _change)),
            if (_change > 0)
              _row(context, 'Change Return to Rider', _money(_change)),
            if (_outstanding > 0)
              _row(
                context,
                'Outstanding',
                _money(_outstanding),
                valueColor: const Color(0xFFDC2626),
              ),
          ]),
          SizedBox(height: context.h(12)),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your Earning',
                  style: AppTypography.bold.copyWith(
                    fontSize: 15,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ),
              Text(
                _money(widget.earning),
                style: AppTypography.bold.copyWith(
                  fontSize: 15,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A static, QR-looking code (finder squares + seeded modules). Placeholder
/// until the real payment QR comes from the backend.
class _StaticQrPainter extends CustomPainter {
  _StaticQrPainter(this.seed);

  final String seed;
  static const _n = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _n;
    final paint = Paint()..color = Colors.black;
    var state = seed.codeUnits.fold<int>(
      7,
      (a, b) => (a * 31 + b) & 0x7fffffff,
    );
    bool finder(int x, int y) =>
        (x < 8 && y < 8) || (x >= _n - 8 && y < 8) || (x < 8 && y >= _n - 8);

    for (var y = 0; y < _n; y++) {
      for (var x = 0; x < _n; x++) {
        if (finder(x, y)) continue;
        state = (state * 1103515245 + 12345) & 0x7fffffff;
        if ((state >> 16) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell + 0.4, cell + 0.4),
            paint,
          );
        }
      }
    }
    void eye(int ox, int oy) {
      final o = Offset(ox * cell, oy * cell);
      canvas.drawRect(Rect.fromLTWH(o.dx, o.dy, cell * 7, cell * 7), paint);
      canvas.drawRect(
        Rect.fromLTWH(o.dx + cell, o.dy + cell, cell * 5, cell * 5),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(o.dx + cell * 2, o.dy + cell * 2, cell * 3, cell * 3),
        paint,
      );
    }

    eye(0, 0);
    eye(_n - 7, 0);
    eye(0, _n - 7);
  }

  @override
  bool shouldRepaint(covariant _StaticQrPainter old) => old.seed != seed;
}
