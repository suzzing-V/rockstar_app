import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/appBar/default_app_bar.dart';
import 'package:rockstar_app/common/dialog/one_button_dialog.dart';
import 'package:rockstar_app/common/text/main_text.dart';
import 'package:rockstar_app/services/api/band_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/home/dialogs/one_title_two_button_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectManagerPage extends StatefulWidget {
  final int bandId;

  const SelectManagerPage({super.key, required this.bandId});

  @override
  State<SelectManagerPage> createState() => _SelectManagerPageState();
}

class _SelectManagerPageState extends State<SelectManagerPage> {
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
        _hasMore = !(decoded['last'] ?? true);
        isEmptyList = users.isEmpty;
      });
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: DefaultAppBar(title: "새 관리자 선택하기"),
      body: SafeArea(
        child: users.length == 1
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: MainText(label: "멤버가 없습니다.", fontSize: 18),
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
                      itemCount: users.length + 1,
                      separatorBuilder: (context, index) {
                        if (index < users.length && users[index]['isManager']) {
                          return const SizedBox.shrink();
                        }
                        return Divider(
                          thickness: 3,
                          height: 1,
                          color: Theme.of(context).colorScheme.primary,
                        );
                      },
                      itemBuilder: (context, index) {
                        if (index < users.length &&
                            !users[index]['isManager']) {
                          final user = users[index];
                          return InkWell(
                            onTap: () async {
                              await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) =>
                                    OneTitleTwoButtonDialog(
                                  title: '${user['nickname']}에게 관리자를 위임하시겠습니까?',
                                  onConfirm: () async {
                                    final response =
                                        await BandService.delegateManager(
                                            widget.bandId, user['userId']);
                                    print('{$jsonDecode(response.body)}');
                                    if (response.statusCode == 200) {
                                      Navigator.pop(context);
                                      Navigator.pop(context, true);
                                    } else if (response.statusCode == 404) {
                                      Navigator.pop(context);
                                      await showDialog(
                                        context: context,
                                        builder: (context) => OneButtonDialog(
                                          title: '밴드 멤버가 아닙니다.',
                                          onConfirm: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      );
                                    } else if (response.statusCode == 401) {
                                      final response =
                                          await UserService.reissueToken();

                                      if (response.statusCode == 200) {
                                        final decoded = jsonDecode(
                                            utf8.decode(response.bodyBytes));
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        await prefs.setString('accessToken',
                                            decoded['accessToken']);
                                        await prefs.setString('refreshToken',
                                            decoded['refreshToken']);

                                        /// ✅ 토큰 재발급 성공 후 재시도
                                        final retry =
                                            await BandService.delegateManager(
                                                widget.bandId, user['userId']);
                                        if (retry.statusCode != 200) {
                                          // TODO: 오류 발생 시 행동
                                        }
                                      } else if (response.statusCode == 401) {
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
                                        print('{$jsonDecode(response.body)}');
                                      }
                                    } else {
                                      // 오류 시 행동

                                      print('밴드 이름 수정 실패: ${response.body}');
                                    }
                                  },
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  MainText(
                                    label: user['nickname'],
                                    fontSize: 23,
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
