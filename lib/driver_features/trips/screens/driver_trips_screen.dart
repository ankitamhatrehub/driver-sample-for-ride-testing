import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/service/driver_api_service.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
part 'driver_trips_screen_sections.dart';

// --- DRIVER TRIP HISTORY SCREEN ---
class DriverTripsScreen extends StatefulWidget {
  const DriverTripsScreen({
    super.key,
    this.parcelsOnly = false,
    this.title = 'Trip Activity History',
  });

  final bool parcelsOnly;
  final String title;

  @override
  State<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {
  bool _loading = true;
  List<dynamic> _trips = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone') ?? '';

    if (phone.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Driver phone not found. Please log in again.';
      });
      return;
    }
    try {
      final trips = await DriverApiService.fetchTrips(phone);
      if (mounted) {
        setState(() {
          _trips = trips;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load trips: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.parcelsOnly
        ? _trips.where(
            (t) => t['is_parcel'] == true || t['service_type'] == 'parcel',
          )
        : _trips;
    final completedRides = source
        .where((t) => t['status'] == 'completed')
        .toList();
    final cancelledRides = source
        .where((t) => t['status'] == 'cancelled' || t['status'] == 'rejected')
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.torkk.surfaceMuted,
        appBar: AppBar(
          title: Text(
            widget.parcelsOnly ? 'Parcels' : widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: context.torkk.background,
          foregroundColor: context.themed(
            light: Colors.black,
            dark: context.torkk.textSecondary,
          ),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF4F46E5),
            unselectedLabelColor: Colors.black54,
            indicatorColor: Color(0xFF4F46E5),
            tabs: [
              Tab(
                text: 'Completed',
                icon: Icon(Icons.check_circle_outline_rounded, size: 20),
              ),
              Tab(
                text: 'Cancelled',
                icon: Icon(Icons.cancel_outlined, size: 20),
              ),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTrips,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : TabBarView(
                children: [
                  _buildTripList(completedRides),
                  _buildTripList(cancelledRides),
                ],
              ),
      ),
    );
  }
}
