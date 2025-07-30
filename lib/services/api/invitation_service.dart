import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_call.dart';

class InvitationService {
  static Future<http.Response> getInvitations() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final url = Uri.parse("https://${ApiCall.host}/api/v0/invite/list");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    return response;
  }

  static Future<http.Response> acceptInvitation(int bandId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url =
        Uri.parse("https://${ApiCall.host}/api/v0/invite/accept/$bandId");

    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  static Future<http.Response> rejectInvitation(int bandId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url =
        Uri.parse("https://${ApiCall.host}/api/v0/invite/reject/$bandId");

    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }
}
