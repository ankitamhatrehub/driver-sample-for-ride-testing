import 'package:flutter/material.dart';
import 'package:rider_app/driver_features/profile/screens/driver_profile_screen.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class CustomDriverDrawer extends StatelessWidget {
  final String profilePhotoUrl;
  final String driverName;
  final double driverRating;
  final String driverDob; // e.g. '29 Feb 2000'
  final Map<String, dynamic> driverProfile;
  final VoidCallback onClose;
  final VoidCallback? onPerformanceTap;
  final VoidCallback? onTripsTap;
  final VoidCallback? onSupportTap;

  const CustomDriverDrawer({
    super.key,
    required this.profilePhotoUrl,
    required this.driverName,
    required this.driverRating,
    required this.driverDob,
    this.driverProfile = const {},
    required this.onClose,
    this.onPerformanceTap,
    this.onTripsTap,
    this.onSupportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 283,
      child: Container(
        decoration: BoxDecoration(
          color: context.torkk.surface,
          borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
        ),
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row (Close Button and MENU text)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4B5563), // Dark grey
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'MENU',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: context.torkk.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Card (Gradient)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2D3C9D), // Royal blue matching Figma
                          Color(0xFF511A3E), // Deep plum/maroon matching Figma
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(
                                0xFF0044CC,
                              ), // Solid blue border
                              width: 3.5,
                            ),
                            color: Colors.white24,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: profilePhotoUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    profilePhotoUrl,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                  size: 40,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driverName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16, // Reduced to fit longer names
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    driverRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        Icons.star,
                                        color: index < driverRating.round()
                                            ? Colors.amber
                                            : Colors.grey.shade400,
                                        size: 12,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'DOB: $driverDob',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Documents Section
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      Text(
                        'Documents',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: context.torkk.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded Documents',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.torkk.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildDocumentItem(
                        context,
                        'Aadhar Card',
                        driverProfile['aadhaar_number'] != null &&
                                driverProfile['aadhaar_number']
                                    .toString()
                                    .isNotEmpty
                            ? 'Uploaded'
                            : 'Pending (Tap to upload)',
                        onTap: () {
                          onClose();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DriverProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDocumentItem(
                        context,
                        'PAN Card',
                        driverProfile['pan_number'] != null &&
                                driverProfile['pan_number']
                                    .toString()
                                    .isNotEmpty
                            ? 'Uploaded'
                            : 'Pending (Tap to upload)',
                        onTap: () {
                          onClose();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DriverProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDocumentItem(
                        context,
                        'Drivers Licence',
                        driverProfile['driving_licence_number'] != null &&
                                driverProfile['driving_licence_number']
                                    .toString()
                                    .isNotEmpty
                            ? 'Uploaded'
                            : 'Pending (Tap to upload)',
                        onTap: () {
                          onClose();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DriverProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDocumentItem(
                        context,
                        'RC',
                        driverProfile['rc_number'] != null &&
                                driverProfile['rc_number'].toString().isNotEmpty
                            ? 'Uploaded'
                            : 'Pending (Tap to upload)',
                        onTap: () {
                          onClose();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DriverProfileScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      const Divider(color: Colors.black54),
                      const SizedBox(height: 16),

                      _buildLinkItem(
                        context,
                        'Performance Metrics',
                        onTap: () {
                          onClose();
                          if (onPerformanceTap != null) {
                            onPerformanceTap!();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Performance Metrics coming soon!',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      _buildLinkItem(
                        context,
                        'Rewards & Coins',
                        onTap: () {
                          onClose();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rewards coming soon!'),
                            ),
                          );
                        },
                      ),

                      _buildLinkItem(
                        context,
                        'All Trip Activity',
                        onTap: () {
                          onClose();
                          if (onTripsTap != null) {
                            onTripsTap!();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Trip Activity coming soon!'),
                              ),
                            );
                          }
                        },
                      ),
                      _buildLinkItem(
                        context,
                        'Help & Support',
                        onTap: () {
                          onClose();
                          if (onSupportTap != null) {
                            onSupportTap!();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Help & Support coming soon!'),
                              ),
                            );
                          }
                        },
                      ),
                      _buildLinkItem(
                        context,
                        'Settings',
                        onTap: () {
                          onClose();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DriverProfileScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentItem(
    BuildContext context,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.torkk.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: subtitle == 'Uploaded'
                        ? Colors.green
                        : context.themed(
                            light: Colors.black54,
                            dark: context.torkk.textSecondary,
                          ),
                    fontWeight: subtitle == 'Uploaded'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: context.torkk.textPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context,
    String title, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.torkk.textPrimary,
              ),
            ),
            Icon(Icons.chevron_right, color: context.torkk.textPrimary),
          ],
        ),
      ),
    );
  }
}
