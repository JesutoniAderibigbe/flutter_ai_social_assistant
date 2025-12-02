import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/post_data.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY']!;
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  Future<PostData> generatePost({
    required File image,
    required String platform,
    String userStyle = 'casual and authentic',
  }) async {
    try {
      // Read image bytes
      final imageBytes = await image.readAsBytes();

      // Create prompt with context
      final prompt = _buildPrompt(platform, userStyle);

      // Create content with image and text
      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      // Generate response
      final response = await _model.generateContent(content);

      // Parse response
      return _parseResponse(response.text!, platform);
    } catch (e) {
      throw Exception('Failed to generate post: $e');
    }
  }

  String _buildPrompt(String platform, String userStyle) {
    // THE SECRET SAUCE - Prompt Engineering
    return '''
You are a social media expert helping create engaging posts.

CONTEXT:
- Platform: $platform
- User's style: $userStyle
- Image: Analyze the uploaded image

TASK:
Analyze this image and create a compelling social media post.

REQUIREMENTS:
1. Write a caption that:
   - Captures the mood and story in the image
   - Matches the user's personal voice ($userStyle)
   - Is optimized for $platform
   - Feels authentic, not robotic
   
2. For Instagram: 150-200 words, emoji-friendly, story-driven
3. For Twitter: Under 280 chars, punchy, conversational
4. For LinkedIn: Professional tone, insight-driven, 100-150 words

5. Include relevant hashtags (5-8 for Instagram, 3-5 for others)

6. Identify the tone (e.g., "Inspirational", "Humorous", "Professional")

RESPONSE FORMAT (JSON):
{
  "caption": "your engaging caption here",
  "hashtags": ["hashtag1", "hashtag2", "hashtag3"],
  "tone": "describe the tone"
}

Be creative, be human, be engaging!
''';
  }

  PostData _parseResponse(String responseText, String platform) {
    // Clean response - remove markdown code blocks if present
    String cleaned =
        responseText.replaceAll('```json', '').replaceAll('```', '').trim();

    try {
      // Parse as JSON
      final jsonStart = cleaned.indexOf('{');
      final jsonEnd = cleaned.lastIndexOf('}') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        cleaned = cleaned.substring(jsonStart, jsonEnd);
      }

      final Map<String, dynamic> data = jsonDecode(cleaned);

      return PostData(
        caption: data['caption'] ?? '',
        hashtags: List<String>.from(data['hashtags'] ?? []),
        tone: data['tone'] ?? 'Engaging',
        platform: platform,
      );
    } catch (e) {
      // Fallback parsing if JSON fails
      return PostData(
        caption: cleaned,
        hashtags: ['#AI', '#Generated'],
        tone: 'Creative',
        platform: platform,
      );
    }
  }
}
