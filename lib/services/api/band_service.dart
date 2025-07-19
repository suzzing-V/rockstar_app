import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rockstar_app/services/api/api_call.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandService {
  static Future<http.Response> getMyBandList(int page) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url =
        Uri.parse("http://${ApiCall.host}/api/v0/band/user?page=$page&size=10");

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

  static Future getBandUrl(int bandId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("http://${ApiCall.host}/api/v0/band/url/$bandId");

    return http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  static Future<http.Response> updateBandName(
      int bandId, String bandName) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("http://${ApiCall.host}/api/v0/band/name");

    return http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'name': bandName,
        'bandId': bandId,
      }),
    );
  }

  static Future getBandInfo(int bandId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("http://${ApiCall.host}/api/v0/band/$bandId");

    return http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  static Future withdrawBand(int bandId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("http://${ApiCall.host}/api/v0/band/user/$bandId");

    return http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
  }
}
