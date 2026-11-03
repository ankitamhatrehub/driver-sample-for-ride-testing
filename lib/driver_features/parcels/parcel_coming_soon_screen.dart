import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/coming_soon_text.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/gradient_line.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/notify_button.dart';

/// "Coming Soon" screen for the Parcel tab. The subscription entry points use
/// `new_feature_coming_soon_screen.dart` instead.
class ParcelComingSoonScreen extends StatefulWidget {
  const ParcelComingSoonScreen({super.key});

  @override
  State<ParcelComingSoonScreen> createState() => _ParcelComingSoonScreenState();
}

class _ParcelComingSoonScreenState extends State<ParcelComingSoonScreen> {
  static const _notifyKey = 'notify_parcel_launch';
  static const _grey = Color(0xFF8B909C);

  bool _notified = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _notified = prefs.getBool(_notifyKey) ?? false);
  }

  Future<void> _notify() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifyKey, true);
    if (!mounted) return;
    setState(() => _notified = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Column(
          children: [
            if (Navigator.canPop(context))
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: context.torkk.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                        child: Column(
                          children: [
                            Image.asset(
                              context.isDarkTheme
                                  ? 'assets/coming_soon/new_feature_illustration_dark.png'
                                  : 'assets/coming_soon/new_feature_illustration.png',
                              height: 260,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            const GradientLine('Coming Soon', size: 34),
                            const Spacer(),
                            Image.asset(
                              'assets/coming_soon/share_gift_illustration.png',
                              height: 230,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 16),
                            NotifyButton(
                              label: _notified
                                  ? "You'll be notified"
                                  : 'Notify Me',
                              icon: _notified
                                  ? Icons.check_circle_rounded
                                  : Icons.notifications_rounded,
                              onPressed: _notified ? null : _notify,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Be the first to know when it is live.',
                              style: Inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
