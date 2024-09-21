import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeyConfig {
  static String get googleGeminiApiKey =>
      dotenv.env['GOOGLE_GEMINI_API_KEY'] ?? '';
}
