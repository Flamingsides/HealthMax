import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'nutrition_result_model.dart';

class CalorieEstimateService {
  late final GenerativeModel model;

  CalorieEstimateService() {
    final apiKey = dotenv.env["GEMINI_API_KEY"];

    if (apiKey == null || apiKey.isEmpty) {
      throw ("Gemini API key not found in .env file!");
    }

    model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        // Ensure output is in the right structure (JSON)
        responseMimeType: 'application/json',
      ),
    );

    // Getting AI calorie estimation from text
    Future<NutritionResult> getEstimationFromText(
      String foodDescription,
    ) async {
      final prompt =
          '''
You are a nutrition expert. Estimate the nutritional content for a food described as: "$foodDescription"

If there is missing information about portion sizes then assume portion for 1 person and specify assumption in "notes" in the JSON below.

Respond ONLY with this exact JSON structure:
{
  "foods": [
    {
      "name": "food name",
      "amount": "estimated portion (e.g. 1 cup, 150g)",
      "calories": 000,
      "protein_g": 00.0,
      "carbs_g": 00.0,
      "fat_g": 00.0,
      "fiber_g": 0.0
    }
  ],
  "total_calories": 000,
  "total_protein_g": 00.0,
  "total_carbs_g": 00.0,
  "total_fat_g": 00.0,
  "confidence": "high/medium/low",
  "notes": "any important notes"
}
''';

      final jsonResponse = await model.generateContent([Content.text(prompt)]);
      return NutritionResult.fromJson(jsonResponse.text!);
    }

    // Getting AI calorie estimate from image
    Future<NutritionResult> getEstimationFromImage(File imageFile) async {
      final imageBytes = await imageFile.readAsBytes();

      final prompt = '''
You are a nutrition expert analyzing a food photo.
Identify all visible foods and estimate their nutritional content.

Respond ONLY with this exact JSON structure:
{
  "foods": [
    {
      "name": "food name",
      "amount": "estimated portion",
      "calories": 000,
      "protein_g": 00.0,
      "carbs_g": 00.0,
      "fat_g": 00.0,
      "fiber_g": 0.0
    }
  ],
  "total_calories": 000,
  "total_protein_g": 00.0,
  "total_carbs_g": 00.0,
  "total_fat_g": 00.0,
  "confidence": "high/medium/low",
  "notes": "brief description of what you see"
}

Be realistic with portion sizes. If image is unclear, set confidence to "low".
''';

      final jsonResponse = await model.generateContent([
        Content.multi([TextPart(prompt), DataPart("image/jpeg", imageBytes)]),
      ]);

      return NutritionResult.fromJson(jsonResponse.text!);
    }
  }
}
