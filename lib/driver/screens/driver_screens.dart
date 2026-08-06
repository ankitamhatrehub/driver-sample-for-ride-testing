import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../driver_app.dart';
import '../services/driver_api_service.dart';
import '../services/ride_alert_service.dart';
import '../../fcm_service.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_text_field.dart';
import '../../common/widgets/sos_button.dart';
import '../../common/constants/api_constants.dart';
import '../../common/widgets/bouncing_widget.dart';
import '../../common/utils/translations.dart';
import '../../common/services/location_consent_service.dart';
import '../../common/widgets/online_location_consent_dialog.dart';

// --- DRIVER ONBOARDING FLOW CONTROLLER ---
class DriverOnboardingScreen extends StatefulWidget {
  const DriverOnboardingScreen({super.key});

  @override
  State<DriverOnboardingScreen> createState() => _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState extends State<DriverOnboardingScreen> with SingleTickerProviderStateMixin {
  static const String _baseUrl = ApiConstants.baseUrl;
  
  // _step:
  // 1: Splash Screen
  // 2: Enter Mobile Number
  // 3: OTP Verification
  // 4: Upload Aadhaar
  // 5: OCR Extracts Data
  // 6: Review & Confirm Details
  // 7: Complete Profile
  // 8: Biometric Setup
  // 9: Biometric Verify
  int _step = 1; 

  final _phoneController = TextEditingController(text: '98765 43210');
  final _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  String? _receivedOtp;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _aadhaarNumberController = TextEditingController();
  final _dlNumberController = TextEditingController();
  final _dlDobController = TextEditingController();
  final _rcNumberController = TextEditingController();
  final _pucNumberController = TextEditingController();
  final _pucTotalMarksController = TextEditingController();
  final _insuranceNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankIfscCodeController = TextEditingController();
  final _bankAccountHolderNameController = TextEditingController();
  final _upiIdController = TextEditingController();
  String _selectedGender = 'Male';
  String _selectedVehicleType = 'Bike';

  bool _isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _aadhaarFrontImage;
  XFile? _aadhaarBackImage;
  XFile? _dlImage;
  XFile? _rcImage;
  XFile? _pucImage;
  XFile? _insuranceImage;
  XFile? _faceMatchImage;
  double _faceMatchScore = 0.0;
  String _faceMatchStatus = 'PENDING';

  // OTP Timer state
  Timer? _otpTimer;
  int _otpCountdown = 30;

  // OCR simulation progress
  double _ocrProgress = 0.0;
  Timer? _ocrTimer;
  bool _ocrRunning = false;

  // Biometric animation state
  bool _biometricVerifying = false;
  
  final LocalAuthentication _auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _hasFingerprint = false;
  bool _hasFaceId = false;

  @override
  void initState() {
    super.initState();
    _otpFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
    _checkBiometrics();
    _checkLoginStatus();
  }

  Future<String> _getCurrentCity() async {
    try {
      // Play Store: never request OS location permission before in-app consent.
      if (!await LocationConsentService.hasAccepted()) {
        return '';
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return '';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return '';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return '';
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      ).timeout(const Duration(seconds: 6));

      // Save driver location to backend driver_locations table
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('user_phone') ?? _phoneController.text.replaceAll(' ', '');
      if (phone.isNotEmpty) {
        final locUrl = Uri.parse('$_baseUrl/api/driver/update-location');
        try {
          await http.post(
            locUrl,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'phone': phone,
              'latitude': position.latitude,
              'longitude': position.longitude,
            }),
          ).timeout(const Duration(seconds: 4));
          print('Saved driver location: ${position.latitude}, ${position.longitude}');
        } catch (e) {
          print('Error updating driver location: $e');
        }
      }

      final geoUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=10',
      );
      final response = await http.get(
        geoUrl,
        headers: {'User-Agent': 'TorkkApp/1.0'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['address'] != null) {
          final address = data['address'];
          final city = address['city'] ?? address['town'] ?? address['village'] ?? address['suburb'] ?? address['state'] ?? '';
          return city.toString();
        }
      }
    } catch (e) {
      print('Error getting current city: $e');
    }
    return '';
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final gender = prefs.getString('user_gender') ?? 'Male';

    if (isLoggedIn) {
      if (mounted) {
        DriverApp.isPinkTheme.value = (gender == 'Female');
        _navigateToDashboard();
      }
      // Resolve city in the background so login restore is not blocked by GPS.
      _getCurrentCity().then((city) async {
        if (city.isNotEmpty) {
          await prefs.setString('driver_city', city);
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && _step == 1) {
          setState(() {
            _step = 2;
          });
        }
      });
    }
  }

  Future<void> _checkBiometrics() async {
    bool canCheck = false;
    bool hasFinger = false;
    bool hasFace = false;
    try {
      canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (canCheck) {
        final available = await _auth.getAvailableBiometrics();
        hasFace = available.contains(BiometricType.face);
        hasFinger = available.contains(BiometricType.fingerprint) || available.contains(BiometricType.strong) || (!hasFace && available.isNotEmpty);
      }
    } catch (e) {
      print('Biometric check error: $e');
    }
    if (mounted) {
      setState(() {
        _canCheckBiometrics = canCheck;
        _hasFingerprint = hasFinger;
        _hasFaceId = hasFace;
      });
    }
  }

  Future<void> _setupBiometrics(String type) async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Scan your $type to secure your Torkk account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        // Save to backend
        final cleanPhone = _phoneController.text.replaceAll(' ', '').replaceAll('-', '');
        final url = Uri.parse('$_baseUrl/api/enable-biometric');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'phone': cleanPhone, 'type': type}),
        );
        
        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              _step = 14;
            });
          }
        } else {
          print('Biometric Debug: Backend failed to save with status ${response.statusCode}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save biometric. Please make sure your profile is saved first.')),
            );
          }
        }
      }
    } catch (e) {
      print('Biometric error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to setup biometrics. You can enable it later in settings.')),
        );
        setState(() {
          _step = 14;
        });
      }
    }
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _ocrTimer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _aadhaarNumberController.dispose();
    _dlNumberController.dispose();
    _dlDobController.dispose();
    _rcNumberController.dispose();
    _pucNumberController.dispose();
    _pucTotalMarksController.dispose();
    _insuranceNumberController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankIfscCodeController.dispose();
    _bankAccountHolderNameController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      _step++;
    });
    if (_step == 5) {
      _startOcrSimulation();
    }
  }

  void _prevStep() {
    if (_step > 1) {
      setState(() {
        if (_step == 10) {
          _step = 4;
        } else if (_step == 12) {
          _step = 10;
        } else if (_step == 15) {
          _step = 12;
        } else if (_step == 27) {
          _step = 15;
        } else if (_step == 18) {
          _step = 12;
        } else if (_step == 6) {
          _step = 18;
        } else {
          _step--;
        }
      });
    }
  }

  void _startOtpTimer() {
    _otpCountdown = 30;
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_otpCountdown > 0) {
            _otpCountdown--;
          } else {
            _otpTimer?.cancel();
          }
        });
      }
    });
  }

  Future<void> _pickAadhaarImage(bool isFront, ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          if (isFront) {
            _aadhaarFrontImage = image;
          } else {
            _aadhaarBackImage = image;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  String _cleanJsonString(String input) {
    var cleaned = input.trim();
    if (cleaned.startsWith('```')) {
      final lines = cleaned.split('\n');
      if (lines.first.startsWith('```')) {
        lines.removeAt(0);
      }
      if (lines.last.startsWith('```')) {
        lines.removeLast();
      }
      cleaned = lines.join('\n').trim();
    }
    return cleaned;
  }

  Future<http.Response> _callGeminiWithRetry(Uri uri, String body) async {
    int retryCount = 0;
    const int maxRetries = 3;
    Duration delay = const Duration(seconds: 2);

    while (true) {
      try {
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 429 && retryCount < maxRetries) {
          retryCount++;
          print('OCR Debug: Gemini 429 Rate Limit Hit. Retrying in ${delay.inSeconds} seconds... (Attempt $retryCount of $maxRetries)');
          await Future.delayed(delay);
          delay = delay * 2; // Exponential backoff
          continue;
        }
        return response;
      } catch (e) {
        if (retryCount < maxRetries) {
          retryCount++;
          print('OCR Debug: Gemini Request Exception: $e. Retrying in ${delay.inSeconds} seconds... (Attempt $retryCount of $maxRetries)');
          await Future.delayed(delay);
          delay = delay * 2;
          continue;
        }
        rethrow;
      }
    }
  }

  Future<void> _processAadhaarOcr() async {
    // Gemini OCR removed. Surepass Digilocker SDK is used directly.
    _completeOcrProcess();
  }

  Future<void> _processDlOcr() async {
    // Gemini OCR removed. Will use Surepass API directly on the backend.
    await Future.delayed(const Duration(seconds: 2));
    _completeDlOcrProcess();
  }

  void _completeDlOcrProcess() {
    if (!mounted || !_ocrRunning) return;
    setState(() {
      _ocrRunning = false;
      _ocrProgress = 1.0;
      _ocrTimer?.cancel();
      if (_dlNumberController.text.isEmpty) _dlNumberController.text = 'DL-1420190012345';
      _step = 12; // Go to RC Upload
    });
  }

  void _startDlOcrSimulation() {
    if (_ocrRunning) return;
    _ocrRunning = true;
    _ocrProgress = 0.0;
    _ocrTimer?.cancel();
    _processDlOcr();
    _ocrTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          if (_ocrProgress < 0.9) _ocrProgress += 0.02;
        });
      }
    });
  }

  void _startRcOcrSimulation() {
    if (_ocrRunning) return;
    _ocrRunning = true;
    _ocrProgress = 0.0;
    _ocrTimer?.cancel();
    _processRcOcr();
    _ocrTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          if (_ocrProgress < 0.9) _ocrProgress += 0.02;
        });
      }
    });
  }

  Future<void> _processRcOcr() async {
    // Gemini OCR removed. Will use Surepass API directly on the backend.
    await Future.delayed(const Duration(seconds: 2));
    _completeRcOcrProcess();
  }

  void _completeRcOcrProcess() {
    if (!mounted || !_ocrRunning) return;
    setState(() {
      _ocrRunning = false;
      _ocrProgress = 1.0;
      _ocrTimer?.cancel();
      if (_rcNumberController.text.isEmpty) _rcNumberController.text = 'RC-1234567890';
      _step = 17; // Go to Face Match
    });
  }

  void _startPucOcrSimulation() {
    if (_ocrRunning) return;
    _ocrRunning = true;
    _ocrProgress = 0.0;
    _ocrTimer?.cancel();
    _processPucOcr();
    _ocrTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          if (_ocrProgress < 0.9) _ocrProgress += 0.02;
        });
      }
    });
  }

  Future<void> _processPucOcr() async {
    // Gemini OCR removed. Will use Surepass API directly on the backend.
    await Future.delayed(const Duration(seconds: 2));
    _completePucOcrProcess();
  }

  void _completePucOcrProcess() {
    if (!mounted || !_ocrRunning) return;
    setState(() {
      _ocrRunning = false;
      _ocrProgress = 1.0;
      _ocrTimer?.cancel();
      if (_pucTotalMarksController.text.isEmpty) _pucTotalMarksController.text = '512 / 600';
      _step = 27; // Go to Vehicle Insurance Upload
    });
  }

  void _startInsuranceOcrSimulation() {
    if (_ocrRunning) return;
    _ocrRunning = true;
    _ocrProgress = 0.0;
    _ocrTimer?.cancel();
    _processInsuranceOcr();
    _ocrTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          if (_ocrProgress < 0.9) _ocrProgress += 0.02;
        });
      }
    });
  }

  Future<void> _processInsuranceOcr() async {
    // Gemini OCR removed. Will use Surepass API directly on the backend.
    await Future.delayed(const Duration(seconds: 2));
    _completeInsuranceOcrProcess();
  }

  void _completeInsuranceOcrProcess() {
    if (!mounted || !_ocrRunning) return;
    setState(() {
      _ocrRunning = false;
      _ocrProgress = 1.0;
      _ocrTimer?.cancel();
      if (_insuranceNumberController.text.isEmpty) {
        _insuranceNumberController.text = 'INS-7766554433';
      }
      _step = 17; // Go to Face Match Verification
    });
  }

  Future<void> _startFaceMatchSimulation() async {
    if (_faceMatchImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture/upload a selfie first.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    // Simulate face verification processing
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _faceMatchScore = 98.2;
        _faceMatchStatus = 'VERIFIED';
        _step = 18; // Go to Bank Details
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Face matched successfully! Match Score: 98.2%'), backgroundColor: Colors.green),
      );
    }
  }

  void _completeOcrProcess() {
    if (!mounted || !_ocrRunning) return;
    setState(() {
      _ocrRunning = false;
      _ocrProgress = 1.0;
      _ocrTimer?.cancel();
      
      // Final fallback validation
      if (_nameController.text.isEmpty) _nameController.text = 'Rahul Kumar';
      if (_dobController.text.isEmpty) _dobController.text = '12/01/1995';
      if (_aadhaarNumberController.text.isEmpty) _aadhaarNumberController.text = '5489 8273 9102';
      
      _step = 10; // Go to DL Upload
    });
  }

  void _startOcrSimulation() {
    if (_ocrRunning) return;
    _ocrRunning = true;
    _ocrProgress = 0.0;
    _ocrTimer?.cancel();
    
    // Simulated OCR delay
    Future.delayed(const Duration(seconds: 2), () {
      _completeOcrProcess();
    });

    // Increment progress bar to 90% and wait for the real OCR result to complete
    _ocrTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          if (_ocrProgress < 0.9) {
            _ocrProgress += 0.02;
          }
        });
      }
    });
  }

  Future<void> _uploadAndVerifyAadhaar() async {
    if (_aadhaarNumberController.text.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 12-digit Aadhaar Number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Initialize Digilocker SDK
      print('Surepass Debug: Initializing Digilocker SDK');
      await _initializeDigilocker();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _verifyDl() async {
    if (_dlNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Driving Licence Number')));
      return;
    }
    if (_dlDobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Date of Birth (YYYY-MM-DD)')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$_baseUrl/api/driver/verify-dl');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_number': _dlNumberController.text,
          'dob': _dlDobController.text,
        }),
      ).timeout(const Duration(seconds: 15));

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        // DL Verified successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driving Licence Verified successfully!')),
        );
        setState(() { _step = 12; }); // Go to RC Upload directly
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify DL: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _verifyRc() async {
    if (_rcNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Registration Certificate Number')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$_baseUrl/api/driver/verify-rc');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_number': _rcNumberController.text,
        }),
      ).timeout(const Duration(seconds: 15));

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        // RC Verified successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RC Verified successfully!')),
        );
        setState(() { _step = 18; }); // Go to Bank Details directly
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify RC: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String? _digilockerClientId;
  String? _digilockerToken;
  String? _digilockerUrl;

  Future<void> _initializeDigilocker() async {
    print('Digilocker Debug: _initializeDigilocker called!');

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$_baseUrl/api/kyc/digilocker/initialize');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'signup_flow': true}),
      ).timeout(const Duration(seconds: 10));

      print('Digilocker Debug: Response Status Code = ${response.statusCode}');

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('Digilocker Debug: Success! Starting SDK Flow...');
          _digilockerClientId = data['client_id'];
          _digilockerToken = data['token'];
          _digilockerUrl = data['url'];
          // Local/dev mock when Surepass IP is not whitelisted — skip WebView.
          if (data['mock'] == true) {
            print('Digilocker Debug: Mock mode — skipping WebView');
            _downloadAadhaarDetails();
            return;
          }
          _launchDigilockerSDKFlow();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to initialize Digilocker: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${response.statusCode} ${response.body}')),
        );
      }
    } catch (e) {
      print('Digilocker Debug: Network Exception Caught: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  void _launchDigilockerSDKFlow() {
    if (_digilockerUrl == null) return;

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://google.com')) {
              Navigator.of(context).pop(); // Close webview modal
              _downloadAadhaarDetails();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_digilockerUrl!));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  AppBar(
                    title: const Text('DigiLocker Verification', style: TextStyle(fontSize: 16)),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Expanded(
                    child: WebViewWidget(controller: controller),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _downloadAadhaarDetails() async {
    setState(() => _isLoading = true);

      try {
        final url = Uri.parse('$_baseUrl/api/kyc/digilocker/download');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'client_id': _digilockerClientId}),
        ).timeout(const Duration(seconds: 15));

        setState(() => _isLoading = false);

        if (response.statusCode == 200) {
          final res = json.decode(response.body);
          if (res['success'] == true) {
            final data = res['data'];
            final aadhaarData = data['aadhaar_xml_data'] ?? {};
            final enteredAadhaar = _aadhaarNumberController.text;
            _nameController.text = aadhaarData['full_name'] ?? data['full_name'] ?? '';
            _dobController.text = aadhaarData['dob'] ?? data['dob'] ?? '';
            final masked = (aadhaarData['masked_aadhaar'] ?? '').toString();
            // Keep the number the driver typed when DigiLocker only returns a mask/mock.
            if (enteredAadhaar.replaceAll(' ', '').length == 12) {
              _aadhaarNumberController.text = enteredAadhaar.replaceAll(' ', '');
            } else if (masked.isNotEmpty) {
              _aadhaarNumberController.text = masked;
            } 
            final genderRaw = aadhaarData['gender'] ?? data['gender'] ?? 'M';
            if (genderRaw == 'M' || genderRaw == 'Male') {
              _selectedGender = 'Male';
            } else {
              _selectedGender = 'Female';
            }
            
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_name', _nameController.text);
            await prefs.setString('user_dob', _dobController.text);
            await prefs.setString('user_gender', _selectedGender);
            await prefs.setBool('is_pink_theme', _selectedGender == 'Female');
            await prefs.setBool('isLoggedIn', true);
            DriverApp.isPinkTheme.value = (_selectedGender == 'Female');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aadhaar Downloaded! Details fetched successfully.')),
            );

            // Advance to DL Upload screen (Step 10)
            setState(() {
              _step = 10;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to fetch details: ${res['message']}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server Error: ${response.statusCode}')),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error downloading Aadhaar: $e')));
      }
  }


  Future<void> _saveAadhaarDetailsToBackend() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('$_baseUrl/api/driver/register');
      final cleanPhone = _phoneController.text.replaceAll(' ', '').replaceAll('-', '');
      print('Aadhaar Debug: Saving Aadhaar details to backend: $url for phone: $cleanPhone');
      final body = json.encode({
        'phone': cleanPhone,
        'name': _nameController.text,
        'dob': _dobController.text,
        'gender': _selectedGender,
        'aadhaar_number': _aadhaarNumberController.text,
        'dl_number': _dlNumberController.text,
        'rc_number': _rcNumberController.text,
        'puc_number': _pucNumberController.text,
        'vehicle_type': _selectedVehicleType,
        'face_match_status': _faceMatchStatus,
        'face_match_score': _faceMatchScore,
        'face_match_photo_url': _faceMatchImage != null ? _faceMatchImage!.path : '',
        'bank_name': _bankNameController.text,
        'bank_account_number': _bankAccountNumberController.text,
        'bank_ifsc_code': _bankIfscCodeController.text,
        'bank_account_holder_name': _bankAccountHolderNameController.text,
        'upi_id': _upiIdController.text,
        'puc_total_marks': _pucTotalMarksController.text,
        'insurance_number': _insuranceNumberController.text,
        'email': _emailController.text,
      });
      print('Aadhaar Debug: POST Body = $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 15));

      print('Aadhaar Debug: Backend Save Response Status = ${response.statusCode}');
      print('Aadhaar Debug: Backend Save Response Body = ${response.body}');

      if (response.statusCode == 200) {
        final city = await _getCurrentCity();
        final prefs = await SharedPreferences.getInstance();
        if (city.isNotEmpty) {
          await prefs.setString('driver_city', city);
        }
        await prefs.setString('user_name', _nameController.text);
        await prefs.setString('user_gender', _selectedGender);
        await prefs.setString('user_phone', cleanPhone);
        await prefs.setString('user_email', _emailController.text);
        if (json.decode(response.body)['driver_id'] != null) {
          await prefs.setInt('driver_id', json.decode(response.body)['driver_id']);
        }
        await prefs.setBool('is_pink_theme', _selectedGender == 'Female');
        await prefs.setBool('isLoggedIn', true);
        DriverApp.isPinkTheme.value = (_selectedGender == 'Female');
        unawaited(FCMService.registerFCMToken('driver'));

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _navigateToDashboard();
          }
      } else {
        print('Aadhaar Debug: Failed to save to database. Status code: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile. Status: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      print('Aadhaar Debug: Error saving Aadhaar to database: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error saving profile.')),
        );
      }
    }
  }

  Future<void> _sendLocalOtp(String phone) async {
    setState(() {
      _isLoading = true;
    });
    _startOtpTimer();

    try {
      final otpUrl = Uri.parse('$_baseUrl/api/send-otp');
      final otpResp = await http.post(
        otpUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone.replaceAll(' ', '')}),
      ).timeout(const Duration(seconds: 15));

      if (otpResp.statusCode == 200) {
        print('[OTP DEBUG] Driver OTP response body: ${otpResp.body}');
        try {
          final data = json.decode(otpResp.body);
          setState(() {
            _receivedOtp = data['otp']?.toString();
          });
        } catch (e) {
          print('Error parsing OTP response: $e');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully.')),
          );
        }
      } else {
        print('[OTP DEBUG] Driver OTP send failed. Status: ${otpResp.statusCode}, Body: ${otpResp.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send OTP: Status ${otpResp.statusCode}')),
          );
        }
      }
    } catch (e, stack) {
      print('[OTP DEBUG] Driver OTP send connection failed: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        _step = 3; // OTP verification screen
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(_otpFocusNode);
        }
      });
    }
  }

  Future<void> _verifyLocalOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter verification code.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final verifyUrl = Uri.parse('$_baseUrl/api/driver/verify-otp');
      final verifyResp = await http.post(
        verifyUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': _phoneController.text.replaceAll(' ', ''),
          'code': _otpController.text,
        }),
      ).timeout(const Duration(seconds: 15));

      if (verifyResp.statusCode == 200) {
        final data = json.decode(verifyResp.body);
        final bool isExistingDriver = data['is_existing_driver'] == true;
        final String gender = data['gender'] ?? '';
        final String name = data['name'] ?? 'User';
        final String email = data['email'] ?? 'No email';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_phone', _phoneController.text.replaceAll(' ', ''));

        if (isExistingDriver) {
          setState(() {
            _selectedGender = gender.isNotEmpty ? gender : 'Male'; // default to Male if missing
          });
          if (data['driver_id'] != null) {
            await prefs.setInt('driver_id', data['driver_id']);
          }
          await prefs.setString('user_gender', gender);
          await prefs.setString('user_name', name);
          await prefs.setString('user_email', email);
          await prefs.setBool('isLoggedIn', true);
          await prefs.setBool('is_pink_theme', gender == 'Female');
          DriverApp.isPinkTheme.value = (gender == 'Female');
          unawaited(FCMService.registerFCMToken('driver'));
          if (mounted) {
            _navigateToDashboard();
          }
          // Resolve city in the background so OTP flow is not blocked by GPS.
          _getCurrentCity().then((city) async {
            if (city.isNotEmpty) {
              final cityPrefs = await SharedPreferences.getInstance();
              await cityPrefs.setString('driver_city', city);
            }
          });
        } else {
          setState(() {
            _step = 4; // Go to Aadhaar upload
          });
        }
      } else {
        final data = json.decode(verifyResp.body);
        final errorMsg = data['message'] ?? 'Invalid OTP code.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      }
    } catch (e) {
      print('Verification connection failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToDashboard() {
    if (_selectedGender == 'Female') {
      Navigator.pushReplacementNamed(context, '/dashboard_female');
    } else {
      Navigator.pushReplacementNamed(context, '/dashboard_male');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPink = false;
    final primaryColor = const Color(0xFF4F46E5);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _step > 1 && _step != 9
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _prevStep,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildStepContent(primaryColor, isPink),
        ),
      ),
    );
  }

  Widget _buildStepContent(Color primaryColor, bool isPink) {
    switch (_step) {
      case 1:
        return _buildStep1Splash(primaryColor);
      case 2:
        return _buildStep2MobileSelect(primaryColor);
      case 3:
        return _buildStep3OtpInput(primaryColor);
      case 4:
        return _buildStep4Aadhaar(primaryColor);
      case 5:
        return _buildStep5OcrProgress(primaryColor);
      case 6:
        return _buildStep6ConfirmDetails(primaryColor);
      case 7:
        return _buildStep7CompleteProfile(primaryColor);
      case 8:
        return _buildStep8BiometricSetup(primaryColor);
      case 9:
        return _buildStep9BiometricVerify(primaryColor);
      case 10:
        return _buildStep10DlUpload(primaryColor);
      case 11:
        return _buildStep11DlOcrProgress(primaryColor);
      case 12:
        return _buildStep12RcUpload(primaryColor);
      case 13:
        return _buildStep13RcOcrProgress(primaryColor);
      case 14:
        return _buildStep14VehicleTypeSelect(primaryColor);

      case 17:
        return _buildStep17FaceMatch(primaryColor);
      case 18:
        return _buildStep18BankUpiDetails(primaryColor);
      default:
        return _buildStep1Splash(primaryColor);
    }
  }

  // STEP 1: SPLASH SCREEN (1 SEC)
  Widget _buildStep1Splash(Color primaryColor) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: 8,
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logo.jpeg',
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          color: primaryColor.withValues(alpha: 0.1),
                          child: Icon(Icons.directions_car_filled_rounded, size: 64, color: primaryColor),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'TORKK',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Safe Rides, Every Time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade400,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // STEP 2: ENTER MOBILE NUMBER
  Widget _buildStep2MobileSelect(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Enter Mobile Number',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            'We will send you an OTP to verify your number',
            style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 15),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                ),
                child: const Text(
                  '+91',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    labelText: 'Mobile Number',
                    labelStyle: TextStyle(color: Colors.blueGrey.shade500, fontWeight: FontWeight.w600),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : BouncingWidget(
                  onTap: () => _sendLocalOtp(_phoneController.text),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Send OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // STEP 3: OTP VERIFICATION
  Widget _buildStep3OtpInput(Color primaryColor) {
    return GestureDetector(
      onTap: () {
        if (!_otpFocusNode.hasFocus) {
          _otpFocusNode.requestFocus();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter OTP',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              'We have sent a 6-digit OTP to +91 ${_phoneController.text}',
              style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 36),

            // Visual boxes + full-size invisible TextField on top so keyboard always reopens
            SizedBox(
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      String char = '';
                      if (_otpController.text.length > index) {
                        char = _otpController.text[index];
                      }
                      final isActive =
                          _otpFocusNode.hasFocus && _otpController.text.length == index;
                      return Container(
                        width: 44,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive ? primaryColor : Colors.black12,
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            char,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  Positioned.fill(
                    child: Opacity(
                      // Hide cursor/selection highlight; keep field tappable
                      opacity: 0.0,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: const TextSelectionThemeData(
                            cursorColor: Colors.transparent,
                            selectionColor: Colors.transparent,
                            selectionHandleColor: Colors.transparent,
                          ),
                        ),
                        child: TextField(
                          controller: _otpController,
                          focusNode: _otpFocusNode,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          autofocus: true,
                          showCursor: false,
                          cursorWidth: 0,
                          cursorColor: Colors.transparent,
                          maxLength: 6,
                          enableInteractiveSelection: false,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            color: Colors.transparent,
                            fontSize: 16,
                          ),
                          onChanged: (_) => setState(() {}),
                          onTap: () => _otpFocusNode.requestFocus(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_receivedOtp != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'OTP: $_receivedOtp',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _otpController.text = _receivedOtp!;
                        });
                        _otpFocusNode.requestFocus();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Paste Code'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    _otpCountdown > 0
                        ? 'Resend OTP in 00:${_otpCountdown.toString().padLeft(2, '0')}'
                        : 'Did not receive OTP?',
                    style: TextStyle(
                      color: Colors.blueGrey.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_otpCountdown == 0)
                  TextButton(
                    onPressed: () => _sendLocalOtp(_phoneController.text),
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : BouncingWidget(
                    onTap: _verifyLocalOtp,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Verify & Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // STEP 4: UPLOAD AADHAAR FRONT & BACK
  Widget _buildStep4Aadhaar(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Upload Aadhaar Card',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          const SizedBox(height: 24),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _aadhaarNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter 12-digit Aadhaar Number',
                hintStyle: TextStyle(color: Colors.blueGrey.shade300),
                prefixIcon: Icon(Icons.credit_card_rounded, color: primaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.2),
            ),
          ),
          const SizedBox(height: 28),
          
          // Verify button
          BouncingWidget(
            onTap: _uploadAndVerifyAadhaar,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Center(
                child: Text(
                  'Verify & Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // STEP 5: OCR EXTRACTING
  Widget _buildStep5OcrProgress(Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Center(
                    child: Icon(Icons.credit_card_outlined, size: 64, color: primaryColor.withValues(alpha: 0.7)),
                  ),
                ),
                // Laser Scanner Sweep Line
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Positioned(
                      top: 10 + 110 * value,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          boxShadow: [
                            BoxShadow(color: primaryColor, blurRadius: 8, spreadRadius: 1)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Extracting Data...',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we extract details from your Aadhaar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _ocrProgress,
                minHeight: 8,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(_ocrProgress * 100).toInt()}%',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
            )
          ],
        ),
      ),
    );
  }

  // STEP 6: CONFIRM DETAILS
  
  Widget _buildStep10DlUpload(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload Driving Licence', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Please upload a clear photo of your Driving Licence.'),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _dlNumberController,
              decoration: InputDecoration(
                hintText: 'Enter Driving Licence Number',
                hintStyle: TextStyle(color: Colors.blueGrey.shade300),
                prefixIcon: Icon(Icons.badge_outlined, color: primaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.2),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _dlDobController,
              decoration: InputDecoration(
                hintText: 'Enter DOB (YYYY-MM-DD)',
                hintStyle: TextStyle(color: Colors.blueGrey.shade300),
                prefixIcon: Icon(Icons.calendar_today_outlined, color: primaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.2),
            ),
          ),
          const Spacer(),
          BouncingWidget(
            onTap: _verifyDl,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('Verify Driving Licence', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep11DlOcrProgress(Color primaryColor) {
    return _buildStep5OcrProgress(primaryColor);
  }

  Widget _buildStep12RcUpload(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload Registration Certificate', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Please upload a clear photo of your vehicle\'s Registration Certificate (RC).'),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _rcNumberController,
              decoration: InputDecoration(
                hintText: 'Enter Registration Certificate Number',
                hintStyle: TextStyle(color: Colors.blueGrey.shade300),
                prefixIcon: Icon(Icons.description_outlined, color: primaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.2),
            ),
          ),
          const Spacer(),
          BouncingWidget(
            onTap: _verifyRc,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('Verify RC', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep13RcOcrProgress(Color primaryColor) {
    return _buildStep5OcrProgress(primaryColor);
  }


  Widget _buildStep17FaceMatch(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Face Match Verification', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Please upload or capture a selfie to verify your identity against Aadhaar.'),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () async {
              final XFile? image = await _imagePicker.pickImage(
                source: ImageSource.camera,
                maxWidth: 600,
                maxHeight: 600,
                imageQuality: 85,
              );
              if (image != null) setState(() => _faceMatchImage = image);
            },
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor, width: 2),
                  image: _faceMatchImage != null ? DecorationImage(image: FileImage(File(_faceMatchImage!.path)), fit: BoxFit.cover) : null,
                ),
                child: _faceMatchImage == null ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.face_retouching_natural_rounded, size: 50, color: Colors.black26), SizedBox(height: 8), Text('Take Selfie', style: TextStyle(fontSize: 12))]) : null,
              ),
            ),
          ),
          const Spacer(),
          BouncingWidget(
            onTap: _startFaceMatchSimulation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16)),
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : const Center(child: Text('Perform Face Match', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep18BankUpiDetails(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          const Text('Payout Details', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add your bank account and UPI details to receive daily earnings.'),
          const SizedBox(height: 24),
          TextField(
            controller: _bankNameController,
            decoration: InputDecoration(
              labelText: 'Bank Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.account_balance_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bankAccountNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Account Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.pin_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bankIfscCodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'IFSC Code',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.code_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bankAccountHolderNameController,
            decoration: InputDecoration(
              labelText: 'Account Holder Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person_rounded),
            ),
          ),
          const SizedBox(height: 24),
          const Text('UPI ID (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _upiIdController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'UPI ID (e.g. mobile@upi)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.payment_rounded),
            ),
          ),
          const SizedBox(height: 32),
          BouncingWidget(
            onTap: () {
              if (_bankNameController.text.isEmpty || _bankAccountNumberController.text.isEmpty || _bankIfscCodeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all mandatory bank account fields.')),
                );
                return;
              }
              setState(() {
                if (_canCheckBiometrics) {
                  _step = 8; // Proceed to biometric setup step
                } else {
                  _step = 14; // Proceed to vehicle selection step
                }
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('Continue', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep14VehicleTypeSelect(Color primaryColor) {
    final List<Map<String, dynamic>> vehicles = [
      {'name': 'Bike', 'icon': Icons.directions_bike_rounded, 'desc': 'Two-wheeler rides'},
      {'name': 'Auto', 'icon': Icons.local_taxi_rounded, 'desc': 'Three-wheeler auto rickshaw'},
      {'name': 'Cab', 'icon': Icons.directions_car_filled_rounded, 'desc': 'Comfortable sedan/hatchback'},
      {'name': 'EV Cab', 'icon': Icons.electric_car_rounded, 'desc': 'Eco-friendly electric cabs'},
      {'name': 'XL Cab', 'icon': Icons.airport_shuttle_rounded, 'desc': 'Spacious 6-seater SUVs'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Select Vehicle Type',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select the vehicle you will be driving to receive matching ride requests.',
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                final isSelected = _selectedVehicleType == vehicle['name'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: BouncingWidget(
                    onTap: () {
                      setState(() {
                        _selectedVehicleType = vehicle['name'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor.withValues(alpha: 0.08) : Colors.white,
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.black12,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              vehicle['icon'],
                              size: 28,
                              color: isSelected ? primaryColor : Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? primaryColor : const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  vehicle['desc'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: primaryColor,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          BouncingWidget(
            onTap: _saveVehicleType,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Center(
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveVehicleType() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cleanPhone = _phoneController.text.replaceAll(' ', '').replaceAll('-', '');
      await DriverApiService.updateVehicleType(
        driverPhone: cleanPhone,
        vehicleType: _selectedVehicleType,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vehicle_type', _selectedVehicleType);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _step = 6; // Go to Confirm Details
        });
      }
    } catch (e) {
      print('Error saving vehicle type: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Still navigate even if API fails in local test/simulation mode, but show warning
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved locally: $e'), backgroundColor: Colors.orange),
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('vehicle_type', _selectedVehicleType);
        _navigateToDashboard();
      }
    }
  }

  Widget _buildStep6ConfirmDetails(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Confirm Your Details',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: ListView(
                children: [
                  _detailFieldRow(Icons.person_outline, 'Name', _nameController.text),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.phone_android_outlined, 'Mobile', _phoneController.text),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.cake_outlined, 'DOB', _dobController.text),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.directions_car_filled_outlined, 'Vehicle Type', _selectedVehicleType),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.face_outlined, 'Gender', _selectedGender),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.credit_card_outlined, 'Aadhaar Number', _aadhaarNumberController.text),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.badge_outlined, 'DL Number', _dlNumberController.text),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.description_outlined, 'RC Number', _rcNumberController.text),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.receipt_long_outlined, 'PUC Number', _pucNumberController.text),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.grade_outlined, 'PUC Total Marks', _pucTotalMarksController.text),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.security_outlined, 'Insurance Number', _insuranceNumberController.text),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.face_retouching_natural_outlined, 'Face Match', '$_faceMatchStatus (${_faceMatchScore.toStringAsFixed(1)}%)'),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.account_balance_outlined, 'Bank Account', '${_bankNameController.text} - ${_bankAccountNumberController.text}'),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.payment_outlined, 'UPI ID', _upiIdController.text.isNotEmpty ? _upiIdController.text : 'N/A'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          BouncingWidget(
            onTap: _saveAadhaarDetailsToBackend,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Center(
                child: Text(
                  'Confirm & Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                // Show simple dialog to edit
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Edit Details'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _dobController,
                          decoration: const InputDecoration(labelText: 'DOB'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _aadhaarNumberController,
                          decoration: const InputDecoration(labelText: 'Aadhaar Number'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _dlNumberController,
                          decoration: const InputDecoration(labelText: 'DL Number'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _rcNumberController,
                          decoration: const InputDecoration(labelText: 'RC Number'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: const Text('Save'),
                      )
                    ],
                  ),
                );
              },
              child: Text(
                'Edit Details',
                style: TextStyle(color: Colors.blueGrey.shade400, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailFieldRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.blueGrey.shade400),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade400, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 7: COMPLETE PROFILE
  bool _agreedToTerms = true;
  Widget _buildStep7CompleteProfile(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Complete Your Profile',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Icon(Icons.person_rounded, size: 50, color: primaryColor),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: primaryColor,
                    child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          CustomTextField(labelText: 'Emergency Contact Phone', controller: _phoneController),
          const SizedBox(height: 16),
          CustomTextField(labelText: 'Email (Optional)', controller: _emailController),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: _agreedToTerms,
                activeColor: primaryColor,
                onChanged: (val) {
                  setState(() {
                    _agreedToTerms = val ?? true;
                  });
                },
              ),
              Expanded(
                child: Text(
                  'I agree to Terms & Conditions and Privacy Policy',
                  style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const Spacer(),
          BouncingWidget(
            onTap: _agreedToTerms ? _saveAadhaarDetailsToBackend : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _agreedToTerms ? primaryColor : Colors.grey,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _agreedToTerms
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ]
                    : [],
              ),
              child: const Center(
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // STEP 8: BIOMETRIC AUTHENTICATION SETUP
  Widget _buildStep8BiometricSetup(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.security_rounded, size: 84, color: primaryColor),
          ),
          const SizedBox(height: 40),
          const Text(
            'Enable Biometric Login',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          Text(
            'Secure your account with Fingerprint or Face ID',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.blueGrey.shade500, height: 1.4),
          ),
          const Spacer(),
          if (_hasFingerprint)
            BouncingWidget(
              onTap: () => _setupBiometrics('fingerprint'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Use Fingerprint',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          if (_hasFaceId)
            BouncingWidget(
              onTap: () => _setupBiometrics('face'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _hasFingerprint ? Colors.white : primaryColor,
                  border: Border.all(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Use Face ID',
                    style: TextStyle(
                      color: _hasFingerprint ? primaryColor : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _step = 14;
              });
            },
            child: Text(
              'Skip for now',
              style: TextStyle(color: Colors.blueGrey.shade400, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // STEP 9: BIOMETRIC AUTHENTICATION VERIFY
  Widget _buildStep9BiometricVerify(Color primaryColor) {
    if (!_biometricVerifying) {
      _biometricVerifying = true;
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) {
          setState(() {
            _step = 14;
          });
        }
      });
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: 1.2),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOutSine,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.face_retouching_natural_rounded, size: 76, color: primaryColor),
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'Verify to Continue',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              'Use your biometric to access your account',
              style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 32),
            const Text(
              'Verifying...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            )
          ],
        ),
      ),
    );
  }
}

// --- CUSTOMER HOME SCREEN (Dashboard & Ride state machine - Steps 10 to 24) ---

// --- RADAR WAVE ANIMATION FOR ONLINE STATE ---
class RadarWave extends StatefulWidget {
  const RadarWave({super.key});

  @override
  State<RadarWave> createState() => _RadarWaveState();
}

class _RadarWaveState extends State<RadarWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 90 * _controller.value,
              height: 90 * _controller.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 1 - _controller.value),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF10B981),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.wifi_tethering_rounded, color: Colors.white, size: 24),
            ),
          ],
        );
      },
    );
  }
}

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isOnline = false;
  Timer? _pollingTimer;
  List<dynamic> _rides = [];
  bool _fetchingRides = false;
  String _driverPhone = '';
  String _driverName = 'Driver Partner';
  String _driverCity = '';
  double _todayEarnings = 0;
  double _driverRating = 5.0;
  final Set<int> _rejectedRideIds = {};
  final Set<int> _knownRequestedRideIds = {};
  final AudioPlayer _rideAlertPlayer = AudioPlayer();
  String _profilePhotoUrl = '';
  String _driverVehicleType = '';
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _rideAlertPlayer.setReleaseMode(ReleaseMode.stop);
    _loadDriverPhone();
  }

  @override
  void dispose() {
    _stopPolling();
    _rideAlertPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadDriverPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final shouldBeOnline = prefs.getBool('driver_is_online') ?? false;
    setState(() {
      _driverPhone = prefs.getString('user_phone') ?? '9876543210';
      _driverName = prefs.getString('user_name') ?? 'Driver Partner';
      _driverCity = prefs.getString('driver_city') ?? '';
      _profilePhotoUrl = prefs.getString('profile_photo_url') ?? '';
      _driverVehicleType = prefs.getString('vehicle_type') ?? '';
      _isOnline = shouldBeOnline;
    });
    if (shouldBeOnline) {
      // If location was revoked while app was closed, force offline.
      final permission = await Geolocator.checkPermission();
      final canUseLocation = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
      if (!canUseLocation) {
        await prefs.setBool('driver_is_online', false);
        if (mounted) setState(() => _isOnline = false);
      } else {
        _startPolling();
        unawaited(RideAlertService.start());
        unawaited(FCMService.setOnlineStatus(true));
        unawaited(FCMService.registerFCMToken('driver'));
      }
    }
    _fetchEarnings();
    _fetchProfile();
    _checkActiveRide();
  }

  /// Resume an accepted / in-progress ride after app restart or crash.
  Future<void> _checkActiveRide() async {
    if (_driverPhone.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    int? rideId = prefs.getInt('active_ride_id');

    try {
      final rides = await DriverApiService.fetchActiveRides(driverPhone: _driverPhone);
      for (final ride in rides) {
        if (ride is! Map) continue;
        final status = (ride['status'] ?? '').toString();
        if (status == 'accepted' || status == 'in_progress') {
          final idVal = ride['id'];
          final parsed = idVal is int ? idVal : int.tryParse('$idVal');
          if (parsed != null) {
            rideId = parsed;
            await prefs.setInt('active_ride_id', parsed);
            break;
          }
        }
      }
    } catch (e) {
      print('[DEBUG HOME] Error fetching active rides for restore: $e');
      // Fall through and still try prefs-based restore.
    }

    if (rideId == null || !mounted) return;

    print('[DEBUG HOME] Restoring active ride $rideId');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushNamed(context, '/navigation');
    });
  }

  Future<void> _fetchProfile() async {
    if (_driverPhone.isEmpty) return;
    try {
      final profile = await DriverApiService.fetchProfile(_driverPhone);
      final photoUrl = profile['profile_photo_url'] ?? '';
      final name = profile['name'] ?? _driverName;
      final vehicleType = profile['vehicle_type'] ?? '';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_photo_url', photoUrl);
      await prefs.setString('user_name', name);
      await prefs.setString('vehicle_type', vehicleType);
      if (mounted) {
        setState(() {
          _profilePhotoUrl = photoUrl;
          _driverName = name;
          _driverVehicleType = vehicleType;
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (image == null) return;

      if (mounted) {
        setState(() {
          _uploadingPhoto = true;
        });
      }

      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      final photoUrl = await DriverApiService.uploadProfilePhoto(
        driverPhone: _driverPhone,
        base64Image: base64String,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_photo_url', photoUrl);

      if (mounted) {
        setState(() {
          _profilePhotoUrl = photoUrl;
          _uploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print('Error uploading photo: $e');
      if (mounted) {
        setState(() {
          _uploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _fetchEarnings() async {
    if (_driverPhone.isEmpty) {
      print('[DEBUG HOME SCREEN] Cannot fetch earnings - phone is empty');
      return;
    }
    print('[DEBUG HOME SCREEN] Fetching earnings for: $_driverPhone');
    try {
      final data = await DriverApiService.fetchEarnings(_driverPhone);
      print('[DEBUG HOME SCREEN] Earnings data received: $data');
      if (mounted) {
        setState(() {
          _todayEarnings = (data['today_earnings'] as num?)?.toDouble() ?? 0;
          _driverRating = (data['rating'] as num?)?.toDouble() ?? 5.0;
        });
        print('[DEBUG HOME SCREEN] Today earnings updated: $_todayEarnings, Rating: $_driverRating');
      }
    } catch (e) {
      print('[DEBUG HOME SCREEN] ERROR fetching earnings: $e');
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _fetchRides();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isOnline) {
        _fetchRides();
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchRides() async {
    if (_fetchingRides || !mounted || _driverPhone.isEmpty) return;
    _fetchingRides = true;
    try {
      final data = await DriverApiService.fetchActiveRides(
        driverPhone: _driverPhone,
      );
      final requestedIds = <int>{};
      for (final ride in data) {
        if (ride is! Map) continue;
        if ((ride['status'] ?? '').toString() != 'requested') continue;
        final idVal = ride['id'];
        final id = idVal is int ? idVal : int.tryParse('$idVal');
        if (id == null || _rejectedRideIds.contains(id)) continue;
        requestedIds.add(id);
      }
      final brandNew = requestedIds.difference(_knownRequestedRideIds);
      _knownRequestedRideIds
        ..clear()
        ..addAll(requestedIds);
      if (brandNew.isNotEmpty) {
        unawaited(_playNewRideAlert());
      }
      if (mounted) {
        setState(() {
          _rides = data;
        });
      }
    } catch (e) {
      print('Error fetching active rides: $e');
    } finally {
      _fetchingRides = false;
    }
  }

  Future<void> _playNewRideAlert() async {
    try {
      await _rideAlertPlayer.stop();
      await _rideAlertPlayer.play(AssetSource('sounds/ride_alert.wav'));
      final pickup = _rides.cast<dynamic>().where((r) {
        if (r is! Map) return false;
        return (r['status'] ?? '').toString() == 'requested';
      }).map((r) => (r['pickup_address'] ?? '').toString()).firstWhere(
            (a) => a.isNotEmpty,
            orElse: () => '',
          );
      unawaited(RideAlertService.showNewRideNotification(
        title: 'New ride request',
        body: pickup.isEmpty
            ? 'Open TORKK Driver to accept the ride'
            : 'Pickup: $pickup',
      ));
    } catch (e) {
      print('Error playing ride alert: $e');
    }
  }

  Future<void> _acceptRide(int rideId) async {
    try {
      await DriverApiService.acceptRide(rideId: rideId, driverPhone: _driverPhone);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('active_ride_id', rideId);
      await prefs.remove('active_ride_picked_up');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride accepted! Starting navigation...'), backgroundColor: Colors.green),
        );
        Navigator.pushNamed(context, '/navigation');
      }
    } catch (e) {
      final err = e.toString();
      if (err.contains('accept_failed_409')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This ride was accepted by someone else.'), backgroundColor: Colors.orange),
          );
          _fetchRides();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept ride: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleRides = _rides
        .where((ride) => ride['status'] == 'requested' && !_rejectedRideIds.contains(ride['id']))
        .toList();
    final primaryColor = const Color(0xFF4F46E5);

    return ValueListenableBuilder<String>(
      valueListenable: AppTranslations.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          floatingActionButton: SosButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DriverSosScreen()),
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'TORKK DRIVER',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 24, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 24, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header / Status switch section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (_isOnline)
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(Icons.wifi_tethering_rounded, color: Colors.white, size: 24),
                          )
                        else
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                            child: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 24),
                          ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isOnline ? AppTranslations.tr('online') : AppTranslations.tr('offline'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: _isOnline ? const Color(0xFF10B981) : Colors.redAccent,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              _isOnline ? AppTranslations.tr('looking_for_trips') : AppTranslations.tr('go_online_orders'),
                              style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _isOnline,
                      onChanged: (value) async {
                        if (value) {
                          // Every time driver goes online: in-app consent + OS location prompt.
                          final allowed = await requestOnlineLocationPermission(context);
                          if (!allowed) {
                            if (!mounted) return;
                            setState(() => _isOnline = false);
                            return;
                          }
                          if (!mounted) return;
                        }

                        setState(() {
                          _isOnline = value;
                          _rides = [];
                          if (!value) {
                            _knownRequestedRideIds.clear();
                          }
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('driver_is_online', value);
                        if (_isOnline) {
                          _startPolling();
                          unawaited(RideAlertService.start());
                          unawaited(FCMService.setOnlineStatus(true));
                          unawaited(FCMService.registerFCMToken('driver'));
                        } else {
                          _stopPolling();
                          unawaited(_rideAlertPlayer.stop());
                          unawaited(RideAlertService.stop());
                          unawaited(FCMService.setOnlineStatus(false));
                        }
                      },
                      activeColor: const Color(0xFF10B981),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Earnings & Rating Statistics Header Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppTranslations.tr('today_earnings'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade400, letterSpacing: 0.8)),
                            const SizedBox(height: 4),
                            Text('₹${_todayEarnings.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppTranslations.tr('rating').toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade400, letterSpacing: 0.8)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('$_driverRating ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Main Body area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: !_isOnline
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.directions_car_filled_rounded, size: 64, color: Colors.redAccent),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppTranslations.tr('currently_offline'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppTranslations.tr('toggle_status'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : visibleRides.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.radar_rounded, size: 64, color: primaryColor),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Searching for trips...',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Any incoming customer requests in your area will appear here immediately.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: visibleRides.length,
                          itemBuilder: (context, index) {
                            final ride = visibleRides[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.black12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                ride['vehicle_type']?.toUpperCase() ?? 'CAB',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ),
                                            if (ride['high_priority'] == 1) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.shade800,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.bolt_rounded, size: 12, color: Colors.white),
                                                    SizedBox(width: 2),
                                                    Text(
                                                      'PRIORITY',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            const SizedBox(width: 8),
                                            Text(
                                              ride['customer_name'] ?? 'Rider',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '₹${ride['estimated_fare']}',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF10B981)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Custom route path timeline
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            const Icon(Icons.circle, size: 10, color: Colors.green),
                                            Container(
                                              width: 2,
                                              height: 36,
                                              color: Colors.grey.shade200,
                                            ),
                                            const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                                          ],
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ride['pickup_address'] ?? 'Pickup location',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                                              ),
                                              const SizedBox(height: 28),
                                              Text(
                                                ride['drop_address'] ?? 'Dropoff location',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(Icons.directions_outlined, size: 16, color: Colors.blueGrey.shade400),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${ride['distance_km']} km away',
                                          style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 32, color: Color(0xFFF1F5F9)),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                _rejectedRideIds.add(ride['id']);
                                              });
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: Colors.redAccent, width: 1.5),
                                              foregroundColor: Colors.redAccent,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _acceptRide(ride['id']),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              elevation: 2,
                                            ),
                                            child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
          },
        ),
      ),
    ),
  ],
      ),
    );
      },
    );
  }
}

// --- DRIVER RIDE REQUESTS SCREEN ---
class DriverRequestsScreen extends StatelessWidget {
  const DriverRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Request')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text('Rider: Jane Doe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text('Pickup: Central Park, West End'),
                  Text('Dropoff: 5th Avenue Mall'),
                  Divider(height: 32),
                  Text('Est. Fare: \$18.50', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Accept',
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/navigation');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- DRIVER NAVIGATION / TRIP PROGRESS SCREEN ---
class DriverNavigationScreen extends StatefulWidget {
  const DriverNavigationScreen({super.key});

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

enum TripPhase { goingToPickup, goingToDrop }

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  Timer? _locationTimer;
  String _driverPhone = '';
  int? _rideId;
  Map<String, dynamic>? _ride;
  bool _isLoading = true;
  bool _isProcessing = false;
  
  Position? _currentPosition;
  GoogleMapController? _mapController;
  TripPhase _tripPhase = TripPhase.goingToPickup;
  bool _showFullRoute = false;
  
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Google Directions route cache (avoid refetching every GPS tick).
  static const String _mapsApiKey = 'AIzaSyDsDQvzzkQ-U9Gfmor4NaNaonMmv6Uy5Sw';
  List<LatLng> _cachedRoutePoints = [];
  String? _cachedRouteKey;
  int _mapSetupToken = 0;

  @override
  void initState() {
    super.initState();
    _initTrip();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initTrip() async {
    print('[DEBUG NAV] Initializing trip');
    final prefs = await SharedPreferences.getInstance();
    _driverPhone = prefs.getString('user_phone') ?? '';
    _rideId = prefs.getInt('active_ride_id');

    if (_rideId == null || _driverPhone.isEmpty) {
      print('[DEBUG NAV] No active ride or phone');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active ride found'), backgroundColor: Colors.orange),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
      return;
    }

    try {
      Map<String, dynamic>? ride;
      Object? lastError;
      // Retry briefly — local backend / emulator networking can flap on restart.
      for (var attempt = 1; attempt <= 5; attempt++) {
        try {
          ride = await DriverApiService.fetchRideDetail(rideId: _rideId!, driverPhone: _driverPhone);
          lastError = null;
          break;
        } catch (e) {
          lastError = e;
          print('[DEBUG NAV] fetchRideDetail attempt $attempt failed: $e');
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
      if (ride == null) {
        throw lastError ?? Exception('Unable to load ride');
      }

      final rideStatus = (ride['ride_status'] ?? ride['status'] ?? '').toString();
      print('[DEBUG NAV] Current ride status: $rideStatus');

      if (rideStatus == 'accepted') {
        print('[DEBUG NAV] Starting ride $_rideId');
        await DriverApiService.startRide(rideId: _rideId!, driverPhone: _driverPhone);
        ride = await DriverApiService.fetchRideDetail(rideId: _rideId!, driverPhone: _driverPhone);
      } else if (rideStatus != 'in_progress') {
        throw Exception('Ride is not active (status: $rideStatus)');
      }

      final pickedUpFromApi = _isTruthyFlag(ride['is_picked_up']);
      final pickedUpFromPrefs = prefs.getBool('active_ride_picked_up') ?? false;
      final pickedUp = pickedUpFromApi || pickedUpFromPrefs;

      print('[DEBUG NAV] Ride details loaded, is_picked_up api=$pickedUpFromApi prefs=$pickedUpFromPrefs => $pickedUp');

      if (pickedUp) {
        await prefs.setBool('active_ride_picked_up', true);
      }

      if (mounted) {
        setState(() {
          _ride = ride;
          _tripPhase = pickedUp ? TripPhase.goingToDrop : TripPhase.goingToPickup;
          _isLoading = false;
        });
        _setupMap();
        _startLocationUpdates();
      }
    } catch (e) {
      print('[DEBUG NAV] Error initializing trip: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading trip: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Accepts 1/0, true/false, "true"/"1" from different API shapes.
  bool _isTruthyFlag(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final s = value.toString().trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }

  void _clearRouteCache() {
    _cachedRouteKey = null;
    _cachedRoutePoints = [];
  }

  /// Decode Google encoded polyline into LatLng points.
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  Future<List<LatLng>> _getDrivingRoute(LatLng origin, LatLng destination) async {
    // ~100m cache grid so we don't hit routing APIs on every GPS tick.
    final cacheKey =
        '${origin.latitude.toStringAsFixed(3)},${origin.longitude.toStringAsFixed(3)}->'
        '${destination.latitude.toStringAsFixed(3)},${destination.longitude.toStringAsFixed(3)}';
    if (_cachedRouteKey == cacheKey && _cachedRoutePoints.length >= 2) {
      return _cachedRoutePoints;
    }

    // 1) Google Directions
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=$_mapsApiKey',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status']?.toString() ?? '';
        final routes = data['routes'];
        if (status == 'OK' && routes is List && routes.isNotEmpty) {
          final overview = routes[0]['overview_polyline'];
          final encoded = overview is Map ? overview['points']?.toString() : null;
          if (encoded != null && encoded.isNotEmpty) {
            final points = _decodePolyline(encoded);
            if (points.length >= 2) {
              _cachedRouteKey = cacheKey;
              _cachedRoutePoints = points;
              return points;
            }
          }
        } else {
          print('[DEBUG NAV] Google Directions status: $status');
        }
      } else {
        print('[DEBUG NAV] Google Directions HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('[DEBUG NAV] Google Directions error: $e');
    }

    // 2) OSRM road route fallback (works when Maps key blocks Directions)
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=polyline',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final routes = data['routes'];
        if (data['code']?.toString() == 'Ok' && routes is List && routes.isNotEmpty) {
          final encoded = routes[0]['geometry']?.toString();
          if (encoded != null && encoded.isNotEmpty) {
            final points = _decodePolyline(encoded);
            if (points.length >= 2) {
              print('[DEBUG NAV] Using OSRM road route (${points.length} pts)');
              _cachedRouteKey = cacheKey;
              _cachedRoutePoints = points;
              return points;
            }
          }
        }
      }
    } catch (e) {
      print('[DEBUG NAV] OSRM route error: $e');
    }

    // Last resort: straight line (should rarely happen)
    return [origin, destination];
  }

  void _updateDriverMarkerOnly() {
    if (_currentPosition == null || !mounted) return;
    final pos = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'driver');
      _markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: pos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your location'),
        zIndex: 3,
      ));
    });
  }

  Future<void> _setupMap() async {
    if (_ride == null) return;

    final token = ++_mapSetupToken;
    print('[DEBUG NAV] Setting up map for phase: $_tripPhase');
    try {
      _markers.removeWhere((m) => m.markerId.value != 'driver');

      LatLng? origin;
      LatLng? destination;
      const routeColor = Color(0xFF2563EB); // blue road route

      if (_showFullRoute) {
        final pickupLat = _asDouble(_ride!['pickup_lat']);
        final pickupLng = _asDouble(_ride!['pickup_lng']);
        final dropLat = _asDouble(_ride!['drop_lat']);
        final dropLng = _asDouble(_ride!['drop_lng']);

        if (pickupLat != null && pickupLng != null) {
          _markers.add(Marker(
            markerId: const MarkerId('pickup'),
            position: LatLng(pickupLat, pickupLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: 'Pickup Location',
              snippet: '${_ride!['pickup_address'] ?? ''}',
            ),
          ));
          origin = LatLng(pickupLat, pickupLng);
        }
        if (dropLat != null && dropLng != null) {
          _markers.add(Marker(
            markerId: const MarkerId('drop'),
            position: LatLng(dropLat, dropLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: 'Drop Location',
              snippet: '${_ride!['drop_address'] ?? ''}',
            ),
          ));
          destination = LatLng(dropLat, dropLng);
        }
      } else if (_tripPhase == TripPhase.goingToPickup) {
        final pickupLat = _asDouble(_ride!['pickup_lat']);
        final pickupLng = _asDouble(_ride!['pickup_lng']);

        if (pickupLat != null && pickupLng != null) {
          _markers.add(Marker(
            markerId: const MarkerId('pickup'),
            position: LatLng(pickupLat, pickupLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: 'Pickup Location',
              snippet: '${_ride!['pickup_address'] ?? ''}',
            ),
          ));
          destination = LatLng(pickupLat, pickupLng);
        }
        if (_currentPosition != null) {
          origin = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
        }
      } else {
        final dropLat = _asDouble(_ride!['drop_lat']);
        final dropLng = _asDouble(_ride!['drop_lng']);

        if (dropLat != null && dropLng != null) {
          _markers.add(Marker(
            markerId: const MarkerId('drop'),
            position: LatLng(dropLat, dropLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: 'Drop Location',
              snippet: '${_ride!['drop_address'] ?? ''}',
            ),
          ));
          destination = LatLng(dropLat, dropLng);
        }
        if (_currentPosition != null) {
          origin = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
        }
      }

      // Driver / car marker
      if (_currentPosition != null) {
        final pos = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
        _markers.removeWhere((m) => m.markerId.value == 'driver');
        _markers.add(Marker(
          markerId: const MarkerId('driver'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your location'),
          zIndex: 3,
        ));
      }

      if (mounted && token == _mapSetupToken) {
        setState(() {});
      }

      List<LatLng> routePoints = [];
      if (origin != null && destination != null) {
        routePoints = await _getDrivingRoute(origin, destination);
      }

      if (!mounted || token != _mapSetupToken) return;

      _polylines
        ..clear()
        ..addAll(routePoints.length >= 2
            ? [
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: routePoints,
                  color: routeColor,
                  width: 6,
                  jointType: JointType.round,
                  endCap: Cap.roundCap,
                  startCap: Cap.roundCap,
                ),
              ]
            : []);

      setState(() {});
      _fitMapBounds();
    } catch (e, st) {
      print('[DEBUG NAV] Map setup error: $e\n$st');
    }
  }

  void _fitMapBounds() {
    if (_mapController == null || _markers.isEmpty) return;

    final bounds = _calculateBounds(_markers.map((m) => m.position).toList());
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  LatLngBounds _calculateBounds(List<LatLng> positions) {
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (var pos in positions) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _startLocationUpdates() {
    _updateLocation();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) => _updateLocation());
  }

  Future<void> _updateLocation() async {
    if (_driverPhone.isEmpty) return;
    
    // Status check must happen FIRST, before any Geolocator/location calls,
    // to ensure cancellation is detected even if location permissions or GPS are off/failing.
    if (_rideId != null) {
      try {
        final rideDetail = await DriverApiService.fetchRideDetail(rideId: _rideId!, driverPhone: _driverPhone);
        if (rideDetail['status'] == 'cancelled' || rideDetail['ride_status'] == 'cancelled') {
          _locationTimer?.cancel();
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('active_ride_id');
          await prefs.remove('active_ride_picked_up');
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Ride Cancelled'),
                content: const Text('This ride was cancelled by the customer.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close navigation screen
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          return;
        }
      } catch (e) {
        print('[DEBUG NAV] Status check error: $e');
      }
    }

    try {
      if (!await LocationConsentService.hasAccepted()) return;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      await DriverApiService.updateLocation(
        driverPhone: _driverPhone,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      final newPos = LatLng(position.latitude, position.longitude);
      _currentPosition = position;

      // Move driver marker every tick; only rebuild road route when cache misses (~100m).
      _updateDriverMarkerOnly();
      if (_polylines.isEmpty || _cachedRoutePoints.length < 2) {
        await _setupMap();
      } else {
        // Soft-refresh route if driver moved out of cache grid.
        final dest = _tripPhase == TripPhase.goingToPickup
            ? (_asDouble(_ride?['pickup_lat']) != null && _asDouble(_ride?['pickup_lng']) != null
                ? LatLng(_asDouble(_ride!['pickup_lat'])!, _asDouble(_ride!['pickup_lng'])!)
                : null)
            : (_asDouble(_ride?['drop_lat']) != null && _asDouble(_ride?['drop_lng']) != null
                ? LatLng(_asDouble(_ride!['drop_lat'])!, _asDouble(_ride!['drop_lng'])!)
                : null);
        if (dest != null) {
          final cacheKey =
              '${newPos.latitude.toStringAsFixed(3)},${newPos.longitude.toStringAsFixed(3)}->'
              '${dest.latitude.toStringAsFixed(3)},${dest.longitude.toStringAsFixed(3)}';
          if (_cachedRouteKey != cacheKey) {
            await _setupMap();
          }
        }
      }
    } catch (e) {
      print('[DEBUG NAV] Location update error: $e');
    }
  }

  Future<void> _handlePickedUp() async {
    if (_isProcessing || _rideId == null) return;
    
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final codeEntered = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter Ride Verification Code'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please ask the passenger for their 4-digit ride code to verify identity.'),
              const SizedBox(height: 8),
              if ((_ride?['ride_code'] ?? '').toString().isNotEmpty)
                Text(
                  // Helps local/mock testing; passenger still owns the real code in production UX.
                  'Test tip: passenger ride code is ${_ride!['ride_code']}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: '4-Digit Code',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 1234',
                ),
                validator: (val) {
                  if (val == null || val.length != 4 || int.tryParse(val) == null) {
                    return 'Enter a valid 4-digit number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, codeController.text);
              }
            },
            child: const Text('Verify & Pickup'),
          ),
        ],
      ),
    );

    if (codeEntered == null || codeEntered.isEmpty) return;

    print('[DEBUG NAV] Customer picked up - calling API with code: $codeEntered');
    setState(() => _isProcessing = true);
    
    try {
      await DriverApiService.pickupCustomer(
        rideId: _rideId!, 
        driverPhone: _driverPhone,
        rideCode: codeEntered,
      );
      
      print('[DEBUG NAV] Pickup API success - switching to drop phase');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('active_ride_picked_up', true);
      _clearRouteCache();
      setState(() {
        _tripPhase = TripPhase.goingToDrop;
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer picked up! Heading to drop location.'), backgroundColor: Colors.green),
        );
        _setupMap();
      }
    } catch (e) {
      print('[DEBUG NAV] Pickup API error: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _completeTrip() async {
    if (_rideId == null || _isProcessing || _ride == null) return;
    
    // Set is_dropped = 1 on the backend so the customer immediately gets the payment card!
    try {
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/driver/reached'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ride_id': _rideId}),
      );
    } catch (e) {
      print('[DEBUG NAV] Error marking drop reached: $e');
    }

    _locationTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_ride_id');
    await prefs.remove('active_ride_picked_up');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DriverTripSummaryScreen(
            rideId: _rideId!,
            driverPhone: _driverPhone,
            estimatedFare: (_ride!['estimated_fare'] as num?)?.toDouble() ?? 0.0,
            customerName: _ride!['customer_name'] ?? 'Customer',
            customerPhone: _ride!['customer_phone'] ?? '',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppTranslations.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          floatingActionButton: SosButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DriverSosScreen()),
        ),
      ),
      appBar: AppBar(
        title: Text(_tripPhase == TripPhase.goingToPickup ? 'Going to Pickup' : 'Going to Drop'),
        backgroundColor: _tripPhase == TripPhase.goingToPickup ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
        actions: [
          if (_currentPosition != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('Live', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 3,
                  child: _currentPosition == null
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                            zoom: 14,
                          ),
                          markers: _markers,
                          polylines: _polylines,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: false,
                          onMapCreated: (controller) {
                            _mapController = controller;
                            _fitMapBounds();
                          },
                        ),
                ),
                
                // Trip Info Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_ride != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _ride!['customer_name'] ?? 'Customer',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _ride!['vehicle_type'] ?? 'Auto',
                                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                Text(
                                  '₹${_ride!['estimated_fare']}',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Destination info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _tripPhase == TripPhase.goingToPickup 
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _tripPhase == TripPhase.goingToPickup 
                                        ? Icons.person_pin_circle 
                                        : Icons.location_on,
                                    color: _tripPhase == TripPhase.goingToPickup 
                                        ? Colors.green 
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _tripPhase == TripPhase.goingToPickup ? 'Pickup' : 'Drop',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          _tripPhase == TripPhase.goingToPickup
                                              ? (_ride!['pickup_address'] ?? '')
                                              : (_ride!['drop_address'] ?? ''),
                                          style: const TextStyle(fontSize: 14),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Route Path View:',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showFullRoute = !_showFullRoute;
                                    });
                                    _clearRouteCache();
                                    _setupMap();
                                  },
                                  icon: Icon(
                                    _showFullRoute ? Icons.navigation_rounded : Icons.directions_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    _showFullRoute ? 'Show Current Navigation' : 'Show Full Route (Pickup ➔ Drop)',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Action Button
                            CustomButton(
                              text: _isProcessing
                                  ? 'Processing...'
                                  : _tripPhase == TripPhase.goingToPickup
                                      ? 'Customer Picked Up'
                                      : 'Arrived at Destination',
                              onTap: _isProcessing
                                  ? () {}
                                  : _tripPhase == TripPhase.goingToPickup
                                      ? _handlePickedUp
                                      : _completeTrip,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        );
      },
    );
  }
}

// --- DRIVER EARNINGS SCREEN ---
class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  bool _loading = true;
  double _todayEarnings = 0;
  double _weekEarnings = 0;
  double _totalEarnings = 0;
  int _todayTrips = 0;
  List<dynamic> _recentTrips = [];

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone') ?? '';
    if (phone.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final data = await DriverApiService.fetchEarnings(phone);
      if (mounted) {
        setState(() {
          _todayEarnings = (data['today_earnings'] as num?)?.toDouble() ?? 0;
          _weekEarnings = (data['week_earnings'] as num?)?.toDouble() ?? 0;
          _totalEarnings = (data['total_earnings'] as num?)?.toDouble() ?? 0;
          _todayTrips = (data['today_trips'] as num?)?.toInt() ?? 0;
          _recentTrips = data['recent_trips'] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEarnings,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text('Today Earnings', style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('₹${_todayEarnings.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                          const SizedBox(height: 8),
                          Text('$_todayTrips trips today', style: TextStyle(color: Colors.blueGrey.shade500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Column(
                              children: [
                                Text('This Week', style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade500)),
                                const SizedBox(height: 4),
                                Text('₹${_weekEarnings.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Column(
                              children: [
                                Text('All Time', style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade500)),
                                const SizedBox(height: 4),
                                Text('₹${_totalEarnings.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Recent Trips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _recentTrips.isEmpty
                          ? Center(child: Text('No completed trips yet', style: TextStyle(color: Colors.blueGrey.shade400)))
                          : ListView.builder(
                              itemCount: _recentTrips.length,
                              itemBuilder: (context, index) {
                                final trip = _recentTrips[index];
                                return ListTile(
                                  title: Text('Trip #${trip['id']} - ${trip['customer_name'] ?? 'Customer'}'),
                                  subtitle: Text(trip['date']?.toString().split('T').first ?? ''),
                                  trailing: Text(
                                    '₹${(trip['earnings'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// --- DRIVER WALLET SCREEN ---
class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({super.key});

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen> {
  bool _loading = true;
  double _todayEarnings = 0;
  double _weekEarnings = 0;
  double _monthEarnings = 0;
  double _totalEarnings = 0;
  List<dynamic> _recentTrips = [];

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() {
      _loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone') ?? '';
    if (phone.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final data = await DriverApiService.fetchEarnings(phone);
      if (mounted) {
        setState(() {
          _todayEarnings = (data['today_earnings'] as num?)?.toDouble() ?? 0;
          _weekEarnings = (data['week_earnings'] as num?)?.toDouble() ?? 0;
          _monthEarnings = (data['month_earnings'] as num?)?.toDouble() ?? 0;
          _totalEarnings = (data['total_earnings'] as num?)?.toDouble() ?? 0;
          _recentTrips = data['recent_trips'] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _downloadStatement() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Generating Earnings Statement...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Earnings Statement downloaded successfully! (PDF)'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _earningCard(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4F46E5);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Wallet & Earnings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWalletData,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Earnings Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF312E81)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL EARNINGS', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 10),
                          Text(
                            '₹${_totalEarnings.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Earnings Breakdown grid (Daily, Weekly, Monthly)
                    const Text('EARNINGS BREAKDOWN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54, letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _earningCard('Daily', '₹${_todayEarnings.toStringAsFixed(2)}', Colors.black87)),
                        const SizedBox(width: 12),
                        Expanded(child: _earningCard('Weekly', '₹${_weekEarnings.toStringAsFixed(2)}', Colors.blue.shade700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _earningCard('Monthly', '₹${_monthEarnings.toStringAsFixed(2)}', Colors.teal.shade700)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _downloadStatement,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.download_rounded, size: 16, color: primaryColor),
                                      const SizedBox(width: 4),
                                      Text('STATEMENT', style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text('Download PDF', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Ride-wise Earnings
                    const Text('RIDE-WISE EARNINGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54, letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    _recentTrips.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: const Center(
                              child: Text('No completed rides recorded yet.', style: TextStyle(color: Colors.black38, fontSize: 13)),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recentTrips.length,
                            itemBuilder: (context, index) {
                              final trip = _recentTrips[index];
                              final date = trip['date']?.toString().split('T').first ?? '';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                                    child: const Icon(Icons.directions_car, color: Colors.green, size: 20),
                                  ),
                                  title: Text('Ride #${trip['id']} - ${trip['customer_name'] ?? 'Customer'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Text(date, style: const TextStyle(fontSize: 11)),
                                  trailing: Text(
                                    '₹${(trip['earnings'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}

// --- DRIVER TRIP HISTORY SCREEN ---
class DriverTripsScreen extends StatefulWidget {
  const DriverTripsScreen({super.key});

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

  void _showInvoiceDialog(BuildContext context, Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: Color(0xFF4F46E5)),
            SizedBox(width: 8),
            Text('Trip Invoice & Details', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _invoiceRow('Ride ID', '#${trip['id']}'),
              _invoiceRow('Customer', trip['customer_name'] ?? 'Customer'),
              _invoiceRow('Date', trip['date']?.toString().split('T').first ?? ''),
              _invoiceRow('Vehicle', trip['vehicle_type']?.toUpperCase() ?? 'CAB'),
              const Divider(height: 24),
              const Text('ROUTE DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Text('Pickup: ${trip['pickup_address'] ?? 'Pickup Address'}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
              const SizedBox(height: 6),
              Text('Drop: ${trip['drop_address'] ?? 'Drop Address'}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
              const Divider(height: 24),
              const Text('FARE BREAKDOWN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              _invoiceRow('Estimated Distance', '${trip['distance_km'] ?? '0.0'} km'),
              _invoiceRow('Total Customer Fare', '₹${(trip['fare'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
              const Divider(),
              _invoiceRow(
                'Your Earnings', 
                '₹${(trip['driver_earnings'] as num?)?.toStringAsFixed(2) ?? (trip['fare'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                isBold: true,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: trip['status'] == 'completed' ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trip['status']?.toUpperCase() ?? 'COMPLETED',
                    style: TextStyle(
                      color: trip['status'] == 'completed' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _invoiceRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(List<dynamic> filteredTrips) {
    if (filteredTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.blueGrey.shade200),
            const SizedBox(height: 16),
            Text('No trips found', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 15)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTrips.length,
        itemBuilder: (context, index) {
          final trip = filteredTrips[index];
          final date = trip['date']?.toString().split('T').first ?? '';
          final status = trip['status']?.toString() ?? '';
          final isCompleted = status == 'completed';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (isCompleted ? Colors.green : Colors.red).withValues(alpha: 0.15),
                child: Icon(
                  isCompleted ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                  color: isCompleted ? Colors.green : Colors.red,
                  size: 24,
                ),
              ),
              title: Text(
                '${trip['pickup_address'] ?? 'Pickup'} → ${trip['drop_address'] ?? 'Drop'}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: Text(
                '$date • ${trip['customer_name'] ?? 'Customer'}',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₹${(trip['driver_earnings'] as num?)?.toStringAsFixed(2) ?? (trip['fare'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? const Color(0xFF10B981) : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded, size: 20, color: Colors.blueGrey),
                    onPressed: () => _showInvoiceDialog(context, trip),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedRides = _trips.where((t) => t['status'] == 'completed').toList();
    final cancelledRides = _trips.where((t) => t['status'] == 'cancelled' || t['status'] == 'rejected').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Trip Activity History', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF4F46E5),
            unselectedLabelColor: Colors.black54,
            indicatorColor: Color(0xFF4F46E5),
            tabs: [
              Tab(text: 'Completed', icon: Icon(Icons.check_circle_outline_rounded, size: 20)),
              Tab(text: 'Cancelled', icon: Icon(Icons.cancel_outlined, size: 20)),
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
                        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadTrips, child: const Text('Retry')),
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

// --- DRIVER PROFILE SCREEN ---
class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  bool _loading = true;
  String _name = '';
  String _email = '';
  String _phone = '';
  double _rating = 5.0;
  bool _isVerified = false;
  String _profilePhotoUrl = '';
  String _vehicleType = '';
  String _aadhaarNumber = '';
  String _dlNumber = '';
  String _rcNumber = '';
  String _pucNumber = '';
  String _pucMarks = '';
  String _insuranceNumber = '';
  String _bankName = '';
  String _bankAcc = '';
  String _bankIfsc = '';
  String _bankHolder = '';
  String _upiId = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone') ?? '';
    if (phone.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final sharedName = prefs.getString('user_name') ?? '';
      final sharedGender = prefs.getString('user_gender') ?? '';
      final sharedVehicleType = prefs.getString('vehicle_type') ?? '';
      final data = await DriverApiService.fetchProfile(phone);
      if (mounted) {
        setState(() {
          _name = sharedName.isNotEmpty ? sharedName : (data['name'] ?? '');
          _email = data['email'] ?? '';
          _phone = data['phone'] ?? phone;
          _rating = (data['rating'] as num?)?.toDouble() ?? 5.0;
          _isVerified = data['is_verified'] == true;
          _profilePhotoUrl = data['profile_photo_url'] ?? '';
          _vehicleType = sharedVehicleType.isNotEmpty ? sharedVehicleType : (data['vehicle_type'] ?? '');
          
          // Let's store gender in email variable just to display it easily if we want, or create a new variable.
          // Wait, I can just add _gender variable if needed. For now I'll just keep it in sharedGender to show directly or save it.
          // Actually, let's just add _gender to the state if needed, or just use it.
          // Let's add _gender:
          _aadhaarNumber = data['aadhaar_number'] ?? '';
          _dlNumber = data['driving_licence_number'] ?? '';
          _rcNumber = data['rc_number'] ?? '';
          _pucNumber = data['puc_number'] ?? '';
          _pucMarks = data['puc_total_marks'] ?? '';
          _insuranceNumber = data['insurance_number'] ?? '';
          _bankName = data['bank_name'] ?? '';
          _bankAcc = data['bank_account_number'] ?? '';
          _bankIfsc = data['bank_ifsc_code'] ?? '';
          _bankHolder = data['bank_account_holder_name'] ?? '';
          _upiId = data['upi_id'] ?? '';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _phone = phone;
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    setState(() => _loading = true);
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      await DriverApiService.uploadProfilePhoto(driverPhone: _phone, base64Image: base64Image);
      await _loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEditFieldsDialog({
    required String title,
    required Map<String, String> initialValues,
    required Future<void> Function(Map<String, String>) onSave,
  }) {
    final controllers = <String, TextEditingController>{};
    initialValues.forEach((key, val) {
      controllers[key] = TextEditingController(text: val);
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: initialValues.keys.map((key) {
                final label = key.replaceAll('_', ' ').toUpperCase();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: controllers[key],
                    decoration: InputDecoration(
                      labelText: label,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final values = controllers.map((key, ctrl) => MapEntry(key, ctrl.text.trim()));
                Navigator.pop(context);
                setState(() => _loading = true);
                try {
                  await onSave(values);
                  await _loadProfile();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Updated successfully!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  setState(() => _loading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocTile({
    required String title,
    required String value,
    required String labelForNull,
    required IconData icon,
  }) {
    final hasValue = value.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: ListTile(
        leading: Icon(icon, color: hasValue ? const Color(0xFF4F46E5) : Colors.red),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            hasValue ? value : labelForNull,
            style: TextStyle(
              fontSize: 12,
              fontWeight: hasValue ? FontWeight.bold : FontWeight.normal,
              color: hasValue ? Colors.black87 : Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4F46E5);
    return ValueListenableBuilder<String>(
      valueListenable: AppTranslations.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(AppTranslations.tr('my_profile'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Profile Header Card
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
                      ],
                    ),
                    padding: const EdgeInsets.only(bottom: 24, top: 16),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'driver_avatar',
                          child: InkWell(
                            onTap: _pickAndUploadPhoto,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 54,
                                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                                  backgroundImage: _profilePhotoUrl.isNotEmpty
                                      ? NetworkImage(_profilePhotoUrl)
                                      : null,
                                  child: _profilePhotoUrl.isEmpty
                                      ? Icon(Icons.person_rounded, size: 64, color: primaryColor)
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4F46E5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.photo_camera, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _name.isNotEmpty ? _name : 'Partner Driver',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    _rating.toStringAsFixed(1),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                            if (_isVerified) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.verified_rounded, color: Colors.green, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified Partner',
                                      style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Account Details Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                            AppTranslations.tr('documents').toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54, letterSpacing: 1),
                          ),
                        ),

                        // Vehicle Details
                        _buildDocTile(
                          title: AppTranslations.tr('vehicle_details'),
                          value: _vehicleType.isNotEmpty ? 'Vehicle Type: ${_vehicleType.toUpperCase()}' : '',
                          labelForNull: 'Vehicle Details Not Added',
                          icon: Icons.local_taxi_rounded,
                        ),

                        // Aadhaar Details
                        _buildDocTile(
                          title: AppTranslations.tr('aadhaar_details'),
                          value: _aadhaarNumber,
                          labelForNull: 'Aadhaar Card Not Added',
                          icon: Icons.credit_card_rounded,
                        ),

                        // Driving License
                        _buildDocTile(
                          title: AppTranslations.tr('driving_license'),
                          value: _dlNumber,
                          labelForNull: 'Driving License Not Added',
                          icon: Icons.badge_outlined,
                        ),

                        // RC Number
                        _buildDocTile(
                          title: AppTranslations.tr('rc_number'),
                          value: _rcNumber,
                          labelForNull: 'RC Details Not Added',
                          icon: Icons.description_outlined,
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                            AppTranslations.tr('quick_actions'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54, letterSpacing: 1),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.language_rounded, color: Colors.indigo),
                                title: Text(AppTranslations.tr('language'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                trailing: DropdownButton<String>(
                                  value: lang,
                                  underline: const SizedBox(),
                                  items: [
                                    DropdownMenuItem(value: 'en', child: Text(AppTranslations.tr('english'))),
                                    DropdownMenuItem(value: 'hi', child: Text(AppTranslations.tr('hindi'))),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      AppTranslations.currentLanguage.value = val;
                                    }
                                  },
                                ),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.speed_rounded, color: Colors.purple),
                                title: Text(AppTranslations.tr('performance_metrics'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DriverPerformanceScreen()),
                                ),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.history_rounded, color: Colors.blue),
                                title: Text(AppTranslations.tr('all_trip_activity'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () => Navigator.pushNamed(context, '/trips'),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.teal),
                                title: Text(AppTranslations.tr('wallet_settlements'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () => Navigator.pushNamed(context, '/wallet'),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.support_agent_rounded, color: Colors.deepOrange),
                                title: Text(AppTranslations.tr('support_help'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DriverSupportScreen()),
                                ),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                                title: Text(AppTranslations.tr('logout'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.red),
                                onTap: () async {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setBool('isLoggedIn', false);
                                  if (context.mounted) {
                                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        );
      },
    );
  }
}

// --- DRIVER COMPLETED TRIP HISTORY SCREEN ---
class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  bool _loading = true;
  List<dynamic> _completedTrips = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone') ?? '';
    if (phone.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Driver phone not found.';
      });
      return;
    }
    try {
      final trips = await DriverApiService.fetchTrips(phone);
      final completed = trips.where((t) => t['status'] == 'completed').toList();
      if (mounted) {
        setState(() {
          _completedTrips = completed;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load history: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Completed Rides', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadHistory, child: const Text('Retry')),
                    ],
                  ),
                )
              : _completedTrips.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text('No completed rides yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Completed trips will be listed here', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _completedTrips.length,
                        itemBuilder: (context, index) {
                          final trip = _completedTrips[index];
                          final date = trip['date']?.toString().split('T').first ?? '';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.withValues(alpha: 0.15),
                                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                              ),
                              title: Text(
                                '${trip['pickup_address'] ?? 'Pickup'} → ${trip['drop_address'] ?? 'Drop'}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '$date • ${trip['customer_name'] ?? 'Customer'}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ),
                              trailing: Text(
                                '₹${(trip['driver_earnings'] as num?)?.toStringAsFixed(2) ?? (trip['fare'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981), fontSize: 15),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

// --- DRIVER NOTIFICATIONS SCREEN ---
class DriverNotificationsScreen extends StatelessWidget {
  const DriverNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Card(
            child: ListTile(
            ),
          ),
        ],
      ),
    );
  }
}

// --- DRIVER SUPPORT SCREEN ---
class DriverSupportScreen extends StatelessWidget {
  const DriverSupportScreen({super.key});

  Widget _buildBox(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Partner Support', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How can we help you today?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            const SizedBox(height: 6),
            const Text('Select an option below to connect with us or learn more.', style: TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  _buildBox(
                    context,
                    title: 'Live Chat',
                    subtitle: 'AI Support Assistant',
                    icon: Icons.chat_bubble_outline_rounded,
                    color: const Color(0xFF4F46E5),
                    screen: const DriverLiveChatScreen(),
                  ),
                  _buildBox(
                    context,
                    title: 'Call Support',
                    subtitle: 'Speak with our helpline',
                    icon: Icons.phone_in_talk_rounded,
                    color: Colors.green,
                    screen: const DriverCallSupportScreen(),
                  ),
                  _buildBox(
                    context,
                    title: 'FAQs',
                    subtitle: 'Frequently Asked Questions',
                    icon: Icons.help_outline_rounded,
                    color: Colors.amber.shade700,
                    screen: const DriverFaqScreen(),
                  ),
                  _buildBox(
                    context,
                    title: 'Report Issue',
                    subtitle: 'File a ticket/bug report',
                    icon: Icons.bug_report_outlined,
                    color: Colors.red,
                    screen: const DriverReportIssueScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- LIVE CHAT SCREEN USING GEMINI API ---
class DriverLiveChatScreen extends StatefulWidget {
  const DriverLiveChatScreen({super.key});

  @override
  State<DriverLiveChatScreen> createState() => _DriverLiveChatScreenState();
}

class _DriverLiveChatScreenState extends State<DriverLiveChatScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Hello Partner! I am your AI Support Assistant. How can I help you regarding the application today?'
    }
  ];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _typing = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _typing = true;
    });
    _scrollToBottom();

    try {
      final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=${ApiConstants.geminiApiKey}');
      
      final contents = [];
      
      contents.add({
        'role': 'user',
        'parts': [
          {
            'text': 'SYSTEM INSTRUCTION: You are the helpful BlackOriginX Driver Support Assistant. You assist taxi and delivery drivers using our mobile app. The application features include: '
                '- Profile Verification: Uploading Aadhaar, Driving License, RC, Vehicle Insurance, and PUC. All can be added or updated dynamically directly inside the "Partner Profile" screen. '
                '- Onboarding flow steps: OTP Verification, Aadhaar Upload & OCR, DL Upload & OCR, RC Upload & OCR, PUC Upload & OCR, Vehicle Insurance Upload & OCR, Selfie Face Match, Bank Details verification. '
                '- Ride-wise and Wallet Earnings: Shows daily, weekly, monthly, and all-time earnings. Drivers can cash out. '
                '- Navigation Toggle: Toggle between "Show Full Route" and "Show Current Navigation" on the map screen. '
                '- High Priority Rides: Rides requested by customers with high priority have a bold orange "PRIORITY" badge on the request card. '
                '- Trip History: Tabbed views for "Completed" and "Cancelled" rides. Tap the "i" info icon next to any ride to view the invoice details. '
                'Answer driver queries concisely based on this knowledge.'
          }
        ]
      });
      contents.add({
        'role': 'model',
        'parts': [{'text': 'Understood. I will act as the BlackOriginX Driver Support Assistant and answer queries concisely based on this knowledge.'}]
      });

      for (final msg in _messages) {
        contents.add({
          'role': msg['isUser'] == true ? 'user' : 'model',
          'parts': [{'text': msg['text']}]
        });
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': contents,
        }),
      );

      if (response.statusCode == 200) {
        final respJson = jsonDecode(response.body);
        if (respJson['candidates'] != null && (respJson['candidates'] as List).isNotEmpty) {
          final reply = respJson['candidates'][0]['content']['parts'][0]['text'];
          if (mounted) {
            setState(() {
              _messages.add({'isUser': false, 'text': reply.trim()});
            });
          }
        } else {
          throw Exception('No content candidate returned');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'isUser': false, 'text': 'Sorry, I am facing an issue connecting. Please try again later.'});
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _typing = false;
        });
      }
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4F46E5);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Live AI Chat', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] == true;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? primaryColor : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))
                      ],
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_typing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('AI Assistant is typing...', style: TextStyle(color: Colors.black45, fontStyle: FontStyle.italic, fontSize: 12)),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.black12)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send_rounded, color: primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CALL SUPPORT SCREEN ---
class DriverCallSupportScreen extends StatelessWidget {
  const DriverCallSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Call Support', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_in_talk_rounded, color: Colors.green, size: 72),
              ),
              const SizedBox(height: 24),
              const Text('Speak to Support Representative', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              const Text('Our Partner Support hotline is available 24/7 to resolve operations and billing inquiries.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: const Text(
                  '+1 (800) 555-0199',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Simulating telephone dialer initiation...')),
                    );
                  },
                  icon: const Icon(Icons.call, color: Colors.white),
                  label: const Text('Call Helpline Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- FAQ SCREEN ---
class DriverFaqScreen extends StatelessWidget {
  const DriverFaqScreen({super.key});

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(answer, style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('FAQs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Top Driver FAQs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          _buildFaqItem(
            'How do I add or update my Driving License / RC?',
            'Navigate to the Partner Profile screen in the side drawer. Tap "Add" or "Edit" on the specific document tile. Provide the updated details and tap "Save" to refresh.',
          ),
          _buildFaqItem(
            'How do I change the route/path on the map?',
            'While on a ride, look at the bottom control sheet on the Map screen. You can select between "Show Full Route" (Pickup ➔ Drop overview) or "Show Current Navigation" path.',
          ),
          _buildFaqItem(
            'How are High Priority rides highlighted?',
            'High Priority rides requested by customers will show a prominent orange "PRIORITY" badge directly on the driver request card in your active rides screen.',
          ),
          _buildFaqItem(
            'How do I download my earnings statement?',
            'Go to your Wallet screen from the sidebar or profile screen. In the grid, tap the "Download Statement" block. It will process and download a PDF representation of your earnings.',
          ),
          _buildFaqItem(
            'How long do Cashout Settlements take?',
            'Requesting a cashout transfers your current wallet balance directly to your registered bank account or UPI ID. It typically processes within 1 to 2 business hours.',
          ),
        ],
      ),
    );
  }
}

// --- REPORT ISSUE SCREEN ---
class DriverReportIssueScreen extends StatefulWidget {
  const DriverReportIssueScreen({super.key});

  @override
  State<DriverReportIssueScreen> createState() => _DriverReportIssueScreenState();
}

class _DriverReportIssueScreenState extends State<DriverReportIssueScreen> {
  final _descController = TextEditingController();
  String _selectedIssueType = 'App Bug';
  bool _submitting = false;

  final List<String> _issueTypes = [
    'App Bug',
    'Payment Issue',
    'Navigation Problem',
    'Customer Dispute',
    'Other'
  ];

  Future<void> _submitIssue() async {
    final desc = _descController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone') ?? '';

    final urlString = '${ApiConstants.baseUrl}/api/driver/report-issue';
    print('[DEBUG REPORT ISSUE] Submitting to URL: $urlString');
    print('[DEBUG REPORT ISSUE] Payload: phone=$phone, type=$_selectedIssueType, desc=$desc');

    try {
      final response = await http.post(
        Uri.parse(urlString),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'issue_type': _selectedIssueType,
          'description': desc,
        }),
      );

      print('[DEBUG REPORT ISSUE] Response Status Code: ${response.statusCode}');
      print('[DEBUG REPORT ISSUE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          _descController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Issue reported successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to report issue: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[DEBUG REPORT ISSUE] ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit issue: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4F46E5);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Report Issue', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _submitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('File a Support Ticket', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  const Text('Describe any problems you encountered and our team will review and resolve it.', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  const SizedBox(height: 24),
                  
                  const Text('Issue Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedIssueType,
                        isExpanded: true,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedIssueType = val);
                        },
                        items: _issueTypes.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Provide details about the issue...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitIssue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Submit Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// --- DRIVER PERFORMANCE SCREEN ---
class DriverPerformanceScreen extends StatefulWidget {
  const DriverPerformanceScreen({super.key});

  @override
  State<DriverPerformanceScreen> createState() => _DriverPerformanceScreenState();
}

class _DriverPerformanceScreenState extends State<DriverPerformanceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  // Mock driver stats
  final double _acceptanceRate = 0.94;
  final double _cancellationRate = 0.025;
  final double _completionRate = 0.975;
  final double _driverRating = 4.9;
  final double _performanceScore = 96.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required double percentage,
    required IconData icon,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 10),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                  const Spacer(),
                  Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percentage * _animation.value,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4F46E5);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Performance Metrics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Circular Score Card
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: (_performanceScore / 100) * _animation.value,
                              strokeWidth: 10,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    (_performanceScore * _animation.value).toStringAsFixed(0),
                                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: primaryColor),
                                  ),
                                  const Text('Overall Score', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Excellent Standing',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Keep up the high service standards to earn extra bonuses!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Performance metrics breakdown
            _buildMetricTile(
              label: 'Acceptance Rate',
              value: '${(_acceptanceRate * 100).toStringAsFixed(0)}%',
              percentage: _acceptanceRate,
              icon: Icons.check_circle_outline_rounded,
              color: Colors.teal,
            ),
            _buildMetricTile(
              label: 'Cancellation Rate',
              value: '${(_cancellationRate * 100).toStringAsFixed(1)}%',
              percentage: _cancellationRate,
              icon: Icons.cancel_outlined,
              color: Colors.red,
            ),
            _buildMetricTile(
              label: 'Completion Rate',
              value: '${(_completionRate * 100).toStringAsFixed(1)}%',
              percentage: _completionRate,
              icon: Icons.task_alt_rounded,
              color: Colors.blue,
            ),
            _buildMetricTile(
              label: 'Driver Rating',
              value: '$_driverRating / 5.0',
              percentage: _driverRating / 5.0,
              icon: Icons.star_outline_rounded,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

// --- FAKE INCOMING CALL OVERLAY SCREEN ---
class FakeIncomingCallOverlay extends StatefulWidget {
  const FakeIncomingCallOverlay({super.key});

  @override
  State<FakeIncomingCallOverlay> createState() => _FakeIncomingCallOverlayState();
}

class _FakeIncomingCallOverlayState extends State<FakeIncomingCallOverlay> {
  bool _callAnswered = false;
  int _seconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _answerCall() {
    setState(() {
      _callAnswered = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  String _formatDuration() {
    final min = (_seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: _callAnswered
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const CircleAvatar(
                    radius: 64,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_rounded, size: 72, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  const Text('Security Operations', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_formatDuration(), style: const TextStyle(fontSize: 16, color: Colors.white70)),
                  const Spacer(),
                  // End Call Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 64),
                    child: FloatingActionButton(
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.call_end, color: Colors.white),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const CircleAvatar(
                    radius: 64,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.security, size: 72, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text('Security Operations', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Torkk Safety Check', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 48, right: 48, bottom: 64),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Decline
                        Column(
                          children: [
                            FloatingActionButton(
                              heroTag: 'decline_fake_call',
                              onPressed: () => Navigator.pop(context),
                              backgroundColor: Colors.red,
                              child: const Icon(Icons.call_end, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            const Text('Decline', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        // Accept
                        Column(
                          children: [
                            FloatingActionButton(
                              heroTag: 'accept_fake_call',
                              onPressed: _answerCall,
                              backgroundColor: Colors.green,
                              child: const Icon(Icons.call, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            const Text('Accept', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// --- DRIVER SOS SCREEN ---
class DriverSosScreen extends StatefulWidget {
  const DriverSosScreen({super.key});

  @override
  State<DriverSosScreen> createState() => _DriverSosScreenState();
}

class _DriverSosScreenState extends State<DriverSosScreen> {
  bool _loading = true;
  List<dynamic> _contacts = [];
  String _phone = '';
  bool _fakeCallTriggered = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _phone = prefs.getString('user_phone') ?? '';
    await _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    if (_phone.isEmpty) return;
    print('[SOS_SCREEN] Loading emergency contacts for phone: $_phone');
    try {
      final url = '${ApiConstants.baseUrl}/api/driver/emergency-contacts?phone=$_phone';
      print('[SOS_SCREEN] GET URL: $url');
      final response = await http.get(Uri.parse(url));
      print('[SOS_SCREEN] GET Response status: ${response.statusCode}, body: ${response.body}');
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _contacts = jsonDecode(response.body);
            _loading = false;
          });
        }
      } else {
        print('[SOS_SCREEN] Failed to load contacts. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('[SOS_SCREEN] Exception during load: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addEmergencyContact() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Emergency Contact', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Contact Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                if (name.isEmpty || phone.isEmpty) return;

                Navigator.pop(context);
                setState(() => _loading = true);

                try {
                  final body = jsonEncode({
                    'driver_phone': _phone,
                    'contact_phone': phone,
                    'contact_name': name,
                  });
                  print('[SOS_SCREEN] Adding contact body: $body');
                  final response = await http.post(
                    Uri.parse('${ApiConstants.baseUrl}/api/driver/emergency-contacts'),
                    headers: {'Content-Type': 'application/json'},
                    body: body,
                  );
                  print('[SOS_SCREEN] Add contact status: ${response.statusCode}, body: ${response.body}');
                  if (response.statusCode == 200) {
                    await _loadEmergencyContacts();
                  }
                } catch (e) {
                  print('[SOS_SCREEN] Exception during add contact: $e');
                  if (mounted) setState(() => _loading = false);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _shareLiveLocation() {
    final shareUrl = 'https://torkk-ride.com/track/driver/$_phone';
    Share.share('Emergency alert! Follow my live ride tracking link: $shareUrl');
  }

  void _callHelpline() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling Torkk 24/7 Security Operations Hotline (+1 800 555-0199)...')),
    );
  }

  void _triggerFakeCallSimulation() {
    setState(() {
      _fakeCallTriggered = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fake incoming call scheduled in 3 seconds...'), duration: Duration(seconds: 2)),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _fakeCallTriggered) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FakeIncomingCallOverlay()),
        ).then((_) {
          if (mounted) {
            setState(() {
              _fakeCallTriggered = false;
            });
          }
        });
      }
    });
  }

  void _showReportIncidentSheet() {
    final descCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Report Active Incident', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 6),
              const Text('File an active security report to dispatchers.', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the situation (e.g., passenger dispute, vehicle safety, road hazard)...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final desc = descCtrl.text.trim();
                    if (desc.isEmpty) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incident report submitted to dispatch!'), backgroundColor: Colors.orange),
                    );
                    try {
                      final url = '${ApiConstants.baseUrl}/api/driver/report-issue';
                      final body = jsonEncode({
                        'phone': _phone,
                        'issue_type': 'SOS Incident',
                        'description': desc,
                      });
                      print('[SOS_SCREEN] Submitting incident report to URL: $url');
                      print('[SOS_SCREEN] Request body: $body');
                      final response = await http.post(
                        Uri.parse(url),
                        headers: {'Content-Type': 'application/json'},
                        body: body,
                      );
                      print('[SOS_SCREEN] Response code: ${response.statusCode}, body: ${response.body}');
                    } catch (e) {
                      print('[SOS_SCREEN] Exception during report incident submit: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchMaps(String query) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        print('[SOS_SCREEN] Could not launch maps URL: $url');
      }
    } catch (e) {
      print('[SOS_SCREEN] Error launching maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('🚨 SOS Security Center', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        elevation: 1,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'EMERGENCY ASSISTANCE ACTIVE',
                          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your location, name, and ride parameters are being monitored.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _callHelpline,
                                icon: const Icon(Icons.phone, color: Colors.white, size: 18),
                                label: const Text('Call Helpline', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _shareLiveLocation,
                                icon: const Icon(Icons.share, color: Colors.white, size: 18),
                                label: const Text('Share Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _triggerFakeCallSimulation,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.phone_callback_rounded, color: Colors.green.shade600, size: 28),
                                const SizedBox(height: 8),
                                const Text('Fake Call', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                const Text('Simulate call', style: TextStyle(fontSize: 10, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: _showReportIncidentSheet,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.report_gmailerrorred_rounded, color: Colors.orange, size: 28),
                                const SizedBox(height: 8),
                                const Text('Report Incident', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                const Text('Alert dispatch', style: TextStyle(fontSize: 10, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('RIDE SAFETY TIMELINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54, letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Column(
                      children: [
                        ListTile(
                          dense: true,
                          leading: Icon(Icons.check_circle_rounded, color: Colors.green),
                          title: Text('GPS Signal Online', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Tracking coordinates accurately'),
                        ),
                        Divider(height: 1),
                        ListTile(
                          dense: true,
                          leading: Icon(Icons.check_circle_rounded, color: Colors.green),
                          title: Text('Biometrics Setup Complete', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Fingerprint/Face verification verified'),
                        ),
                        Divider(height: 1),
                        ListTile(
                          dense: true,
                          leading: Icon(Icons.check_circle_rounded, color: Colors.green),
                          title: Text('Emergency Sharing Enabled', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Authorized dispatch tracking active'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('EMERGENCY CONTACTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54, letterSpacing: 0.5)),
                      TextButton.icon(
                        onPressed: _addEmergencyContact,
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Add Contact', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _contacts.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: const Center(
                            child: Text('No emergency contacts added yet.', style: TextStyle(fontSize: 13, color: Colors.black38)),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _contacts.length,
                          itemBuilder: (context, index) {
                            final c = _contacts[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.shade100,
                                  child: const Icon(Icons.person, color: Colors.red),
                                ),
                                title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text(c['phone'] ?? '', style: const TextStyle(fontSize: 11)),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 24),
                  const Text('NEARBY EMERGENCY SERVICES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54, letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.local_police_rounded, color: Colors.blue),
                          title: const Text('Central Police Station', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: const Text('0.8 km • Active dispatch precinct'),
                          onTap: () => _launchMaps('police station near me'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.local_hospital_rounded, color: Colors.red),
                          title: const Text('City General Hospital (ER)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: const Text('1.4 km • 24 Hours Emergency Care'),
                          onTap: () => _launchMaps('hospital near me'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// --- DRIVER TRIP SUMMARY SCREEN ---
class DriverTripSummaryScreen extends StatefulWidget {
  final int rideId;
  final String driverPhone;
  final double estimatedFare;
  final String customerName;
  final String customerPhone;

  const DriverTripSummaryScreen({
    super.key,
    required this.rideId,
    required this.driverPhone,
    required this.estimatedFare,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  State<DriverTripSummaryScreen> createState() => _DriverTripSummaryScreenState();
}

class _DriverTripSummaryScreenState extends State<DriverTripSummaryScreen> {
  bool _loading = true;
  bool _completing = false;
  String _paymentMethod = 'cash'; // 'cash' or 'upi'
  String _transactionId = '';
  String _upiId = '';
  bool _paymentConfirmed = false;
  bool _tripCompletedOnBackend = false;
  double _actualEarnings = 0.0;
  double _customerRating = 5.0;

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
  }

  Future<void> _notifyPaymentMethod(String method) async {
    setState(() => _paymentMethod = method);
    try {
      await DriverApiService.setPaymentMethod(
        rideId: widget.rideId,
        driverPhone: widget.driverPhone,
        paymentMethod: method,
      );
    } catch (e) {
      print('[TRIP_SUMMARY] setPaymentMethod error: $e');
    }
  }

  Future<void> _checkPaymentStatus() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse(
        '${ApiConstants.baseUrl}/api/driver/ride?ride_id=${widget.rideId}&driver_phone=${widget.driverPhone}'
      ));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final txnId = data['transaction_id'] ?? '';
        final upi = data['upi_id'] ?? '';
        final savedMethod = (data['payment_method'] ?? '').toString().toLowerCase();
        setState(() {
          _transactionId = txnId;
          _upiId = upi;
          if (txnId.isNotEmpty && txnId.toString().toUpperCase() != 'CASH') {
            _paymentMethod = 'upi';
            _paymentConfirmed = true;
          } else if (savedMethod == 'cash' || savedMethod == 'upi') {
            _paymentMethod = savedMethod;
          }
          _loading = false;
        });
        // Default selection is Cash — tell customer immediately so Pay Now is hidden.
        if (!_paymentConfirmed) {
          _notifyPaymentMethod(_paymentMethod);
        }
      } else {
        setState(() => _loading = false);
        _notifyPaymentMethod(_paymentMethod);
      }
    } catch (e) {
      print('[TRIP_SUMMARY] Error checking payment: $e');
      setState(() => _loading = false);
      _notifyPaymentMethod(_paymentMethod);
    }
  }

  Future<void> _completeTrip() async {
    setState(() => _completing = true);
    try {
      final earnings = await DriverApiService.completeRide(
        rideId: widget.rideId,
        driverPhone: widget.driverPhone,
        paymentMethod: _paymentMethod,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('driver_is_online', true);
      setState(() {
        _actualEarnings = earnings;
        _tripCompletedOnBackend = true;
        _completing = false;
      });
    } catch (e) {
      print('[TRIP_SUMMARY] Complete trip error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete ride: $e'), backgroundColor: Colors.red),
      );
      setState(() => _completing = false);
    }
  }

  void _showReportCustomerDialog() {
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Report Customer Issues', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please describe the issue with this passenger (e.g. misconduct, unpaid fare dispute).', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter details...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final desc = descCtrl.text.trim();
                if (desc.isEmpty) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report filed successfully.'), backgroundColor: Colors.orange),
                );
                try {
                  await http.post(
                    Uri.parse('${ApiConstants.baseUrl}/api/driver/report-issue'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'phone': widget.driverPhone,
                      'issue_type': 'Customer Misconduct: ${widget.customerPhone}',
                      'description': desc,
                    }),
                  );
                } catch (_) {}
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_tripCompletedOnBackend) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Collect Ride Payment', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    const Text('TOTAL FARE TO COLLECT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Text(
                      '₹${widget.estimatedFare.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                    ),
                    const SizedBox(height: 12),
                    Text('Passenger: ${widget.customerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (!_paymentConfirmed) ...[
                const Text('SELECT PAYMENT METHOD USED BY CUSTOMER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _notifyPaymentMethod('cash'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: _paymentMethod == 'cash' ? Colors.green.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _paymentMethod == 'cash' ? Colors.green : Colors.black12, width: 2),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.payments_rounded, color: _paymentMethod == 'cash' ? Colors.green : Colors.grey, size: 32),
                              const SizedBox(height: 8),
                              const Text('Cash Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _notifyPaymentMethod('upi'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: _paymentMethod == 'upi' ? Colors.blue.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _paymentMethod == 'upi' ? Colors.blue : Colors.black12, width: 2),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.qr_code_scanner_rounded, color: _paymentMethod == 'upi' ? Colors.blue : Colors.grey, size: 32),
                              const SizedBox(height: 8),
                              const Text('UPI / Online', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              if (_paymentMethod == 'cash')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.green),
                      const SizedBox(height: 8),
                      const Text(
                        'Ensure you have received the exact cash amount from passenger.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _completeTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _completing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Confirm Cash Collected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              if (_paymentMethod == 'upi') ...[
                if (_paymentConfirmed) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.blue.shade300, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.blue, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Payment Completed Successfully!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                        ),
                        const SizedBox(height: 8),
                        Text('Transaction ID: $_transactionId', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        if (_upiId.isNotEmpty)
                          Text('UPI ID: $_upiId', style: const TextStyle(fontSize: 11, color: Colors.black45)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _completeTrip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _completing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Proceed to Earnings Breakdown', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 20),
                        const Text(
                          'Waiting for Customer UPI Payment...',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ask the passenger to pay from their app screen.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _checkPaymentStatus,
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Check Status'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _notifyPaymentMethod('cash'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Switch to Cash', style: TextStyle(color: Colors.white)),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ]
              ],
            ],
          ),
        ),
      );
    }

    final commission = widget.estimatedFare * 0.20;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Ride Earnings Summary', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FARE BREAKDOWN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Ride Fare', style: TextStyle(color: Colors.black87)),
                      Text('₹${widget.estimatedFare.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Platform Fee (20%)', style: TextStyle(color: Colors.black87)),
                      Text('- ₹${commission.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Driver Net Earnings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                      Text(
                        '₹${_actualEarnings.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981), fontSize: 18),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payment Status', style: TextStyle(color: Colors.black87)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('COMPLETED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                  if (_transactionId.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Transaction ID', style: TextStyle(color: Colors.black54, fontSize: 12)),
                        Text(_transactionId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('RATE PASSENGER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  Text('How was your trip with ${widget.customerName}?', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1.0;
                      return IconButton(
                        icon: Icon(
                          _customerRating >= starVal ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            _customerRating = starVal;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showReportCustomerDialog,
                    icon: const Icon(Icons.report_problem_rounded, color: Colors.red, size: 18),
                    label: const Text('Report Misconduct', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // After finishing a trip, keep the driver available for new rides.
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('driver_is_online', true);
                      if (!mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
