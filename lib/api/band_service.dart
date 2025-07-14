import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rockstar_app/api/api_call.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandService {
  static Future<http.Response> getMyBandList() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("http://${ApiCall.host}/api/v0/band/user");

    return http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  static Future<http.Response> createBand(String bandName) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("http://${ApiCall.host}/api/v0/band");

    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'name': bandName,
      }),
    );
  }
}
