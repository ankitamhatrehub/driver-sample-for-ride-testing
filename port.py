import re

with open('lib/customer/screens/customer_screens.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Extract CustomerOnboardingScreen
start_idx = -1
end_idx = -1
for i, line in enumerate(lines):
    if 'class CustomerOnboardingScreen extends StatefulWidget {' in line:
        start_idx = i
    if 'class CustomerHomeScreen extends StatefulWidget {' in line:
        end_idx = i
        break

onboarding_code = ''.join(lines[start_idx:end_idx])

# 1. Rename Customer to Driver
onboarding_code = onboarding_code.replace('CustomerOnboardingScreen', 'DriverOnboardingScreen')
onboarding_code = onboarding_code.replace('CustomerHomeScreen', 'DriverHomeScreen')
onboarding_code = onboarding_code.replace('CustomerApp', 'DriverApp')

# 2. Fix the primary color and themes
onboarding_code = onboarding_code.replace('final isPink = _selectedGender == \'Female\';\n    final primaryColor = _step <= 6 \n        ? Colors.black \n        : (isPink ? const Color(0xFFEC4899) : const Color(0xFF6366F1));', 'final isPink = false;\n    final primaryColor = const Color(0xFF4F46E5);')

# 3. Add DL OCR step
# First add DL variables
onboarding_code = onboarding_code.replace('XFile? _aadhaarBackImage;', 'XFile? _aadhaarBackImage;\n  XFile? _dlImage;')
onboarding_code = onboarding_code.replace('final _aadhaarNumberController = TextEditingController();', 'final _aadhaarNumberController = TextEditingController();\n  final _dlNumberController = TextEditingController();')

# We need to insert a DL OCR process
dl_ocr_code = '''
  Future<void> _processDlOcr() async {
    if (_dlImage == null) {
      _completeDlOcrProcess();
      return;
    }
    try {
      final imageBytes = await _dlImage!.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=YOUR_GEMINI_API_KEY');
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
      print('DL OCR Error: \');
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
'''
onboarding_code = onboarding_code.replace('void _completeOcrProcess() {', dl_ocr_code + '\n  void _completeOcrProcess() {')

# Redirect Aadhaar complete to DL upload instead of Review
onboarding_code = onboarding_code.replace('_nextStep(); // Advance to Step 6 (Review & Confirm)', '_step = 10; // Go to DL Upload')

# Add DL Upload UI
dl_ui_code = '''
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
'''
onboarding_code = onboarding_code.replace('Widget _buildStep6ConfirmDetails(Color primaryColor) {', dl_ui_code + '\n  Widget _buildStep6ConfirmDetails(Color primaryColor) {')

# Update buildStepContent switch
onboarding_code = onboarding_code.replace('case 9:\n        return _buildStep9BiometricVerify(primaryColor);', 'case 9:\n        return _buildStep9BiometricVerify(primaryColor);\n      case 10:\n        return _buildStep10DlUpload(primaryColor);\n      case 11:\n        return _buildStep11DlOcrProgress(primaryColor);')

# Update Confirm Details to show DL
onboarding_code = onboarding_code.replace('const Divider(height: 32),', 'const Divider(height: 32),\n                        _buildDetailRow(\'DL Number\', _dlNumberController.text),\n                        const Divider(height: 32),')

# Update backend saving logic to include DL
onboarding_code = onboarding_code.replace("'aadhaar_number': _aadhaarNumberController.text,", "'aadhaar_number': _aadhaarNumberController.text,\n        'dl_number': _dlNumberController.text,")

# Save back to a temp file
with open('lib/driver/screens/driver_onboarding_temp.dart', 'w', encoding='utf-8') as f:
    f.write(onboarding_code)

print('Generated driver_onboarding_temp.dart')
