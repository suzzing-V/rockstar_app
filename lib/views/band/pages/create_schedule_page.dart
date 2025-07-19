import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/appBar/default_app_bar.dart';
import 'package:rockstar_app/common/buttons/primary_button.dart';
import 'package:rockstar_app/common/text/main_text.dart';
import 'package:rockstar_app/services/api/schedule_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/band/button/date_picker_button.dart';
import 'package:rockstar_app/views/band/button/time_picker_button.dart';
import 'package:rockstar_app/views/band/container/memo_input_box.dart';
import 'package:rockstar_app/common/dialog/one_button_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateSchedulePage extends StatefulWidget {
  final int bandId;

  const CreateSchedulePage({super.key, required this.bandId});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  final _controller = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    createSchedule() async {
      String memo = _controller.text.trim();
      final response = await ScheduleService.createSchedule(
          widget.bandId, _startDate, _endDate, _startTime, _endTime, memo);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('일정 생성 성공: $responseBody');
        Navigator.pop(context, true);
      } else if (response.statusCode == 400) {
        showDialog(
          context: context,
          builder: (context) => OneButtonDialog(
            title: '시작 날짜는 끝 날짜보다\n늦을 수 없습니다.',
            onConfirm: () => Navigator.of(context).pop(),
          ),
        );
      } else if (response.statusCode == 401) {
        final response = await UserService.reissueToken();

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', decoded['accessToken']);
          await prefs.setString('refreshToken', decoded['refreshToken']);

          /// ✅ 토큰 재발급 성공 후 재시도
          final retry = await ScheduleService.createSchedule(
              widget.bandId, _startDate, _endDate, _startTime, _endTime, memo);
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
      appBar: DefaultAppBar(title: '밴드 일정 만들기'),
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
                        onPressed: createSchedule,
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
}
