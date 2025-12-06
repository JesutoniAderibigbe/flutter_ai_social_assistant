class PostData {
  final String caption;
  final List<String> hashtags;
  final String tone;
  final String platform;

  PostData({
    required this.caption,
    required this.hashtags,
    required this.tone,
    required this.platform,
  });

  factory PostData.fromJson(Map<String, dynamic> json) {
    return PostData(
      caption: json['caption'] ?? '',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      tone: json['tone'] ?? '',
      platform: json['platform'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'caption': caption,
      'hashtags': hashtags,
      'tone': tone,
      'platform': platform,
    };
  }

  @override
  String toString() {
    return 'PostData(${toMap()})';
  }
}

