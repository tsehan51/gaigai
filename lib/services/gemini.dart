import 'package:google_generative_ai/google_generative_ai.dart';

import '../features/prompt/prompt_model.dart';

class GeminiService {
  static Future<GenerateContentResponse> generateContent(
      GenerativeModel model, PromptData prompt) async {
      return await GeminiService.generateContentFromText(model, prompt);
  }

  static Future<GenerateContentResponse> generateContentFromText(
      GenerativeModel model, PromptData prompt) async {
    final mainText = TextPart(prompt.textInput);
    final additionalTextParts =
        prompt.placeTouristTextInput.map((t) => TextPart(t)).join("\n");

    return await model.generateContent([
      Content.text(
        '${mainText.text} \n $additionalTextParts',
      )
    ]);
  }
}
