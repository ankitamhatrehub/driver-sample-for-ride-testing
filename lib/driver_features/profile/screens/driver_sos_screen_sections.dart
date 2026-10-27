part of 'package:rider_app/driver_features/profile/screens/driver_sos_screen.dart';

extension _DriverSosScreenStateSections on _DriverSosScreenState {
  void _textEmergency() async {
    final uri = Uri.parse(
      "sms:112?body=Emergency! I need immediate help at Lat: $_currentLat, Lng: $_currentLng",
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  void _callEmergencyContact() async {
    final uri = Uri.parse("tel:112");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  Widget _buildSosOptionTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEF4444), width: 5),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.torkk.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
