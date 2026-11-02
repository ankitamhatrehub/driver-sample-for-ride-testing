import 'package:flutter/material.dart';

import 'package:rider_app/driver_features/subscription/models/subscription_plan.dart';
import 'package:rider_app/driver_features/subscription/screens/available_plans_screen.dart';
import 'package:rider_app/driver_features/subscription/screens/current_plan_screen.dart';
import 'package:rider_app/driver_features/subscription/screens/expired_gate_screen.dart';
import 'package:rider_app/driver_features/subscription/screens/payment_failed_screen.dart';
import 'package:rider_app/driver_features/subscription/screens/payment_processing_screen.dart';
import 'package:rider_app/driver_features/subscription/screens/payment_success_screen.dart';
import 'package:rider_app/driver_features/subscription/screens/plan_activated_screen.dart';
import 'package:rider_app/driver_features/subscription/screens/subscription_payment_screen.dart';

enum _Page {
  expiredGate,
  expiredPlan,
  plans,
  payment,
  processing,
  success,
  failed,
  activated,
  activePlan,
}

/// Dummy subscription flow opened from Profile.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _stack = <_Page>[_Page.expiredGate];
  int _selected = 1;
  PayMethod _method = PayMethod.upi;
  SubscriptionPlan? _purchased;

  SubscriptionPlan get _plan => _purchased ?? subscriptionPlans[_selected];

  void _push(_Page page) => setState(() => _stack.add(page));

  void _back() {
    if (_stack.length > 1) {
      setState(() => _stack.removeLast());
      return;
    }
    if (_stack.last == _Page.activated) {
      setState(() {
        _stack
          ..clear()
          ..add(_Page.activePlan);
      });
      return;
    }
    Navigator.of(context).pop();
  }

  void _recharge() {
    setState(() {
      _stack.remove(_Page.expiredGate);
      _stack.add(_Page.plans);
    });
  }

  void _pay() => _push(_Page.processing);

  void _paymentFinished() {
    if (!mounted) return;
    setState(() {
      _stack.remove(_Page.processing);
      _stack.add(_method == PayMethod.card ? _Page.failed : _Page.success);
    });
  }

  void _retry() {
    setState(() => _stack.remove(_Page.failed));
    _pay();
  }

  void _finish() {
    setState(() {
      _purchased = subscriptionPlans[_selected];
      _stack
        ..clear()
        ..add(_Page.activated);
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_stack.last) {
      _Page.expiredGate => ExpiredGateScreen(
        onBack: _back,
        onRecharge: _recharge,
      ),
      _Page.expiredPlan => CurrentPlanScreen(
        active: false,
        onBack: _back,
        onRenew: () => _push(_Page.plans),
      ),
      _Page.activePlan => CurrentPlanScreen(
        active: true,
        onBack: _back,
        onRenew: () => _push(_Page.plans),
      ),
      _Page.plans => AvailablePlansScreen(
        selected: _selected,
        onSelect: (index) => setState(() => _selected = index),
        onContinue: () => _push(_Page.payment),
        onBack: _back,
      ),
      _Page.payment => SubscriptionPaymentScreen(
        plan: subscriptionPlans[_selected],
        method: _method,
        onMethod: (method) => setState(() => _method = method),
        onPay: _pay,
        onBack: _back,
      ),
      _Page.processing => PaymentProcessingScreen(
        onCompleted: _paymentFinished,
      ),
      _Page.success => PaymentSuccessScreen(
        methodLabel: payMethodLabel(_method),
        onContinue: _finish,
        onBack: _back,
      ),
      _Page.failed => PaymentFailedScreen(
        onRetry: _retry,
        onChangeMethod: () => setState(() => _stack.remove(_Page.failed)),
        onBack: _back,
      ),
      _Page.activated => PlanActivatedScreen(plan: _plan, onBack: _back),
    };
  }
}
