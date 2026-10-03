/// Typed data model for a driver's profile.
///
/// Replaces raw `Map<String, dynamic>` with compile-time safe fields.
/// Constructed from API JSON via [DriverProfile.fromJson].
class DriverProfile {
  final String phone;
  final String name;
  final String email;
  final double rating;
  final bool isVerified;
  final String profilePhotoUrl;
  final String vehicleType;
  final String gender;
  final String dob;
  final String aadhaarNumber;
  final String panNumber;
  final String drivingLicenceNumber;
  final String rcNumber;
  final String pucNumber;
  final String pucTotalMarks;
  final String insuranceNumber;
  final String bankName;
  final String bankAccountNumber;
  final String bankIfscCode;
  final String bankAccountHolderName;
  final String upiId;
  final bool eligibleForParcels;

  const DriverProfile({
    this.phone = '',
    this.name = '',
    this.email = '',
    this.rating = 5.0,
    this.isVerified = false,
    this.profilePhotoUrl = '',
    this.vehicleType = '',
    this.gender = 'Not specified',
    this.dob = 'Not specified',
    this.aadhaarNumber = '',
    this.panNumber = '',
    this.drivingLicenceNumber = '',
    this.rcNumber = '',
    this.pucNumber = '',
    this.pucTotalMarks = '',
    this.insuranceNumber = '',
    this.bankName = '',
    this.bankAccountNumber = '',
    this.bankIfscCode = '',
    this.bankAccountHolderName = '',
    this.upiId = '',
    this.eligibleForParcels = false,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      phone: (json['phone'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      isVerified: json['is_verified'] == true,
      profilePhotoUrl: (json['profile_photo_url'] ?? '').toString(),
      vehicleType: (json['vehicle_type'] ?? '').toString(),
      gender: (json['gender'] ?? 'Not specified').toString(),
      dob: (json['dob'] ?? 'Not specified').toString(),
      aadhaarNumber: (json['aadhaar_number'] ?? '').toString(),
      panNumber: (json['pan_number'] ?? '').toString(),
      drivingLicenceNumber: (json['driving_licence_number'] ?? '').toString(),
      rcNumber: (json['rc_number'] ?? '').toString(),
      pucNumber: (json['puc_number'] ?? '').toString(),
      pucTotalMarks: (json['puc_total_marks'] ?? '').toString(),
      insuranceNumber: (json['insurance_number'] ?? '').toString(),
      bankName: (json['bank_name'] ?? '').toString(),
      bankAccountNumber: (json['bank_account_number'] ?? '').toString(),
      bankIfscCode: (json['bank_ifsc_code'] ?? '').toString(),
      bankAccountHolderName: (json['bank_account_holder_name'] ?? '').toString(),
      upiId: (json['upi_id'] ?? '').toString(),
      eligibleForParcels: json['eligible_for_parcels'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'name': name,
      'email': email,
      'rating': rating,
      'is_verified': isVerified,
      'profile_photo_url': profilePhotoUrl,
      'vehicle_type': vehicleType,
      'gender': gender,
      'dob': dob,
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
      'eligible_for_parcels': eligibleForParcels,
    };
  }

  /// Creates a copy with selected fields overridden.
  DriverProfile copyWith({
    String? phone,
    String? name,
    String? email,
    double? rating,
    bool? isVerified,
    String? profilePhotoUrl,
    String? vehicleType,
    String? gender,
    String? dob,
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
    bool? eligibleForParcels,
  }) {
    return DriverProfile(
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      rating: rating ?? this.rating,
      isVerified: isVerified ?? this.isVerified,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      panNumber: panNumber ?? this.panNumber,
      drivingLicenceNumber: drivingLicenceNumber ?? this.drivingLicenceNumber,
      rcNumber: rcNumber ?? this.rcNumber,
      pucNumber: pucNumber ?? this.pucNumber,
      pucTotalMarks: pucTotalMarks ?? this.pucTotalMarks,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfscCode: bankIfscCode ?? this.bankIfscCode,
      bankAccountHolderName: bankAccountHolderName ?? this.bankAccountHolderName,
      upiId: upiId ?? this.upiId,
      eligibleForParcels: eligibleForParcels ?? this.eligibleForParcels,
    );
  }
}
