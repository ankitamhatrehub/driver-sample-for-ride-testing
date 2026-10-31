/// Typed model for a ride from the driver ride APIs.
///
/// Backend shapes (field names are the JSON keys):
/// - `GET /driver/active-rides` -> `{status, count, rides: [ride]}`
///   ride: id, customer_name, customer_phone, pickup_address, drop_address,
///   pickup_lat/lng, drop_lat/lng, vehicle_type, distance_km,
///   estimated_fare, status.
/// - `GET /driver/ride` -> `{status, ride: detail}`. detail has the same
///   fields plus is_picked_up, is_dropped, transaction_id, upi_id,
///   payment_method.
///
/// The screens still read `Map<String, dynamic>`. [toMap] returns the
/// original JSON with the typed fields written back, so keys the model does
/// not know about are kept. When the backend renames a field, change it in
/// [RideModel.fromJson] only.
class RideModel {
  const RideModel({
    required this.id,
    this.status = '',
    this.customerName = '',
    this.customerPhone = '',
    this.pickupAddress = '',
    this.dropAddress = '',
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng,
    this.vehicleType = '',
    this.distanceKm,
    this.estimatedFare,
    this.paymentMethod = '',
    this.isPickedUp = false,
    this.isDropped = false,
    this.transactionId = '',
    this.upiId = '',
    this.malePassengers,
    this.femalePassengers,
    this.passengerCount,
    this.durationMins,
    this.raw = const {},
  });

  final int id;
  final String status;
  final String customerName;
  final String customerPhone;
  final String pickupAddress;
  final String dropAddress;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropLat;
  final double? dropLng;
  final String vehicleType;
  final double? distanceKm;
  final double? estimatedFare;

  // Detail only.
  final String paymentMethod;
  final bool isPickedUp;
  final bool isDropped;
  final String transactionId;
  final String upiId;

  // Not sent by the ride APIs yet; read when the backend adds them.
  final int? malePassengers;
  final int? femalePassengers;
  final int? passengerCount;
  final int? durationMins;

  /// The JSON this model was built from.
  final Map<String, dynamic> raw;

  /// Accepts the bare ride object or the `{status, ride: {...}}` wrapper.
  factory RideModel.fromResponse(Map<String, dynamic> body) {
    final inner = body['ride'];
    return RideModel.fromJson(inner is Map ? Map<String, dynamic>.from(inner) : body);
  }

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: _int(json['id'] ?? json['ride_id']) ?? 0,
      status: _str(json['status'] ?? json['ride_status']),
      customerName: _str(json['customer_name']),
      customerPhone: _str(json['customer_phone']),
      pickupAddress: _str(json['pickup_address']),
      dropAddress: _str(json['drop_address']),
      pickupLat: _double(json['pickup_lat']),
      pickupLng: _double(json['pickup_lng']),
      dropLat: _double(json['drop_lat']),
      dropLng: _double(json['drop_lng']),
      vehicleType: _str(json['vehicle_type']),
      distanceKm: _double(json['distance_km']),
      estimatedFare: _double(json['estimated_fare']),
      paymentMethod: _str(json['payment_method']),
      isPickedUp: _flag(json['is_picked_up']),
      isDropped: _flag(json['is_dropped']),
      transactionId: _str(json['transaction_id']),
      upiId: _str(json['upi_id']),
      malePassengers: _int(json['male_passengers']),
      femalePassengers: _int(json['female_passengers']),
      passengerCount: _int(json['passenger_count']),
      durationMins: _int(json['duration_mins']),
      raw: Map<String, dynamic>.from(json),
    );
  }

  /// The raw JSON with `id` and `status` normalised and the numeric fields
  /// parsed, so screens can rely on their types.
  Map<String, dynamic> toMap() {
    return {
      ...raw,
      'id': id,
      'status': status,
      if (pickupLat != null) 'pickup_lat': pickupLat,
      if (pickupLng != null) 'pickup_lng': pickupLng,
      if (dropLat != null) 'drop_lat': dropLat,
      if (dropLng != null) 'drop_lng': dropLng,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (estimatedFare != null) 'estimated_fare': estimatedFare,
    };
  }

  bool get isRequested => status == 'requested';
  bool get isAccepted => status == 'accepted';
  bool get isInProgress => status == 'in_progress' || status == 'started';
  bool get isCancelled => status == 'cancelled' || status == 'canceled';
  bool get isCompleted => status == 'completed';

  static String _str(Object? value) => value?.toString().trim() ?? '';

  static double? _double(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static int? _int(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  /// `is_picked_up` / `is_dropped` are int64 (0 or 1) on the backend.
  static bool _flag(Object? value) {
    if (value is bool) return value;
    return (_int(value) ?? 0) != 0;
  }
}
