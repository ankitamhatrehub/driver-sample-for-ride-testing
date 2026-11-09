import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/translations.dart';

/// Google Play "Prominent Disclosure" for location access.
///
/// Full-screen page shown BEFORE the Android system location prompt. The
/// system prompt must only be requested when this returns `true` (Accept).
/// Back button and Deny both return `false`.
///
/// [background] = false: foreground ("while using the app") disclosure.
/// [background] = true:  the extra disclosure for background location, shown
/// before the separate background permission step (Android 11+).
Future<bool> showLocationDisclosure(
  BuildContext context, {
  required bool background,
}) async {
  final accepted = await Navigator.of(context, rootNavigator: true).push<bool>(
    MaterialPageRoute<bool>(
      fullscreenDialog: true,
      builder: (_) => LocationDisclosureScreen(background: background),
    ),
  );
  return accepted == true;
}

class LocationDisclosureScreen extends StatelessWidget {
  const LocationDisclosureScreen({super.key, required this.background});

  final bool background;

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.tr;
    final primary = AppColors.primary;

    // Real features that use location in this app (verified in code):
    //  - POST /v1/location/check            -> service-area (Delhi NCR) check
    //  - POST /api/driver/update-location   -> live position while online
    //  - Home / navigation maps             -> position, route, ETA
    //  - SOS alert                          -> sends current position
    //  - Foreground service (type=location) -> keeps working while online
    //    with the app in the background.
    // TODO(owner): confirm "Who it is shared with" matches the privacy policy
    // (Torkk servers, passenger on the trip, support team, Google Maps APIs).
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(false);
      },
      child: Scaffold(
        backgroundColor: context.torkk.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            background
                                ? Icons.share_location_rounded
                                : Icons.location_on_rounded,
                            size: 40,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        tr(background ? 'locDiscTitleBg' : 'locDiscTitleFg'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: context.torkk.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr(background ? 'locDiscIntroBg' : 'locDiscIntroFg'),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: context.torkk.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _InfoCard(
                        icon: Icons.my_location_rounded,
                        title: tr('locDiscCollectTitle'),
                        body: tr(
                          background ? 'locDiscCollectBg' : 'locDiscCollectFg',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.route_rounded,
                        title: tr('locDiscWhyTitle'),
                        body: tr(background ? 'locDiscWhyBg' : 'locDiscWhyFg'),
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.cloud_sync_rounded,
                        title: tr('locDiscShareTitle'),
                        body: tr('locDiscShareBody'),
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.phonelink_lock_rounded,
                        title: tr('locDiscControlTitle'),
                        body: tr('locDiscControlBody'),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.torkk.textPrimary,
                            side: BorderSide(color: context.torkk.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            tr('locDeny'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            tr('locAccept'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.torkk.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.torkk.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.legible(AppColors.primary), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.torkk.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: context.torkk.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
