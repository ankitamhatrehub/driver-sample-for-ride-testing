import 'package:shared_preferences/shared_preferences.dart';

/// Where a restart should open after OTP, until KYC is finished.
enum KycResumeDestination { none, vehicle, kyc, otp }

/// KYC rows already finished. The next false row is the one to continue.
class KycProgress {
  const KycProgress({
    this.aadhaar = false,
    this.drivingLicence = false,
    this.rc = false,
    this.vehiclePhotos = false,
    this.face = false,
    this.bank = false,
  });

  final bool aadhaar;
  final bool drivingLicence;
  final bool rc;
  final bool vehiclePhotos;
  final bool face;
  final bool bank;

  bool get anyDone => aadhaar || drivingLicence || rc || vehiclePhotos || face || bank;
}

class KycResume {
  KycResume._();

  static const Duration window = Duration(hours: 2);
  static const String _key = 'kyc_resume_at';
  static const String _aadhaar = 'kyc_aadhaar_done';
  static const String _dl = 'kyc_dl_done';
  static const String _rc = 'kyc_rc_done';
  static const String _photos = 'kyc_photos_done';
  static const String _face = 'kyc_face_done';
  static const String _bank = 'kyc_bank_done';

  /// Call when a new driver finishes OTP and still has KYC left.
  static Future<void> markVerified() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, DateTime.now().millisecondsSinceEpoch);
  }

  /// Remember which KYC rows are already done so a reopen continues the next one.
  static Future<void> saveProgress(KycProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aadhaar, progress.aadhaar);
    await prefs.setBool(_dl, progress.drivingLicence);
    await prefs.setBool(_rc, progress.rc);
    await prefs.setBool(_photos, progress.vehiclePhotos);
    await prefs.setBool(_face, progress.face);
    await prefs.setBool(_bank, progress.bank);
  }

  static Future<KycProgress> progress() async {
    final prefs = await SharedPreferences.getInstance();
    return KycProgress(
      aadhaar: prefs.getBool(_aadhaar) ?? false,
      drivingLicence: prefs.getBool(_dl) ?? false,
      rc: prefs.getBool(_rc) ?? false,
      vehiclePhotos: prefs.getBool(_photos) ?? false,
      face: prefs.getBool(_face) ?? false,
      bank: prefs.getBool(_bank) ?? false,
    );
  }

  /// Call when KYC is finished and the driver is logged in.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_aadhaar);
    await prefs.remove(_dl);
    await prefs.remove(_rc);
    await prefs.remove(_photos);
    await prefs.remove(_face);
    await prefs.remove(_bank);
  }

  /// Within [window] and before any KYC row is done, reopen on vehicle select.
  /// A finished KYC row reopens on KYC. After the window with nothing saved, start at OTP.
  static Future<KycResumeDestination> destination() async {
    final prefs = await SharedPreferences.getInstance();
    final resumeAt = prefs.getInt(_key);
    if (resumeAt == null) return KycResumeDestination.none;

    final saved = await progress();
    if (saved.anyDone) return KycResumeDestination.kyc;

    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(resumeAt),
    );
    if (elapsed < window) return KycResumeDestination.vehicle;

    await prefs.remove(_key);
    return KycResumeDestination.otp;
  }

  static Future<String> savedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_phone') ?? '';
  }
}
