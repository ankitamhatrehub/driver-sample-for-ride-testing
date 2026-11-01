/// Centralized repository of all API and external URLs used in the application.
class AppUrls {
  AppUrls._();

  // ---------------------------------------------------------------------------
  // Base Configurations
  // ---------------------------------------------------------------------------
  static const String baseUrl = 'http://3.110.156.16:8080';
  static const String apiBase = '$baseUrl/api';

  /// Converts the HTTP/HTTPS [baseUrl] to WS/WSS format for WebSocket connections.
  static String get wsBase => baseUrl
      .replaceFirst('http://', 'ws://')
      .replaceFirst('https://', 'wss://');

  /// Gemini API Key passed via `--dart-define=GEMINI_API_KEY=...`
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  // ---------------------------------------------------------------------------
  // Authentication & Verification Endpoints
  // ---------------------------------------------------------------------------
  static const String sendOtp = '$apiBase/auth/send-otp';
  static const String verifyOtp = '$apiBase/driver/auth/verify-otp';

  static const String verifyAadhaar = '$apiBase/driver/verify-aadhaar';
  static const String verifyDl = '$apiBase/driver/verify-dl';
  static const String verifyRc = '$apiBase/driver/verify-rc';

  // ---------------------------------------------------------------------------
  // DigiLocker KYC Endpoints
  // ---------------------------------------------------------------------------
  static const String digilockerStart = '$apiBase/kyc/driver/digilocker/start';
  static const String digilockerDownload =
      '$apiBase/kyc/driver/digilocker/fetch';

  // ---------------------------------------------------------------------------
  // Driver Registration & Profile Endpoints
  // ---------------------------------------------------------------------------
  static const String driverRegister = '$apiBase/driver/register';
  static const String updateProfile = '$apiBase/driver/profile'; // remaining
  static const String driverSchedule = '$apiBase/driver/schedule';
  static const String bankDetails = '$apiBase/driver/bank-details';
  static const String chatMessage = '$apiBase/chat/message';
  static String chatHistory(String conversationId) =>
      '$apiBase/chat/${Uri.encodeComponent(conversationId)}/history';
  static const String updateContact = '$apiBase/driver/profile/contact';
  static const String updateVehicleType = '$apiBase/driver/update-vehicle';
  static const String uploadProfilePhoto = '$apiBase/driver/upload-profile-photo';
  static const String updateLocation = '$apiBase/driver/update-location';
  static const String onlineStatus = '$apiBase/driver/online-status';
  static const String reportIssue = '$apiBase/driver/report-issue';

  static String driverProfile(String phone) =>
      '$apiBase/driver/profile?phone=${Uri.encodeComponent(phone)}';

  static String driverWallet(String phone) =>
      '$apiBase/driver/wallet?phone=${Uri.encodeComponent(phone)}';

  static String driverEarnings(String phone) =>
      '$apiBase/driver/earnings?phone=${Uri.encodeComponent(phone)}';

  static String driverTrips(String phone) =>
      '$apiBase/driver/trips?phone=${Uri.encodeComponent(phone)}';

  /// `type`: current | completed | cancelled | scheduled.
  static String driverOrders({required String type}) =>
      '$apiBase/driver/orders?type=${Uri.encodeComponent(type)}';

  /// `type`: ride | parcel.
  static String driverOrderDetail({required Object id, required String type}) =>
      '$apiBase/driver/orders/${Uri.encodeComponent(id.toString())}?type=${Uri.encodeComponent(type)}';

  static String transactionDetails(String transactionId) =>
      '$apiBase/driver/wallet/transactions/${Uri.encodeComponent(transactionId)}';

  static String transactionHistory(String phone) =>
      '$apiBase/driver/wallet/transactions?phone=${Uri.encodeComponent(phone)}';

  // ---------------------------------------------------------------------------
  // Ride Management Endpoints
  // ---------------------------------------------------------------------------
  static const String acceptRide = '$apiBase/driver/accept-ride';
  static const String startRide = '$apiBase/driver/start-ride';
  static const String pickupCustomer = '$apiBase/driver/pickup-customer';
  static const String completeRide = '$apiBase/driver/complete-ride';
  static const String reached = '$apiBase/driver/reached';
  static const String setPaymentMethod = '$apiBase/driver/set-payment-method';

  static String activeRides({required String driverPhone, String city = ''}) {
    if (city.isEmpty) {
      return '$apiBase/driver/active-rides?driver_phone=${Uri.encodeComponent(driverPhone)}';
    }
    return '$apiBase/driver/active-rides?driver_phone=${Uri.encodeComponent(driverPhone)}&city=${Uri.encodeComponent(city)}';
  }

  static String rideDetail({
    required int rideId,
    required String driverPhone,
  }) =>
      '$apiBase/driver/ride?ride_id=$rideId&driver_phone=${Uri.encodeComponent(driverPhone)}';

  // ---------------------------------------------------------------------------
  // FCM & Push Notifications
  // ---------------------------------------------------------------------------
  static const String fcmToken = '$apiBase/fcm-token';

  // ---------------------------------------------------------------------------
  // Realtime WebSocket Endpoints
  // ---------------------------------------------------------------------------
  static String chatWebSocket({
    required String phone,
    String rideId = '0',
  }) =>
      '$wsBase/ws/chat?phone=${Uri.encodeComponent(phone)}&ride_id=$rideId';

  // ---------------------------------------------------------------------------
  // Third-Party & External Services
  // ---------------------------------------------------------------------------
  static String geminiGenerateContent(String apiKey) =>
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$apiKey';

  static String googleReverseGeocode({
    required double lat,
    required double lng,
    required String apiKey,
  }) =>
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$lat,$lng&key=$apiKey';

  static String googleDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String apiKey,
  }) =>
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$originLat,$originLng'
      '&destination=$destLat,$destLng'
      '&mode=driving'
      '&key=$apiKey';

  static String osrmRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) =>
      'https://router.project-osrm.org/route/v1/driving/'
      '$originLng,$originLat;'
      '$destLng,$destLat'
      '?overview=full&geometries=polyline';

  static String googleMapsNavigation({
    required double destLat,
    required double destLng,
  }) =>
      'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=driving';

  static String googleMapsSearch({
    required double lat,
    required double lng,
  }) =>
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

  static String upiQrCode({
    required String upiAddress,
    required String customerName,
    required dynamic amount,
  }) =>
      'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=upi://pay?pa=$upiAddress&pn=${Uri.encodeComponent(customerName)}&am=$amount&cu=INR';
}

/// Alias for developers preferring `ApiUrls`
typedef ApiUrls = AppUrls;
