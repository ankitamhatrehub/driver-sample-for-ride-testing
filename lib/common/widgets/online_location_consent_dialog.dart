import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rider_app/service/location_consent_service.dart';
import 'package:rider_app/service/location_permission_flow.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Go Online: prominent disclosure + OS location permission (foreground, then
/// background as a separate step). Returns true when the driver may go online.
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

  // Already allowed "all the time": nothing to ask.
  if (permission == LocationPermission.always) {
    await LocationConsentService.accept();
    return true;
  }

  // Allowed "while using": offer the background step once (never blocks).
  if (permission == LocationPermission.whileInUse) {
    if (!context.mounted) return true;
    await LocationPermissionFlow.ensure(context, background: true);
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

  // Disclosure screen -> foreground permission, then a separate disclosure ->
  // background permission. Going online only needs foreground; a "Deny" on the
  // background step still lets the driver go online.
  if (!context.mounted) return false;
  final access = await LocationPermissionFlow.ensure(context, background: true);

  if (access == LocationAccess.none) {
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
  return true;
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
                    side: BorderSide(color: context.torkk.border, width: 1.2),
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
