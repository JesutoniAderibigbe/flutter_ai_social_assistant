import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/post_data.dart';

class ResultScreen extends StatelessWidget {
  final PostData postData;
  final File image;

  const ResultScreen({super.key, required this.postData, required this.image});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _sharePost(BuildContext context) async {
    final text = '${postData.caption}\n\n${postData.hashtags.join(' ')}';
    final encodedText = Uri.encodeComponent(text);
    final platform = postData.platform.toLowerCase();
    Uri? uri;

    if (platform == 'twitter') {
      uri = Uri.parse('https://twitter.com/intent/tweet?text=$encodedText');
    } else if (platform == 'linkedin') {
      uri = Uri.parse('https://www.linkedin.com/shareArticle?mini=true&text=$encodedText');
    } else {
      // For Instagram and other platforms, we can only open the app
      // Sharing with pre-filled text is restricted
      // consider using native sharing capabilities
      uri = Uri.parse('instagram://library?AssetPath=${image.path}');
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showError(context, 'Could not launch $platform');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Your AI-Generated Post'),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () => _sharePost(context),
            ),
          ],
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 300, child: Image.file(image, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      postData.platform.toUpperCase(),
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Caption',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.purple,
                                ),
                                onPressed:
                                    () => _copyToClipboard(
                                      context,
                                      postData.caption,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            postData.caption,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Hashtags',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.purple,
                                ),
                                onPressed:
                                    () => _copyToClipboard(
                                      context,
                                      postData.hashtags.join(' '),
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                postData.hashtags.map((tag) {
                                  return Chip(
                                    label: Text(tag),
                                    backgroundColor: Colors.purple.shade50,
                                    labelStyle: TextStyle(
                                      color: Colors.purple.shade700,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sentiment_satisfied,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Tone: ${postData.tone}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final fullPost =
                          '${postData.caption}\n\n${postData.hashtags.join(' ')}';
                      _copyToClipboard(context, fullPost);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        Icon(Icons.content_copy),
                        SizedBox(width: 8),
                        Text(
                          'Copy Complete Post',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
