import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/feature_page.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/launch_page.dart';
import 'package:rider_app/driver_features/parcels/coming_soon/neighbourhood_page.dart';
import 'package:rider_app/service/location_availability_service.dart';

/// Neighbourhood launch screen shown when the backend says service is unavailable.
/// The other frames in the design are additional pages in the same screen.
class ComingSoonScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onChangeLocation;

  /// Where the driver is, sent with the "Notify me" request. When null the
  /// current position is read.
  final double? latitude;
  final double? longitude;

  const ComingSoonScreen({
    super.key,
    this.onBack,
    this.onChangeLocation,
    this.latitude,
    this.longitude,
  });

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  final PageController _pages = PageController();
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reopen_to_signup', true);
    await prefs.setBool('is_outside_delhi_ncr', true);
    final notified = prefs.getBool('notify_torkk_launch') ?? false;
    if (!mounted) return;
    setState(() => _notified = notified);
  }

  /// Saves the driver's "Notify me" request on the server.
  Future<void> _notify() async {
    if (_notified) return;
    try {
      final message = await LocationAvailabilityService.notifyMe(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notify_torkk_launch', true);
      if (!mounted) return;
      setState(() => _notified = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      final text = '$e'.replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> _openInstagram() async {
    final uri = Uri.parse(
      'https://www.instagram.com/torkkapp?mdxt=MTQzdzJtNTE3N2V4dA==',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showBack = widget.onBack != null || Navigator.canPop(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_outside_delhi_ncr', false);
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: context.torkk.background,
        body: SafeArea(
          child: Column(
            children: [
              if (showBack)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: context.torkk.textPrimary,
                        ),
                        onPressed: _handleBack,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  children: [
                    NeighbourhoodPage(
                      notified: _notified,
                      onNotify: _notify,
                      onInstagram: _openInstagram,
                      onChangeLocation:
                          widget.onChangeLocation ??
                          () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('is_outside_delhi_ncr', false);
                            if (context.mounted) {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                context.go(AppRoutes.login);
                              }
                            }
                          },
                    ),
                    LaunchPage(onNotify: _notify),
                    FeaturePage(onNotify: _notify),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
