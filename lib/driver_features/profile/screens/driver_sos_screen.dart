import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rider_app/service/driver_api_service.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'call_112_screen.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
part 'driver_sos_screen_sections.dart';

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

  @override
  Widget build(BuildContext context) {
    final maxDrag = (MediaQuery.of(context).size.width - 40 - 48).clamp(
      100.0,
      400.0,
    );

    return Scaffold(
      backgroundColor: context.torkk.surfaceMuted,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Back Icon
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4, right: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: context.torkk.textPrimary,
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Get Emergency Help",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: context.torkk.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Your Current Location and Information will be shared to the help",
                            style: TextStyle(
                              fontSize: 13,
                              color: context.torkk.textSecondary,
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
                        color: context.torkk.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: context.torkk.border),
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
                                              Icon(
                                                Icons.person,
                                                size: 28,
                                                color: context.torkk.textBody,
                                              ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 28,
                                          color: context.torkk.textBody,
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
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: context.torkk.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "$_driverGender $_driverDob",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: context.torkk.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Vehical Info",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: context.torkk.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _vehicleInfo,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.torkk.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Location",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: context.torkk.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${_currentLat.toStringAsFixed(7)}, ${_currentLng.toStringAsFixed(7)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: context.torkk.textSecondary,
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
                                  child: Center(
                                    child: Icon(
                                      Icons.map_rounded,
                                      color: AppColors.slate500,
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
                          Divider(color: context.torkk.border, height: 1),
                          _buildSosOptionTile(
                            title: "Text Emergency Number",
                            onTap: _textEmergency,
                          ),
                          Divider(color: context.torkk.border, height: 1),
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
