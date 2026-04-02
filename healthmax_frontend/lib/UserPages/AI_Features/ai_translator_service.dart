import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class AiTranslatorService {
  // Singleton pattern so the cache is shared across the entire app
  static final AiTranslatorService _instance = AiTranslatorService._internal();
  factory AiTranslatorService() => _instance;
  AiTranslatorService._internal();

  // The memory cache: Saves translated strings so we don't waste API calls!
  final Map<String, String> _cache = {};

  Future<String> translate(String text, String targetLangCode) async {
    if (targetLangCode == 'en' || text.trim().isEmpty) return text;

    // Check if we already translated this exact phrase
    String cacheKey = "$targetLangCode:${text.trim()}";
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    String languageName = "English";
    switch (targetLangCode) {
      case 'ms':
        languageName = "Malay";
        break;
      case 'zh':
        languageName = "Simplified Chinese";
        break;
      case 'ta':
        languageName = "Tamil";
        break;
    }

    final prompt =
        '''
You are a professional translator inside a health app. Translate the following text into $languageName.
Respond ONLY with the translated text. Keep it brief. Do not add quotes or explanations.
Text to translate: "$text"
''';
    String? apiKey = dotenv.env["GEMINI_API_KEY"];
    if (apiKey == null || apiKey.isEmpty) {
      apiKey = const String.fromEnvironment('GEMINI_API_KEY');
      if (apiKey.isEmpty) {
        throw ("Gemini API key not found in .env file!");
      }
    }

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
      final response = await model.generateContent([Content.text(prompt)]);
      final translated = response.text?.trim() ?? text;

      _cache[cacheKey] = translated; // Save to memory
      return translated;
    } catch (e) {
      print("Translation Error: $e");
      return text;
    }
  }
}

// ==========================================
// MAGIC CUSTOM WIDGET
// Drop this anywhere you need dynamic text translated!
// ==========================================
class AiTranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AiTranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = Provider.of<ThemeProvider>(context).currentLanguage;

    if (langCode == 'en') {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return FutureBuilder<String>(
      future: AiTranslatorService().translate(text, langCode),
      builder: (context, snapshot) {
        // While loading, show the original English text slightly faded so the UI doesn't look empty
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            text,
            style: style?.copyWith(color: style?.color?.withValues(alpha: 0.5)),
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );
        }
        return Text(
          snapshot.data ?? text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
