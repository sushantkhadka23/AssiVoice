import 'package:assivoice/config/api_key_config.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GenerativeModelService {
  final String apiKey = ApiKeyConfig.googleGeminiApiKey;

  /// Sends input to the Google Generative AI model and returns a response.
  Future<String> getResponseUsingModel(String input) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );
      final prompt = Content.text(input);
      final response = await model.generateContent([prompt]);
      return response.text.toString();
    } catch (e) {
      return 'Sorry, I could not generate a response. Please try again later.';
    }
  }
}
