class ApiConstants {
  static const String baseUrl = 'http://13.201.83.177:8080';

  /// Set via `--dart-define=GEMINI_API_KEY=...` (do not commit real keys).
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
}
