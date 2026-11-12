import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';

import 'package:rider_app/driver_features/rides/payment/payment_adjust_page.dart';
import 'package:rider_app/driver_features/rides/payment/payment_cash_page.dart';
import 'package:rider_app/driver_features/rides/payment/payment_done_page.dart';
import 'package:rider_app/driver_features/rides/payment/payment_qr_page.dart';
import 'package:rider_app/driver_features/rides/payment/payment_result.dart';
import 'package:rider_app/driver_features/rides/payment/payment_review_page.dart';
import 'package:rider_app/service/razorpay_service.dart';

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
    required this.rideId,
    required this.distanceLabel,
    required this.onBack,
    required this.onDone,
  });

  final double total;
  final double earning;
  final String riderId;
  final String rideId;
  final String distanceLabel;
  final VoidCallback onBack;
  final ValueChanged<RidePaymentResult> onDone;

  @override
  State<RidePaymentFlow> createState() => _RidePaymentFlowState();
}

class _RidePaymentFlowState extends State<RidePaymentFlow> {
  _Step _step = _Step.qr;
  _Step _cashBack = _Step.qr;
  Timer? _pollTimer;
  bool _polling = false;

  /// The live Razorpay QR for this fare, and its loading / error state.
  RazorpayQr? _qr;
  bool _qrLoading = true;
  String? _qrError;
  bool _qrPaid = false;

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
    _createQr();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _closeQr();
    _received.dispose();
    super.dispose();
  }

  void _show(_Step step) => setState(() => _step = step);

  /// Creates a fresh QR for the fare and starts watching it for payment.
  Future<void> _createQr() async {
    _pollTimer?.cancel();
    setState(() {
      _qr = null;
      _qrError = null;
      _qrLoading = true;
      _qrPaid = false;
    });
    try {
      final qr = await RazorpayService.createUpiQr(
        amountRupees: _total,
        rideId: widget.rideId,
      );
      if (!mounted) {
        RazorpayService.closeQr(qr.id);
        return;
      }
      setState(() {
        _qr = qr;
        _qrLoading = false;
      });
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _qrLoading = false;
        _qrError = '$e';
      });
    }
  }

  /// Asks Razorpay how much has been paid on the QR. Full amount moves on to
  /// review; a smaller amount goes to the part-payment screen.
  Future<void> _poll() async {
    final qr = _qr;
    if (_polling || qr == null || _step != _Step.qr) return;
    _polling = true;
    try {
      final status = await RazorpayService.fetchQrStatus(qr.id);
      if (!mounted || _step != _Step.qr) return;
      if (status.receivedPaise >= qr.amountPaise) {
        _pollTimer?.cancel();
        _qrPaid = true;
        _setAmounts(upi: _total);
        _show(_Step.review);
      } else if (status.receivedPaise > 0) {
        _pollTimer?.cancel();
        _upi = status.receivedPaise / 100;
        _remainingByCash = true;
        _show(_Step.adjust);
      } else if (status.isClosed) {
        _pollTimer?.cancel();
        setState(() => _qrError = AppStrings.payQrFailed);
      }
    } catch (e) {
      debugPrint('[RAZORPAY] poll failed: $e');
    } finally {
      _polling = false;
    }
  }

  /// Closes the QR if nobody paid on it (cash chosen, or the driver left).
  void _closeQr() {
    final qr = _qr;
    if (qr != null && !_qrPaid) RazorpayService.closeQr(qr.id);
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
    _createQr();
  }

  void _openCash({required _Step back, double upi = 0}) {
    _pollTimer?.cancel();
    if (_step == _Step.qr) _closeQr();
    _upi = upi;
    _cashBack = back;
    _settle = null;
    _carryAgreed = false;
    _received.text = _due.toStringAsFixed(0);
    _show(_Step.cash);
  }

  /// Test-only: pretends the rider paid all but ₹50 by UPI.
  void _partUpi() {
    _pollTimer?.cancel();
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
        _pollTimer?.cancel();
        _closeQr();
        widget.onBack();
      case _Step.cash:
        _cashBack == _Step.qr ? _backToQr() : _show(_cashBack);
      case _Step.adjust:
        _backToQr();
      case _Step.review:
        // Paid in full by UPI: nothing to go back to.
        if (_upi > 0 && _cash == 0 && _outstanding == 0) return;
        _show(_remainingByCash || _upi == 0 ? _Step.cash : _Step.adjust);
      case _Step.done:
        _show(_Step.review);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _Step.qr => PaymentQrPage(
        total: _total,
        paymentId: _qr?.id ?? widget.riderId,
        onBack: _back,
        qrData: _qr?.imageContent,
        qrUrl: _qr?.imageUrl,
        loading: _qrLoading,
        error: _qrError,
        onRetry: _createQr,
        onCollectCash: () => _openCash(back: _Step.qr),
        onPartUpi: kDebugMode ? _partUpi : null,
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
        paymentId: _qr?.id ?? widget.riderId,
        qrData: _qr?.imageContent,
        qrUrl: _qr?.imageUrl,
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
