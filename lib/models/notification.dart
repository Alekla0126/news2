class Notification {
  final String id;
  final String title;
  final String timestamp; // Updated this to match the Bing News Search API
  final String imageUrl; // Updated this to match the Bing News Search API
  final String body;
  bool isRead; // Property to indicate if the notification is read

  Notification({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.imageUrl,
    required this.body,
    this.isRead = false, // Default value for isRead is false (unread)
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['url'] as String? ?? '', // Use url as a unique id, since there's no explicit id in the API response
      title: json['name'] as String? ?? '',
      timestamp: json['datePublished'] as String? ?? '',
      imageUrl: json['image']?['thumbnail']?['contentUrl'] as String? ?? '',
      body: json['description'] as String? ?? '',
    );
  }
}