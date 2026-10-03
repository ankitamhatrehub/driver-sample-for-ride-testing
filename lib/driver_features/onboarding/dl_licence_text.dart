import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Licence number and date of birth read from a driving-licence photo.
class LicenceFields {
  const LicenceFields({this.licenseNumber = '', this.dob = ''});

  final String licenseNumber;
  final String dob;

  bool get isComplete => licenseNumber.isNotEmpty && dob.isNotEmpty;
}

/// Reads the printed text on a licence photo.
Future<String> readDrivingLicenceText(String path) async {
  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  try {
    final result = await recognizer.processImage(InputImage.fromFilePath(path));
    return result.text;
  } finally {
    await recognizer.close();
  }
}

/// Pulls an Indian licence number (`SSRR+year+7 digits`) and a birth date
/// (`dd-mm-yyyy`) out of OCR text.
LicenceFields parseDrivingLicenceText(String raw, {DateTime? today}) {
  return LicenceFields(
    licenseNumber: _licenseNumber(raw),
    dob: _dateOfBirth(raw, today ?? DateTime.now()),
  );
}

/// Returns `dd-mm-yyyy` when [input] is a real birth date, otherwise null.
String? normalizeDob(String input, {DateTime? today}) {
  return _firstBirthDate(input, today ?? DateTime.now());
}

String _licenseNumber(String raw) {
  final compact = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  final match = RegExp(r'[A-Z]{2}[0-9OILSBZ]{13}').firstMatch(compact);
  if (match == null) return '';
  final token = match.group(0)!;
  final tail = token.substring(2).replaceAllMapped(RegExp(r'[OILSBZ]'), _digitLookalike);
  final candidate = '${token.substring(0, 2)}$tail';
  if (RegExp(r'^[A-Z]{2}\d{13}$').hasMatch(candidate)) return candidate;
  return '';
}

String _digitLookalike(Match match) {
  return switch (match.group(0)) {
    'O' => '0',
    'I' || 'L' => '1',
    'S' => '5',
    'B' => '8',
    'Z' => '2',
    _ => match.group(0)!,
  };
}

String _dateOfBirth(String raw, DateTime today) {
  final lines = raw.split(RegExp(r'\r?\n'));
  for (var i = 0; i < lines.length; i++) {
    if (!RegExp(r'd\.?\s*o\.?\s*b|date of birth|\bbirth\b', caseSensitive: false).hasMatch(lines[i])) {
      continue;
    }
    final window = i + 1 < lines.length ? '${lines[i]} ${lines[i + 1]}' : lines[i];
    final labeled = _firstBirthDate(window, today);
    if (labeled != null) return labeled;
  }
  return _oldestBirthDate(raw, today) ?? '';
}

String? _oldestBirthDate(String raw, DateTime today) {
  String? oldest;
  for (final match in _datePattern.allMatches(raw)) {
    final formatted = _formatBirth(match, today);
    if (formatted == null) continue;
    if (oldest == null || formatted.substring(6).compareTo(oldest.substring(6)) < 0) {
      oldest = formatted;
    }
  }
  return oldest;
}

String? _firstBirthDate(String raw, DateTime today) {
  final match = _datePattern.firstMatch(raw);
  if (match == null) return null;
  return _formatBirth(match, today);
}

final _datePattern = RegExp(r'(\d{2})\s*[\/\-.]\s*(\d{2})\s*[\/\-.]\s*(\d{4})');

String? _formatBirth(Match match, DateTime today) {
  final day = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final year = int.tryParse(match.group(3)!);
  if (day == null || month == null || year == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  if (year < 1940 || year > today.year - 16) return null;
  final dd = day.toString().padLeft(2, '0');
  final mm = month.toString().padLeft(2, '0');
  return '$dd-$mm-$year';
}
