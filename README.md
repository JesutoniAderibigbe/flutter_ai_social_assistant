# 📱 AI Social Media Assistant

> Transform your photos into engaging social media posts using Flutter and Google Gemini Vision AI

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Gemini](https://img.shields.io/badge/Google-Gemini%20AI-4285F4?logo=google)](https://ai.google.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🎯 What This Project Does

This mobile app solves a common problem: **we all have amazing photos stuck in our camera roll because we can't think of the perfect caption.**

The AI Social Media Assistant:
1. **Analyzes** your photo using Google Gemini's multimodal AI
2. **Understands** the context, mood, subject, and story in your image
3. **Generates** platform-specific captions (Instagram, Twitter, LinkedIn)
4. **Writes** in an authentic, engaging voice that sounds human
5. **Provides** relevant hashtags and tone suggestions

---

## 🏗️ Architecture Overview

### Project Structure

```
ai_social_assistant/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── post_data.dart        # Data model for generated posts
│   ├── services/
│   │   └── gemini_service.dart   # AI integration & prompt engineering
│   └── screens/
│       ├── home_screen.dart      # Image selection & platform choice
│       └── result_screen.dart    # Display generated content
├── .env                          # API keys (gitignored)
├── pubspec.yaml                  # Dependencies
└── README.md                     # This file
```

### How It Works

```
┌─────────────────────────────────────────────────────────┐
│                     USER FLOW                           │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
                   ┌────────────────┐
                   │  HomeScreen    │
                   │  - Pick Image  │
                   │  - Select      │
                   │    Platform    │
                   └────────┬───────┘
                            │
                            ▼
                   ┌────────────────┐
                   │ GeminiService  │
                   │  - Build       │
                   │    Prompt      │
                   │  - Send to AI  │
                   │  - Parse JSON  │
                   └────────┬───────┘
                            │
                            ▼
                   ┌────────────────┐
                   │ ResultScreen   │
                   │  - Display     │
                   │    Caption     │
                   │  - Show        │
                   │    Hashtags    │
                   │  - Copy to     │
                   │    Clipboard   │
                   └────────────────┘
```

---

## 🧩 Code Breakdown

### 1. **Models** (`post_data.dart`)

**Purpose:** Defines the structure of AI-generated content.

```dart
class PostData {
  final String caption;        // The main post text
  final List<String> hashtags; // Relevant hashtags
  final String tone;           // Writing style/mood
  final String platform;       // Instagram/Twitter/LinkedIn
}
```

**Why:** Having a structured model makes it easy to:
- Pass data between screens
- Parse JSON from Gemini API
- Display content consistently

---

### 2. **Services** (`gemini_service.dart`)

**Purpose:** Handles all AI communication and prompt engineering.

#### Key Components:

**a) Initialization**
```dart
GeminiService() {
  final apiKey = dotenv.env['GEMINI_API_KEY']!;
  _model = GenerativeModel(
    model: 'gemini-1.5-flash',  // Fast, efficient model
    apiKey: apiKey,
  );
}
```

**b) Image Processing**
```dart
final imageBytes = await image.readAsBytes();
final content = [
  Content.multi([
    TextPart(prompt),                      // Text instructions
    DataPart('image/jpeg', imageBytes),    // Image data
  ])
];
```

**c) The "Secret Sauce" - Prompt Engineering**

This is the **most critical part** of the app. The prompt tells the AI:
- **Who it is:** "You are a social media expert"
- **What to analyze:** The uploaded image
- **How to write:** Platform-specific rules
- **Output format:** Structured JSON

```dart
String _buildPrompt(String platform, String userStyle) {
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
   - Matches the user's personal voice
   - Is optimized for $platform
   - Feels authentic, not robotic
   
2. For Instagram: 150-200 words, emoji-friendly, story-driven
3. For Twitter: Under 280 chars, punchy, conversational
4. For LinkedIn: Professional tone, insight-driven

RESPONSE FORMAT (JSON):
{
  "caption": "your engaging caption here",
  "hashtags": ["hashtag1", "hashtag2"],
  "tone": "describe the tone"
}
''';
}
```

**Why This Works:**
- **Clear context** sets expectations
- **Platform rules** ensure appropriate content
- **User voice** maintains authenticity
- **JSON format** makes parsing reliable

**d) Response Parsing**
```dart
PostData _parseResponse(String responseText, String platform) {
  // Clean markdown formatting
  String cleaned = responseText
      .replaceAll('```json', '')
      .replaceAll('```', '')
      .trim();
  
  // Extract JSON
  final jsonStart = cleaned.indexOf('{');
  final jsonEnd = cleaned.lastIndexOf('}') + 1;
  
  // Parse and return
  final Map<String, dynamic> data = jsonDecode(cleaned);
  return PostData.fromJson(data);
}
```

**Fallback:** If JSON parsing fails, returns raw text with default hashtags.

---

### 3. **Screens**

#### **HomeScreen** (`home_screen.dart`)

**Purpose:** User interface for image selection and platform choice.

**Key Features:**
- **Image Picker Integration:** Camera or Gallery
- **Platform Selector:** Instagram, Twitter, LinkedIn
- **Loading State:** Shows animation during AI processing
- **Error Handling:** User-friendly error messages

**State Management:**
```dart
File? _selectedImage;           // Selected photo
String _selectedPlatform;       // Chosen platform
bool _isGenerating;             // Loading state
```

**Critical Methods:**

1. **Image Selection:**
```dart
Future<void> _pickImage(ImageSource source) async {
  final XFile? image = await _imagePicker.pickImage(
    source: source,
    maxWidth: 1920,        // Compress large images
    maxHeight: 1920,
    imageQuality: 85,      // Balance quality & size
  );
  
  if (image != null) {
    setState(() => _selectedImage = File(image.path));
  }
}
```

2. **Post Generation:**
```dart
Future<void> _generatePost() async {
  setState(() => _isGenerating = true);
  
  final postData = await _geminiService.generatePost(
    image: _selectedImage!,
    platform: _selectedPlatform.toLowerCase(),
    userStyle: 'casual and authentic',
  );
  
  // Navigate to results
  Navigator.push(context, MaterialPageRoute(...));
}
```

---

#### **ResultScreen** (`result_screen.dart`)

**Purpose:** Display AI-generated content with copy functionality.

**Features:**
- **Image Preview:** Shows the uploaded photo
- **Caption Display:** Formatted, readable text
- **Hashtag Chips:** Visual, tappable hashtags
- **Tone Indicator:** Shows writing style
- **Copy to Clipboard:** One-tap copying

**UI Components:**
```dart
// Caption Card
Card(
  child: Column(
    children: [
      Text('Caption'),
      IconButton(
        icon: Icon(Icons.copy),
        onPressed: () => _copyToClipboard(caption),
      ),
      Text(postData.caption),
    ],
  ),
)

// Hashtags
Wrap(
  children: hashtags.map((tag) => Chip(label: Text(tag))),
)

// Full Copy Button
ElevatedButton(
  onPressed: () => _copyToClipboard('$caption\n\n$hashtags'),
  child: Text('Copy Complete Post'),
)
```

---

### 4. **Main Entry** (`main.dart`)

**Purpose:** App initialization and configuration.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}
```

**Configuration:**
- **Material Design 3:** Modern UI components
- **Purple Theme:** Consistent branding
- **Dotenv:** Secure API key management

---

## 🔐 Security & Best Practices

### 1. **API Key Protection**
```bash
# .env (never commit this!)
GEMINI_API_KEY=your_actual_key_here

# .gitignore
.env
*.env
```

### 2. **Error Handling**
```dart
try {
  final postData = await geminiService.generatePost(...);
} catch (e) {
  _showError('Failed to generate post: $e');
}
```

### 3. **Image Optimization**
- Max resolution: 1920x1920
- Quality: 85%
- Format: JPEG (smaller size)

### 4. **State Management**
- Proper `setState()` usage
- Mounted checks before navigation
- Loading indicators during async operations

---

## 🎨 Why This Tech Stack?

### **Flutter**
- **Single Codebase:** iOS + Android from one code base
- **Fast Development:** Hot reload for instant UI updates
- **Native Performance:** Compiled to native ARM code
- **Rich UI:** Material Design 3 components

### **Google Gemini Vision**
- **Multimodal AI:** Understands both text and images
- **Context Awareness:** Sees what's in the photo
- **Natural Language:** Generates human-like text
- **Free Tier:** Generous limits for development

### **Image Picker**
- **Native Integration:** Uses platform camera/gallery
- **Cross-Platform:** Works on iOS and Android
- **Compression:** Built-in image optimization

---

## 🚀 Performance Considerations

### Image Processing
- Images compressed before upload
- Async operations prevent UI blocking
- Loading states keep users informed

### API Calls
- Single request per generation
- Proper timeout handling
- Error recovery mechanisms

### UI Responsiveness
- Smooth animations with `loading_animation_widget`
- Efficient state updates
- Material Design best practices

---

## 🔮 Future Enhancements

### Phase 1 - Personalization
```dart
// Learn user's writing style from past posts
final userVoice = await analyzeUserHistory();
userStyle: userVoice.styleProfile
```

### Phase 2 - Advanced Features
- **Multiple Variations:** Generate 3 options, user picks best
- **Emoji Suggestions:** AI recommends relevant emojis
- **Schedule Posts:** Save and schedule for later
- **Analytics:** Track which captions perform best

### Phase 3 - Enterprise
- **Team Collaboration:** Share and approve posts
- **Brand Voice Training:** Consistent company voice
- **Multi-Account:** Manage multiple social profiles
- **A/B Testing:** Test different caption styles

---

## 📊 Data Flow Diagram

```
User Selects Image
        ↓
Image Picker Captures File
        ↓
User Chooses Platform (Instagram/Twitter/LinkedIn)
        ↓
HomeScreen passes data to GeminiService
        ↓
GeminiService:
  1. Reads image bytes
  2. Builds platform-specific prompt
  3. Sends to Gemini API
  4. Receives JSON response
  5. Parses into PostData model
        ↓
ResultScreen displays:
  - Generated caption
  - Relevant hashtags
  - Tone/style indicator
        ↓
User copies to clipboard
        ↓
Paste into actual social media app
```

---

## 🤝 Contributing

This project was built for educational purposes to demonstrate:
- Flutter mobile development
- AI/ML integration in mobile apps
- Prompt engineering best practices
- Clean architecture patterns

Feel free to:
- Fork and experiment
- Suggest improvements
- Report bugs
- Share your results

---

## 📝 License

MIT License - feel free to use this for learning, portfolio projects, or commercial applications.

---

## 🙏 Acknowledgments

- **Google Gemini Team:** For the powerful multimodal AI API
- **Flutter Team:** For the amazing cross-platform framework
- **Community:** For feedback and inspiration

---

## 📞 Support

Questions? Ideas? Found a bug?

- Open an issue on GitHub
- Star the repo if you found it helpful
- Share your generated posts with #AIGeneratedCaption

---

**Built with ❤️ using Flutter & Google Gemini Vision**

*From Photo to Post in Seconds* 📸✨