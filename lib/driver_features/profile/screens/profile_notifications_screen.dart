import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/screens/notification_preferences_screen.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/service/notifications_api_service.dart';

class ProfileNotificationsScreen extends StatefulWidget {
  const ProfileNotificationsScreen({super.key});

  @override
  State<ProfileNotificationsScreen> createState() =>
      _ProfileNotificationsScreenState();
}

class _ProfileNotificationsScreenState
    extends State<ProfileNotificationsScreen> {
  static const _limit = 20;

  final _scroll = ScrollController();
  final List<DriverNotification> _items = [];
  int _page = 0;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  bool get _hasMore => _items.length < _total;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 200) _loadMore();
    });
    _refresh();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final result = await NotificationsApiService.fetchNotifications(
        page: 1,
        limit: _limit,
      );
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(result.items);
        _page = 1;
        _total = result.total;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final result = await NotificationsApiService.fetchNotifications(
        page: _page + 1,
        limit: _limit,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(result.items);
        _page += 1;
        _total = result.total;
        _loadingMore = false;
        // An empty page means we are done, whatever `total` says.
        if (result.items.isEmpty) _total = _items.length;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  /// Shows the notification as read now and tells the server.
  Future<void> _markRead(int index) async {
    final item = _items[index];
    if (item.isRead) return;
    setState(() => _items[index] = item.asRead());
    try {
      await NotificationsApiService.markRead(item.id);
    } catch (_) {
      if (!mounted) return;
      final at = _items.indexWhere((n) => n.id == item.id);
      if (at != -1) setState(() => _items[at] = item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    if (_loading) {
      return ProfilePage(
        title: AppStrings.notification,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null && _items.isEmpty) {
      return ProfilePage(
        title: AppStrings.notification,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              TextButton(
                onPressed: () {
                  setState(() => _loading = true);
                  _refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return const ProfilePage(title: '', child: _EmptyNotifications());
    }

    return ProfilePage(
      title: AppStrings.notification,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            context.w(20),
            context.h(8),
            context.w(20),
            context.h(20),
          ),
          children: [
            Material(
              color: context.adaptiveTint(const Color(0xFFF5F3FF)),
              borderRadius: BorderRadius.circular(context.r(16)),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationPreferencesScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(context.r(16)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(14),
                    vertical: context.h(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        color: accent,
                        size: context.w(22),
                      ),
                      SizedBox(width: context.w(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notification Preferences',
                              style: AppTypography.bold.copyWith(
                                color: context.torkk.textPrimary,
                                fontSize: 14,
                                height: 1.2,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              'Choose what you want to be notified about',
                              style: AppTypography.regular.copyWith(
                                fontSize: 12,
                                color: context.torkk.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.slate400,
                        size: context.w(22),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: context.h(18)),
            Text(
              'Recent Notifications',
              style: AppTypography.regular.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.torkk.textSecondary,
              ),
            ),
            SizedBox(height: context.h(10)),
            for (var i = 0; i < _items.length; i++) ...[
              if (i > 0) SizedBox(height: context.h(10)),
              _NoticeCard(
                item: _Notice.from(_items[i], accent),
                onTap: () => _markRead(i),
              ),
            ],
            if (_loadingMore)
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.h(16)),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: context.w(140),
            height: context.w(140),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: context.w(120),
                  height: context.w(120),
                  decoration: BoxDecoration(
                    color: context.adaptiveTint(Color(0xFFFFF7ED)),
                    shape: BoxShape.circle,
                  ),
                ),
                Image.asset(
                  AppAssets.notification,
                  width: context.w(88),
                  height: context.w(88),
                ),
                Positioned(
                  right: context.w(22),
                  bottom: context.w(28),
                  child: Container(
                    width: context.w(22),
                    height: context.w(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: context.w(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(16)),
          Text(
            'You have no new notifications.',
            style: AppTypography.regular.copyWith(
              fontSize: 14,
              color: AppColors.slate400,
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice {
  const _Notice(
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.iconBg,
    this.unread,
    this.time,
  );

  /// Icon and colours follow the server's notification `type`.
  factory _Notice.from(DriverNotification n, Color accent) {
    const amber = Color(0xFFF59E0B);
    const amberBg = Color(0xFFFFF7ED);
    final type = n.type;
    IconData icon;
    Color color;
    Color bg;
    if (type.contains('payment') ||
        type.contains('wallet') ||
        type.contains('payout')) {
      icon = Icons.account_balance_wallet_outlined;
      color = const Color(0xFF16A34A);
      bg = const Color(0xFFDCFCE7);
    } else if (type.contains('parcel')) {
      icon = Icons.inventory_2_outlined;
      color = amber;
      bg = amberBg;
    } else if (type.contains('schedule')) {
      icon = Icons.schedule_rounded;
      color = amber;
      bg = amberBg;
    } else if (type.contains('offer') ||
        type.contains('reward') ||
        type.contains('coin')) {
      icon = Icons.toll_rounded;
      color = amber;
      bg = amberBg;
    } else {
      icon = Icons.directions_car_filled_rounded;
      color = accent;
      bg = accent.withValues(alpha: 0.12);
    }
    return _Notice(
      n.title,
      n.message,
      icon,
      color,
      bg,
      !n.isRead,
      _timeAgo(n.createdAt),
    );
  }

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool unread;
  final String time;
}

String _timeAgo(DateTime? at) {
  if (at == null) return '';
  final diff = DateTime.now().difference(at);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';
  final l = at.toLocal();
  return '${l.day.toString().padLeft(2, '0')}/${l.month.toString().padLeft(2, '0')}/${l.year}';
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.item, required this.onTap});

  final _Notice item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(12),
          vertical: context.h(12),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(color: context.torkk.border),
        ),
        child: Row(
          children: [
            Container(
              width: context.w(40),
              height: context.w(40),
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(context.r(12)),
              ),
              child: Icon(
                item.icon,
                color: item.iconColor,
                size: context.w(20),
              ),
            ),
            SizedBox(width: context.w(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.bold.copyWith(
                      fontSize: 14,
                      height: 1.2,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    style: AppTypography.regular.copyWith(
                      fontSize: 12,
                      color: context.torkk.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              item.time,
              style: AppTypography.regular.copyWith(
                fontSize: 11,
                color: AppColors.slate400,
              ),
            ),
            if (item.unread) ...[
              SizedBox(width: context.w(6)),
              Container(
                width: context.w(8),
                height: context.w(8),
                decoration: BoxDecoration(
                  color: profileAccent(context),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
