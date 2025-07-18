import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/appBar/default_app_bar.dart';
import 'package:rockstar_app/common/buttons/primary_button.dart';
import 'package:rockstar_app/common/text/main_text.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/services/api/schedule_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/band/button/date_picker_button.dart';
import 'package:rockstar_app/views/band/button/time_picker_button.dart';
import 'package:rockstar_app/views/band/container/memo_input_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditSchedulePage extends StatefulWidget {
  final int scheduleId;
  final int bandId;

  const EditSchedulePage(
      {super.key, required this.scheduleId, required this.bandId});

  @override
  State<EditSchedulePage> createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  final _controller = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  String memo = "";

  @override
  void initState() {
    super.initState();
    getSchedule();
  }

  Future<void> getSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    print(accessToken);
    print('refresh:$refreshToken');
    final response =
        await ScheduleService.getSchedule(widget.scheduleId, widget.bandId);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      print("밴드 일정 불러오기: ${utf8.decode(response.bodyBytes)}");
      setState(() {
        _startDate = DateTime(
            decoded['startYear'], decoded['startMonth'], decoded['startDay']);
        _startTime = TimeOfDay(
            hour: decoded['startHour'], minute: decoded['startMinute']);
        _endDate = DateTime(
            decoded['endYear'], decoded['endMonth'], decoded['endDay']);
        _endTime =
            TimeOfDay(hour: decoded['endHour'], minute: decoded['endMinute']);
        _controller.text = decoded['description'];
      });
    } else if (response.statusCode == 401) {
      final retryResponse = await UserService.reissueToken();
      if (retryResponse.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(retryResponse.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);
        getSchedule(); // 재시도
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => AnimatedStartPage(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      print("일정 불러오기 실패: ${utf8.decode(response.bodyBytes)}");
    }
  }

  @override
  Widget build(BuildContext context) {
    editSchedule() async {
      String memo = _controller.text.trim();
      final response = await ScheduleService.editSchedule(
          widget.scheduleId, _startDate, _endDate, _startTime, _endTime, memo);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('일정 수정 성공: $responseBody');
        toScheduleInfoPage(context);
      } else if (response.statusCode == 401) {
        final response = await UserService.reissueToken();

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', decoded['accessToken']);
          await prefs.setString('refreshToken', decoded['refreshToken']);

          /// ✅ 토큰 재발급 성공 후 재시도
          final retry = await ScheduleService.editSchedule(widget.scheduleId,
              _startDate, _endDate, _startTime, _endTime, memo);
          if (retry.statusCode != 200) {
            // TODO: 오류 발생 시 행동
          }
        } else if (response.statusCode == 401) {
          // refresh token 만료 시
          toAnimatedStartPage(context);
          return;
        } else {
          // TODO: 서버 오류 시 행동
        }
      } else {
        // TODO: 서버 오류 시 행동
      }
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: DefaultAppBar(title: '밴드 일정 편집하기'),
      body: SafeArea(
          bottom: false,
          // ✅ 이거 추가
          child: Padding(
              padding: const EdgeInsets.all(30), // 여백을 줘서 너무 붙지 않게
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 수평 왼쪽 정렬
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  MainText(
                    label: '시작',
                    fontSize: 23,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      DatePickerButton(
                        initialDate: _startDate,
                        onDatePicked: (picked) =>
                            setState(() => _startDate = picked),
                      ),
                      SizedBox(width: 20),
                      TimePickerButton(
                        initialTime: _startTime,
                        onTimePicked: (picked) =>
                            setState(() => _startTime = picked),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  MainText(
                    label: '끝',
                    fontSize: 23,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      DatePickerButton(
                        initialDate: _endDate,
                        onDatePicked: (picked) =>
                            setState(() => _endDate = picked),
                      ),
                      SizedBox(width: 20),
                      TimePickerButton(
                        initialTime: _endTime,
                        onTimePicked: (picked) =>
                            setState(() => _endTime = picked),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  MainText(
                    label: '메모',
                    fontSize: 23,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  MemoInputBox(controller: _controller),
                  SizedBox(
                    height: 30,
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: PrimaryButton(
                        label: '확인',
                        onPressed: editSchedule,
                      )),
                ],
              ))),
    );
  }

  void toAnimatedStartPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => AnimatedStartPage(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void toScheduleInfoPage(BuildContext context) {
    Navigator.pop(context, true);
  }
}
