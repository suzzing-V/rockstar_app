import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_call.dart';

class NotificationService {
  static Future<http.Response> getNotificationsOfUser(int page) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final url = Uri.parse(
        "https://${ApiCall.host}/api/v0/notification/user?page=$page&size=10");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    return response;
  }

  static Future read(int notiUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final url = Uri.parse(
        "https://${ApiCall.host}/api/v0/notification/read/$notiUserId");
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    return response;
  }
}
