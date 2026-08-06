import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../common/constants/api_constants.dart';

class DriverApiService {
  static const String baseUrl = '${ApiConstants.baseUrl}/api';

  static Future<List<dynamic>> fetchActiveRides({
    required String driverPhone,
    String city = '',
  }) async {
    final uri = Uri.parse(
      '$baseUrl/driver/active-rides?driver_phone=${Uri.encodeComponent(driverPhone)}&city=${Uri.encodeComponent(city)}',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to fetch active rides: ${response.statusCode}');
  }

  static Future<void> acceptRide({
    required int rideId,
    required String driverPhone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/driver/accept-ride'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'ride_id': rideId, 'driver_phone': driverPhone}),
    ).timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('accept_failed_${response.statusCode}');
    }
  }

  static Future<void> startRide({
    required int rideId,
    required String driverPhone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/driver/start-ride'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'ride_id': rideId, 'driver_phone': driverPhone}),
    ).timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('Failed to start ride');
    }
  }

  static Future<void> pickupCustomer({
    required int rideId,
    required String driverPhone,
    required String rideCode,
  }) async {
    print('[DEBUG PICKUP API] Calling pickup-customer API for ride: $rideId, code: $rideCode');
    final response = await http.post(
      Uri.parse('$baseUrl/driver/pickup-customer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'ride_id': rideId, 'driver_phone': driverPhone, 'ride_code': rideCode}),
    ).timeout(const Duration(seconds: 5));
    print('[DEBUG PICKUP API] Response status: ${response.statusCode}');
    if (response.statusCode != 200) {
      String message = 'Failed to update pickup status';
      try {
        final data = json.decode(response.body);
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  static Future<double> completeRide({
    required int rideId,
    required String driverPhone,
    String paymentMethod = 'cash',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/driver/complete-ride'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'ride_id': rideId,
        'driver_phone': driverPhone,
        'payment_method': paymentMethod,
      }),
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['driver_earnings'] as num?)?.toDouble() ?? 0;
    }
    final body = response.body.trim();
    throw Exception(body.isNotEmpty ? body : 'Failed to complete ride (${response.statusCode})');
  }

  static Future<void> setPaymentMethod({
    required int rideId,
    required String driverPhone,
    required String paymentMethod,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/driver/set-payment-method'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'ride_id': rideId,
        'driver_phone': driverPhone,
        'payment_method': paymentMethod,
      }),
    ).timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('Failed to set payment method');
    }
  }

  static Future<void> updateLocation({
    required String driverPhone,
    required double latitude,
    required double longitude,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/driver/update-location'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone': driverPhone,
        'latitude': latitude,
        'longitude': longitude,
      }),
    ).timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('Failed to update location');
    }
  }

  static Future<List<dynamic>> fetchTrips(String driverPhone) async {
    print('[DEBUG FETCH TRIPS] Fetching trips for driver: $driverPhone');
    final uri = Uri.parse('$baseUrl/driver/trips?phone=${Uri.encodeComponent(driverPhone)}');
    print('[DEBUG FETCH TRIPS] Request URI: $uri');
    
    final response = await http.get(uri).timeout(const Duration(seconds: 5));
    print('[DEBUG FETCH TRIPS] Response status: ${response.statusCode}');
    print('[DEBUG FETCH TRIPS] Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final trips = data['trips'] ?? [];
      print('[DEBUG FETCH TRIPS] Parsed ${trips.length} trips');
      
      // Count Davangere trips
      int davanagereCount = 0;
      for (var trip in trips) {
        final pickup = trip['pickup_address']?.toString().toLowerCase() ?? '';
        final drop = trip['drop_address']?.toString().toLowerCase() ?? '';
        if (pickup.contains('davangere') || drop.contains('davangere')) {
          davanagereCount++;
          print('[DEBUG FETCH TRIPS] Davangere trip found - ID: ${trip['id']}, Pickup: ${trip['pickup_address']}, Drop: ${trip['drop_address']}');
        }
      }
      print('[DEBUG FETCH TRIPS] Total Davangere trips: $davanagereCount');
      
      return trips;
    }
    print('[DEBUG FETCH TRIPS] ERROR: Failed with status ${response.statusCode}');
    throw Exception('Failed to fetch trips');
  }

  static Future<Map<String, dynamic>> fetchEarnings(String driverPhone) async {
    print('[DEBUG FETCH EARNINGS] Fetching earnings for driver: $driverPhone');
    final uri = Uri.parse('$baseUrl/driver/earnings?phone=${Uri.encodeComponent(driverPhone)}');
    print('[DEBUG FETCH EARNINGS] Request URI: $uri');
    
    final response = await http.get(uri).timeout(const Duration(seconds: 5));
    print('[DEBUG FETCH EARNINGS] Response status: ${response.statusCode}');
    print('[DEBUG FETCH EARNINGS] Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('[DEBUG FETCH EARNINGS] Today: ${data['today_earnings']}, Total: ${data['total_earnings']}, Recent trips: ${data['recent_trips']?.length ?? 0}');
      return data;
    }
    throw Exception('Failed to fetch earnings');
  }

  static Future<Map<String, dynamic>> fetchWallet(String driverPhone) async {
    final response = await http.get(
      Uri.parse('$baseUrl/driver/wallet?phone=${Uri.encodeComponent(driverPhone)}'),
    ).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch wallet');
  }

  static Future<Map<String, dynamic>> fetchProfile(String driverPhone) async {
    final response = await http.get(
      Uri.parse('$baseUrl/driver/profile?phone=${Uri.encodeComponent(driverPhone)}'),
    ).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch profile');
  }

  static Future<Map<String, dynamic>> fetchRideDetail({
    required int rideId,
    required String driverPhone,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/driver/ride?ride_id=$rideId&driver_phone=${Uri.encodeComponent(driverPhone)}'),
    ).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch ride detail');
  }

  static Future<String> uploadProfilePhoto({
    required String driverPhone,
    required String base64Image,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/driver/upload-profile-photo'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone': driverPhone,
        'image_data': base64Image,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['profile_photo_url'] ?? '';
    }
    throw Exception('Failed to upload profile photo: ${response.statusCode}');
  }

  static Future<void> updateVehicleType({
    required String driverPhone,
    required String vehicleType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/driver/update-vehicle-type'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone': driverPhone,
        'vehicle_type': vehicleType,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to update vehicle type: ${response.statusCode}');
    }
  }

  static Future<void> updateProfile({
    required String phone,
    String? name,
    String? email,
    String? vehicleType,
    String? aadhaarNumber,
    String? drivingLicenceNumber,
    String? rcNumber,
    String? pucNumber,
    String? pucTotalMarks,
    String? insuranceNumber,
    String? bankName,
    String? bankAccountNumber,
    String? bankIfscCode,
    String? bankAccountHolderName,
    String? upiId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/driver/update-profile'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone': phone,
        'name': name,
        'email': email,
        'vehicle_type': vehicleType,
        'aadhaar_number': aadhaarNumber,
        'driving_licence_number': drivingLicenceNumber,
        'rc_number': rcNumber,
        'puc_number': pucNumber,
        'puc_total_marks': pucTotalMarks,
        'insurance_number': insuranceNumber,
        'bank_name': bankName,
        'bank_account_number': bankAccountNumber,
        'bank_ifsc_code': bankIfscCode,
        'bank_account_holder_name': bankAccountHolderName,
        'upi_id': upiId,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }
}
