import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/buttons/add_icon_button.dart';
import 'package:rockstar_app/common/buttons/list_button.dart';
import 'package:rockstar_app/common/text/highlight_text.dart';
import 'package:rockstar_app/common/text/primary_text.dart';
import 'package:rockstar_app/services/api/schedule_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/band/pages/create_schedule_page.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/band/pages/schedule_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandSchedulePage extends StatefulWidget {
  final int bandId;
  final String bandName;

  const BandSchedulePage(
      {super.key, required this.bandId, required this.bandName});

  @override
  State<BandSchedulePage> createState() => _BandSchedulePageState();
}

class _BandSchedulePageState extends State<BandSchedulePage> {
  List<Map<String, dynamic>> schedules = [];
  bool isEmptyList = false;
  bool _isManager = false;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getBandSchedules();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoading) {
        getBandSchedules();
      }
    }
  }

  Future<void> getBandSchedules() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    print(accessToken);
    print('refresh:$refreshToken');
    final response =
        await ScheduleService.getBandSchedules(widget.bandId, _currentPage);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      print("밴드 일정 불러오기: ${utf8.decode(response.bodyBytes)}");
      final List content = decoded['scheduleList'];
      setState(() => _isManager = decoded['isManager']);

      if (content.isEmpty) {
        setState(() => _hasMore = false);
        setState(() => isEmptyList = true);
      } else {
        setState(() {
          schedules.addAll(content.cast<Map<String, dynamic>>());
          _currentPage++;
        });
      }
    } else if (response.statusCode == 401) {
      final retryResponse = await UserService.reissueToken();
      if (retryResponse.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(retryResponse.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);
        getBandSchedules(); // 재시도
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
      print("밴드 일정 불러오기 실패: ${utf8.decode(response.bodyBytes)}");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_isManager)
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 20),
          child: Align(
            alignment: Alignment.center,
            child: AddIconButton(
              onPressed: () {
                toCreateSchedulePage(context);
              },
            ),
          ),
        ),
      Expanded(
          child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  schedules.clear();
                  _currentPage = 0;
                  isEmptyList = false;
                });
                await getBandSchedules();
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 20, bottom: 100),
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: schedules.length + 1,
                itemBuilder: (context, index) {
                  if (index < schedules.length) {
                    final schedule = schedules[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Align(
                        alignment: Alignment.center,
                        child: ListButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScheduleInfoPage(
                                    scheduleId: schedule['scheduleId']),
                              ),
                            );

                            if (result == true) {
                              setState(() {
                                schedules.clear();
                                _currentPage = 0;
                                _hasMore = true;
                              });
                              await getBandSchedules(); // ✅ 삭제 후 목록 갱신
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  HighlightText(
                                    label:
                                        '${schedule['startMonth'].toString().padLeft(2, '0')}.${schedule['startDay'].toString().padLeft(2, '0')}',
                                    fontSize: 32,
                                  ),
                                  SizedBox(width: 7),
                                  HighlightText(
                                    label: schedule['dayOfWeek'],
                                    fontSize: 32,
                                  ),
                                  SizedBox(width: 10),
                                  PrimaryText(
                                    label:
                                        '${schedule['startHour'].toString().padLeft(2, '0')}:${schedule['startMinute'].toString().padLeft(2, '0')}~${schedule['endHour'].toString().padLeft(2, '0')}:${schedule['endMinute'].toString().padLeft(2, '0')}',
                                    fontSize: 23,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    if (_isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else {
                      return const SizedBox.shrink(); // 다음 스크롤까지 대기
                    }
                  }
                },
              ))),
    ]);
  }

  void toCreateSchedulePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateSchedulePage(
          bandId: widget.bandId,
          bandName: widget.bandName,
        ),
      ),
    );
  }
}
