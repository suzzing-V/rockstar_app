import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/appBar/default_app_bar.dart';
import 'package:rockstar_app/common/buttons/mini_primary_button.dart';
import 'package:rockstar_app/common/buttons/mini_secondary_button.dart';
import 'package:rockstar_app/common/text/main_text.dart';
import 'package:rockstar_app/services/api/schedule_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/band/container/memo_display_box.dart';
import 'package:rockstar_app/views/band/dialogs/schedule_delete_dialog.dart';
import 'package:rockstar_app/views/band/pages/edit_schedule_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleInfoPage extends StatefulWidget {
  final int scheduleId;
  final int bandId;

  const ScheduleInfoPage(
      {super.key, required this.scheduleId, required this.bandId});

  @override
  State<ScheduleInfoPage> createState() => _ScheduleInfoPageState();
}

class _ScheduleInfoPageState extends State<ScheduleInfoPage> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  String memo = "";
  bool isManager = false;

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
    final response = await ScheduleService.getScheduleOfBand(
        widget.scheduleId, widget.bandId);

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
        memo = decoded['description'];
        isManager = decoded['isManager'];
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
    onPressedEdit() async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditSchedulePage(
            bandId: widget.bandId,
            scheduleId: widget.scheduleId,
          ),
        ),
      );

      if (result == true) {
        getSchedule(); // ✅ 돌아왔을 때 갱신
      }
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: DefaultAppBar(title: ""),
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
                      MainText(
                        label:
                            '${_startDate.year}.${_startDate.month.toString().padLeft(2, '0')}.${_startDate.day.toString().padLeft(2, '0')}',
                        fontSize: 23,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      MainText(
                        label: _startTime.format(context),
                        fontSize: 23,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
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
                      MainText(
                        label:
                            '${_endDate.year}.${_endDate.month.toString().padLeft(2, '0')}.${_endDate.day.toString().padLeft(2, '0')}',
                        fontSize: 23,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      MainText(
                        label: _endTime.format(context),
                        fontSize: 23,
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
                  MemoDisplayBox(text: memo),
                  SizedBox(
                    height: 30,
                  ),
                  if (isManager)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MiniPrimaryButton(
                          onPressed: onPressedEdit,
                          label: '편집',
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        MiniSecondaryButton(
                          onPressed: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => ScheduleDeleteDialog(
                                scheduleId: widget.scheduleId,
                              ),
                            );
                            print("shouldDelete: $shouldDelete");
                            if (shouldDelete == true) {
                              Navigator.pop(context, true); // ✅ 상세 페이지 pop
                            }
                          },
                          label: '삭제',
                        ),
                      ],
                    ),
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

  void toBandPage(BuildContext context) {
    Navigator.pop(context, true);
  }
}
