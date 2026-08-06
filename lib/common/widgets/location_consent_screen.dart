import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/colors.dart';
import '../services/location_consent_service.dart';

/// Play Store prominent disclosure for location collection.
/// Shown before the system location permission prompt.
class LocationConsentScreen extends StatefulWidget {
  final VoidCallback onAccepted;

  const LocationConsentScreen({super.key, required this.onAccepted});

  @override
  State<LocationConsentScreen> createState() => _LocationConsentScreenState();
}

class _LocationConsentScreenState extends State<LocationConsentScreen> {
  bool _isSubmitting = false;

  Future<void> _onAgree() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await LocationConsentService.accept();

      // Request OS permission only after in-app disclosure consent.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
      }

      if (!mounted) return;
      widget.onAccepted();
    } catch (_) {
      if (!mounted) return;
      widget.onAccepted();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _onDecline() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location required'),
        content: const Text(
          'TORKK Driver needs your location to show nearby ride requests, '
          'navigate trips, and keep you and passengers safe.\n\n'
          'Without location access you cannot go online as a driver.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Go back'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Stay on consent screen; user must acknowledge to continue.
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.primary;

    return Scaffold(
      backgroundColor: Colors.white,
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
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 40,
                          color: primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Allow TORKK Driver to use your location?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please read this carefully before continuing. '
                      'This disclosure is required before we can access your location.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _InfoCard(
                      icon: Icons.my_location_rounded,
                      title: 'What we collect',
                      body:
                          'Your precise device location (GPS) while you use the app, '
                          'and in the background when you are online or on an active trip.',
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.route_rounded,
                      title: 'How we use it',
                      body:
                          'To match you with nearby ride requests, show your position on the map, '
                          'guide navigation during trips, update trip progress for passengers, '
                          'and support safety features such as SOS.',
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.cloud_sync_rounded,
                      title: 'Who it is shared with',
                      body:
                          'Location is sent to TORKK servers so customers and our support team '
                          'can see relevant trip and driver status. It is not sold to advertisers.',
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.phonelink_lock_rounded,
                      title: 'You stay in control',
                      body:
                          'You can turn location off anytime in your device Settings. '
                          'If you deny permission, you will not be able to receive rides.',
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'By tapping “I agree & continue”, you acknowledge that '
                              'TORKK Driver collects your location in the foreground and background '
                              'for the purposes described above.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: Color(0xFF92400E),
                                fontWeight: FontWeight.w500,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _onAgree,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'I agree & continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isSubmitting ? null : _onDecline,
                    child: Text(
                      'No thanks',
                      style: TextStyle(
                        color: Colors.blueGrey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.blueGrey.shade700,
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
