import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/driver_features/profile/screens/driver_profile_screen.dart';
import 'package:rider_app/driver_features/wallet/wallet_screen.dart';
import 'package:rider_app/driver_features/earnings/screens/driver_earnings_screen.dart';

// --- DRIVER NOTIFICATIONS SCREEN ---
// --- DRIVER NOTIFICATIONS SCREEN (INBOX) ---
class DriverNotificationsScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final String? profilePhotoUrl;

  const DriverNotificationsScreen({
    super.key,
    this.onClose,
    this.profilePhotoUrl,
  });

  @override
  State<DriverNotificationsScreen> createState() =>
      _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen> {
  String _selectedFilter = 'All';
  String? _cachedPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    if (widget.profilePhotoUrl != null && widget.profilePhotoUrl!.isNotEmpty) {
      setState(() => _cachedPhotoUrl = widget.profilePhotoUrl);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final photo =
        prefs.getString('profile_photo') ??
        prefs.getString('profile_photo_url');
    if (mounted && photo != null && photo.isNotEmpty) {
      setState(() => _cachedPhotoUrl = photo);
    }
  }

  void _handleNotificationTap(Map<String, dynamic> item) {
    if (item['action'] == 'upi') {
      _showUpiSetupSheet();
    } else if (item['action'] == 'start_ride') {
      if (widget.onClose != null) {
        widget.onClose!();
      } else {
        Navigator.maybePop(context);
      }
    } else if (item['action'] == 'wallet') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WalletScreen()),
      );
    } else if (item['action'] == 'earnings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DriverEarningsScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['title'] ?? 'Notification',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  item['description'] ?? item['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _showUpiSetupSheet() {
    final upiCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    '₹',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPI ID Set Up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Receive instant daily ride payouts',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: upiCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. mobile@upi or username@okaxis',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF1E3A8A),
                    width: 1.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final upi = upiCtrl.text.trim();
                  if (upi.isEmpty) return;
                  Navigator.pop(ctx);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('driver_upi_id', upi);
                  final phone = prefs.getString('phone') ?? '';
                  try {
                    await http.post(
                      Uri.parse(AppUrls.setPaymentMethod),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'phone': phone,
                        'payment_method': 'upi',
                        'upi_id': upi,
                      }),
                    );
                  } catch (_) {}
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('UPI ID updated successfully!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save UPI ID',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(String iconType) {
    Color bg;
    Widget iconWidget;

    switch (iconType) {
      case 'blue_rupee':
      case 'rupee':
        bg = const Color(0xFF163E93); // Deep blue from image
        iconWidget = const Text(
          '₹',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
        break;
      case 'blue_thumb':
      case 'thumb':
        bg = const Color(0xFF163E93); // Deep blue from image
        iconWidget = const Icon(
          Icons.thumb_up_alt_outlined,
          color: Colors.white,
          size: 22,
        );
        break;
      case 'red_exit':
      case 'exit':
      case 'transfer':
        bg = const Color(0xFFE1473D); // Red from image
        iconWidget = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 13,
            ),
          ),
        );
        break;
      case 'green_rupee':
      case 'green':
      case 'earnings':
        bg = const Color(0xFF22C55E); // Green from image
        iconWidget = const Text(
          '₹',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
        break;
      default:
        bg = const Color(0xFF163E93);
        iconWidget = const Icon(
          Icons.notifications_rounded,
          color: Colors.white,
          size: 22,
        );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(child: iconWidget),
    );
  }

  List<Map<String, dynamic>> _getFilteredNotifications() {
    final all = [
      {
        'title': 'UPI ID Set Up',
        'time': '23:00',
        'iconType': 'blue_rupee',
        'filter': 'Today',
        'action': 'upi',
        'description':
            'Configure your UPI ID to receive instant direct payouts for completed trips.',
      },
      {
        'title': 'You are all Set to Start Ride',
        'time': '22:30',
        'iconType': 'blue_thumb',
        'filter': 'Today',
        'action': 'start_ride',
        'description':
            'Your documents are verified and profile is ready. Go online anytime to start earning!',
      },
      {
        'title': 'Payout Transferred to Bank Account',
        'time': '21:15',
        'iconType': 'red_exit',
        'filter': 'Today',
        'action': 'wallet',
        'description':
            'Payout of ₹2,450.00 has been transferred to your registered bank account.',
      },
      {
        'title': 'Trip Earnings Credited',
        'time': '20:40',
        'iconType': 'green_rupee',
        'filter': 'Today',
        'action': 'earnings',
        'description':
            '₹340.00 has been credited to your Torkk wallet for completed trip.',
      },
      {
        'title': 'Daily Performance Bonus Credited',
        'time': 'Yesterday, 21:00',
        'iconType': 'green_rupee',
        'filter': 'Yesterday',
        'action': 'earnings',
        'description':
            '₹150.00 daily incentive bonus added for completing 10 rides yesterday!',
      },
      {
        'title': 'Account Verified & Live',
        'time': 'Yesterday, 14:45',
        'iconType': 'blue_thumb',
        'filter': 'Yesterday',
        'action': 'start_ride',
        'description':
            'Congratulations! Your Torkk driver profile has been approved.',
      },
      {
        'title': 'Documents Submitted for Verification',
        'time': '5 days ago',
        'iconType': 'blue_rupee',
        'filter': 'Last week',
        'action': 'none',
        'description':
            'Aadhaar, DL, and RC verification submitted successfully.',
      },
      {
        'title': 'Fast Payout System Activated',
        'time': '6 days ago',
        'iconType': 'red_exit',
        'filter': 'Last week',
        'action': 'wallet',
        'description':
            'Daily auto-withdrawal has been enabled for your driver account.',
      },
    ];

    if (_selectedFilter == 'All') return all;
    return all.where((n) => n['filter'] == _selectedFilter).toList();
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1D4ED8)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = _cachedPhotoUrl;
    final notifications = _getFilteredNotifications();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP BAR (Close Button, Inbox Title, Profile Avatar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: widget.onClose ?? () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF475569),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Text(
                    'Inbox',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DriverProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2563EB),
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: photo != null && photo.isNotEmpty
                            ? (photo.startsWith('http')
                                  ? Image.network(
                                      photo,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, error, stackTrace) => const Icon(
                                        Icons.person,
                                        color: Color(0xFF64748B),
                                      ),
                                    )
                                  : Image.file(
                                      File(photo),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, error, stackTrace) => const Icon(
                                        Icons.person,
                                        color: Color(0xFF64748B),
                                      ),
                                    ))
                            : const Icon(
                                Icons.person,
                                color: Color(0xFF64748B),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // HORIZONTAL FILTER CHIPS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 10),
                  _buildFilterChip('Today'),
                  const SizedBox(width: 10),
                  _buildFilterChip('Yesterday'),
                  const SizedBox(width: 10),
                  _buildFilterChip('Last week'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // SECTION HEADER: "New"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'New',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),

            // NOTIFICATION LIST
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mark_email_read_outlined,
                            size: 56,
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No notifications for "$_selectedFilter"',
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: notifications.length,
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => _handleNotificationTap(item),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildNotificationBadge(
                                      item['iconType']?.toString() ?? '',
                                    ),
                                    const SizedBox(width: 16),
                                    // Title & Time
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'] ?? '',
                                            style: TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w800,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['time'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? Colors.grey.shade400
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                              indent: 84,
                              endIndent: 20,
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
