import 'package:flutter/material.dart';

import 'package:rider_app/driver_features/coins/screens/already_claimed_screen.dart';
import 'package:rider_app/driver_features/coins/screens/coin_history_screen.dart';
import 'package:rider_app/driver_features/coins/screens/coins_home_screen.dart';
import 'package:rider_app/driver_features/coins/screens/how_to_earn_screen.dart';
import 'package:rider_app/driver_features/coins/screens/no_scratch_card_screen.dart';
import 'package:rider_app/driver_features/coins/screens/reward_credited_screen.dart';
import 'package:rider_app/driver_features/coins/screens/reward_pending_screen.dart';
import 'package:rider_app/driver_features/coins/screens/scratch_card_screen.dart';
import 'package:rider_app/driver_features/coins/screens/scratch_failed_screen.dart';
import 'package:rider_app/driver_features/coins/screens/scratch_offer_screen.dart';
import 'package:rider_app/driver_features/coins/screens/scratch_won_screen.dart';

enum _CoinsPage {
  home,
  history,
  howTo,
  offer,
  scratch,
  won,
  credited,
  claimed,
  failed,
  pending,
  none,
}

class CoinsScreen extends StatefulWidget {
  const CoinsScreen({super.key});

  @override
  State<CoinsScreen> createState() => _CoinsScreenState();
}

class _CoinsScreenState extends State<CoinsScreen> {
  final _stack = <_CoinsPage>[_CoinsPage.home];

  void _open(_CoinsPage page) => setState(() => _stack.add(page));

  void _back() {
    if (_stack.length > 1) {
      setState(() => _stack.removeLast());
      return;
    }
    Navigator.of(context).pop();
  }

  void _homeOnly() {
    setState(() {
      _stack
        ..clear()
        ..add(_CoinsPage.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_stack.last) {
      _CoinsPage.home => CoinsHomeScreen(
        onBack: _back,
        onHistory: () => _open(_CoinsPage.history),
        onHowTo: () => _open(_CoinsPage.howTo),
        onView: () => _open(_CoinsPage.offer),
      ),
      _CoinsPage.history => CoinHistoryScreen(onBack: _back),
      _CoinsPage.howTo => HowToEarnScreen(onBack: _back),
      _CoinsPage.offer => ScratchOfferScreen(
        onBack: _back,
        onScratch: () => _open(_CoinsPage.scratch),
      ),
      _CoinsPage.scratch => ScratchCardScreen(
        onBack: _back,
        onReveal: () => _open(_CoinsPage.won),
      ),
      _CoinsPage.won => ScratchWonScreen(
        onBack: _back,
        onClaim: () => _open(_CoinsPage.credited),
      ),
      _CoinsPage.credited => RewardCreditedScreen(onBack: _back, onContinue: _homeOnly),
      _CoinsPage.claimed => AlreadyClaimedScreen(
        onBack: _back,
        onTryAgain: () {
          setState(() {
            _stack
              ..clear()
              ..add(_CoinsPage.home)
              ..add(_CoinsPage.failed);
          });
        },
      ),
      _CoinsPage.failed => ScratchFailedScreen(
        onBack: _back,
        onTryAgain: () {
          setState(() {
            _stack
              ..clear()
              ..add(_CoinsPage.home)
              ..add(_CoinsPage.pending);
          });
        },
      ),
      _CoinsPage.pending => RewardPendingScreen(onBack: _homeOnly),
      _CoinsPage.none => NoScratchCardScreen(onBack: _back),
    };
  }
}
