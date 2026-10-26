import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/driver_features/onboarding/kyc_resume.dart';
import 'package:rider_app/driver_features/onboarding/screens/application_status_screen.dart';
import 'package:rider_app/driver_features/onboarding/screens/bank_payout_screen.dart';
import 'package:rider_app/service/driver_api_service.dart';
import 'package:rider_app/service/fcm_service.dart';

/// Shared onboarding data for the route-based flow.
class OnboardingSession extends ChangeNotifier {
  OnboardingSession._();

  static final OnboardingSession instance = OnboardingSession._();

  /// Set by [DriverApp]. Gender changes here have no [BuildContext].
  void Function(bool isPink)? publishAccent;

  final phone = TextEditingController();
  final otp = TextEditingController();
  final otpFocus = FocusNode();
  final name = TextEditingController();
  final dob = TextEditingController();
  final email = TextEditingController();
  final aadhaar = TextEditingController();
  final dlNumber = TextEditingController();
  final rcNumber = TextEditingController();
  final bankHolder = TextEditingController();
  final bankAccount = TextEditingController();
  final bankIfsc = TextEditingController();
  final bankName = TextEditingController();

  String gender = AppStrings.genderMale;
  String vehicleType = 'Bike';
  String? photoPath;
  bool termsAccepted = false;
  bool vehicleChosen = false;
  bool loading = false;
  bool otpError = false;
  bool announceOtp = false;
  int otpCountdown = 30;
  String? receivedOtp;

  bool aadhaarVerified = false;
  bool dlVerified = false;
  bool rcVerified = false;
  bool photosVerified = false;
  bool faceVerified = false;
  bool bankVerified = false;
  bool playDigilockerSuccess = false;
  String panNumber = '';

  bool returnToReview = false;
  String reviewEntry = '';
  DateTime? submittedAt;
  ApplicationOutcome outcome = ApplicationOutcome.underReview;

  String? token;
  String? digilockerClientId;
  String? digilockerUrl;

  Timer? _otpTimer;

  void touch() => notifyListeners();

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token') ?? prefs.getString('token');
    final saved = await KycResume.progress();
    aadhaarVerified = saved.aadhaar;
    dlVerified = saved.drivingLicence;
    rcVerified = saved.rc;
    photosVerified = saved.vehiclePhotos;
    faceVerified = saved.face;
    bankVerified = saved.bank;
    notifyListeners();
  }

  Future<void> rememberKyc() {
    return KycResume.saveProgress(
      KycProgress(
        aadhaar: aadhaarVerified,
        drivingLicence: dlVerified,
        rc: rcVerified,
        vehiclePhotos: photosVerified,
        face: faceVerified,
        bank: bankVerified,
      ),
    );
  }

  void rememberBank(BankPayoutDetails details) {
    bankHolder.text = details.holderName;
    bankAccount.text = details.accountNumber;
    bankIfsc.text = details.ifsc;
    bankName.text = details.bankName;
    notifyListeners();
  }

  Future<void> rememberPan(String pan) async {
    panNumber = pan.trim().toUpperCase();
    if (panNumber.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pan_number', panNumber);
    }
    notifyListeners();
  }

  /// Fills document numbers that were saved by a verification screen
  /// but never copied onto this session.
  Future<void> loadSavedDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    void fill(TextEditingController controller, String key) {
      if (controller.text.trim().isNotEmpty) return;
      final value = prefs.getString(key) ?? '';
      if (value.isNotEmpty) controller.text = value;
    }

    fill(aadhaar, 'aadhaar_number');
    fill(dlNumber, 'driving_licence_number');
    fill(rcNumber, 'rc_number');
    if (panNumber.isEmpty) panNumber = prefs.getString('pan_number') ?? '';
    notifyListeners();
  }

  void startOtpTimer() {
    otpCountdown = 30;
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpCountdown > 0) {
        otpCountdown--;
      } else {
        timer.cancel();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void clearOtp() {
    otp.clear();
    otpError = false;
    notifyListeners();
  }

  Future<String?> sendOtp() async {
    final clean = phone.text.replaceAll(' ', '');
    loading = true;
    notifyListeners();
    startOtpTimer();
    try {
      if (clean == '9999999999') {
        receivedOtp = '123456';
        announceOtp = true;
        return null;
      }
      final response = await http
          .post(
            Uri.parse(AppUrls.sendOtp),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'phone': clean}),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = json.decode(response.body);
          receivedOtp = data['otp']?.toString() ?? data['data']?['otp']?.toString();
        } catch (e) {
          debugPrint('[Route] OTP parse failed: $e');
        }
        announceOtp = true;
        return null;
      }
      return 'Failed to send OTP: Status ${response.statusCode}';
    } catch (e) {
      return 'Network error: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Returns true when the driver should open the dashboard.
  Future<OtpVerifyResult> verifyOtp() async {
    final clean = phone.text.replaceAll(' ', '');
    loading = true;
    otpError = false;
    notifyListeners();
    print('[verifyOtp] Verifying OTP for $clean');
    try {
      if (clean == '9999999999' && otp.text == '123456') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_phone', clean);
        await prefs.setInt('driver_id', 9999);
        await prefs.setString('user_gender', 'Male');
        await prefs.setString('user_name', 'Apple Reviewer');
        await prefs.setBool('isLoggedIn', true);
        await KycResume.clear();
        gender = 'Male';
        clearOtp();
        unawaited(FCMService.registerFCMToken('driver'));
        return const OtpVerifyResult.dashboard();
      }

      http.Response response = await http
          .post(
            Uri.parse(AppUrls.verifyOtp),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'phone': clean, 'otp': otp.text, 'code': otp.text}),
          )
          .timeout(const Duration(seconds: 15));
print('[verifyOtp] Status: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 404) {
        response = await http
            .post(
              Uri.parse(AppUrls.verifyAuthFallback),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'phone': clean, 'otp': otp.text, 'code': otp.text}),
            )
            .timeout(const Duration(seconds: 15));
      }

      if (response.statusCode == 404) {
        response = await http
            .post(
              Uri.parse(AppUrls.verifyDriverOtpFallback),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'phone': clean, 'otp': otp.text, 'code': otp.text}),
            )
            .timeout(const Duration(seconds: 15));
      }

      debugPrint('[verifyOtp] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        otpError = true;
        return const OtpVerifyResult.failed();
      }
print('dg - 07 [verifyOtp] OTP verified successfully for $clean');
      final data = json.decode(response.body);
      final extractedToken = (data['token'] ??
              data['access_token'] ??
              data['auth_token'] ??
              data['jwt'] ??
              data['data']?['token'] ??
              data['data']?['access_token'])
          ?.toString();
print('dg - 08 [verifyOtp] Extracted token: $extractedToken');
     
      final existing = data['is_existing_driver'] == true ||
          data['is_existing_user'] == true ||
          data['existing'] == true ||
          data['is_existing'] == true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_phone', clean);
print('dg - 09 [verifyOtp] Saved user phone: $clean');
      if (extractedToken != null && extractedToken.isNotEmpty) {
        token = extractedToken;
        await prefs.setString('auth_token', extractedToken);
        await prefs.setString('token', extractedToken);
        debugPrint('[verifyOtp] Saved auth token');
      }

      if (existing) {
        print('dg - 10 [verifyOtp] Existing driver detected, applying profile data');
        gender = (data['gender'] ?? 'Male').toString();
        if (gender.isEmpty) gender = 'Male';
        name.text = (data['name'] ?? '').toString();
        email.text = (data['email'] ?? '').toString();
        if (data['driver_id'] != null) {
          await prefs.setInt('driver_id', data['driver_id']);
        }
        await prefs.setString('user_gender', gender);
        await prefs.setString('user_name', name.text);
        await prefs.setString('user_email', email.text);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('is_pink_theme', gender == 'Female');
        await KycResume.clear();
        publishAccent?.call(gender == 'Female');
        unawaited(FCMService.registerFCMToken('driver'));
        clearOtp();
        return const OtpVerifyResult.dashboard();
      }
print('dg - 11 [verifyOtp] New driver detected, marking KYC as verified');
      await KycResume.markVerified();
      clearOtp();
       print('dg - 12 [verifyOtp] KYC marked as verified, proceeding to vehicle selection');
      return const OtpVerifyResult.vehicle();
     
    } catch (e) {
      return OtpVerifyResult.error('Network error: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> saveVehicle() async {
    loading = true;
    notifyListeners();
    try {
      final clean = phone.text.replaceAll(' ', '').replaceAll('-', '');
      await DriverApiService.updateVehicleType(driverPhone: clean, vehicleType: vehicleType);
    } catch (e) {
      debugPrint('[Route] vehicle save: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vehicle_type', vehicleType);
      vehicleChosen = true;
      loading = false;
      notifyListeners();
    }
    return null;
  }

  Future<String?> verifyAadhaar() async {
    final number = aadhaar.text.replaceAll(' ', '').replaceAll('-', '');
    if (number.length != 12) return 'Please enter a valid 12-digit Aadhaar Number';
    loading = true;
    notifyListeners();
    try {
      var cleanPhone = phone.text.replaceAll(' ', '').replaceAll('-', '');
      if (cleanPhone.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        cleanPhone = prefs.getString('user_phone') ?? '';
      }

      http.Response response = await http
          .post(
            Uri.parse(AppUrls.verifyAadhaar),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'aadhaar_number': number,
              'phone': cleanPhone,
              'pan_number': panNumber,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        response = await http
            .post(
              Uri.parse(AppUrls.verifyAadhaarFallback),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'aadhaar_number': number,
                'phone': cleanPhone,
                'pan_number': panNumber,
              }),
            )
            .timeout(const Duration(seconds: 10));
      }

      debugPrint('[verifyAadhaar] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = json.decode(response.body);
          if ((data['name'] ?? '').toString().isNotEmpty && name.text.isEmpty) {
            name.text = data['name'].toString();
          }
          if ((data['dob'] ?? '').toString().isNotEmpty && dob.text.isEmpty) {
            dob.text = data['dob'].toString();
          }
          if ((data['gender'] ?? '').toString().isNotEmpty) {
            gender = data['gender'] == 'Female' ? 'Female' : 'Male';
            publishAccent?.call(gender == 'Female');
          }
        } catch (_) {}
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('aadhaar_number', number);
      if (panNumber.isNotEmpty) await prefs.setString('pan_number', panNumber);
      if (name.text.isNotEmpty) await prefs.setString('user_name', name.text);
      aadhaarVerified = true;
      await rememberKyc();
      return null;
    } catch (e) {
      debugPrint('[verifyAadhaar] Fallback local save: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('aadhaar_number', number);
      if (panNumber.isNotEmpty) await prefs.setString('pan_number', panNumber);
      aadhaarVerified = true;
      await rememberKyc();
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> applyDigilockerDownload(Map<String, dynamic> data) async {
    final aadhaarData = data['aadhaar_xml_data'] ?? {};
    final entered = aadhaar.text;
    name.text = (aadhaarData['full_name'] ?? data['full_name'] ?? name.text).toString();
    dob.text = (aadhaarData['dob'] ?? data['dob'] ?? dob.text).toString();
    final masked = (aadhaarData['masked_aadhaar'] ?? '').toString();
    if (entered.replaceAll(' ', '').length == 12) {
      aadhaar.text = entered.replaceAll(' ', '');
    } else if (masked.isNotEmpty) {
      aadhaar.text = masked;
    }
    final genderRaw = (aadhaarData['gender'] ?? data['gender'] ?? 'M').toString();
    gender = (genderRaw == 'F' || genderRaw == 'Female') ? 'Female' : 'Male';
    publishAccent?.call(gender == 'Female');

    final pan = (data['pan_number'] ?? '').toString().trim();
    final dl = (data['driving_licence_number'] ?? '').toString().trim();
    final rc = (data['rc_number'] ?? '').toString().trim();
    panNumber = pan;
    if (dl.isNotEmpty) dlNumber.text = dl;
    if (rc.isNotEmpty) rcNumber.text = rc;
    aadhaarVerified = true;
    dlVerified = dl.isNotEmpty;
    rcVerified = rc.isNotEmpty;
    playDigilockerSuccess = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name.text);
    await prefs.setString('user_dob', dob.text);
    await prefs.setString('user_gender', gender);
    await prefs.setBool('is_pink_theme', gender == 'Female');
    await prefs.setString('aadhaar_number', aadhaar.text);
    if (pan.isNotEmpty) await prefs.setString('pan_number', pan);
    if (dl.isNotEmpty) {
      await prefs.setString('driving_licence_number', dl);
    } else {
      await prefs.remove('driving_licence_number');
    }
    if (rc.isNotEmpty) {
      await prefs.setString('rc_number', rc);
    } else {
      await prefs.remove('rc_number');
    }
    try {
      await DriverApiService.updateProfile(
        phone: phone.text.replaceAll(' ', '').replaceAll('-', ''),
        name: name.text,
        aadhaarNumber: aadhaar.text,
        panNumber: pan.isNotEmpty ? pan : null,
        drivingLicenceNumber: dl.isNotEmpty ? dl : null,
        rcNumber: rc.isNotEmpty ? rc : null,
      );
    } catch (e) {
      debugPrint('[Route] DigiLocker profile update failed: $e');
    }
    await rememberKyc();
    notifyListeners();
  }

  Future<String?> submitApplication() async {
    loading = true;
    notifyListeners();
    try {
      final clean = phone.text.replaceAll(' ', '').replaceAll('-', '');
      final response = await http
          .post(
            Uri.parse(AppUrls.driverRegister),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'phone': clean,
              'name': name.text,
              'dob': dob.text,
              'gender': gender,
              'aadhaar_number': aadhaar.text,
              'dl_number': dlNumber.text,
              'rc_number': rcNumber.text,
              'vehicle_type': vehicleType,
              'bank_name': bankName.text,
              'bank_account_number': bankAccount.text,
              'bank_ifsc_code': bankIfsc.text,
              'bank_account_holder_name': bankHolder.text,
              'email': email.text,
            }),
          )
          .timeout(const Duration(seconds: 15));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name.text);
      await prefs.setString('user_gender', gender);
      await prefs.setString('user_phone', clean);
      await prefs.setString('user_email', email.text);
      await prefs.setBool('is_pink_theme', gender == 'Female');
      await prefs.setBool('isLoggedIn', true);
      try {
        if (response.statusCode == 200) {
          final body = json.decode(response.body);
          if (body['driver_id'] != null) await prefs.setInt('driver_id', body['driver_id']);
          final regToken = (body['token'] ??
                  body['access_token'] ??
                  body['auth_token'] ??
                  body['jwt'] ??
                  body['data']?['token'])
              ?.toString();
          if (regToken != null && regToken.isNotEmpty) {
            token = regToken;
            await prefs.setString('auth_token', regToken);
            await prefs.setString('token', regToken);
          }
        }
      } catch (_) {}
      await KycResume.clear();
      publishAccent?.call(gender == 'Female');
      unawaited(FCMService.registerFCMToken('driver'));
      submittedAt = DateTime.now();
      outcome = ApplicationOutcome.underReview;
      return null;
    } catch (e) {
      submittedAt = DateTime.now();
      outcome = ApplicationOutcome.underReview;
      return 'Saved locally: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

class OtpVerifyResult {
  const OtpVerifyResult._(this.kind, this.message);
  const OtpVerifyResult.dashboard() : this._(_OtpKind.dashboard, null);
  const OtpVerifyResult.vehicle() : this._(_OtpKind.vehicle, null);
  const OtpVerifyResult.failed() : this._(_OtpKind.failed, null);
  const OtpVerifyResult.error(String message) : this._(_OtpKind.error, message);
  final _OtpKind kind;
  final String? message;

  bool get openDashboard => kind == _OtpKind.dashboard;
  bool get openVehicle => kind == _OtpKind.vehicle;
}

enum _OtpKind { dashboard, vehicle, failed, error }
