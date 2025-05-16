import 'package:gaigai/services/gemini.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../services/firestore.dart';
import '../placeTourist/place_tourist_model.dart';
import 'prompt_model.dart';

class PromptViewModel extends ChangeNotifier {
  PromptViewModel({
    required this.textModel,
  });

  final GenerativeModel textModel;
  bool loadingNewplaceTourist = false;
  bool isLoading = false;

  PromptData userPrompt = PromptData.empty();
  TextEditingController promptTextController = TextEditingController();

  PlaceTourist? placeTourist;
  String? _geminiFailureResponse;
  String? get geminiFailureResponse => _geminiFailureResponse;
  set geminiFailureResponse(String? value) {
    _geminiFailureResponse = value;
    notifyListeners();
  }

  DateTime? _selectedDate; 

  DateTime? get selectedDate => _selectedDate;

  set selectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();  
  }

  void notify() => notifyListeners();

  void resetPrompt() {
    userPrompt = PromptData.empty();
    notifyListeners();
  }

  PromptData buildPrompt() {
    return PromptData(
      textInput: mainPrompt,
    );
  }

  Future<void> submitPrompt() async {
    loadingNewplaceTourist = true;
    isLoading = true;
    geminiFailureResponse = null;
    placeTourist = null; 
    notifyListeners();

    try {
      final model = textModel;
      final prompt = buildPrompt();

      final content = await GeminiService.generateContent(model, prompt);

      if (content.text != null) {
        placeTourist = PlaceTourist.fromGeneratedContent(content);
      } else {
        geminiFailureResponse = 'No text response received from Gemini';
      }
    } catch (error) {
      geminiFailureResponse = 'Failed to reach Gemini. \n\n$error';
      if (kDebugMode) {
        debugPrint(error.toString());
      }
    } finally {
      loadingNewplaceTourist = false;
      isLoading = false;
      notifyListeners();
    }
  }

  String get mainPrompt {
    return '''
You are a disaster information expert and a travel safety advisor at the same time. You are able to provide information on the flood and earthquake risks for the location tourists plan to visit using the latest and reliable available data provided by the government of Japan and organizations which are responsible for giving warnings or information regarding the risks of floods or earthquakes worldwide. 

Guide me based on the current risk and suggest whether it might be safe to travel to the $promptTextController on $selectedDate or i should reconsider.

 Return your response ONLY in raw JSON format — no explanations, no markdown, and no extra text.
Use this exact structure:
{
  "title": \$placeTouristTitle,
  "id": \$uniqueId,
  "placeTourist" : \$placeTourist,
  "dateTourist": \$dateTourist,
  "floodRisk": \$floodRisk,
  "floodRiskExplanation": \$floodRiskExplanation,
  "earthquakeRisk": \$earthquakeRisk,
  "earthquakeRiskExplanation": \$earthquakeRiskExplanation,
  "scamRiskLevel": \$scamRiskLevel,
  "scamTypes": \$scamTypes,
  "conclusion": \$conclusion,
  "conclusionExplanation": \$conclusionExplanation,
  "travelTips":\$travelTips,
}
  
uniqueId should be unique and of type String. 
placeTouristTitle, placeTourist, dateTourist, floodRisk, floodRiskExplanation, earthquakeRisk, earthquakeRiskExplanation, scamRiskLevel, scamTypes, conclusion and conclusionExplanation should be of String type.
dateTourist should not contain the time portion. 
travelTip should be of type List<String>.

i want to know about
risk of flood on $selectedDate: Very High, High, Moderate, Low or Very Low and explanation
risk of earthquake on $selectedDate: Very High, High, Moderate, Low or Very Low and explanation
Should tourist visit on $selectedDate: Yes or No and explanation
scamRiskLevel must be one of: "Low Risk", "Medium Risk", "High Risk"  
scamTypes should be a comma-separated list of scam types (e.g., fake taxis, overpricing, pickpocketing)

if tourist should not visit $promptTextController on $selectedDate then,
alternative date the tourist can visit$promptTextController :
alternative places you can visit in $promptTextController are:
alternative place you can visit in the world are:

If tourist should visit $promptTextController on $selectedDate then,
Travel Tips:
''';
  }

  Future<bool> isBookmarked() async {
    bool result = await FirestoreService.isBookmarked(placeTourist!);
  
    if (result) {
    return true;
    } else {
      return false;
    }
  }

  void toggleBookmark() async {
    if (await isBookmarked()) {
      await FirestoreService.deletePlace(placeTourist!);
    } else {
      await FirestoreService.savePlace(placeTourist!);
    }

    notifyListeners();
  }

}
  


