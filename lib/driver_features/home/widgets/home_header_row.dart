import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_app/common/widgets/bouncing_widget.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/routes/app_routes.dart';

/// Top header row of the driver dashboard containing:
/// - Notification Bell button
/// - OFFLINE / ONLINE toggle pill
/// - Profile Avatar with gender-specific dynamic ring (Blue for Male, Pink for Female)
class HomeHeaderRow extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggleOnline;
  final VoidCallback onProfileTap;
  final VoidCallback? onNotificationsTap;
  final String profileImageUrl;
  final String driverGender;

  const HomeHeaderRow({
    super.key,
    required this.isOnline,
    required this.onToggleOnline,
    required this.onProfileTap,
    this.onNotificationsTap,
    required this.profileImageUrl,
    this.driverGender = 'Male',
  });

  @override
  Widget build(BuildContext context) {
    final String cleanGender = driverGender.trim().toLowerCase();
    final bool isFemale = cleanGender == 'female' ||
        cleanGender == 'f' ||
        cleanGender.contains('female');
    final Color avatarRingColor =
        isFemale ? const Color(0xFFEC4899) : const Color(0xFF1D4ED8);


    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Notification Bell Button
        GestureDetector(
          onTap: () {
            if (onNotificationsTap != null) {
              onNotificationsTap!();
            } else {
              context.push(AppRoutes.notifications);
            }
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF52525B), // Charcoal grey
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),

        // OFFLINE / ONLINE Pill Button
        BouncingWidget(
          onTap: onToggleOnline,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 36,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF16A34A) // Green Online
                  : const Color(0xFFDC2626), // Red Offline
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isOnline
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626))
                      .withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              isOnline ? 'ONLINE' : 'OFFLINE',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        // Profile Avatar with Blue for Male, Pink for Female ring
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: avatarRingColor, // Dynamic ring color
                width: 2.5,
              ),
              color: context.themed(light: Colors.grey.shade200, dark: context.torkk.surfaceMuted),
            ),
            child: ClipOval(
              child: profileImageUrl.isNotEmpty
                  ? Image.network(
                      profileImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.person,
                        color: avatarRingColor.withValues(alpha: 0.7),
                        size: 24,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: avatarRingColor.withValues(alpha: 0.7),
                      size: 24,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
