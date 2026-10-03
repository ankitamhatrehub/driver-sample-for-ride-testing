import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rider_app/service/driver_api_service.dart';
import 'call_112_screen.dart';

// --- DRIVER SOS SCREEN ---
class DriverSosScreen extends StatefulWidget {
  const DriverSosScreen({super.key});

  @override
  State<DriverSosScreen> createState() => _DriverSosScreenState();
}

class _DriverSosScreenState extends State<DriverSosScreen> {
  String _phone = "";
  String _driverName = "";
  String _driverGender = "";
  String _driverDob = "";
  String _vehicleInfo = "";
  String _driverPhotoUrl = "";
  double _currentLat = 28.6139;
  double _currentLng = 77.2090;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _phone =
          prefs.getString("user_phone") ??
          prefs.getString("driver_phone") ??
          "";

      if (_phone.isNotEmpty) {
        try {
          final profile = await DriverApiService.fetchProfile(_phone);
          if (mounted) {
            setState(() {
              _driverName =
                  profile["name"] ??
                  profile["driver_name"] ??
                  prefs.getString("user_name") ??
                  "Driver";
              _driverPhotoUrl =
                  profile["profile_photo"] ??
                  profile["photo_url"] ??
                  prefs.getString("driver_photo_url") ??
                  "";
              _driverGender =
                  profile["gender"] ??
                  prefs.getString("driver_gender") ??
                  "Male";
              _driverDob =
                  profile["dob"] ?? prefs.getString("driver_dob") ?? "";

              final vName =
                  profile["vehicle_name"] ??
                  profile["vehicle_type"] ??
                  prefs.getString("vehicle_info") ??
                  "Vehicle";
              final vNum =
                  profile["vehicle_number"] ?? profile["rc_number"] ?? "";
              _vehicleInfo = vNum.isNotEmpty ? "$vName, $vNum" : vName;
            });
          }
        } catch (_) {
          if (mounted) {
            setState(() {
              _driverName =
                  prefs.getString("user_name") ??
                  prefs.getString("driver_name") ??
                  "Driver";
              _driverPhotoUrl = prefs.getString("driver_photo_url") ?? "";
              _driverGender = prefs.getString("driver_gender") ?? "Male";
              _driverDob = prefs.getString("driver_dob") ?? "";
              _vehicleInfo =
                  prefs.getString("vehicle_info") ?? "Registered Vehicle";
            });
          }
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _currentLat = pos.latitude;
          _currentLng = pos.longitude;
        });
      }
    } catch (_) {}
  }

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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxDrag = (MediaQuery.of(context).size.width - 40 - 48).clamp(
      100.0,
      400.0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Back Icon
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4, right: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: Color(0xFF0F172A),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Block
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Get Emergency Help",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Your Current Location and Information will be shared to the help",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Driver & Vehicle Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1D4ED8),
                                    width: 2.5,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _driverPhotoUrl.isNotEmpty
                                      ? Image.network(
                                          _driverPhotoUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              const Icon(
                                                Icons.person,
                                                size: 28,
                                                color: Color(0xFF334155),
                                              ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 28,
                                          color: Color(0xFF334155),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _driverName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "$_driverGender $_driverDob",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Vehical Info",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _vehicleInfo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Location",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${_currentLat.toStringAsFixed(7)}, ${_currentLng.toStringAsFixed(7)}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xFFCBD5E1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                "assets/welcome_car_city.png",
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: const Color(0xFFCBD5E1),
                                  child: const Center(
                                    child: Icon(
                                      Icons.map_rounded,
                                      color: Color(0xFF64748B),
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Options List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildSosOptionTile(
                            title: "Call 112",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Call112Screen(),
                              ),
                            ),
                          ),
                          const Divider(color: Color(0xFFE2E8F0), height: 1),
                          _buildSosOptionTile(
                            title: "Text Emergency Number",
                            onTap: _textEmergency,
                          ),
                          const Divider(color: Color(0xFFE2E8F0), height: 1),
                          _buildSosOptionTile(
                            title: "Call Emergency Contact",
                            onTap: _callEmergencyContact,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Red Slider Button: Slide to Call for help
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFB91C1C),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      "Slide to Call for help",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Positioned(
                    left: _dragOffset,
                    top: 4,
                    bottom: 4,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _dragOffset = (_dragOffset + details.delta.dx).clamp(
                            0.0,
                            maxDrag,
                          );
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        if (_dragOffset > maxDrag * 0.7) {
                          setState(() => _dragOffset = maxDrag);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Call112Screen(),
                            ),
                          ).then((_) {
                            if (mounted) setState(() => _dragOffset = 0.0);
                          });
                        } else {
                          setState(() => _dragOffset = 0.0);
                        }
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
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
