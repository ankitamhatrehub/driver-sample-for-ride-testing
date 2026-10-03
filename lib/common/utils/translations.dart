import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTranslations {
  // Global value notifier for language state
  static final ValueNotifier<String> currentLanguage = ValueNotifier<String>(
    'en',
  );

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('app_language') ?? 'en';
    currentLanguage.value = savedLang;
  }

  static Future<void> changeLanguage(String langCode) async {
    currentLanguage.value = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', langCode);
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'quick_actions': 'QUICK ACTIONS',
      'language': 'Language',
      'english': 'English',
      'hindi': 'Hindi',
      'performance_metrics': 'Performance Metrics',
      'all_trip_activity': 'All Trip Activity',
      'wallet_settlements': 'Wallet & Settlements',
      'support_help': 'Support & Help',
      'my_profile': 'My Profile',
      'verified_partner': 'Verified Partner',
      'personal_details': 'Personal Details',
      'vehicle_registration': 'Vehicle & Registration',
      'documents': 'Documents',
      'bank_upi_details': 'Bank & UPI Details',
      'profile_info': 'Profile Info',
      'vehicle_details': 'Vehicle Details',
      'aadhaar_details': 'Aadhaar Details',
      'driving_license': 'Driving License',
      'rc_certificate': 'RC Certificate',
      'vehicle_insurance': 'Vehicle Insurance',
      'puc_certificate': 'PUC Certificate',
      'online': 'ONLINE',
      'offline': 'OFFLINE',
      'today_earnings': 'TODAY EARNINGS',
      'rating': 'Rating',
      'currently_offline': 'You are currently offline',
      'looking_for_trips': 'Looking for local trips',
      'go_online_orders': 'Go online to accept orders',
      'toggle_status': 'Toggle status switch at the top to start driving.',
      'add': 'Add',
      'edit': 'Edit',
      'save': 'Save',
      'cancel': 'Cancel',
      'logout': 'Logout',
      'select_preferred_language': 'Select Prefered\nLanguage',
      'continue_btn': 'Continue →',
      'language_changed_later': 'Language can be changed later from settings',
      'need_help': 'Need Help?',
      'enter_mobile_number': 'Enter Mobile Number',
      'enter_mobile_subtitle':
          'Enter your mobile number to begin. We\'ll verify most details automatically.',
      'i_agree_to_the': 'I agree to the ',
      'privacy_policy': 'Privacy Policy',
      'and_text': ' and ',
      'terms_conditions': 'Terms & Conditions',
      'valid_mobile_error': 'Please enter a valid 10-digit mobile number',
      'accept_terms_error':
          'Please accept the Privacy Policy and Terms & Conditions',
      'verify_with_otp': 'Verify with OTP',
      'enter_6_digit_code': 'Enter the 6-digit code sent to\n',
      'change_text': 'Change',
      'didnt_get_it': 'Didn\'t get it? ',
      'resend_otp_in': 'Resend OTP in ',
      'resend_otp': 'Resend OTP',
      'verify_action': 'Verify →',
      'enter_verification_code': 'Please enter verification code.',
    },
    'hi': {
      'quick_actions': 'त्वरित कार्रवाई',
      'language': 'भाषा (Language)',
      'english': 'English',
      'hindi': 'हिंदी',
      'performance_metrics': 'प्रदर्शन मेट्रिक्स',
      'all_trip_activity': 'सभी ट्रिप गतिविधि',
      'wallet_settlements': 'वॉलेट और सेटलमेंट',
      'support_help': 'सहायता और मदद',
      'my_profile': 'मेरी प्रोफाइल',
      'verified_partner': 'सत्यापित पार्टनर',
      'personal_details': 'व्यक्तिगत विवरण',
      'vehicle_registration': 'वाहन और पंजीकरण',
      'documents': 'दस्तावेज़',
      'bank_upi_details': 'बैंक और UPI विवरण',
      'profile_info': 'प्रोफाइल जानकारी',
      'vehicle_details': 'वाहन विवरण',
      'aadhaar_details': 'आधार विवरण',
      'driving_license': 'ड्राइविंग लाइसेंस',
      'rc_certificate': 'आरसी प्रमाणपत्र',
      'vehicle_insurance': 'वाहन बीमा',
      'puc_certificate': 'पीयूसी प्रमाणपत्र',
      'online': 'ऑनलाइन',
      'offline': 'ऑफ़लाइन',
      'today_earnings': 'आज की कमाई',
      'rating': 'रेटिंग',
      'currently_offline': 'आप वर्तमान में ऑफ़लाइन हैं',
      'looking_for_trips': 'स्थानीय ट्रिप खोज रहे हैं',
      'go_online_orders': 'ऑर्डर स्वीकार करने के लिए ऑनलाइन जाएं',
      'toggle_status':
          'ड्राइविंग शुरू करने के लिए शीर्ष पर स्थिति स्विच टॉगल करें।',
      'add': 'जोड़ें',
      'edit': 'संपादित करें',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'logout': 'लॉग आउट',
      'select_preferred_language': 'पसंदीदा\nभाषा चुनें',
      'continue_btn': 'जारी रखें →',
      'language_changed_later': 'भाषा बाद में सेटिंग्स से बदली जा सकती है',
      'need_help': 'मदद चाहिए?',
      'enter_mobile_number': 'मोबाइल नंबर दर्ज करें',
      'enter_mobile_subtitle':
          'शुरू करने के लिए अपना मोबाइल नंबर दर्ज करें। हम अधिकांश विवरणों को स्वचालित रूप से सत्यापित करेंगे।',
      'i_agree_to_the': 'मैं सहमत हूँ ',
      'privacy_policy': 'गोपनीयता नीति',
      'and_text': ' और ',
      'terms_conditions': 'नियम और शर्तों',
      'valid_mobile_error': 'कृपया एक वैध 10-अंकीय मोबाइल नंबर दर्ज करें',
      'accept_terms_error':
          'कृपया गोपनीयता नीति और नियम व शर्तों को स्वीकार करें',
      'verify_with_otp': 'OTP से सत्यापित करें',
      'enter_6_digit_code':
          'नीचे दिए गए नंबर पर भेजा गया 6 अंकों का कोड दर्ज करें:\n',
      'change_text': 'बदलें',
      'didnt_get_it': 'नहीं मिला? ',
      'resend_otp_in': 'OTP पुनः भेजें ',
      'resend_otp': 'OTP पुनः भेजें',
      'verify_action': 'सत्यापित करें →',
      'enter_verification_code': 'कृपया सत्यापन कोड दर्ज करें।',
    },
  };

  // Helper method to get the translated string
  static String tr(String key) {
    final lang = currentLanguage.value;
    return _translations[lang]?[key] ?? _translations['en']?[key] ?? key;
  }
}
