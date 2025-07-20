import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/appBar/default_app_bar.dart';
import 'package:rockstar_app/common/text/main_text.dart';
import 'package:rockstar_app/common/text/primary_text.dart';
import 'package:rockstar_app/services/api/notification_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/band/band_page.dart';
import 'package:rockstar_app/views/band/pages/pure_schedule_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({
    super.key,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  bool isEmptyList = false;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getNotifications();
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
        getNotifications();
      }
    }
  }

  Future<void> getNotifications() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final response =
        await NotificationService.getNotificationsOfUser(_currentPage);
    print('${jsonDecode(utf8.decode(response.bodyBytes))}');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List content = decoded['content'];

      print("알림 불러오기: ${utf8.decode(response.bodyBytes)}");

      setState(() {
        notifications.addAll(content.cast<Map<String, dynamic>>());
        _currentPage++;
        _hasMore = !(decoded['last'] ?? true);
        isEmptyList = notifications.isEmpty;
      });
    } else if (response.statusCode == 401) {
      final retryResponse = await UserService.reissueToken();
      if (retryResponse.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(retryResponse.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);
        getNotifications(); // 재시도
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
      print("알림 불러오기 실패: ${utf8.decode(response.bodyBytes)}");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: DefaultAppBar(title: "알림"),
      body: SafeArea(
        child: notifications.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: MainText(label: "알림이 없습니다.", fontSize: 18),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(
                        right: 30,
                        left: 30,
                        bottom: 50,
                      ),
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: notifications.length + 1,
                      separatorBuilder: (context, index) {
                        return Divider(
                          thickness: 3,
                          height: 1,
                          color: Theme.of(context).colorScheme.primary,
                        );
                      },
                      itemBuilder: (context, index) {
                        if (index < notifications.length) {
                          final noti = notifications[index];
                          return InkWell(
                            onTap: () async {
                              String type = noti['notificationType'];

                              if (type == 'SCHEDULE_CREATED' ||
                                  type == 'SCHEDULE_UPDATED') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PureScheduleInfoPage(
                                      scheduleId: noti['contentId'],
                                    ),
                                  ),
                                );
                              } else if (type == 'SCHEDULE_DELETED') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BandPage(
                                      bandId: noti['contentId'],
                                    ),
                                  ),
                                );
                              }
                              // TODO: 가입 관련 추가
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (noti['isRead']) const SizedBox(width: 10),
                                  if (!noti['isRead'])
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 7), // 원하는 만큼 조절 가능
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 10),
                                  // 제목+내용이 줄바꿈되도록 Expanded 사용
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${noti['title']}: ',
                                                style: TextStyle(
                                                  fontFamily: 'PixelFont',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondaryContainer,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '${noti['content']}',
                                                style: TextStyle(
                                                  fontFamily: 'PixelFont',
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondaryContainer,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (noti['daysAgo'] != 0)
                                              PrimaryText(
                                                label: '${noti['daysAgo']}일 전',
                                                fontSize: 12,
                                              ),
                                            if (noti['hourAgo'] != 0)
                                              PrimaryText(
                                                label: '${noti['hourAgo']}시간 전',
                                                fontSize: 12,
                                              ),
                                            if (noti['minuteAgo'] != 0)
                                              PrimaryText(
                                                label:
                                                    '${noti['minuteAgo']}분 전',
                                                fontSize: 12,
                                              ),
                                            if (noti['secondAgo'] != 0)
                                              PrimaryText(
                                                label:
                                                    '${noti['secondAgo']}초 전',
                                                fontSize: 12,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
