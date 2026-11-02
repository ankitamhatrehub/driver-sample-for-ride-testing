import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/service/driver_api_service.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
part 'driver_history_screen_sections.dart';

bool _photoStartsWithHttp(String path) => path.startsWith('http');

// --- DRIVER COMPLETED TRIP HISTORY SCREEN ---
class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  bool _loading = true;
  List<dynamic> _completedTrips = [];
  String? _profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final photo =
        prefs.getString('profile_photo') ??
        prefs.getString('profile_photo_url') ??
        '';
    final phone =
        prefs.getString('user_phone') ?? prefs.getString('phone') ?? '';

    if (mounted) {
      setState(() {
        _profilePhotoUrl = photo;
      });
    }

    if (phone.isNotEmpty) {
      try {
        final trips = await DriverApiService.fetchTrips(phone);
        if (mounted) {
          setState(() {
            _completedTrips = trips;
            _loading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _loading = false);
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trips = _completedTrips;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = context.torkk.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP BAR (Close button, "All Trips" title, Profile avatar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
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
                    'All Trips',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.profile),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1D4ED8),
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            _profilePhotoUrl != null &&
                                _profilePhotoUrl!.isNotEmpty
                            ? (_photoStartsWithHttp(_profilePhotoUrl!)
                                  ? Image.network(
                                      _profilePhotoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, error, stackTrace) =>
                                          Icon(
                                            Icons.person,
                                            color: context.torkk.textSecondary,
                                          ),
                                    )
                                  : Image.file(
                                      File(_profilePhotoUrl!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, error, stackTrace) =>
                                          Icon(
                                            Icons.person,
                                            color: context.torkk.textSecondary,
                                          ),
                                    ))
                            : Icon(
                                Icons.person,
                                color: context.torkk.textSecondary,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SECTION HEADER: "All Trips and Activities"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'All Trips and Activities',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),

            // LIST OF TRIPS
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : trips.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.directions_car_outlined,
                            size: 48,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No trips completed yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.torkk.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Your completed ride history will appear here.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: trips.length,
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (context, index) {
                        return _buildTripTile(
                          context,
                          trips[index] as Map<String, dynamic>,
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
