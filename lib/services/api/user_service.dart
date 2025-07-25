import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_call.dart';

class UserService {
  static Future<http.Response> updateNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("https://${ApiCall.host}/api/v0/user/nickname");
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

    final url = Uri.parse("https://${ApiCall.host}/api/v0/user/reissue");
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
        Uri.parse("https://${ApiCall.host}/api/v0/user/verification-code");
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
    final url = Uri.parse("https://${ApiCall.host}/api/v0/user");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    return response;
  }

  static Future<http.Response> getBandMembers(int bandId, int page) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final url = Uri.parse(
        "https://${ApiCall.host}/api/v0/user/band-member/$bandId?page=$page&size=10");
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
    final url = Uri.parse("https://${ApiCall.host}/api/v0/user/login");
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

  static Future<http.Response> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("https://${ApiCall.host}/api/v0/user/logout");
    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization-refresh': 'Bearer $refreshToken',
        'Authorization': 'Bearer $accessToken'
      },
    );
  }

  static Future<http.Response> withdraw() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("https://${ApiCall.host}/api/v0/user");
    return http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization-refresh': 'Bearer $refreshToken',
        'Authorization': 'Bearer $accessToken'
      },
    );
  }
}
