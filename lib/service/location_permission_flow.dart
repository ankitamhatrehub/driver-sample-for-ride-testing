import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/widgets/location_disclosure_screen.dart';
import 'package:rider_app/service/location_consent_service.dart';

/// How much location access the app ended up with.
enum LocationAccess { none, foreground, background }

/// The ONLY place that asks the OS for location permission.
///
/// Flow (Google Play prominent disclosure):
///  1. Disclosure screen -> Accept -> request foreground ("while in use").
///  2. Only once foreground is granted: second disclosure for background ->
///     Accept -> request background as its own step (Android 11+).
/// Denying at any step never blocks the app. The background step is offered
/// automatically only once, so the driver is not nagged; it is offered again
/// only when [force] is true (the driver tapped something to re-enable it).
class LocationPermissionFlow {
  static const _bgPromptedKey = 'location_background_prompted_v1';

  // One flow at a time. If a second caller arrives while the disclosure or the
  // system prompt is still open, it waits for the same answer instead of
  // opening a second disclosure screen on top.
  static Future<LocationAccess>? _inFlight;

  static Future<LocationAccess> ensure(
    BuildContext context, {
    bool background = false,
    bool force = false,
  }) {
    final running = _inFlight;
    if (running != null) {
      debugPrint('[LOCATION FLOW] already running, joining it');
      return running;
    }
    debugPrint(
      '[LOCATION FLOW] start background=$background force=$force '
      'from:\n${StackTrace.current.toString().split('\n').skip(1).take(4).join('\n')}',
    );
    final flow = _run(
      context,
      background: background,
      force: force,
    ).whenComplete(() => _inFlight = null);
    _inFlight = flow;
    return flow;
  }

  static Future<LocationAccess> _run(
    BuildContext context, {
    required bool background,
    required bool force,
  }) async {
    var permission = await Geolocator.checkPermission();
    debugPrint('[LOCATION FLOW] current permission: $permission');

    // Blocked for good: only the phone's Settings can change it. The caller
    // decides how to tell the driver (see requestOnlineLocationPermission).
    if (permission == LocationPermission.deniedForever) {
      return LocationAccess.none;
    }

    // Step 1: foreground.
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      if (!context.mounted) return LocationAccess.none;
      final accepted = await showLocationDisclosure(context, background: false);
      if (!accepted || !context.mounted) return LocationAccess.none;
      await LocationConsentService.accept();
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return LocationAccess.none;
      }
    }

    // Step 2: background, separate prompt, only after foreground is granted.
    if (background && permission == LocationPermission.whileInUse) {
      final prefs = await SharedPreferences.getInstance();
      final alreadyAsked = prefs.getBool(_bgPromptedKey) ?? false;
      if ((force || !alreadyAsked) && context.mounted) {
        final accepted = await showLocationDisclosure(
          context,
          background: true,
        );
        await prefs.setBool(_bgPromptedKey, true);
        if (accepted) {
          permission = await Geolocator.requestPermission();
        }
      }
    }

    return permission == LocationPermission.always
        ? LocationAccess.background
        : LocationAccess.foreground;
  }
}
