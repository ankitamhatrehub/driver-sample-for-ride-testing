import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

void showLocationDetailBottomSheet({
  required BuildContext context,
  required String title,
  required String address,
  required String distanceText,
  required Color color,
  double? lat,
  double? lng,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.torkk.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.torkk.textPrimary,
                  ),
                ),
                const Spacer(),
                if (distanceText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      distanceText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'FULL ADDRESS DETAILS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            SelectableText(
              address.isNotEmpty ? address : 'No address provided',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.torkk.textBody,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        if (lat != null &&
                            lng != null &&
                            lat != 0.0 &&
                            lng != 0.0) {
                          final mapUrl = Uri.parse(
                            AppUrls.googleMapsSearch(lat: lat, lng: lng),
                          );
                          if (await canLaunchUrl(mapUrl)) {
                            await launchUrl(
                              mapUrl,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.navigation_rounded, size: 20),
                      label: const Text(
                        'Navigate in Maps',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
