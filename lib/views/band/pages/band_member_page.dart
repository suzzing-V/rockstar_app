import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/buttons/add_icon_button.dart';
import 'package:rockstar_app/common/icon/crown_icon.dart';
import 'package:rockstar_app/common/text/main_text.dart';
import 'package:rockstar_app/services/api/band_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/band/dialogs/band_url_dialog.dart';
import 'package:rockstar_app/views/band/pages/create_schedule_page.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandMemberPage extends StatefulWidget {
  final int bandId;
  final String bandName;

  const BandMemberPage(
      {super.key, required this.bandId, required this.bandName});

  @override
  State<BandMemberPage> createState() => _BandMemberPageState();
}

class _BandMemberPageState extends State<BandMemberPage> {
  List<Map<String, dynamic>> users = [];
  bool isEmptyList = false;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String bandUrl = "";
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getBandMembers();
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
        getBandMembers();
      }
    }
  }

  Future<void> getBandMembers() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    print(accessToken);
    print('refresh:$refreshToken');
    final response =
        await UserService.getBandMembers(widget.bandId, _currentPage);
    print('${jsonDecode(utf8.decode(response.bodyBytes))}');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List content = decoded['content'];

      print("밴드 멤버 불러오기: ${utf8.decode(response.bodyBytes)}");

      setState(() {
        users.addAll(content.cast<Map<String, dynamic>>());
        _currentPage++;
        _hasMore = !(decoded['last'] ?? true); // 🔁 여기!
      });

      if (content.isEmpty) {
        setState(() => isEmptyList = true);
      }
    } else if (response.statusCode == 401) {
      final retryResponse = await UserService.reissueToken();
      if (retryResponse.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(retryResponse.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);
        getBandMembers(); // 재시도
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
      Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 20),
        child: Align(
          alignment: Alignment.center,
          child: AddIconButton(
            onPressed: () async {
              await getBandUrl(context);

              showDialog(
                  context: context,
                  builder: (context) => BandUrlDialog(bandUrl: bandUrl));
            },
          ),
        ),
      ),
      Expanded(
          child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            users.clear();
            _currentPage = 0;
            isEmptyList = false;
          });
          await getBandMembers();
        },
        child: ListView.separated(
          padding: const EdgeInsets.only(right: 30, left: 30, bottom: 130),
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: users.length + 1,
          separatorBuilder: (context, index) => Divider(
              thickness: 3,
              height: 1,
              color: Theme.of(context).colorScheme.primary),
          itemBuilder: (context, index) {
            if (index < users.length) {
              final user = users[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    MainText(
                      label: user['nickname'],
                      fontSize: 23,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    if (user['isManager']) const CrownIcon(size: 20),
                  ],
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
        ),
      )),
    ]);
  }

  Future<void> getBandUrl(BuildContext context) async {
    final response = await BandService.getBandUrl(widget.bandId);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      print("밴드 멤버 불러오기: ${utf8.decode(response.bodyBytes)}");

      setState(() {
        bandUrl = decoded['url'];
      });
    } else if (response.statusCode == 401) {
      final retryResponse = await UserService.reissueToken();
      if (retryResponse.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(retryResponse.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);
        getBandUrl(context); // 재시도
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => AnimatedStartPage()),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      // TODO: 서버 오류 시 행동
      print("밴드 목록 불러오기 실패: ${jsonDecode(utf8.decode(response.bodyBytes))}");
    }
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
