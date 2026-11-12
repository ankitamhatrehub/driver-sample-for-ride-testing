import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rider_app/driver_features/rides/payment/payment_adjust_page.dart';
import 'package:rider_app/driver_features/rides/payment/payment_cash_page.dart';
import 'package:rider_app/driver_features/rides/payment/payment_done_page.dart';
import 'package:rider_app/driver_features/rides/payment/payment_qr_page.dart';
import 'package:rider_app/driver_features/rides/payment/payment_result.dart';
import 'package:rider_app/driver_features/rides/payment/payment_review_page.dart';

export 'package:rider_app/driver_features/rides/payment/payment_result.dart';

enum _Step { qr, cash, adjust, review, done }

/// Payment steps after the driver taps End Ride: collect by QR (UPI), collect
/// cash (with change / outstanding handling), review, then confirm.
///
/// This widget only holds the state and the step logic; every screen lives in
/// `payment/`, and all fixed text is in `AppStrings`.
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

  /// Partial UPI: was the remaining amount taken in cash (true) or left
  /// outstanding (false)?
  bool _remainingByCash = true;

  final _received = TextEditingController();
  PaymentSettle? _settle;
  bool _carryAgreed = false;

  double get _total => widget.total;
  double get _due => (_total - _upi).clamp(0, double.infinity).toDouble();

  RidePaymentResult get _result => RidePaymentResult(
    total: _total,
    upi: _upi,
    cash: _cash,
    change: _change,
    outstanding: _outstanding,
  );

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

  void _show(_Step step) => setState(() => _step = step);

  /// Placeholder for the payment webhook: the QR "gets paid" after a few
  /// seconds. Replace with the real payment status once the API exists.
  void _startWaiting() {
    _upiTimer?.cancel();
    _upiTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted || _step != _Step.qr) return;
      _setAmounts(upi: _total);
      _show(_Step.review);
    });
  }

  void _setAmounts({
    double upi = 0,
    double cash = 0,
    double change = 0,
    double outstanding = 0,
  }) {
    _upi = upi;
    _cash = cash;
    _change = change;
    _outstanding = outstanding;
  }

  void _backToQr() {
    _show(_Step.qr);
    _startWaiting();
  }

  void _openCash({required _Step back, double upi = 0}) {
    _upiTimer?.cancel();
    _upi = upi;
    _cashBack = back;
    _settle = null;
    _carryAgreed = false;
    _received.text = _due.toStringAsFixed(0);
    _show(_Step.cash);
  }

  void _partUpi() {
    _upiTimer?.cancel();
    _upi = (_total - 50).clamp(0, _total).toDouble();
    _remainingByCash = true;
    _show(_Step.adjust);
  }

  void _confirmCash() {
    final received = double.tryParse(_received.text.trim()) ?? 0;
    if (received >= _due) {
      _setAmounts(upi: _upi, cash: _due, change: received - _due);
    } else {
      _setAmounts(upi: _upi, cash: received, outstanding: _due - received);
    }
    _show(_Step.review);
  }

  void _continueAdjust() {
    if (_remainingByCash) {
      _openCash(back: _Step.adjust, upi: _upi);
      return;
    }
    _setAmounts(upi: _upi, outstanding: _due);
    _show(_Step.review);
  }

  void _back() {
    switch (_step) {
      case _Step.qr:
        _upiTimer?.cancel();
        widget.onBack();
      case _Step.cash:
        _cashBack == _Step.qr ? _backToQr() : _show(_cashBack);
      case _Step.adjust || _Step.review:
        _backToQr();
      case _Step.done:
        _show(_Step.review);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _Step.qr => PaymentQrPage(
        total: _total,
        paymentId: widget.riderId,
        onBack: _back,
        onCollectCash: () => _openCash(back: _Step.qr),
        onPartUpi: _partUpi,
      ),
      _Step.cash => PaymentCashPage(
        upiPaid: _upi,
        due: _due,
        riderId: widget.riderId,
        received: _received,
        settle: _settle,
        carryAgreed: _carryAgreed,
        onChanged: () => setState(() {}),
        onSettle: (s) => setState(() => _settle = s),
        onCarry: () => setState(() => _carryAgreed = !_carryAgreed),
        onConfirm: _confirmCash,
        onBack: _back,
      ),
      _Step.adjust => PaymentAdjustPage(
        upiPaid: _upi,
        remaining: _due,
        paymentId: widget.riderId,
        byCash: _remainingByCash,
        onChoose: (cash) => setState(() => _remainingByCash = cash),
        onContinue: _continueAdjust,
        onBack: _back,
      ),
      _Step.review => PaymentReviewPage(
        result: _result,
        riderId: widget.riderId,
        onConfirm: () => _show(_Step.done),
        onBack: _back,
      ),
      _Step.done => PaymentDonePage(
        result: _result,
        riderId: widget.riderId,
        distanceLabel: widget.distanceLabel,
        earning: widget.earning,
        onContinue: () => widget.onDone(_result),
        onBack: _back,
      ),
    };
  }
}
