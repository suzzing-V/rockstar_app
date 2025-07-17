import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rockstar_app/services/api/schedule_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/common/button/custom_back_button.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/band/band_page.dart';
import 'package:rockstar_app/views/band/pages/edit_schedule_page%20copy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleInfoPage extends StatefulWidget {
  final int scheduleId;
  final int bandId;
  final String bandName;

  const ScheduleInfoPage(
      {super.key,
      required this.bandId,
      required this.bandName,
      required this.scheduleId});

  @override
  State<ScheduleInfoPage> createState() => _ScheduleInfoPageState();
}

class _ScheduleInfoPageState extends State<ScheduleInfoPage> {
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
    final response = await ScheduleService.getSchedule(widget.scheduleId);

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
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: CustomBackButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
                builder: (context) => BandPage(
                      bandId: widget.bandId,
                      bandName: widget.bandName,
                    ) // 일정 상세
                ),
            // (route) =>
            //     route.isFirst, // HomePage가 첫 번째 페이지일 경우 유지
          ),
        ),
        leadingWidth: 50,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text(
              //   '합주 일정 편집하기',
              //   style: TextStyle(
              //     fontFamily: 'PixelFont',
              //     fontSize: 25,
              //     color: Theme.of(context).colorScheme.secondaryContainer,
              //   ),
              // ),
            ],
          ),
        ),
      ),
      body: SafeArea(
          bottom: false,
          // ✅ 이거 추가
          child: Padding(
              padding: const EdgeInsets.all(30), // 여백을 줘서 너무 붙지 않게
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 수평 왼쪽 정렬
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '시작',
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      fontSize: 23,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        '${_startDate.year}.${_startDate.month.toString().padLeft(2, '0')}.${_startDate.day.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          fontSize: 23,
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        _startTime.format(context),
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          fontSize: 23,
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    '끝',
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      fontSize: 23,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        '${_endDate.year}.${_endDate.month.toString().padLeft(2, '0')}.${_endDate.day.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          fontSize: 23,
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        _endTime.format(context),
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          fontSize: 23,
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    '메모',
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      fontSize: 23,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 342,
                    height: 170,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withOpacity(0.8),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent,
                    ),
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: SingleChildScrollView(
                      child: Text(
                        memo,
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          fontSize: 18,
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.tonal(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(130, 55), // 버튼 자체 크기
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withOpacity(0.8),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          textStyle: TextStyle(fontSize: 20),
                        ),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditSchedulePage(
                                      scheduleId: widget.scheduleId,
                                    ) // 일정 상세
                                ),
                            // (route) =>
                            //     route.isFirst, // HomePage가 첫 번째 페이지일 경우 유지
                          );
                        },
                        child: Text('편집',
                            style: TextStyle(
                              fontFamily: 'PixelFont',
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(130, 55), // 버튼 자체 크기
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          textStyle: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3, // ✅ 테두리 두께
                          ),
                        ),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                actionsPadding:
                                    EdgeInsets.only(bottom: 5, right: 8),
                                title: Text(
                                  '일정을 삭제하시겠습니까?',
                                  style: TextStyle(
                                    fontFamily: 'PixelFont',
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                                // content: Text(
                                //   '시작 날짜는 끝 날짜보다\n늦을 수 없습니다.',
                                //   style: TextStyle(
                                //     fontFamily: 'PixelFont',
                                //     fontSize: 16,
                                //     color: Theme.of(context)
                                //         .colorScheme
                                //         .onPrimaryContainer,
                                //   ),
                                // ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          final response = await ScheduleService
                                              .deleteSchedule(
                                                  widget.scheduleId);

                                          if (response.statusCode == 200) {
                                            final responseBody =
                                                jsonDecode(response.body);
                                            print('일정 삭제 성공: ${responseBody}');
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BandPage(
                                                        bandId: widget.bandId,
                                                        bandName:
                                                            widget.bandName,
                                                      ) // 일정 상세
                                                  ),
                                              // (route) =>
                                              //     route.isFirst, // HomePage가 첫 번째 페이지일 경우 유지
                                            );
                                          } else if (response.statusCode ==
                                              401) {
                                            final response = await UserService
                                                .reissueToken();

                                            if (response.statusCode == 200) {
                                              final decoded = jsonDecode(utf8
                                                  .decode(response.bodyBytes));
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              await prefs.setString(
                                                  'accessToken',
                                                  decoded['accessToken']);
                                              await prefs.setString(
                                                  'refreshToken',
                                                  decoded['refreshToken']);

                                              /// ✅ 토큰 재발급 성공 후 재시도
                                              final retry =
                                                  await ScheduleService
                                                      .editSchedule(
                                                          widget.scheduleId,
                                                          _startDate,
                                                          _endDate,
                                                          _startTime,
                                                          _endTime,
                                                          memo);
                                              if (retry.statusCode != 200) {
                                                // TODO: 오류 발생 시 행동
                                              }
                                            } else if (response.statusCode ==
                                                401) {
                                              // refresh token 만료 시
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AnimatedStartPage(),
                                                ),
                                                (Route<dynamic> route) => false,
                                              );
                                              return;
                                            } else {
                                              // TODO: 서버 오류 시 행동
                                            }
                                          } else {
                                            // TODO: 서버 오류 시 행동
                                          } // 창 닫기
                                        },
                                        child: Text(
                                          '확인',
                                          style: TextStyle(
                                            fontFamily: 'PixelFont',
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // 창 닫기
                                        },
                                        child: Text(
                                          '취소',
                                          style: TextStyle(
                                            fontFamily: 'PixelFont',
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('삭제',
                            style: TextStyle(
                              fontFamily: 'PixelFont',
                            )),
                      ),
                    ],
                  ),
                ],
              ))),
    );
  }
}
