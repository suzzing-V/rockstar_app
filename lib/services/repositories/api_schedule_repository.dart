import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rockstar_app/services/api/availability_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/home/pages/user_schedule_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiScheduleRepository implements ScheduleRepository {
  final BuildContext? context;

  ApiScheduleRepository({this.context});
  @override
  Future<Map<DateTime, DayAvailability>> fetchMonth(
      DateTime anyDayInMonth) async {
    final response = await AvailabilityService.getMonthlyAvailability(
        anyDayInMonth.year, anyDayInMonth.month);

    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      final Map<DateTime, DayAvailability> result = {};

      // 해당 월의 모든 날짜를 초기화 (가능 상태로)
      final firstDay = DateTime(anyDayInMonth.year, anyDayInMonth.month, 1);
      final lastDay = DateTime(anyDayInMonth.year, anyDayInMonth.month + 1, 0);

      for (int day = 1; day <= lastDay.day; day++) {
        final date = DateTime(anyDayInMonth.year, anyDayInMonth.month, day);
        result[date] = DayAvailability.available();
      }

      // API 응답 데이터를 매핑
      for (final item in data) {
        final dateStr = item['date'] as String;
        final dateParts = dateStr.split('-');
        final date = DateTime(
          int.parse(dateParts[0]), // year
          int.parse(dateParts[1]), // month
          int.parse(dateParts[2]), // day
        );

        final bool isAllDay = item['isAllDay'] as bool;
        final List<dynamic> rangesData = item['ranges'] as List<dynamic>;

        final ranges = rangesData
            .map((r) => MinuteRange(r['startMin'] as int, r['endMin'] as int))
            .toList();

        result[date] = DayAvailability(allDay: isAllDay, ranges: ranges);
      }

      return result;
    } else if (response.statusCode == 401) {
      await _handleTokenRefresh();
      return fetchMonth(anyDayInMonth); // 재시도
    } else {
      print("월별 스케줄 불러오기 실패: ${jsonDecode(utf8.decode(response.bodyBytes))}");
      return _getEmptyMonth(anyDayInMonth);
    }
  }

  @override
  Future<void> saveDay(
      int userId, DateTime day, DayAvailability availability) async {
    final dateStr =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

    final ranges = availability.ranges
        .map((r) => {'startMin': r.startMin, 'endMin': r.endMin})
        .toList();

    final response = await AvailabilityService.saveAvailability(
      date: dateStr,
      isAllDay: availability.allDay,
      ranges: ranges,
    );

    if (response.statusCode == 200) {
      print("스케줄 저장 성공: ${utf8.decode(response.bodyBytes)}");
    } else if (response.statusCode == 401) {
      await _handleTokenRefresh();
      return saveDay(userId, day, availability); // 재시도
    } else {
      print("스케줄 저장 실패: ${jsonDecode(utf8.decode(response.bodyBytes))}");
    }
  }

  Future<void> _handleTokenRefresh() async {
    final retryResponse = await UserService.reissueToken();
    if (retryResponse.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(retryResponse.bodyBytes));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', decoded['accessToken']);
      await prefs.setString('refreshToken', decoded['refreshToken']);
    } else if (context != null) {
      Navigator.pushAndRemoveUntil(
        context!,
        MaterialPageRoute(builder: (_) => AnimatedStartPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Map<DateTime, DayAvailability> _getEmptyMonth(DateTime anyDayInMonth) {
    final Map<DateTime, DayAvailability> result = {};
    final firstDay = DateTime(anyDayInMonth.year, anyDayInMonth.month, 1);
    final lastDay = DateTime(anyDayInMonth.year, anyDayInMonth.month + 1, 0);

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(anyDayInMonth.year, anyDayInMonth.month, day);
      result[date] = DayAvailability.available();
    }

    return result;
  }
}
