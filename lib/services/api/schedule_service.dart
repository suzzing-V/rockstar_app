import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rockstar_app/services/api/api_call.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleService {
  static Future<http.Response> createSchedule(
      int bandId,
      DateTime startDate,
      DateTime endDate,
      TimeOfDay startTime,
      TimeOfDay endTime,
      String memo) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("http://${ApiCall.host}/api/v0/schedule");

    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        "bandId": bandId,
        "startYear": startDate.year,
        "startMonth": startDate.month,
        "startDay": startDate.day,
        "startHour": startTime.hour,
        "startMinute": startTime.minute,
        "endYear": endDate.year,
        "endMonth": endDate.month,
        "endDay": endDate.day,
        "endHour": endTime.hour,
        "endMinute": endTime.minute,
        "description": memo
      }),
    );
  }

  static Future<http.Response> getSchedule(int scheduleId, int bandId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url =
        Uri.parse("http://${ApiCall.host}/api/v0/schedule/$bandId/$scheduleId");

    return http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  static Future<http.Response> editSchedule(
      int scheduleId,
      DateTime startDate,
      DateTime endDate,
      TimeOfDay startTime,
      TimeOfDay endTime,
      String memo) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("http://${ApiCall.host}/api/v0/schedule/$scheduleId");

    return http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        "startYear": startDate.year,
        "startMonth": startDate.month,
        "startDay": startDate.day,
        "startHour": startTime.hour,
        "startMinute": startTime.minute,
        "endYear": endDate.year,
        "endMonth": endDate.month,
        "endDay": endDate.day,
        "endHour": endTime.hour,
        "endMinute": endTime.minute,
        "description": memo
      }),
    );
  }

  static Future<http.Response> deleteSchedule(int scheduleId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("http://${ApiCall.host}/api/v0/schedule/$scheduleId");

    return http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  static Future<http.Response> getBandSchedules(int bandId, int page) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse(
        "http://${ApiCall.host}/api/v0/schedule/band/$bandId?page=$page&size=10");

    return http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
  }
}
