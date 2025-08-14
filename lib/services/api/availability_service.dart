import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_call.dart';

class AvailabilityService {
  /// 월별 unavailability 조회
  /// GET /api/v1/availability?year={year}&month={month}
  static Future<http.Response> getMonthlyAvailability(int year, int month) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse(
        "https://${ApiCall.host}/api/v1/availability?year=$year&month=$month");
    
    return http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  /// unavailability 등록/수정
  /// POST /api/v1/availability
  static Future<http.Response> saveAvailability({
    required String date, // "2025-01-15" 형태
    required bool isAllDay,
    required List<Map<String, int>> ranges, // [{"startMin": 540, "endMin": 1020}]
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("https://${ApiCall.host}/api/v1/availability");
    
    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'date': date,
        'isAllDay': isAllDay,
        'ranges': ranges,
      }),
    );
  }
}