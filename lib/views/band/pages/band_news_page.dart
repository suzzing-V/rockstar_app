import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/text/primary_text.dart';
import 'package:rockstar_app/services/api/news_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/band/container/news_box.dart';
import 'package:rockstar_app/views/band/container/news_box_delete.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/band/pages/schedule_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandNewsPage extends StatefulWidget {
  final int bandId;

  const BandNewsPage({super.key, required this.bandId});

  @override
  State<BandNewsPage> createState() => _BandNewsPageState();
}

class _BandNewsPageState extends State<BandNewsPage> {
  List<Map<String, dynamic>> news = [];
  bool isEmptyList = false;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getBandNews();
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
        getBandNews();
      }
    }
  }

  Future<void> getBandNews() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    print(accessToken);
    print('refresh:$refreshToken');
    final response = await NewsService.getBandNews(widget.bandId, _currentPage);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      print("밴드 소식 불러오기: ${utf8.decode(response.bodyBytes)}");
      final List content = decoded['content'];

      if (content.isEmpty) {
        setState(() => _hasMore = false);
        setState(() => isEmptyList = true);
      } else {
        setState(() {
          news.addAll(content.cast<Map<String, dynamic>>());
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
        getBandNews(); // 재시도
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
      Expanded(
          child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  news.clear();
                  _currentPage = 0;
                  isEmptyList = false;
                });
                await getBandNews();
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 20, bottom: 110),
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: news.length + 1,
                itemBuilder: (context, index) {
                  if (index < news.length) {
                    final schedule = news[index];
                    return Padding(
                        padding: const EdgeInsets.only(bottom: 10, right: 20),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                (schedule['newsType'] == 'SCHEDULE_DELETED')
                                    ? NewsBoxDelete(
                                        text1: schedule['title'],
                                        text2: schedule['content'],
                                      )
                                    : NewsBox(
                                        text1: schedule['title'],
                                        text2: schedule['content'],
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ScheduleInfoPage(
                                                scheduleId:
                                                    schedule['scheduleId'],
                                                bandId: widget.bandId,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: PrimaryText(
                                    label: schedule['createdDateTime'],
                                    fontSize: 15,
                                  ),
                                )
                              ]),
                        ));
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
}
