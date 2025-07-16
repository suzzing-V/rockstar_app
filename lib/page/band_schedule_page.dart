import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rockstar_app/api/band_service.dart';
import 'package:rockstar_app/api/user_service.dart';
import 'package:rockstar_app/page/band_page.dart';
import 'package:rockstar_app/page/create_band_page.dart';
import 'package:rockstar_app/page/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandSchedulePage extends StatefulWidget {
  final int bandId;
  const BandSchedulePage({super.key, required this.bandId});

  @override
  State<BandSchedulePage> createState() => _BandSchedulePageState();
}

class _BandSchedulePageState extends State<BandSchedulePage> {
  List<Map<String, dynamic>> schedules = [];
  bool isEmptyList = false;
  bool isManager = false;
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

    final response =
        await BandService.getBandSchedules(widget.bandId, _currentPage);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List content = decoded['content'];

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AnimatedStartPage()),
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
      Padding(
        padding: EdgeInsets.only(bottom: 30, top: 20),
        child: Align(
          alignment: Alignment.center,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: Size(300, 60),
              maximumSize: Size(300, 60),
              side: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withOpacity(0.8),
                width: 3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.transparent,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const Placeholder(), // 일정 생성 페이지
                ),
              );
            },
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.primaryFixed,
                size: 40,
              ),
            ),
          ),
        ),
      ),
      Expanded(
          child: ListView.builder(
        // padding: const EdgeInsets.only(top: 20),
        controller: _scrollController,
        itemCount: schedules.length + 1,
        itemBuilder: (context, index) {
          if (index < schedules.length) {
            final schedule = schedules[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Align(
                alignment: Alignment.center,
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.8),
                    minimumSize: Size(350, 80), // 버튼 자체 크기
                    maximumSize: Size(350, 80),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Placeholder(),
                        ) // 일정 상세 페이지
                        );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start, // ✅ 왼쪽 정렬
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            schedule['month'].toString().padLeft(2, '0') +
                                '.' +
                                schedule['day'].toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontFamily: 'PixelFont',
                              fontSize: 32,
                            ),
                          ),
                          SizedBox(width: 7),
                          Text(
                            schedule['dayOfWeek'],
                            style: TextStyle(
                              fontFamily: 'PixelFont',
                              fontSize: 32,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            schedule['hour'].toString().padLeft(2, '0') +
                                ':' +
                                schedule['minute'].toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontFamily: 'PixelFont',
                              fontSize: 23,
                              color: Theme.of(context).colorScheme.primary,
                            ),
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
      )),
    ]);
  }
}
