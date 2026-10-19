class ApiConstants {
  static const String baseUrl = 'http://3.110.156.16:8080';

  /// Set via `--dart-define=GEMINI_API_KEY=...` (do not commit real keys).
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
}
