import 'package:flutter/material.dart';

import 'package:rider_app/driver_features/coins/models/coin_models.dart';
import 'package:rider_app/service/coins_api_service.dart';

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

  CoinAccount? _account;
  ScratchCard? _card;
  ScratchClaim? _claim;
  bool _loading = true;
  bool _claiming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Account (balance) and the available scratch card. A scratch-card failure
  /// only hides the card; an account failure shows the retry state.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final results = await Future.wait<Object?>([
      CoinsApiService.fetchAccount()
          .then<Object?>((v) => v)
          .catchError((Object e) => e),
      CoinsApiService.fetchAvailableScratchCard()
          .then<Object?>((v) => v)
          .catchError((Object e) => e),
    ]);
    if (!mounted) return;
    setState(() {
      _loading = false;
      final account = results[0];
      if (account is CoinAccount) {
        _account = account;
      } else {
        _error = '$account'.replaceFirst('Exception: ', '');
      }
      final card = results[1];
      _card = card is ScratchCard ? card : null;
    });
  }

  Future<void> _claimCard() async {
    final card = _card;
    if (card == null || _claiming) return;
    setState(() => _claiming = true);
    try {
      final claim = await CoinsApiService.claimScratchCard(card.id);
      if (!mounted) return;
      setState(() {
        _claim = claim;
        _claiming = false;
        _card = null;
      });
      _open(_CoinsPage.credited);
      _load();
    } on CoinsApiException catch (e) {
      if (!mounted) return;
      setState(() => _claiming = false);
      _open(e.isAlreadyClaimed ? _CoinsPage.claimed : _CoinsPage.failed);
    } catch (_) {
      if (!mounted) return;
      setState(() => _claiming = false);
      _open(_CoinsPage.failed);
    }
  }

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
        onView: () => _open(_card == null ? _CoinsPage.none : _CoinsPage.offer),
        account: _account,
        card: _card,
        loading: _loading,
        error: _error,
        onRetry: _load,
      ),
      _CoinsPage.history => CoinHistoryScreen(onBack: _back),
      _CoinsPage.howTo => HowToEarnScreen(onBack: _back),
      _CoinsPage.offer => ScratchOfferScreen(
        card: _card,
        onBack: _back,
        onScratch: () => _open(_CoinsPage.scratch),
      ),
      _CoinsPage.scratch => ScratchCardScreen(
        onBack: _back,
        onReveal: () => _open(_CoinsPage.won),
      ),
      _CoinsPage.won => ScratchWonScreen(
        coins: _card?.coinAmount ?? 0,
        claiming: _claiming,
        onBack: _back,
        onClaim: _claimCard,
      ),
      _CoinsPage.credited => RewardCreditedScreen(
        claim: _claim,
        onBack: _homeOnly,
        onContinue: _homeOnly,
      ),
      _CoinsPage.claimed => AlreadyClaimedScreen(
        onBack: _homeOnly,
        onTryAgain: () {
          _homeOnly();
          _load();
        },
      ),
      // Back to the reveal page, where Claim tries the call again.
      _CoinsPage.failed => ScratchFailedScreen(
        onBack: _back,
        onTryAgain: _back,
      ),
      _CoinsPage.pending => RewardPendingScreen(onBack: _homeOnly),
      _CoinsPage.none => NoScratchCardScreen(onBack: _back),
    };
  }
}
