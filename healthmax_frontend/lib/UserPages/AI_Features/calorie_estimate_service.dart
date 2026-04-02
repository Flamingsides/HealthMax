import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'nutrition_result_model.dart';

class CalorieEstimatorService {
  late final GenerativeModel model;

  CalorieEstimatorService() {
    String? apiKey = dotenv.env["GEMINI_API_KEY"];

    if (apiKey == null || apiKey.isEmpty) {
      apiKey = const String.fromEnvironment('GEMINI_API_KEY');
      if (apiKey.isEmpty) {
        throw ("Gemini API key not found in .env file!");
      }
    }

    model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  // Helper function to clean Markdown formatting
  String _cleanJsonResponse(String text) {
    String cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.replaceFirst('```json', '');
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst('```', '');
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }

  // Getting AI calorie estimation from text
  Future<NutritionResult> estimateFromText(String foodDescription) async {
    final prompt = '''
You are a nutrition expert. Estimate the nutritional content for a food described as: "$foodDescription"

If there is missing information then assume and specify assumption in "notes" in the JSON below.

CRITICAL INSTRUCTIONS: 
1. Extract the exact quantity/servings requested. If the user says "3 fried chickens", the "servings" value MUST be 3.
2. The "total_calories_kcal" and all other "total_*" fields MUST represent the COMBINED total for ALL servings requested.

Respond ONLY with this exact JSON structure:
{
  "label": "Name of the food without the number (e.g. 'Fried Chicken')",
  "servings": <integer representing the exact quantity>,
  "foods": [
    {
      "name": "food name",
      "amount": "estimated portion for one serving",
      "calories_kcal": 000,
      "protein_g": 00.0,
      "carbs_g": 00.0,
      "fat_g": 00.0,
      "fiber_g": 0.0
    }
  ],
  "total_calories_kcal": 000,
  "total_protein_g": 00.0,
  "total_carbs_g": 00.0,
  "total_fat_g": 00.0,
  "confidence": "00.0%",
  "notes": "any important notes"
}
''';

    final jsonResponse = await model.generateContent([Content.text(prompt)]);
    String rawText = jsonResponse.text ?? "{}";
    
    // Apply the cleaner before parsing
    String cleanJson = _cleanJsonResponse(rawText);
    return await NutritionResult.fromJsonAsync(cleanJson);
  }

  // Getting AI calorie estimate from image
  Future<NutritionResult> estimateFromImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();

    final prompt = '''
You are a nutrition expert analyzing a food photo.
Identify all visible foods and estimate their nutritional content.

CRITICAL INSTRUCTIONS: 
1. Estimate the exact quantity/servings visible. If there are 3 slices of pizza, the "servings" value MUST be 3.
2. The "total_calories_kcal" and all other "total_*" fields MUST represent the COMBINED total for ALL servings visible.

Respond ONLY with this exact JSON structure:
{
  "label": "Concise label for this food without numbers",
  "servings": <integer representing the exact quantity visible>,
  "foods": [
    {
      "name": "food name",
      "amount": "estimated portion for one serving",
      "calories_kcal": 000,
      "protein_g": 00.0,
      "carbs_g": 00.0,
      "fat_g": 00.0,
      "fiber_g": 0.0
    }
  ],
  "total_calories_kcal": 000,
  "total_protein_g": 00.0,
  "total_carbs_g": 00.0,
  "total_fat_g": 00.0,
  "confidence": "00.0%",
  "notes": "brief description of what you see"
}
''';

    final jsonResponse = await model.generateContent([
      Content.multi([TextPart(prompt), DataPart("image/jpeg", imageBytes)]),
    ]);

    String rawText = jsonResponse.text ?? "{}";
    
    // Apply the cleaner before parsing
    String cleanJson = _cleanJsonResponse(rawText);
    return await NutritionResult.fromJsonAsync(cleanJson);
  }
}