/// Indian vehicle registration number read from an RC photo.
String? parseRegistrationNumber(String raw) {
  final compact = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  final standard = RegExp(r'[A-Z]{2}\d{1,2}[A-Z]{1,3}\d{4}').firstMatch(compact);
  if (standard != null) return standard.group(0);
  final bharat = RegExp(r'\d{2}BH\d{4}[A-Z]{1,2}').firstMatch(compact);
  return bharat?.group(0);
}

/// True when [input] is only a registration number, with spaces ignored.
bool isRegistrationNumber(String input) {
  final compact = input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  final parsed = parseRegistrationNumber(compact);
  return parsed != null && parsed == compact;
}
