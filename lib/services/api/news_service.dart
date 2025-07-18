import 'package:http/http.dart' as http;
import 'package:rockstar_app/services/api/api_call.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsService {
  static Future<http.Response> getBandNews(int bandId, int page) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse(
        "http://${ApiCall.host}/api/v0/news/band/$bandId?page=$page&size=20");

    return http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
  }
}
