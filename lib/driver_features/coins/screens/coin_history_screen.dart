import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/coins/models/coin_models.dart';
import 'package:rider_app/driver_features/coins/widgets/coin_async.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/service/coins_api_service.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  static const _tabs = ['All', 'Earned', 'Redeemed'];
  static const _types = ['all', 'earned', 'redeemed'];
  int _tab = 0;
  List<CoinTransaction> _rows = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tab = _tab;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await CoinsApiService.fetchLedger(_types[tab]);
      if (!mounted || tab != _tab) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || tab != _tab) return;
      setState(() {
        _error = '$e'.replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  /// Icon and tint for a ledger row, picked from its reason text.
  (IconData, Color, Color) _look(CoinTransaction t) {
    final reason = t.reason.toLowerCase();
    if (!t.isCredit) {
      return (
        Icons.redeem_rounded,
        const Color(0xFFEF4444),
        const Color(0xFFFEE2E2),
      );
    }
    if (reason.contains('parcel')) {
      return (
        Icons.inventory_2_rounded,
        const Color(0xFFF59E0B),
        const Color(0xFFFEF3C7),
      );
    }
    if (reason.contains('scratch')) {
      return (
        Icons.confirmation_number_outlined,
        const Color(0xFFF59E0B),
        const Color(0xFFFEF3C7),
      );
    }
    return (
      Icons.directions_car_filled_rounded,
      const Color(0xFF7C3AED),
      const Color(0xFFF3E8FF),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return ProfilePage(
      title: 'Coin History',
      onBack: widget.onBack,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(20),
        ),
        children: [
          Container(
            padding: EdgeInsets.all(context.w(4)),
            decoration: BoxDecoration(
              color: context.torkk.surfaceMuted,
              borderRadius: BorderRadius.circular(context.r(14)),
            ),
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_tab == i) return;
                        setState(() => _tab = i);
                        _load();
                      },
                      child: Container(
                        height: context.h(36),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _tab == i ? accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(context.r(10)),
                        ),
                        child: Text(
                          _tabs[i],
                          style: AppTypography.regular.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _tab == i
                                ? Theme.of(context).colorScheme.onPrimary
                                : AppColors.slate500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: context.h(14)),
          if (_loading)
            const CoinLoading()
          else if (_error != null)
            CoinError(message: _error!, onRetry: _load)
          else if (_rows.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(40)),
              child: Center(
                child: Text(
                  'No coin transactions yet',
                  style: AppTypography.regular.copyWith(
                    fontSize: 13,
                    color: context.torkk.textSecondary,
                  ),
                ),
              ),
            )
          else
            for (final t in _rows)
              Container(
                margin: EdgeInsets.only(bottom: context.h(10)),
                padding: EdgeInsets.all(context.w(12)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.r(14)),
                  border: Border.all(color: context.torkk.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: context.w(36),
                      height: context.w(36),
                      decoration: BoxDecoration(
                        color: _look(t).$3,
                        borderRadius: BorderRadius.circular(context.r(10)),
                      ),
                      child: Icon(
                        _look(t).$1,
                        color: _look(t).$2,
                        size: context.w(18),
                      ),
                    ),
                    SizedBox(width: context.w(10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.reason.isEmpty
                                ? (t.isCredit
                                      ? 'Coins earned'
                                      : 'Coins redeemed')
                                : t.reason,
                            style: AppTypography.regular.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            coinDate(t.createdAt),
                            style: AppTypography.regular.copyWith(
                              fontSize: 12,
                              color: context.torkk.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${t.isCredit ? '+' : '-'} ${coinNumber(t.amount)}',
                      style: AppTypography.regular.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: t.isCredit
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    SizedBox(width: context.w(4)),
                    Image.asset(
                      AppAssets.rewardCoins,
                      width: context.w(16),
                      height: context.w(16),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
