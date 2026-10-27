import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/colors.dart';
import 'package:rider_app/service/location_consent_service.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

part 'online_location_consent_dialog_parts/choice_option.dart';

enum OnlineLocationChoice { always, whileInUse, thisTime }

/// Shown every time a driver toggles Online, before the OS location prompt.
/// Returns the selected choice, or null if the driver stays offline.

Future<OnlineLocationChoice?> showOnlineLocationConsentDialog(
  BuildContext context,
) async {
  return showModalBottomSheet<OnlineLocationChoice>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: context.torkk.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => const _OnlineLocationConsentSheet(),
  );
}

class _OnlineLocationConsentSheet extends StatefulWidget {
  const _OnlineLocationConsentSheet();

  @override
  State<_OnlineLocationConsentSheet> createState() =>
      _OnlineLocationConsentSheetState();
}

class _OnlineLocationConsentSheetState
    extends State<_OnlineLocationConsentSheet> {
  OnlineLocationChoice _selected = OnlineLocationChoice.always;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.torkk.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 34,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Location needed to go online',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: context.torkk.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how TORKK Driver can use your location while you are online. '
              'You can change this every time you go online.',
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: context.torkk.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _ChoiceOption(
              title: 'Allow all the time',
              subtitle:
                  'Best for drivers — get rides even when the app is in the background',
              recommended: true,
              selected: _selected == OnlineLocationChoice.always,
              onTap: () =>
                  setState(() => _selected = OnlineLocationChoice.always),
            ),
            const SizedBox(height: 8),
            _ChoiceOption(
              title: 'While using the app',
              subtitle: 'Location only when TORKK Driver is open',
              selected: _selected == OnlineLocationChoice.whileInUse,
              onTap: () =>
                  setState(() => _selected = OnlineLocationChoice.whileInUse),
            ),
            const SizedBox(height: 8),
            _ChoiceOption(
              title: 'Only this time',
              subtitle: 'Ask again the next time you go online',
              selected: _selected == OnlineLocationChoice.thisTime,
              onTap: () =>
                  setState(() => _selected = OnlineLocationChoice.thisTime),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.adaptiveTint(const Color(0xFFEFF6FF)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Next, your phone may show the system location permission so Android '
                'can confirm your choice.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text(
                  'Cancel (Stay Offline)',
                  style: TextStyle(
                    color: context.themed(light: Colors.blueGrey, dark: context.torkk.textSecondary),
                    fontWeight: FontWeight.w600,
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

/// In-app online consent + OS location permission based on the driver's choice.
Future<bool> requestOnlineLocationPermission(BuildContext context) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    if (context.mounted) {
      final open = await _showLocationActionDialog(
        context: context,
        icon: Icons.location_off_rounded,
        iconColor: const Color(0xFFF59E0B),
        title: 'Turn on location',
        message:
            'Device location is turned off. Enable GPS to go online and receive ride requests.',
        confirmText: 'Open Settings',
      );
      if (open == true) {
        await Geolocator.openLocationSettings();
      }
    }
    return false;
  }

  var permission = await Geolocator.checkPermission();

  // If location permission is ALREADY granted, skip all modal sheets and return true immediately!
  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    await LocationConsentService.accept();
    return true;
  }

  if (permission == LocationPermission.deniedForever) {
    if (context.mounted) {
      final open = await _showLocationActionDialog(
        context: context,
        icon: Icons.block_rounded,
        iconColor: const Color(0xFFEF4444),
        title: 'Location Blocked',
        message:
            'Location permission is permanently denied. Open Settings and allow location (Always / While using the app) to go online.',
        confirmText: 'Open Settings',
      );
      if (open == true) {
        await Geolocator.openAppSettings();
      }
    }
    return false;
  }

  // OS permission is denied: show in-app disclosure modal ONCE before OS prompt
  final choice = await showOnlineLocationConsentDialog(context);
  if (choice == null) return false;
  if (!context.mounted) return false;

  permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is required to go online.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    return false;
  }

  await LocationConsentService.accept();
  return permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;
}

Future<bool?> _showLocationActionDialog({
  required BuildContext context,
  required IconData icon,
  required Color iconColor,
  required String title,
  required String message,
  required String confirmText,
  String cancelText = 'Cancel',
}) {
  final isLongCancel = cancelText.length > 8;

  return showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: context.torkk.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.torkk.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: context.torkk.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            if (isLongCancel) ...[
              // Stacked layout for multi-word or long secondary action
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    side: BorderSide(
                      color: context.torkk.border,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    foregroundColor: context.torkk.textBody,
                  ),
                  child: Text(
                    cancelText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Balanced side-by-side layout for single-word actions
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          side: const BorderSide(
                            color: Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          foregroundColor: context.torkk.textBody,
                        ),
                        child: Text(
                          cancelText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF6366F1,
                              ).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            confirmText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
