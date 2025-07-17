import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rockstar_app/api/schedule_service.dart';
import 'package:rockstar_app/api/user_service.dart';
import 'package:rockstar_app/button/custom_back_button.dart';
import 'package:rockstar_app/page/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditSchedulePage extends StatefulWidget {
  final int scheduleId;

  const EditSchedulePage({super.key, required this.scheduleId});

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
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: CustomBackButton(),
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
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withOpacity(0.8),
                          minimumSize: Size(155, 40), // 버튼 자체 크기
                          maximumSize: Size(155, 40),
                          padding:
                              EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            locale: const Locale('ko'),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  datePickerTheme: DatePickerThemeData(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    headerHeadlineStyle: TextStyle(
                                      fontFamily: 'PixelFont',
                                      fontSize: 25,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    headerHelpStyle: TextStyle(
                                      fontFamily: 'PixelFont',
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  dialogTheme: DialogThemeData(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                  ),
                                  colorScheme: ColorScheme.light(
                                    primary: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    onPrimary: Colors.white,
                                    onSurface:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  textTheme: TextTheme(
                                    displayLarge: TextStyle(
                                        fontFamily: 'PixelFont'), // year
                                    headlineMedium: TextStyle(
                                        fontFamily: 'PixelFont'), // month
                                    titleSmall: TextStyle(
                                        fontFamily: 'PixelFont'), // weekdays
                                    bodyLarge: TextStyle(
                                        fontFamily: 'PixelFont'), // days
                                    bodyMedium: TextStyle(
                                        fontFamily: 'PixelFont'), // etc
                                    labelLarge: TextStyle(
                                        fontFamily: 'PixelFont'), // buttons
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      textStyle: TextStyle(
                                        fontFamily: 'PixelFont',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null && picked != _startDate) {
                            setState(() {
                              _startDate = picked;
                            });
                          }
                        },
                        child: Center(
                          child: Text(
                            '${_startDate.year}.${_startDate.month.toString().padLeft(2, '0')}.${_startDate.day.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontFamily: 'PixelFont',
                              fontSize: 23,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withOpacity(0.8),
                          minimumSize: Size(100, 40), // 버튼 자체 크기
                          maximumSize: Size(100, 40),
                          padding:
                              EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _startTime,
                            initialEntryMode: TimePickerEntryMode.input,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  // 커스텀 폰트와 색상 적용
                                  timePickerTheme: TimePickerThemeData(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    hourMinuteTextStyle: TextStyle(
                                      fontFamily: 'PixelFont',
                                      fontSize: 32,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    dayPeriodTextStyle: TextStyle(
                                      fontFamily: 'PixelFont',
                                      fontSize: 20,
                                    ),
                                    helpTextStyle: TextStyle(
                                      fontFamily: 'PixelFont',
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                                    dialTextColor:
                                        Theme.of(context).colorScheme.primary,
                                    entryModeIconColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  textTheme: Theme.of(context).textTheme.apply(
                                        fontFamily: 'PixelFont',
                                      ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null && picked != _startTime) {
                            setState(() {
                              _startTime = picked;
                            });
                          }
                        },
                        child: Center(
                          child: Text(
                            _startTime.format(context),
                            style: TextStyle(
                              fontFamily: 'PixelFont',
                              fontSize: 23,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
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
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withOpacity(0.8),
                          minimumSize: Size(155, 40), // 버튼 자체 크기
                          maximumSize: Size(155, 40),
                          padding:
                              EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            locale: const Locale('ko'),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  datePickerTheme: DatePickerThemeData(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    headerHeadlineStyle: TextStyle(
                                      fontFamily: 'PixelFont',
                                      fontSize: 25,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    headerHelpStyle: TextStyle(
                                      fontFamily: 'PixelFont',
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  dialogTheme: DialogThemeData(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                  ),
                                  colorScheme: ColorScheme.light(
                                    primary: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    onPrimary: Colors.white,
                                    onSurface:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  textTheme: TextTheme(
                                    displayLarge: TextStyle(
                                        fontFamily: 'PixelFont'), // year
                                    headlineMedium: TextStyle(
                                        fontFamily: 'PixelFont'), // month
                                    titleSmall: TextStyle(
                                        fontFamily: 'PixelFont'), // weekdays
                                    bodyLarge: TextStyle(
                                        fontFamily: 'PixelFont'), // days
                                    bodyMedium: TextStyle(
                                        fontFamily: 'PixelFont'), // etc
                                    labelLarge: TextStyle(
                                        fontFamily: 'PixelFont'), // buttons
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      textStyle: TextStyle(
                                        fontFamily: 'PixelFont',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null && picked != _endDate) {
                            setState(() {
                              _endDate = picked;
                            });
                          }
                        },
                        child: Center(
                          child: Text(
                            '${_endDate.year}.${_endDate.month.toString().padLeft(2, '0')}.${_endDate.day.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontFamily: 'PixelFont',
                              fontSize: 23,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withOpacity(0.8),
                          minimumSize: Size(100, 40), // 버튼 자체 크기
                          maximumSize: Size(100, 40),
                          padding:
                              EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                            initialEntryMode: TimePickerEntryMode.input,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  // 커스텀 폰트와 색상 적용
                                  timePickerTheme: TimePickerThemeData(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    hourMinuteTextStyle: TextStyle(
                                      fontFamily: 'PixelFont',
                                      fontSize: 32,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    dayPeriodTextStyle: TextStyle(
                                      fontFamily: 'PixelFont',
                                      fontSize: 20,
                                    ),
                                    helpTextStyle: TextStyle(
                                      fontFamily: 'PixelFont',
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                                    dialTextColor:
                                        Theme.of(context).colorScheme.primary,
                                    entryModeIconColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  textTheme: Theme.of(context).textTheme.apply(
                                        fontFamily: 'PixelFont',
                                      ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null && picked != _endTime) {
                            setState(() {
                              _endTime = picked;
                            });
                          }
                        },
                        child: Center(
                          child: Text(
                            _endTime.format(context),
                            style: TextStyle(
                              fontFamily: 'PixelFont',
                              fontSize: 23,
                            ),
                          ),
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
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: TextField(
                      controller: _controller,
                      expands: true, // ✅ TextField가 부모를 꽉 채움
                      maxLines: null,
                      minLines: null,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      maxLength: 100,
                      style: TextStyle(
                        fontFamily: 'PixelFont',
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                      decoration: InputDecoration(
                        hintText: '입력하세요',

                        border: InputBorder.none,
                        isDense: true, // 공간 줄이기
                        contentPadding: EdgeInsets.zero,
                        counterText: '', // 내부 여백 제거
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: FilledButton.tonal(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(220, 55), // 버튼 자체 크기
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withOpacity(0.8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: TextStyle(fontSize: 20),
                      ),
                      onPressed: () async {
                        String memo = _controller.text.trim();
                        final response = await ScheduleService.editSchedule(
                            widget.scheduleId,
                            _startDate,
                            _endDate,
                            _startTime,
                            _endTime,
                            memo);

                        if (response.statusCode == 200) {
                          final responseBody = jsonDecode(response.body);
                          print('일정 수정 성공: ${responseBody}');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Placeholder() // 일정 상세
                                ),
                            // (route) =>
                            //     route.isFirst, // HomePage가 첫 번째 페이지일 경우 유지
                          );
                        } else if (response.statusCode == 401) {
                          final response = await UserService.reissueToken();

                          if (response.statusCode == 200) {
                            final decoded =
                                jsonDecode(utf8.decode(response.bodyBytes));
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString(
                                'accessToken', decoded['accessToken']);
                            await prefs.setString(
                                'refreshToken', decoded['refreshToken']);

                            /// ✅ 토큰 재발급 성공 후 재시도
                            final retry = await ScheduleService.editSchedule(
                                widget.scheduleId,
                                _startDate,
                                _endDate,
                                _startTime,
                                _endTime,
                                memo);
                            if (retry.statusCode != 200) {
                              // TODO: 오류 발생 시 행동
                            }
                          } else if (response.statusCode == 401) {
                            // refresh token 만료 시
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnimatedStartPage(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                            return;
                          } else {
                            // TODO: 서버 오류 시 행동
                          }
                        } else {
                          // TODO: 서버 오류 시 행동
                        }
                      },
                      child: Text('확인',
                          style: TextStyle(
                            fontFamily: 'PixelFont',
                          )),
                    ),
                  ),
                ],
              ))),
    );
  }
}
