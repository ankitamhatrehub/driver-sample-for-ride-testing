/// Typed data model for a ride request / active ride.
///
/// Replaces raw `Map<String, dynamic>` used in home screen ride lists,
/// navigation screen, and trip summary.
class RideModel {
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
  final double? fare;
  final double? distance;
  final String? vehicleType;
  final String? paymentMethod;
  final String? rideCode;
  final String? driverPhone;
  final DateTime? createdAt;

  // Parcel Specific Fields
  final bool isParcel;
  final String? itemCategory;
  final String? itemWeight;
  final String? itemNotes;
  final String? senderName;
  final String? senderPhone;
  final String? receiverName;
  final String? receiverPhone;

  const RideModel({
    required this.id,
    this.status = '',
    this.customerName = 'Customer',
    this.customerPhone = '',
    this.pickupAddress = '',
    this.dropAddress = '',
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng,
    this.fare,
    this.distance,
    this.vehicleType,
    this.paymentMethod,
    this.rideCode,
    this.driverPhone,
    this.createdAt,
    this.isParcel = false,
    this.itemCategory,
    this.itemWeight,
    this.itemNotes,
    this.senderName,
    this.senderPhone,
    this.receiverName,
    this.receiverPhone,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    // Resolve customer name from multiple possible keys
    final name = (json['customer_name'] ??
            json['user_name'] ??
            json['passenger_name'] ??
            json['name'] ??
            '')
        .toString()
        .trim();

    // Resolve customer phone from multiple possible keys
    final phone = (json['customer_phone'] ??
            json['user_phone'] ??
            json['phone'] ??
            json['rider_phone'] ??
            '')
        .toString();

    return RideModel(
      id: _parseInt(json['id']) ?? 0,
      status: (json['status'] ?? json['ride_status'] ?? '').toString(),
      customerName: name.isNotEmpty ? name : 'Customer',
      customerPhone: phone,
      pickupAddress: (json['pickup_address'] ?? json['pickup'] ?? '').toString(),
      dropAddress: (json['drop_address'] ?? json['drop'] ?? '').toString(),
      pickupLat: _parseDouble(json['pickup_lat']),
      pickupLng: _parseDouble(json['pickup_lng']),
      dropLat: _parseDouble(json['drop_lat']),
      dropLng: _parseDouble(json['drop_lng']),
      fare: _parseDouble(json['fare'] ?? json['amount'] ?? json['driver_earnings']),
      distance: _parseDouble(json['distance'] ?? json['ride_distance']),
      vehicleType: json['vehicle_type']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      rideCode: json['ride_code']?.toString(),
      driverPhone: json['driver_phone']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      isParcel: json['is_parcel'] == true || json['service_type'] == 'parcel',
      itemCategory: json['item_category']?.toString(),
      itemWeight: json['item_weight']?.toString(),
      itemNotes: json['item_notes']?.toString(),
      senderName: json['sender_name']?.toString() ?? name,
      senderPhone: json['sender_phone']?.toString() ?? phone,
      receiverName: json['receiver_name']?.toString(),
      receiverPhone: json['receiver_phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'pickup_address': pickupAddress,
      'drop_address': dropAddress,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'drop_lat': dropLat,
      'drop_lng': dropLng,
      'fare': fare,
      'distance': distance,
      'vehicle_type': vehicleType,
      'payment_method': paymentMethod,
      'ride_code': rideCode,
      'driver_phone': driverPhone,
      'created_at': createdAt?.toIso8601String(),
      'is_parcel': isParcel,
      'item_category': itemCategory,
      'item_weight': itemWeight,
      'item_notes': itemNotes,
      'sender_name': senderName,
      'sender_phone': senderPhone,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
    };
  }

  bool get isRequested => status == 'requested';
  bool get isAccepted => status == 'accepted';
  bool get isInProgress => status == 'in_progress' || status == 'started';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
