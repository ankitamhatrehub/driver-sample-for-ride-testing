/// Typed model for the driver Orders APIs.
///
/// - `GET /driver/orders?type=` -> `{status, type, count, data: [order]}`
///   order: order_id, order_type, status, amount, payment_method,
///   created_at, pickup_address, drop_address, distance_km, vehicle_type,
///   parcel_type, weight_kg.
/// - `GET /driver/orders/{id}?type=` -> `{status, data: detail}`. detail adds
///   receiver_name, male_passengers, female_passengers, the parcel fields and
///   the fare breakup (base_fare ... total_fare, driver_earnings).
///
/// One class covers both, because the list item is a subset of the detail.
/// [toMap] gives the keys the Orders screens read, so a backend rename is
/// fixed in [DriverOrderModel.fromJson] and [toMap] only.
class DriverOrderModel {
  const DriverOrderModel({
    required this.orderId,
    this.orderType = 'ride',
    this.status = '',
    this.createdAt,
    this.pickupAddress = '',
    this.dropAddress = '',
    this.distanceKm,
    this.vehicleType = '',
    this.paymentMethod = '',
    this.paymentStatus = '',
    this.amount,
    this.receiverName = '',
    this.malePassengers = 0,
    this.femalePassengers = 0,
    this.parcelType = '',
    this.weightKg,
    this.estimatedFare,
    this.driverEarnings,
    this.baseFare,
    this.distanceCharge,
    this.weightCharge,
    this.sizeCharge,
    this.additionalFees,
    this.discount,
    this.coinsUsed,
    this.totalFare,
  });

  final String orderId;

  /// `ride` or `parcel`.
  final String orderType;
  final String status;
  final DateTime? createdAt;
  final String pickupAddress;
  final String dropAddress;
  final double? distanceKm;
  final String vehicleType;
  final String paymentMethod;
  final String paymentStatus;

  /// List only.
  final double? amount;

  // Detail only.
  final String receiverName;
  final int malePassengers;
  final int femalePassengers;
  final String parcelType;
  final double? weightKg;
  final double? estimatedFare;
  final double? driverEarnings;
  final double? baseFare;
  final double? distanceCharge;
  final double? weightCharge;
  final double? sizeCharge;
  final double? additionalFees;
  final double? discount;
  final int? coinsUsed;
  final double? totalFare;

  bool get isParcel => orderType.toLowerCase() == 'parcel';
  int get passengers => malePassengers + femalePassengers;

  /// Accepts the item itself or the `{status, data: {...}}` wrapper.
  factory DriverOrderModel.fromResponse(Map<String, dynamic> body) {
    final inner = body['data'];
    return DriverOrderModel.fromJson(inner is Map ? Map<String, dynamic>.from(inner) : body);
  }

  factory DriverOrderModel.fromJson(Map<String, dynamic> json) {
    return DriverOrderModel(
      orderId: _str(json['order_id'] ?? json['id']),
      orderType: _str(json['order_type']).isEmpty ? 'ride' : _str(json['order_type']),
      status: _str(json['status']),
      createdAt: DateTime.tryParse(_str(json['created_at']))?.toLocal(),
      pickupAddress: _str(json['pickup_address']),
      dropAddress: _str(json['drop_address']),
      distanceKm: _double(json['distance_km']),
      vehicleType: _str(json['vehicle_type']),
      paymentMethod: _str(json['payment_method']),
      paymentStatus: _str(json['payment_status']),
      amount: _double(json['amount']),
      receiverName: _str(json['receiver_name']),
      malePassengers: _int(json['male_passengers']) ?? 0,
      femalePassengers: _int(json['female_passengers']) ?? 0,
      parcelType: _str(json['parcel_type']),
      weightKg: _double(json['weight_kg']),
      estimatedFare: _double(json['estimated_fare']),
      driverEarnings: _double(json['driver_earnings']),
      baseFare: _double(json['base_fare']),
      distanceCharge: _double(json['distance_charge']),
      weightCharge: _double(json['weight_charge']),
      sizeCharge: _double(json['size_charge']),
      additionalFees: _double(json['additional_fees']),
      discount: _double(json['discount']),
      coinsUsed: _int(json['coins_used']),
      totalFare: _double(json['total_fare']),
    );
  }

  /// Keys read by `orders_screen.dart`, its card and `order_details_screen.dart`.
  /// Values the API does not send are left out so the screens' own fallbacks apply.
  Map<String, dynamic> toMap() {
    final otherCharges = (distanceCharge ?? 0) + (weightCharge ?? 0) + (sizeCharge ?? 0) + (additionalFees ?? 0);
    final fare = amount ?? totalFare ?? estimatedFare;
    return {
      'id': orderId,
      'order_id': orderId,
      'order_type': orderType,
      'is_parcel': isParcel,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'pickup_address': pickupAddress,
      'drop_address': dropAddress,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (vehicleType.isNotEmpty) 'vehicle_type': vehicleType,
      if (paymentMethod.isNotEmpty) 'payment_method': paymentMethod,
      if (paymentStatus.isNotEmpty) 'payment_status': paymentStatus,
      if (fare != null) 'fare': fare,
      if ((driverEarnings ?? 0) > 0) 'driver_earnings': driverEarnings,
      if (receiverName.isNotEmpty) 'customer_name': receiverName,
      if (passengers > 0) ...{
        'passenger_count': passengers,
        'passengers': passengers,
        'male_passengers': malePassengers,
        'female_passengers': femalePassengers,
      },
      if (parcelType.isNotEmpty) 'item_category': parcelType,
      if (weightKg != null) 'item_weight': '${_trim(weightKg!)} kg',
      if (baseFare != null) 'base_fare': baseFare,
      if (discount != null) 'discount': discount,
      if (otherCharges > 0) 'other_charges': otherCharges,
      if (totalFare != null) 'total_fare': totalFare,
    };
  }

  static String _trim(double value) => value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

  static String _str(Object? value) => value?.toString().trim() ?? '';

  static double? _double(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static int? _int(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
