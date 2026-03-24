import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CalorieEstimateService {
  late final GenerativeModel model;

  CalorieEstimateService() {
    final API_KEY = dotenv.env["GEMINI_API_KEY"];

    if (API_KEY == null || API_KEY.isEmpty) {
      throw ("Gemini API key not found in .env file!");
    }

    model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: API_KEY!,
      generationConfig: GenerationConfig(
        // Ensure output is in the right structu (JSON)
        responseMimeType: 'application/json',
      ),
    );
  }

  // TODO: Add methods to send requests to API and parse responses
}
