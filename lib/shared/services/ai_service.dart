import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // Put your actual Google AI Studio key here
  static const String _apiKey = 'AIzaSyDde40Mgc-MTNBp1OwIXY0EhcTxLLLgk1Q';

  static Future<String> getAnswer(String userText) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );

    final prompt = [Content.text(userText)];
    final response = await model.generateContent(prompt);

    return response.text ?? 'No answer provided.';
  }
}