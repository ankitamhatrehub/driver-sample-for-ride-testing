part of 'package:rider_app/driver_features/notifications/screens/driver_notifications_screen.dart';

extension _DriverNotificationsScreenStateSections
    on _DriverNotificationsScreenState {
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
          backgroundColor: context.torkk.surface,
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
                  style: TextStyle(
                    fontSize: 14,
                    color: context.torkk.textBody,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: onColorFor(const Color(0xFF4F46E5)),
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
      backgroundColor: context.torkk.surface,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPI ID Set Up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.torkk.textPrimary,
                      ),
                    ),
                    Text(
                      'Receive instant daily ride payouts',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.torkk.textSecondary,
                      ),
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
                fillColor: context.torkk.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: context.torkk.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: context.torkk.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: context.legible(Color(0xFF1E3A8A)),
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
                  final phone = prefs.getString('user_phone') ?? '';
                  try {
                    await DriverApiService.saveUpiPaymentMethod(
                      phone: phone,
                      upiId: upi,
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
                  foregroundColor: onColorFor(const Color(0xFF1E3A8A)),
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
}
