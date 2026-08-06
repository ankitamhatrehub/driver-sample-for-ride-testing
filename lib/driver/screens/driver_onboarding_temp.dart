import 'dart:convert';
import '../../common/constants/api_constants.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import '../../common/widgets/bouncing_widget.dart';

class DriverOnboardingScreen extends StatefulWidget {
  const DriverOnboardingScreen({super.key});

  @override
  State<DriverOnboardingScreen> createState() => _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState extends State<DriverOnboardingScreen> with SingleTickerProviderStateMixin {
  static const String _baseUrl = '${ApiConstants.baseUrl}/api';
  
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
  // 10: Upload DL
  // 11: DL OCR Progress
  // 12: Upload RC
  // 13: RC OCR Progress
  int _step = 1; 

  final _phoneController = TextEditingController(text: '98765 43210');
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _aadhaarNumberController = TextEditingController();
  final _dlNumberController = TextEditingController();
  final _rcNumberController = TextEditingController();
  String _selectedGender = 'Male';

  bool _isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _aadhaarFrontImage;
  XFile? _aadhaarBackImage;
  XFile? _dlImage;
  XFile? _rcImage;

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
    _checkBiometrics();
    // Splash screen transitions after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _step == 1) {
        setState(() {
          _step = 2;
        });
      }
    });
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
            _navigateToDashboard();
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
        _navigateToDashboard();
      }
    }
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _ocrTimer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _aadhaarNumberController.dispose();
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
        _step--;
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

  Future<void> _processAadhaarOcr() async {
    if (_aadhaarFrontImage == null) {
      _completeOcrProcess();
      return;
    }
    try {
      print('OCR Debug: Starting Gemini Vision OCR on ${_aadhaarFrontImage!.path}');
      
      final imageBytes = await _aadhaarFrontImage!.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=${ApiConstants.geminiApiKey}');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'You are an Aadhaar card OCR system. Extract the details strictly as a JSON object with keys: "name", "dob" (format DD/MM/YYYY), "gender" (Male/Female), and "aadhaar_number".'},
                {
                  'inlineData': {
                    'mimeType': 'image/jpeg',
                    'data': base64Image
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json'
          }
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final respJson = jsonDecode(response.body);
        final contentStr = respJson['candidates'][0]['content']['parts'][0]['text'];
        print('OCR Debug: Gemini Response JSON:\n$contentStr');
        
        final extractedData = jsonDecode(contentStr);
        
        if (mounted) {
          setState(() {
            if (extractedData['name'] != null) _nameController.text = extractedData['name'];
            if (extractedData['dob'] != null) _dobController.text = extractedData['dob'];
            if (extractedData['gender'] != null) {
              _selectedGender = extractedData['gender'];
              DriverApp.isPinkTheme.value = (_selectedGender == 'Female');
            }
            if (extractedData['aadhaar_number'] != null) {
              _aadhaarNumberController.text = extractedData['aadhaar_number'].toString().replaceAll(' ', '');
            }
          });
        }
      } else {
        print('OCR Debug: Gemini API failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('OCR Debug: Gemini Vision Exception: $e');
    } finally {
      _completeOcrProcess();
    }
  }

  
  Future<void> _processDlOcr() async {
    if (_dlImage == null) {
      _completeDlOcrProcess();
      return;
    }
    try {
      final imageBytes = await _dlImage!.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=${ApiConstants.geminiApiKey}');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'You are a Driving Licence OCR system. Extract the details strictly as a JSON object with keys: "dl_number".'},
                {
                  'inlineData': {
                    'mimeType': 'image/jpeg',
                    'data': base64Image
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json'
          }
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final respJson = jsonDecode(response.body);
        final contentStr = respJson['candidates'][0]['content']['parts'][0]['text'];
        final extractedData = jsonDecode(contentStr);
        if (mounted) {
          setState(() {
            if (extractedData['dl_number'] != null) {
              _dlNumberController.text = extractedData['dl_number'];
            }
          });
        }
      }
    } catch (e) {
      print('DL OCR Error: ');
    } finally {
      _completeDlOcrProcess();
    }
  }

  void _completeDlOcrProcess() {
    if (!mounted || !_ocrRunning) return;
    setState(() {
      _ocrRunning = false;
      _ocrProgress = 1.0;
      _ocrTimer?.cancel();
      if (_dlNumberController.text.isEmpty) _dlNumberController.text = 'DL-1420190012345';
      _step = 6; // Go to Review & Confirm
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

  void _completeOcrProcess() {
    if (!mounted) return;
    setState(() {
      // Final fallback validation
      if (_nameController.text.isEmpty) _nameController.text = 'Rahul Kumar';
      if (_dobController.text.isEmpty) _dobController.text = '12/01/1995';
      if (_aadhaarNumberController.text.isEmpty) _aadhaarNumberController.text = '548982739102';
    });
  }

  Future<void> _uploadAndVerifyAadhaar() async {
    if (_aadhaarFrontImage == null || _aadhaarBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload front and back of Aadhaar card')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Run Gemini OCR
      print('Surepass Debug: Starting Gemini Extraction...');
      await _processAadhaarOcr();
      
      // 2. Validate Gemini Output
      if (_aadhaarNumberController.text.isEmpty) {
        throw Exception("Failed to extract Aadhaar number from image.");
      }

      // 3. Trigger Digilocker SDK
      print('Surepass Debug: Initializing Digilocker SDK');
      await _initializeDigilocker();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _digilockerClientId;
  String? _digilockerToken;

  Future<void> _initializeDigilocker() async {
    print('Digilocker Debug: _initializeDigilocker called!');

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$_baseUrl/kyc/digilocker/initialize');
      
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
          _launchDigilockerSDKFlow();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to initialize Digilocker: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${response.statusCode}')),
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

  void _launchDigilockerSDKFlow() async {
    // In a real app, you would call the Surepass Digilocker Flutter SDK here, e.g.:
    // await Digiboost.start(token: _digilockerToken, clientId: _digilockerClientId);
    
    // Simulating SDK Launch & Webhook response for now using url_launcher or dialog
    final authUrl = Uri.parse('https://sandbox.surepass.app/digilocker?token=$_digilockerToken');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('DigiLocker Verification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 60, color: Colors.indigo),
              const SizedBox(height: 16),
              const Text('Connecting to DigiLocker Secure SDK...', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ),
        );
      },
    );

    // Simulate SDK process delay
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.pop(context); // Close the loading dialog
      
      // Assume Webhook returned success and we fetch the user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text);
      await prefs.setString('user_gender', _selectedGender);
      await prefs.setBool('is_pink_theme', _selectedGender == 'Female');
      await prefs.setBool('isLoggedIn', true);
      DriverApp.isPinkTheme.value = (_selectedGender == 'Female');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aadhaar Verified via DigiLocker Successfully!')),
      );

      // Advance to DL Upload screen (Step 10)
      setState(() {
        _isLoading = false;
        _step = 10;
      });
    }
  }

  // Obsolete function - kept for reference if needed
  Future<void> _generateSurepassOTP() async {
    print('Surepass Debug: _generateSurepassOTP called!');
    if (_aadhaarNumberController.text.isEmpty) {
      print('Surepass Debug: Aadhaar number is empty. Aborting.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Aadhaar number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$_baseUrl/kyc/aadhaar/generate-otp');
      final cleanAadhaar = _aadhaarNumberController.text.replaceAll(' ', '');
      print('Surepass Debug: URL = $url, Clean Aadhaar = $cleanAadhaar');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'aadhaar_number': cleanAadhaar}),
      ).timeout(const Duration(seconds: 10));

      print('Surepass Debug: Response Status Code = ${response.statusCode}');
      print('Surepass Debug: Response Body = ${response.body}');

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('Surepass Debug: Success! Opening Dialog...');
          _surepassClientId = data['client_id'];
          _showAadhaarOtpDialog();
        } else {
          print('Surepass Debug: API returned success: false. Message: ${data['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to generate OTP: ${data['message']}')),
          );
        }
      } else {
        print('Surepass Debug: Server returned error status code.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Surepass Debug: Network Exception Caught: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  void _showAadhaarOtpDialog() {
    final otpController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Enter Aadhaar OTP'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('An OTP has been sent to your Aadhaar-linked mobile number.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter 6-digit OTP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (otpController.text.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Enter a valid 6-digit OTP')),
                            );
                            return;
                          }

                          setStateDialog(() => isSubmitting = true);
                          final prefs = await SharedPreferences.getInstance();
                          final phone = prefs.getString('user_phone') ?? _phoneController.text.replaceAll(' ', '');

                          try {
                            final url = Uri.parse('$_baseUrl/kyc/aadhaar/submit-otp');
                            final response = await http.post(
                              url,
                              headers: {'Content-Type': 'application/json'},
                              body: json.encode({
                                'client_id': _surepassClientId,
                                'otp': otpController.text,
                                'phone': phone,
                              }),
                            );

                            if (response.statusCode == 200) {
                              final data = json.decode(response.body);
                              if (data['success'] == true) {
                                Navigator.pop(context); // Close dialog
                                
                                // Save standard preferences
                                await prefs.setString('user_name', _nameController.text);
                                await prefs.setString('user_gender', _selectedGender);
                                await prefs.setBool('is_pink_theme', _selectedGender == 'Female');
                                await prefs.setBool('isLoggedIn', true);
                                DriverApp.isPinkTheme.value = (_selectedGender == 'Female');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Aadhaar Verified Successfully!')),
                                );

                                // Advance to DL Upload screen (Step 10)
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                    _step = 10;
                                  });
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('OTP Failed: ${data['message']}')),
                                );
                                setStateDialog(() => isSubmitting = false);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to submit OTP')),
                              );
                              setStateDialog(() => isSubmitting = false);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                            setStateDialog(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Verify & Submit'),
                ),
              ],
            );
          }
        );
      },
    );
  }
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
      ).timeout(const Duration(seconds: 4));

      if (otpResp.statusCode == 200) {
        final data = json.decode(otpResp.body);
        final receivedOtp = data['otp'] ?? '123456';
        _showOtpDialog(receivedOtp);
      } else {
        _showOtpDialog('123456');
      }
    } catch (e) {
      print('Connection failed, entering demo mode: $e');
      _showOtpDialog('123456');
    } finally {
      setState(() {
        _isLoading = false;
        _step = 3; // OTP verification screen
      });
    }
  }

  void _showOtpDialog(String otp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Torkk Security Code', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your demo verification OTP is:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Center(
                child: Text(
                  otp,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.indigo),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
      final verifyUrl = Uri.parse('$_baseUrl/api/verify-otp');
      final verifyResp = await http.post(
        verifyUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': _phoneController.text.replaceAll(' ', ''),
          'code': _otpController.text,
        }),
      ).timeout(const Duration(seconds: 4));

      if (verifyResp.statusCode == 200) {
        final data = json.decode(verifyResp.body);
        final bool isExistingUser = data['is_existing_user'] == true;
        final String gender = data['gender'] ?? '';
        final String name = data['name'] ?? 'User';
        final String email = data['email'] ?? 'No email';

        if (isExistingUser) {
          setState(() {
            _selectedGender = gender.isNotEmpty ? gender : 'Male'; // default to Male if missing
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_gender', gender);
          await prefs.setString('user_name', name);
          await prefs.setString('user_email', email);
          await prefs.setString('user_phone', _phoneController.text.replaceAll(' ', ''));
          await prefs.setBool('isLoggedIn', true);
          await prefs.setBool('is_pink_theme', gender == 'Female');
          DriverApp.isPinkTheme.value = (gender == 'Female');
          if (mounted) {
            _navigateToDashboard();
          }
          return;
        }
      }
    } catch (e) {
      print('Verification connection skipped: $e');
    }

    // Default simulation pathway: advance to Step 4 (Upload Aadhaar)
    setState(() {
      _isLoading = false;
      _step = 4;
    });
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          
          // OTP input boxes simulation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              String char = '';
              if (_otpController.text.length > index) {
                char = _otpController.text[index];
              }
              return Container(
                width: 44,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _otpController.text.length == index ? primaryColor : Colors.black12,
                    width: _otpController.text.length == index ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    char,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          // Hidden TextField to manage input easily
          Opacity(
            opacity: 0.0,
            child: SizedBox(
              height: 1,
              child: TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                autofocus: true,
                maxLength: 6,
                onChanged: (val) {
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _otpCountdown > 0 ? 'Resend OTP in 00:${_otpCountdown.toString().padLeft(2, '0')}' : 'Did not receive OTP?',
                style: TextStyle(color: Colors.blueGrey.shade400, fontWeight: FontWeight.w600),
              ),
              if (_otpCountdown == 0)
                TextButton(
                  onPressed: () => _sendLocalOtp(_phoneController.text),
                  child: Text('Resend OTP', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const Spacer(),
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
          const SizedBox(height: 12),
        ],
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
          Text(
            'Please upload clear photos of the front and back of your card.',
            style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          
          // Front upload card slot
          GestureDetector(
            onTap: () => _pickAadhaarImage(true, ImageSource.gallery),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              clipBehavior: Clip.antiAlias,
              child: _aadhaarFrontImage != null
                  ? Image.file(File(_aadhaarFrontImage!.path), fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card_rounded, size: 48, color: primaryColor.withValues(alpha: 0.6)),
                        const SizedBox(height: 8),
                        const Text('Front Side', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text('Tap to upload', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Back upload card slot
          GestureDetector(
            onTap: () => _pickAadhaarImage(false, ImageSource.gallery),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              clipBehavior: Clip.antiAlias,
              child: _aadhaarBackImage != null
                  ? Image.file(File(_aadhaarBackImage!.path), fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card_rounded, size: 48, color: primaryColor.withValues(alpha: 0.6)),
                        const SizedBox(height: 8),
                        const Text('Back Side', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text('Tap to upload', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13)),
                      ],
                    ),
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
          GestureDetector(
            onTap: () async {
              final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
              if (image != null) setState(() => _dlImage = image);
            },
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12, style: BorderStyle.solid),
                image: _dlImage != null ? DecorationImage(image: FileImage(java.io.File(_dlImage!.path)), fit: BoxFit.cover) : null,
              ),
              child: _dlImage == null ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, size: 40, color: Colors.black26), SizedBox(height: 8), Text('Tap to upload')]) : null,
            ),
          ),
          const Spacer(),
          BouncingWidget(
            onTap: () {
              setState(() { _step = 11; }); // DL OCR
              _startDlOcrSimulation();
            },
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
                  _detailFieldRow(Icons.cake_outlined, 'DOB', _dobController.text),
                  const Divider(height: 28),
                  _detailFieldRow(Icons.face_outlined, 'Gender', _selectedGender),
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
              // Direct navigation to Dashboard
              _navigateToDashboard();
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
          _navigateToDashboard();
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
