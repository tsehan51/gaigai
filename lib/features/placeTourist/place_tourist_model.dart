import 'dart:convert';

import 'package:gaigai/util/json_parsing.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class PlaceTourist {
  PlaceTourist({
    required this.title,
    required this.id,
    required this.placeTourist, 
    required this.dateTourist, 
    required this.floodRisk, 
    required this.floodRiskExplanation, 
    required this.earthquakeRisk, 
    required this.earthquakeRiskExplanation, 
    required this.conclusion, 
    required this.conclusionExplanation, 
    required this.travelTips, 
   
  });

  final String id;
  final String title;
  final String placeTourist;
  final DateTime dateTourist ;
  final String floodRisk;
  final String floodRiskExplanation;
  final String earthquakeRisk;
  final String earthquakeRiskExplanation;
  final String conclusion;
  final String conclusionExplanation;
  final List<String> travelTips;

factory PlaceTourist.fromJson(Map<String, dynamic> json) {
  
    // Parse date with format detection
    final dateString = json['dateTourist'] as String;
    final dateTourist = _parseDate(dateString);
    
    // Convert travelTips from List<dynamic> to List<String>
    final travelTipsDynamic = json['travelTips'] as List<dynamic>;
    final travelTips = travelTipsDynamic.map((e) => e.toString()).toList();

  return PlaceTourist(
    id: json['id'] as String,
    title: json['title'] as String,
    placeTourist: json['placeTourist'] as String,
    dateTourist: dateTourist,
    floodRisk: json['floodRisk'] as String,
    floodRiskExplanation: json['floodRiskExplanation'] as String,
    earthquakeRisk: json['earthquakeRisk'] as String,
    earthquakeRiskExplanation: json['earthquakeRiskExplanation'] as String,
    conclusion: json['conclusion'] as String,
    conclusionExplanation: json['conclusionExplanation'] as String,
    travelTips: travelTips,
  );
}

Map<String, dynamic> toJson() {
  return {
   'id': id,
          'title': title,
          'placeTourist': placeTourist,
          'dateTourist': dateTourist,
          'floodRisk': floodRisk,
          'floodRiskExplanation': floodRiskExplanation,
          'earthquakeRisk': earthquakeRisk,
          'earthquakeRiskExplanation': earthquakeRiskExplanation,
          'conclusion': conclusion,
          'conclusionExplanation': conclusionExplanation,
         ' travelTips': travelTips,
  };
}

factory PlaceTourist.fromGeneratedContent(GenerateContentResponse content) {
  assert(content.text != null);
  
  try {
    // Clean and parse the JSON
    final validJson = cleanJson(content.text!);
    final dynamic decodedJson = jsonDecode(validJson);

    // Handle case where the response might be a List
    final Map<String, dynamic> jsonMap = decodedJson is List 
        ? decodedJson.first as Map<String, dynamic> 
        : decodedJson as Map<String, dynamic>;

    // Safe parsing with null checks
    return PlaceTourist(
      id: jsonMap['id']?.toString() ?? '',
      title: jsonMap['title']?.toString() ?? '',
      placeTourist: jsonMap['placeTourist']?.toString() ?? '',
      dateTourist: _parseDate(jsonMap['dateTourist']?.toString()),
      floodRisk: jsonMap['floodRisk']?.toString() ?? '',
      floodRiskExplanation: jsonMap['floodRiskExplanation']?.toString() ?? '',
      earthquakeRisk: jsonMap['earthquakeRisk']?.toString() ?? '',
      earthquakeRiskExplanation: jsonMap['earthquakeRiskExplanation']?.toString() ?? '',
      conclusion: jsonMap['conclusion']?.toString() ?? '',
      conclusionExplanation: jsonMap['conclusionExplanation']?.toString() ?? '',
      travelTips: (jsonMap['travelTips'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  } catch (e) {

    throw FormatException('Failed to parse PlaceTourist: ${e.toString()}');
  }
}

static DateTime _parseDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return DateTime.now();
  }

  try {
    // First try parsing directly as ISO format
    return DateTime.parse(dateString);
  } catch (_) {
    // If ISO format fails, try common patterns manually
    final patterns = [
      'yyyy-MM-dd',  // ISO-like
      'MM/dd/yyyy',  // US format
      'yyyy/MM/dd',  // Alternative format
      'dd-MM-yyyy',  // European format
      'dd/MM/yyyy'   // European format
    ];

    for (final pattern in patterns) {
      try {
        return DateFormat(pattern).parse(dateString);
      } catch (_) {}
    }

    // If all else fails, return current date
    return DateTime.now();
  }
}

  Map<String, Object?> toFirestore() {
    return {
          'id': id,
          'title': title,
          'placeTourist': placeTourist,
          'dateTourist': dateTourist,
          'floodRisk': floodRisk,
          'floodRiskExplanation': floodRiskExplanation,
          'earthquakeRisk': earthquakeRisk,
          'earthquakeRiskExplanation': earthquakeRiskExplanation,
          'conclusion': conclusion,
          'conclusionExplanation': conclusionExplanation,
         ' travelTips': travelTips,
    };
  }

  factory PlaceTourist.fromFirestore(Map<String, Object?> data) {
    if (data
        case {
          "id": String id,
          "title": String title,
          "placeTourist" : String placeTourist,
          "dateTourist": DateTime dateTourist,
          "floodRisk": String floodRisk,
          "floodRiskExplanation": String floodRiskExplanation,
          "earthquakeRisk": String earthquakeRisk,
          "earthquakeRiskExplanation": String earthquakeRiskExplanation,
          "conclusion": String conclusion,
          "conclusionExplanation": String conclusionExplanation,
          "travelTips":List<String> travelTips,
        }) {
      return PlaceTourist(
          id: id,
          title: title,
          placeTourist: placeTourist,
          dateTourist: dateTourist,
          floodRisk: floodRisk,
          floodRiskExplanation: floodRiskExplanation,
          earthquakeRisk: earthquakeRisk,
          earthquakeRiskExplanation: earthquakeRiskExplanation,
          conclusion: conclusion,
          conclusionExplanation: conclusionExplanation,
          travelTips: travelTips.map((i) => i.toString()).toList(),
      );
    }

    throw "Malformed Firestore data";
  }
}
