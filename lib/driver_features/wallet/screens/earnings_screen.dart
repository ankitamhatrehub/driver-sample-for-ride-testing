import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/wallet/earnings_statement_pdf.dart';
import 'package:rider_app/driver_features/wallet/wallet_format.dart';
import 'package:rider_app/service/driver_api_service.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  int _range = 0;
  bool _loading = true;
  String _phone = '';
  String _driverName = '';
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _phone = prefs.getString('phone') ?? prefs.getString('user_phone') ?? '';
    _driverName = prefs.getString('user_name') ?? '';
    if (_phone.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final data = await DriverApiService.fetchEarnings(_phone);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading earnings: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---- derived data -------------------------------------------------------

  double get _headline =>
      pickAmount(_data, [
        const ['today_earnings', 'week_earnings', 'month_earnings'][_range],
      ]) ??
      0;

  String get _headlineLabel => const [
    "Today's Earnings",
    "This Week's Earnings",
    "This Month's Earnings",
  ][_range];

  String get _periodLabel {
    final now = DateTime.now();
    switch (_range) {
      case 0:
        return 'Today, ${now.day} ${_monthNames[now.month - 1].substring(0, 3)} ${now.year}';
      case 1:
        return 'This Week';
      default:
        return '${_monthNames[now.month - 1]} ${now.year}';
    }
  }

  double _field(List<String> keys) => pickAmount(_data, keys) ?? 0;

  List<_EarnRow> get _topRows => [
    _EarnRow(
      Icons.star_rounded,
      const Color(0xFFDB2777),
      const Color(0xFFFCE7F3),
      'Bonus/Incentives',
      '',
      rupees(_field(['incentives', 'bonus'])),
    ),
  ];

  List<_EarnRow> get _chargeRows => [
    _EarnRow(
      Icons.nightlight_round,
      const Color(0xFF7C3AED),
      const Color(0xFFF3E8FF),
      'Night Charges',
      '10:00 am - 5:00 am',
      rupees(_field(['night_charges', 'night_charge'])),
    ),
    _EarnRow(
      Icons.access_time_filled_rounded,
      const Color(0xFFF59E0B),
      const Color(0xFFFEF3C7),
      'Waiting Charges',
      'after 5 mins of waiting',
      rupees(_field(['waiting_charges', 'waiting_charge'])),
    ),
    _EarnRow(
      Icons.two_wheeler_rounded,
      const Color(0xFFF59E0B),
      const Color(0xFFFEF3C7),
      'Fair / km Plan(Bike)',
      'Standard Plan',
      rupees(_field(['plan_charges', 'per_km_charges'])),
    ),
  ];

  Future<void> _download() async {
    await downloadEarningsStatementPdf(
      context,
      driverName: _driverName,
      phone: _phone,
      periodLabel: _periodLabel,
      summary: [
        MapEntry(_headlineLabel, _headline),
        for (final r in [..._topRows, ..._chargeRows])
          MapEntry(r.title, toAmount(r.amount.replaceAll(RegExp('[₹,]'), ''))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    const ranges = ['Day', 'Week', 'Month'];
    return ProfilePage(
      title: 'Earnings',
      trailing: IconButton(
        onPressed: _loading ? null : _download,
        icon: Icon(
          Icons.file_download_outlined,
          color: context.torkk.textPrimary,
          size: context.w(24),
        ),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
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
                        for (var i = 0; i < ranges.length; i++)
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _range = i),
                              child: Container(
                                height: context.h(36),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _range == i
                                      ? accent
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    context.r(10),
                                  ),
                                ),
                                child: Text(
                                  ranges[i],
                                  style: AppTypography.regular.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _range == i
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
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
                  Row(
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.slate400,
                        size: context.w(22),
                      ),
                      Expanded(
                        child: Text(
                          _periodLabel,
                          textAlign: TextAlign.center,
                          style: AppTypography.regular.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.slate400,
                        size: context.w(22),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(14)),
                  Container(
                    padding: EdgeInsets.all(context.w(14)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.r(16)),
                      border: Border.all(color: context.torkk.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _headlineLabel,
                                style: AppTypography.regular.copyWith(
                                  fontSize: 12,
                                  color: context.torkk.textSecondary,
                                ),
                              ),
                              Text(
                                rupees(_headline),
                                style: AppTypography.bold.copyWith(
                                  fontSize: 22,
                                  height: 1.2,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFF472B6),
                          size: context.w(22),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.h(12)),
                  _group(context, _topRows),
                  SizedBox(height: context.h(12)),
                  _group(context, _chargeRows),
                ],
              ),
            ),
    );
  }

  Widget _group(BuildContext context, List<_EarnRow> rows) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: context.torkk.border),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(12),
                vertical: context.h(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: context.w(36),
                    height: context.w(36),
                    decoration: BoxDecoration(
                      color: rows[i].background,
                      borderRadius: BorderRadius.circular(context.r(10)),
                    ),
                    child: Icon(
                      rows[i].icon,
                      color: rows[i].color,
                      size: context.w(18),
                    ),
                  ),
                  SizedBox(width: context.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rows[i].title,
                          style: AppTypography.regular.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (rows[i].subtitle.isNotEmpty)
                          Text(
                            rows[i].subtitle,
                            style: AppTypography.regular.copyWith(
                              fontSize: 12,
                              color: context.torkk.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    rows[i].amount,
                    style: AppTypography.regular.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
}

class _EarnRow {
  const _EarnRow(
    this.icon,
    this.color,
    this.background,
    this.title,
    this.subtitle,
    this.amount,
  );
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String subtitle;
  final String amount;
}
