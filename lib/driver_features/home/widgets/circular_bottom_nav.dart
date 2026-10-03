import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';

/// Floating dashboard bar: Home, Orders, Parcel, Wallet, Profile.
class CircularBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const CircularBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  static const List<_NavItem> _items = [
    _NavItem(AppStrings.navHome, Icons.home_rounded, Icons.home_outlined),
    _NavItem(AppStrings.navOrders, Icons.article_rounded, Icons.article_outlined),
    _NavItem(AppStrings.navParcel, Icons.view_in_ar, Icons.view_in_ar_outlined),
    _NavItem(AppStrings.navWallet, Icons.account_balance_wallet, Icons.account_balance_wallet_outlined),
    _NavItem(AppStrings.profile, Icons.person, Icons.person_outline),
  ];

  static LinearGradient _gradient(BuildContext context, double opacity) {
    const degrees = 286.17;
    final radians = degrees * math.pi / 180;
    final dx = math.sin(radians);
    final dy = -math.cos(radians);
    final female = Theme.of(context).colorScheme.primary == AppColors.femalePink;
    final colors = female
        ? const [Color(0xFFE85AAD), Color(0xFFBA2879), Color(0xFF6B1848)]
        : const [Color(0xFF0F3FBF), Color(0xFF61217E), Color(0xFF40105F)];
    return LinearGradient(
      begin: Alignment(-dx, -dy),
      end: Alignment(dx, dy),
      colors: [for (final color in colors) color.withValues(alpha: opacity)],
      stops: const [0, 0.5, 1],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.w(18), 0, context.w(18), context.h(28)),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.r(47)),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), offset: Offset(0, 8), blurRadius: 24),
            ],
          ),
          child: Container(
            height: context.h(68),
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(47)),
              gradient: _gradient(context, 0.35),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.r(46)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(context.w(8), context.h(6), context.w(8), context.h(6)),
                  child: Row(
                    children: [
                      for (var i = 0; i < _items.length; i++)
                        i == currentIndex
                            ? _selected(context, _items[i], () => onItemSelected(i))
                            : Expanded(child: _plain(context, _items[i], () => onItemSelected(i))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selected(BuildContext context, _NavItem item, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.w(76),
        height: context.h(54),
        padding: EdgeInsets.fromLTRB(context.w(9), context.h(10), context.w(9), context.h(10)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(34)),
          gradient: _gradient(context, 0.93),
          boxShadow: const [
            BoxShadow(color: Color(0x1C000000), offset: Offset(0, 1), blurRadius: 4),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.selectedIcon, color: Colors.white, size: context.w(16)),
            Text(
              item.label,
              style: AppTypography.regular.copyWith(
                color: Colors.white,
                fontSize: 10,
                height: 15 / 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _plain(BuildContext context, _NavItem item, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: AppColors.gray500, size: context.w(20)),
          Text(
            item.label,
            style: AppTypography.regular.copyWith(
              color: AppColors.gray500,
              fontSize: 10,
              height: 15 / 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.selectedIcon, this.icon);

  final String label;
  final IconData selectedIcon;
  final IconData icon;
}
