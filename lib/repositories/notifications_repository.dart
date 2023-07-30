import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';

class NotificationsRepository {
  List<Notification> notifications = [];
  List<Notification> readNotifications = [];

  // Update this to your Bing News Search API endpoint
  final endpoint = "https://bing-news-search1.p.rapidapi.com/news/search?cc=ru&safeSearch=Off&textFormat=Raw&freshness=Day&count=100";

  Future<List<Notification>> fetchNotifications() async {
    final response = await http.get(
      Uri.parse(endpoint),
      // Add headers required by Bing News Search API
      headers: {
        "x-rapidapi-host": "bing-news-search1.p.rapidapi.com",
        "x-rapidapi-key": "f60fb43273msh5455818c9fbac8ep1c8ac0jsn7149158c8677",
        "x-bingapis-sdk": "true"
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> body = jsonResponse['value'];
      notifications = body.map<Notification>((item) => Notification.fromJson(item)).toList();
      return notifications;
    } else {
      print('Failed to load notifications. Status code: ${response.statusCode}. Response body: ${response.body}');
      throw Exception('Failed to load notifications');
    }
  }

  Future<List<Notification>> fetchMoreNotifications() async {
    // For now, let's re-fetch the same data when we want to fetch more
    return await fetchNotifications();
  }

  void deleteReadNotifications() {
    readNotifications.addAll(notifications.where((notification) => notification.isRead));
    notifications.removeWhere((notification) => notification.isRead);
  }
}
