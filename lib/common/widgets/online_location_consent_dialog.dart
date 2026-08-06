import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/colors.dart';

enum OnlineLocationChoice {
  always,
  whileInUse,
  thisTime,
}

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
    backgroundColor: Colors.white,
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
                  color: Colors.black12,
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
            const Text(
              'Location needed to go online',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how TORKK Driver can use your location while you are online. '
              'You can change this every time you go online.',
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.blueGrey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            _ChoiceOption(
              title: 'Allow all the time',
              subtitle:
                  'Best for drivers — get rides even when the app is in the background',
              recommended: true,
              selected: _selected == OnlineLocationChoice.always,
              onTap: () => setState(() => _selected = OnlineLocationChoice.always),
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
                color: const Color(0xFFEFF6FF),
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text(
                  'Stay offline',
                  style: TextStyle(
                    color: Colors.blueGrey.shade500,
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

class _ChoiceOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final bool recommended;
  final VoidCallback onTap;

  const _ChoiceOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.recommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? (recommended ? const Color(0xFF10B981) : AppColors.primary)
        : Colors.black12;
    final bgColor = selected
        ? (recommended ? const Color(0xFFECFDF5) : const Color(0xFFEEF2FF))
        : const Color(0xFFF8FAFC);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: selected ? 1.6 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: 22,
                color: selected
                    ? (recommended ? const Color(0xFF059669) : AppColors.primary)
                    : Colors.blueGrey.shade400,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (recommended) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Recommended',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: Colors.blueGrey.shade600,
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

/// In-app online consent + OS location permission based on the driver's choice.
Future<bool> requestOnlineLocationPermission(BuildContext context) async {
  final choice = await showOnlineLocationConsentDialog(context);
  if (choice == null) return false;
  if (!context.mounted) return false;

  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    if (context.mounted) {
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Turn on location'),
          content: const Text(
            'Device location is turned off. Enable GPS to go online and receive rides.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Open settings'),
            ),
          ],
        ),
      );
      if (open == true) {
        await Geolocator.openLocationSettings();
      }
    }
    return false;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied) {
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

  if (permission == LocationPermission.deniedForever) {
    if (context.mounted) {
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Location blocked'),
          content: const Text(
            'Location permission is permanently denied. Open Settings and allow '
            'location (Always / While using the app) to go online.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Open settings'),
            ),
          ],
        ),
      );
      if (open == true) {
        await Geolocator.openAppSettings();
      }
    }
    return false;
  }

  // If driver selected Always, try upgrading beyond while-in-use.
  if (choice == OnlineLocationChoice.always &&
      permission == LocationPermission.whileInUse) {
    if (Platform.isAndroid) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.always && context.mounted) {
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Enable “Allow all the time”'),
          content: const Text(
            'Android needs you to set location to “Allow all the time” in Settings '
            'for background ride matching.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep while using'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Open settings'),
            ),
          ],
        ),
      );
      if (open == true) {
        await Geolocator.openAppSettings();
        permission = await Geolocator.checkPermission();
      }
    }
  }

  // whileInUse and thisTime both need at least while-in-use from the OS.
  // "Only this time" is an OS-level one-session grant when the system dialog offers it.
  return permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;
}
