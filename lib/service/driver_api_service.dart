import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rider_app/service/api_client.dart';
import 'package:rider_app/common/constants/app_urls.dart';

class DriverApiService {
  static const String baseUrl = AppUrls.apiBase;

  /// Shared client; adds the Bearer token to every protected request.
  static http.Client get client => apiClient;

  static Future<List<dynamic>> fetchActiveRides({
    required String driverPhone,
    String city = '',
  }) async {
    final uri = Uri.parse(
      AppUrls.activeRides(driverPhone: driverPhone, city: city),
    );
    final response = await apiClient.get(uri).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) return decoded;
      if (decoded is Map) {
        for (final key in const ['rides', 'data', 'results', 'active_rides']) {
          final value = decoded[key];
          if (value is List) return value;
        }
        // Map without a rides list (e.g. {"message": "..."}): treat as no rides.
        debugPrint('[ACTIVE RIDES] Unexpected object response: ${response.body}');
        return [];
      }
      throw Exception('Unexpected active rides response: ${response.body}');
    }
    throw Exception('Failed to fetch active rides: ${response.statusCode}');
  }

  static Future<void> acceptRide({
    required int rideId,
    required String driverPhone,
  }) async {
    final response = await apiClient
        .post(
          Uri.parse(AppUrls.acceptRide),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'ride_id': rideId, 'driver_phone': driverPhone}),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('accept_failed_${response.statusCode}');
    }
  }

  static Future<void> startRide({
    required int rideId,
    required String driverPhone,
  }) async {
    final response = await apiClient
        .post(
          Uri.parse(AppUrls.startRide),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'ride_id': rideId, 'driver_phone': driverPhone}),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('Failed to start ride');
    }
  }

  static Future<void> pickupCustomer({
    required int rideId,
    required String driverPhone,
    required String rideCode,
  }) async {
    debugPrint(
      '[DEBUG PICKUP API] Calling pickup-customer API for ride: $rideId, code: $rideCode',
    );
    final response = await apiClient
        .post(
          Uri.parse(AppUrls.pickupCustomer),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'ride_id': rideId,
            'driver_phone': driverPhone,
            'ride_code': rideCode,
          }),
        )
        .timeout(const Duration(seconds: 5));
    debugPrint('[DEBUG PICKUP API] Response status: ${response.statusCode}');
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
    final response = await apiClient
        .post(
          Uri.parse(AppUrls.completeRide),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'ride_id': rideId,
            'driver_phone': driverPhone,
            'payment_method': paymentMethod,
          }),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['driver_earnings'] as num?)?.toDouble() ?? 0;
    }
    final body = response.body.trim();
    throw Exception(
      body.isNotEmpty
          ? body
          : 'Failed to complete ride (${response.statusCode})',
    );
  }

  /// Tells the backend the drop-off was reached (no timeout, response ignored).
  static Future<void> markReached({required Object? rideId}) async {
    await apiClient.post(
      Uri.parse(AppUrls.reached),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'ride_id': rideId}),
    );
  }

  static Future<void> setPaymentMethod({
    required int rideId,
    required String driverPhone,
    required String paymentMethod,
  }) async {
    final response = await apiClient
        .post(
          Uri.parse(AppUrls.setPaymentMethod),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'ride_id': rideId,
            'driver_phone': driverPhone,
            'payment_method': paymentMethod,
          }),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('Failed to set payment method');
    }
  }

  /// Saves the driver's UPI id as the payment method. No timeout, and the
  /// response is not checked (the caller ignores failures).
  static Future<void> saveUpiPaymentMethod({
    required String phone,
    required String upiId,
  }) async {
    await apiClient.post(
      Uri.parse(AppUrls.setPaymentMethod),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone': phone,
        'payment_method': 'upi',
        'upi_id': upiId,
      }),
    );
  }

  static Future<void> updateLocation({
    required String driverPhone,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await apiClient
          .post(
            Uri.parse(AppUrls.updateLocation),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'phone': driverPhone,
              'latitude': latitude,
              'longitude': longitude,
            }),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) {
        debugPrint(
          'Location update failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Location update failed: $e');
    }
  }

  /// GET /api/driver/wallet/transactions/{transaction_id}
  static Future<Map<String, dynamic>> fetchTransactionDetails(
    String transactionId,
  ) async {
    final uri = Uri.parse(AppUrls.transactionDetails(transactionId));
    final response = await apiClient.get(uri).timeout(const Duration(seconds: 10));
    debugPrint('[TXN DETAILS] ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch transaction details: ${response.statusCode}');
    }
    final decoded = json.decode(response.body);
    if (decoded is Map) {
      for (final key in const ['transaction', 'data', 'details']) {
        final value = decoded[key];
        if (value is Map) return Map<String, dynamic>.from(value);
      }
      return Map<String, dynamic>.from(decoded);
    }
    throw Exception('Unexpected transaction details response');
  }

  /// GET /api/wallet/transaction-history?phone=...
  static Future<List<dynamic>> fetchTransactionHistory(String driverPhone) async {
    final uri = Uri.parse(AppUrls.transactionHistory(driverPhone));
    final response = await apiClient.get(uri).timeout(const Duration(seconds: 10));
    debugPrint('[TXN HISTORY] ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch transaction history: ${response.statusCode}');
    }
    final decoded = json.decode(response.body);
    if (decoded is List) return decoded;
    if (decoded is Map) {
      for (final key in const ['transactions', 'history', 'data', 'results']) {
        final value = decoded[key];
        if (value is List) return value;
      }
      return [];
    }
    throw Exception('Unexpected transaction history response');
  }

  /// GET /api/driver/orders?type=current|completed|cancelled|scheduled
  static Future<List<Map<String, dynamic>>> fetchOrders({required String type}) async {
    final uri = Uri.parse(AppUrls.driverOrders(type: type));
    final response = await apiClient.get(uri).timeout(const Duration(seconds: 10));
    debugPrint('[ORDERS $type] ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch orders: ${response.statusCode}');
    }
    final decoded = json.decode(response.body);
    Object? list = decoded;
    if (decoded is Map) {
      list = null;
      for (final key in const ['orders', 'data', 'results', 'trips']) {
        if (decoded[key] is List) {
          list = decoded[key];
          break;
        }
      }
    }
    if (list is! List) return [];
    return [
      for (final item in list)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }

  /// GET /api/driver/orders/{id}?type=ride|parcel
  static Future<Map<String, dynamic>> fetchOrderDetail({
    required Object id,
    required String type,
  }) async {
    final uri = Uri.parse(AppUrls.driverOrderDetail(id: id, type: type));
    final response = await apiClient.get(uri).timeout(const Duration(seconds: 10));
    debugPrint('[ORDER DETAIL $type/$id] ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch order details: ${response.statusCode}');
    }
    final decoded = json.decode(response.body);
    if (decoded is Map) {
      for (final key in const ['order', 'data', 'details']) {
        final value = decoded[key];
        if (value is Map) return Map<String, dynamic>.from(value);
      }
      return Map<String, dynamic>.from(decoded);
    }
    throw Exception('Unexpected order details response');
  }

  /// PUT /api/driver/profile/contact  { "email": ... }
  /// Throws an Exception with the server message on failure.
  static Future<void> updateEmail(String email) async {
    print('DriverApiService.updateEmail called with email: $email');
    final response = await apiClient
        .put(
          Uri.parse(AppUrls.updateContact),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email}),
        )
        .timeout(const Duration(seconds: 10));
        print('DriverApiService.updateEmail response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 204) return;
    var message = 'Failed to update email (${response.statusCode})';
    try {
      final body = json.decode(response.body);
      if (body is Map) {
        final m = body['message'] ?? body['error'] ?? body['detail'];
        if (m != null && m.toString().isNotEmpty) message = m.toString();
      }
    } catch (_) {}
    throw Exception(message);
  }

  static Future<List<dynamic>> fetchTrips(String driverPhone) async {
    debugPrint('[DEBUG FETCH TRIPS] Fetching trips for driver: $driverPhone');
    final uri = Uri.parse(AppUrls.driverTrips(driverPhone));
    debugPrint('[DEBUG FETCH TRIPS] Request URI: $uri');

    final response = await apiClient.get(uri).timeout(const Duration(seconds: 5));
    debugPrint('[DEBUG FETCH TRIPS] Response status: ${response.statusCode}');
    debugPrint('[DEBUG FETCH TRIPS] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final trips = data['trips'] ?? [];
      debugPrint('[DEBUG FETCH TRIPS] Parsed ${trips.length} trips');

      // Count Davangere trips
      int davanagereCount = 0;
      for (var trip in trips) {
        final pickup = trip['pickup_address']?.toString().toLowerCase() ?? '';
        final drop = trip['drop_address']?.toString().toLowerCase() ?? '';
        if (pickup.contains('davangere') || drop.contains('davangere')) {
          davanagereCount++;
          debugPrint(
            '[DEBUG FETCH TRIPS] Davangere trip found - ID: ${trip['id']}, Pickup: ${trip['pickup_address']}, Drop: ${trip['drop_address']}',
          );
        }
      }
      debugPrint('[DEBUG FETCH TRIPS] Total Davangere trips: $davanagereCount');

      return trips;
    }
    debugPrint(
      '[DEBUG FETCH TRIPS] ERROR: Failed with status ${response.statusCode}',
    );
    throw Exception('Failed to fetch trips');
  }

  static Future<Map<String, dynamic>> fetchEarnings(String driverPhone) async {
    debugPrint(
      '[DEBUG FETCH EARNINGS] Fetching earnings for driver: $driverPhone',
    );
    final uri = Uri.parse(AppUrls.driverEarnings(driverPhone));
    debugPrint('[DEBUG FETCH EARNINGS] Request URI: $uri');

    final response = await apiClient.get(uri).timeout(const Duration(seconds: 5));
    debugPrint(
      '[DEBUG FETCH EARNINGS] Response status: ${response.statusCode}',
    );
    debugPrint('[DEBUG FETCH EARNINGS] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint(
        '[DEBUG FETCH EARNINGS] Today: ${data['today_earnings']}, Total: ${data['total_earnings']}, Recent trips: ${data['recent_trips']?.length ?? 0}',
      );
      return data;
    }
    throw Exception('Failed to fetch earnings');
  }

  static Future<Map<String, dynamic>> fetchWallet(String driverPhone) async {
    final response = await apiClient
        .get(Uri.parse(AppUrls.driverWallet(driverPhone)))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch wallet');
  }

  static Future<Map<String, dynamic>> fetchProfile(String driverPhone) async {
    final response = await apiClient
        .get(Uri.parse(AppUrls.driverProfile(driverPhone)))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch profile');
  }

  static Future<Map<String, dynamic>> fetchDriverProfile(String driverPhone) =>
      fetchProfile(driverPhone);

  static Future<Map<String, dynamic>> fetchRideDetail({
    required int rideId,
    required String driverPhone,
  }) async {
    final response = await apiClient
        .get(
          Uri.parse(
            AppUrls.rideDetail(rideId: rideId, driverPhone: driverPhone),
          ),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch ride detail');
  }

  /// Raw ride-detail response (no timeout, status not checked) for callers
  /// that handle non-200 replies themselves.
  static Future<http.Response> fetchRideDetailResponse({
    required int rideId,
    required String driverPhone,
  }) {
    return apiClient.get(
      Uri.parse(AppUrls.rideDetail(rideId: rideId, driverPhone: driverPhone)),
    );
  }

  static Future<String> uploadProfilePhoto({
    required String driverPhone,
    required String base64Image,
  }) async {
    final response = await apiClient
        .post(
          Uri.parse(AppUrls.uploadProfilePhoto),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'phone': driverPhone, 'image_data': base64Image}),
        )
        .timeout(const Duration(seconds: 15));

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
    debugPrint('Updating vehicle type for $driverPhone to $vehicleType');
    final response = await apiClient
        .post(
          Uri.parse(AppUrls.updateVehicleType),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'phone': driverPhone,
            'vehicle_type': vehicleType,
          }),
        )
        .timeout(const Duration(seconds: 10));
    debugPrint(
      'Update vehicle type response: ${response.statusCode} - ${response.body}',
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update vehicle type: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<void> updateProfile({
    required String phone,
    String? name,
    String? email,
    String? vehicleType,
    String? aadhaarNumber,
    String? panNumber,
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
    final response = await apiClient
        .post(
          Uri.parse(AppUrls.updateProfile),
          headers: {'Content-Type': 'application/json'},
          
          body: json.encode({
            'phone': phone,
            'name': name,
            'email': email,
            'vehicle_type': vehicleType,
            'aadhaar_number': aadhaarNumber,
            'pan_number': panNumber,
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
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }
}
