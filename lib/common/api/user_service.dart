import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rockstar_app/services/api/api_call.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<http.Response> updateNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("http://${ApiCall.host}/api/v0/user/nickname");
    return http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'nickname': nickname}),
    );
  }

  static Future<http.Response> reissueToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    final url = Uri.parse("http://${ApiCall.host}/api/v0/user/reissue");
    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization-refresh': 'Bearer $refreshToken',
      },
    );
  }

  static Future<http.Response> requestCode(String phonenum, bool isNew) async {
    final url =
        Uri.parse("http://${ApiCall.host}/api/v0/user/verification-code");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNum': phonenum,
        'isNew': isNew,
      }),
    );
    return response;
  }

  static Future<http.Response> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final url = Uri.parse("http://${ApiCall.host}/api/v0/user");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    return response;
  }

  static Future<http.Response> login(
      String code, String phonenum, bool isNew) async {
    final url = Uri.parse("http://${ApiCall.host}/api/v0/user/login");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code,
        'phoneNum': phonenum,
        'isNew': isNew,
      }),
    );
    return response;
  }

  static Future<http.Response> getUserInfoInBand(int bandId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final url = Uri.parse("http://${ApiCall.host}/api/v0/user/band/$bandId");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    return response;
  }
}
