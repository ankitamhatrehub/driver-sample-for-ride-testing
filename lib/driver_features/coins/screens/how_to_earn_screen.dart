import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/coins/models/coin_models.dart';
import 'package:rider_app/driver_features/coins/widgets/coin_async.dart';
import 'package:rider_app/service/coins_api_service.dart';
import 'package:rider_app/driver_features/coins/widgets/coins_text.dart';
import 'package:rider_app/driver_features/coins/widgets/how_it_works_card.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

import '../../../common/constants/string_constants.dart';

class HowToEarnScreen extends StatefulWidget {
  const HowToEarnScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<HowToEarnScreen> createState() => _HowToEarnScreenState();
}

class _HowToEarnScreenState extends State<HowToEarnScreen> {
  List<CoinEarningRule> _rules = const [];
  List<CoinMission> _missions = const [];
  List<CoinMilestone> _milestones = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// The three lists load together. A list that fails is just left empty; the
  /// retry state only shows when all three fail.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    Object? firstError;
    Future<T> safe<T>(Future<T> call, T fallback) async {
      try {
        return await call;
      } catch (e) {
        firstError ??= e;
        return fallback;
      }
    }

    final rules = await safe(
      CoinsApiService.fetchEarningRules(),
      <CoinEarningRule>[],
    );
    final missions = await safe(
      CoinsApiService.fetchDailyMissions(),
      <CoinMission>[],
    );
    final milestones = await safe(
      CoinsApiService.fetchMilestones(),
      <CoinMilestone>[],
    );
    if (!mounted) return;
    setState(() {
      _rules = rules;
      _missions = missions;
      _milestones = milestones;
      _loading = false;
      if (rules.isEmpty &&
          missions.isEmpty &&
          milestones.isEmpty &&
          firstError != null) {
        _error = '$firstError'.replaceFirst('Exception: ', '');
      }
    });
  }

  Widget _heading(BuildContext context, String text) => Padding(
    padding: EdgeInsets.only(top: context.h(18), bottom: context.h(8)),
    child: Text(
      text,
      style: AppTypography.regular.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _card(BuildContext context, List<Widget> rows) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(context.r(16)),
      border: Border.all(color: context.torkk.border),
    ),
    child: Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) Divider(height: 1, color: context.torkk.border),
          Padding(padding: EdgeInsets.all(context.w(14)), child: rows[i]),
        ],
      ],
    ),
  );

  Widget _reward(BuildContext context, int coins) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '+$coins',
        style: AppTypography.regular.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF16A34A),
        ),
      ),
      SizedBox(width: context.w(4)),
      Image.asset(
        AppAssets.rewardCoins,
        width: context.w(16),
        height: context.w(16),
      ),
    ],
  );

  Widget _progressRow(
    BuildContext context, {
    required String title,
    required int done,
    required int target,
    required int reward,
    required bool completed,
  }) {
    final fraction = target <= 0 ? 0.0 : (done / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.regular.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (completed)
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: Color(0xFF16A34A),
              )
            else
              _reward(context, reward),
          ],
        ),
        SizedBox(height: context.h(8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(context.r(6)),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: context.h(6),
            backgroundColor: context.torkk.surfaceMuted,
            color: completed
                ? const Color(0xFF16A34A)
                : const Color(0xFF7C3AED),
          ),
        ),
        SizedBox(height: context.h(4)),
        Text(
          '$done / $target',
          style: AppTypography.regular.copyWith(
            fontSize: 11,
            color: context.torkk.textSecondary,
          ),
        ),
      ],
    );
  }

  List<Widget> _sections(BuildContext context) {
    if (_loading) return const [CoinLoading()];
    if (_error != null) return [CoinError(message: _error!, onRetry: _load)];
    return [
      if (_rules.isNotEmpty) ...[
        _heading(context, 'Ways to earn'),
        _card(context, [
          for (final r in _rules)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.name,
                        style: AppTypography.regular.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (r.description.isNotEmpty) ...[
                        SizedBox(height: context.h(2)),
                        Text(
                          r.description,
                          style: AppTypography.regular.copyWith(
                            fontSize: 11,
                            color: context.torkk.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _reward(context, r.coinAmount),
              ],
            ),
        ]),
      ],
      if (_missions.isNotEmpty) ...[
        _heading(context, 'Daily missions'),
        _card(context, [
          for (final m in _missions)
            _progressRow(
              context,
              title: m.title,
              done: m.done,
              target: m.target,
              reward: m.reward,
              completed: m.isCompleted,
            ),
        ]),
      ],
      if (_milestones.isNotEmpty) ...[
        _heading(context, 'Milestones'),
        _card(context, [
          for (final m in _milestones)
            _progressRow(
              context,
              title: m.name,
              done: m.current,
              target: m.target,
              reward: m.reward,
              completed: m.isCompleted,
            ),
        ]),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.howToEarnCoins,
      onBack: widget.onBack,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(12),
          context.w(20),
          context.h(20),
        ),
        children: [
          SizedBox(
            height: context.h(160),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    1,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                    0,
                    1,
                    1,
                    1,
                    0,
                    0,
                  ]),
                  child: Image.asset(
                    AppAssets.celebration,
                    width: context.w(220),
                    fit: BoxFit.contain,
                  ),
                ),
                Image.asset(
                  AppAssets.giftCard,
                  width: context.w(110),
                  height: context.w(110),
                ),
              ],
            ),
          ),
          Text(
            AppStrings.earnTorkkCoins,
            textAlign: TextAlign.center,
            style: coinsTitle(),
          ),
          SizedBox(height: context.h(6)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(48)),
            child: Text(
              AppStrings.completeRidesDeliveriesToEarnCoins,
              textAlign: TextAlign.center,
              style: coinsMuted(context),
            ),
          ),
          SizedBox(height: context.h(22)),
          ..._sections(context),
          _heading(context, AppStrings.howItWorks),
          const HowItWorksCard(showTitle: false),
        ],
      ),
    );
  }
}
