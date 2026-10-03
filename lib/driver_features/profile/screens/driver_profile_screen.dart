import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:rider_app/service/driver_api_service.dart';
import 'package:rider_app/driver_features/documents/screens/driver_documents_screen.dart';
import 'package:rider_app/driver_features/documents/screens/driver_subscription_pass_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  bool _loading = true;
  String _name = '';
  String _phone = '';
  String _profilePhotoUrl = '';
  String _gender = 'Not specified';
  String _dob = 'Not specified';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone') ?? '';
    if (phone.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final sharedName = prefs.getString('user_name') ?? '';
    final sharedGender = prefs.getString('user_gender') ?? '';
    final _ = prefs.getString('vehicle_type') ?? '';
    final localPhoto = prefs.getString('profile_photo_url') ?? '';
    final localDob = prefs.getString('dob') ?? 'Not specified';
    final _ = prefs.getString('pan_number') ?? '';

    try {
      final data = await DriverApiService.fetchProfile(phone);
      if (mounted) {
        setState(() {
          _name = sharedName.isNotEmpty ? sharedName : (data['name'] ?? '');
          _phone = data['phone'] ?? phone;
          _profilePhotoUrl = localPhoto.isNotEmpty
              ? localPhoto
              : (data['profile_photo_url'] ?? '');

          _gender = sharedGender.isNotEmpty
              ? sharedGender
              : (data['gender'] ?? 'Not specified');
          _dob = localDob.isNotEmpty
              ? localDob
              : (data['dob'] ?? 'Not specified');
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _phone = phone;
          _name = sharedName;
          _profilePhotoUrl = localPhoto;
          _gender = sharedGender.isNotEmpty ? sharedGender : 'Not specified';
          _dob = localDob;
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;

    setState(() => _loading = true);
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      await DriverApiService.uploadProfilePhoto(
        driverPhone: _phone,
        base64Image: base64Image,
      );
      await _loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Widget _buildInfoRow(String title, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildOptionTile({
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, {int currentIndex = 3}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navItems = [
      {'label': 'HOME', 'icon': Icons.home_outlined, 'route': AppRoutes.home},
      {
        'label': 'EARNINGS',
        'icon': Icons.payments_outlined,
        'route': AppRoutes.earnings,
      },
      {
        'label': 'HELP',
        'icon': Icons.headset_mic_outlined,
        'route': AppRoutes.support,
      },
      {
        'label': 'SETTINGS',
        'icon': Icons.settings_outlined,
        'route': AppRoutes.profile,
      },
    ];

    return Container(
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (idx) {
            final item = navItems[idx];
            final isSelected = currentIndex == idx;

            return GestureDetector(
              onTap: () {
                if (currentIndex == idx) return;
                final route = item['route'] as String;
                context.go(route);
              },
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF1D4ED8,
                      ).withValues(alpha: isSelected ? 0.4 : 0.2),
                      blurRadius: isSelected ? 8 : 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !widget.embedded,
        leading: widget.embedded
            ? const SizedBox.shrink()
            : Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF475569),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 22,
          ),
        ),
      ),
      bottomNavigationBar: widget.embedded ? null : _buildBottomNav(context, currentIndex: 3),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // Large centered profile photo with thick blue border (#1D4ED8)
                  Center(
                    child: GestureDetector(
                      onTap: _pickAndUploadPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1D4ED8),
                            width: 4,
                          ),
                        ),
                        child: _profilePhotoUrl.isNotEmpty
                            ? CircleAvatar(
                                radius: 56,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: NetworkImage(_profilePhotoUrl),
                              )
                            : CircleAvatar(
                                radius: 56,
                                backgroundColor: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.person,
                                  size: 56,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Driver Name (e.g. Piyush Kumar from prefs/API)
                  Text(
                    _name.isNotEmpty ? _name : 'Driver Partner',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Info Rows: Gender, DOB
                  _buildInfoRow(
                    'Gender',
                    _gender.isNotEmpty ? _gender : 'Not specified',
                  ),
                  Divider(
                    color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    height: 1,
                  ),
                  _buildInfoRow(
                    'DOB',
                    _dob.isNotEmpty ? _dob : 'Not specified',
                  ),
                  Divider(
                    color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    height: 1,
                  ),
                  const SizedBox(height: 24),
                  // Option Tiles (matching Figma Profile screenshot):
                  _buildOptionTile(
                    title: 'Subscription Pass',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DriverSubscriptionPassScreen(),
                        ),
                      );
                    },
                  ),
                  _buildOptionTile(
                    title: 'Documents',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriverDocumentsScreen(),
                      ),
                    ),
                  ),
                  _buildOptionTile(
                    title: 'All Trip Activity',
                    onTap: () {
                      context.push(AppRoutes.history);
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (mounted) {
                          context.go(AppRoutes.login);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Colors.red, width: 1),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
