import 'dart:io';
import 'package:ai_social_assistant/screens/results_screen.dart';
import 'package:ai_social_assistant/widgets/glassmorphic_container.dart';
import 'package:ai_social_assistant/widgets/animated_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../services/gemini_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  File? _selectedImage;
  String _selectedPlatform = 'Instagram';
  bool _isGenerating = false;
  final _geminiService = GeminiService();
  final _imagePicker = ImagePicker();
  late AnimationController _gradientController;
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _platforms = [
    {'name': 'Instagram', 'icon': Icons.camera_alt, 'color': const Color(0xFFE4405F)},
    {'name': 'Twitter', 'icon': Icons.tag, 'color': const Color(0xFF1DA1F2)},
    {'name': 'LinkedIn', 'icon': Icons.business, 'color': const Color(0xFF0A66C2)},
  ];

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _generatePost() async {
    if (_selectedImage == null) {
      _showError('Please select an image first');
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final postData = await _geminiService.generatePost(
        image: _selectedImage!,
        platform: _selectedPlatform.toLowerCase(),
        userStyle: 'casual and authentic',
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ResultScreen(postData: postData, image: _selectedImage!),
        ),
      );
    } catch (e) {
      print(e);
      _showError('Failed to generate post: $e');
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF9D4EDD),
                    const Color(0xFF7209B7),
                    _gradientController.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF3B82F6),
                    const Color(0xFF8B5CF6),
                    _gradientController.value,
                  )!,
                  Color.lerp(
                    const Color(0xFFEC4899),
                    const Color(0xFFF97316),
                    _gradientController.value,
                  )!,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildImagePreview(),
                    const SizedBox(height: 24),
                    _buildImageButtons(),
                    const SizedBox(height: 40),
                    _buildPlatformSelector(),
                    const SizedBox(height: 40),
                    _buildGenerateButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return GlassmorphicContainer(
      blur: 20,
      opacity: 0.15,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Text(
                'AI Social Assistant',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'From Photo to Post in Seconds ✨',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return GlassmorphicContainer(
      blur: 15,
      opacity: 0.1,
      padding: const EdgeInsets.all(4),
      child: Container(
        height: 340,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.05),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_selectedImage!, fit: BoxFit.cover),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.white.withOpacity(0.3),
                    highlightColor: Colors.white.withOpacity(0.6),
                    child: const Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No image selected',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose from camera or gallery',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImageButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildImageButton(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildImageButton(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            gradient: const [Color(0xFFEC4899), Color(0xFFF97316)],
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildImageButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        blur: 15,
        opacity: 0.15,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Select Platform',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
        Row(
          children: _platforms.map((platform) {
            final isSelected = _selectedPlatform == platform['name'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPlatform = platform['name']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    child: GlassmorphicContainer(
                      blur: isSelected ? 20 : 10,
                      opacity: isSelected ? 0.25 : 0.1,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            platform['icon'],
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                            size: isSelected ? 28 : 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            platform['name'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: isSelected ? 14 : 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return AnimatedGradientButton(
      onPressed: _isGenerating ? null : _generatePost,
      gradientColors: const [
        Color(0xFF9D4EDD),
        Color(0xFFE879F9),
        Color(0xFFFBBF24),
      ],
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: _isGenerating
          ? LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white,
              size: 20,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 28, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Generate Post with AI',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }
}
