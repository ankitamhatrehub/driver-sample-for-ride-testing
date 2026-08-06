import 'package:flutter/foundation.dart';

class AppTranslations {
  // Global value notifier for language state
  static final ValueNotifier<String> currentLanguage = ValueNotifier<String>('en');

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
      'logout': 'Logout'
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
      'toggle_status': 'ड्राइविंग शुरू करने के लिए शीर्ष पर स्थिति स्विच टॉगल करें।',
      'add': 'जोड़ें',
      'edit': 'संपादित करें',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'logout': 'लॉग आउट'
    }
  };

  // Helper method to get the translated string
  static String tr(String key) {
    final lang = currentLanguage.value;
    return _translations[lang]?[key] ?? _translations['en']?[key] ?? key;
  }
}
