import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/appBar/default_app_bar.dart';
import 'package:rockstar_app/common/buttons/mini_primary_button.dart';
import 'package:rockstar_app/common/buttons/mini_secondary_button.dart';
import 'package:rockstar_app/common/dialog/one_button_dialog.dart';
import 'package:rockstar_app/common/text/main_text.dart';
import 'package:rockstar_app/common/text/primary_text.dart';
import 'package:rockstar_app/services/api/invitation_service.dart';
import 'package:rockstar_app/services/api/notification_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/band/band_page.dart';
import 'package:rockstar_app/views/band/pages/pure_schedule_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvitationPage extends StatefulWidget {
  const InvitationPage({
    super.key,
  });

  @override
  State<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
  List<Map<String, dynamic>> invitations = [];
  bool isEmptyList = false;
  bool _isLoading = false;
  bool _hasMore = true;
  bool isSelected = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getInvitations();
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
        getInvitations();
      }
    }
  }

  Future<void> getInvitations() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final response = await InvitationService.getInvitations();
    print('${jsonDecode(utf8.decode(response.bodyBytes))}');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      print("알림 불러오기: $decoded");

      setState(() {
        invitations.addAll(decoded.cast<Map<String, dynamic>>());
        isEmptyList = invitations.isEmpty;
      });
    } else if (response.statusCode == 401) {
      final retryResponse = await UserService.reissueToken();
      if (retryResponse.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(retryResponse.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);
        getInvitations(); // 재시도
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

  void acceptInvitation(int bandId) async {
    final response = await InvitationService.acceptInvitation(bandId);
    print('응답: ${jsonDecode(response.body)}');
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print('멤버 초대 성공: $responseBody');
      setState(() {
        isSelected = true; // ✅ 초대 성공 후 버튼 숨기기
      });
    } else if (response.statusCode == 401) {
      final response = await UserService.reissueToken();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);

        /// ✅ 토큰 재발급 성공 후 재시도
        final retry = await InvitationService.acceptInvitation(bandId);
        if (retry.statusCode != 200) {
          // TODO: 오류 발생 시 행동
        }
      } else if (response.statusCode == 401) {
        toAnimatedStartPage(context);
        return;
      } else {
        print('오류: ${jsonDecode(response.body)}');
      }
    } else {
      print('멤버 초대 실패: ${response.body}');
    }
  }

  void rejectInvitation(int bandId) async {
    final response = await InvitationService.rejectInvitation(bandId);
    print('응답: ${jsonDecode(response.body)}');
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print('멤버 초대 성공: $responseBody');
      setState(() {
        isSelected = true; // ✅ 초대 성공 후 버튼 숨기기
      });
    } else if (response.statusCode == 401) {
      final response = await UserService.reissueToken();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);

        /// ✅ 토큰 재발급 성공 후 재시도
        final retry = await InvitationService.rejectInvitation(bandId);
        if (retry.statusCode != 200) {
          // TODO: 오류 발생 시 행동
        }
      } else if (response.statusCode == 401) {
        toAnimatedStartPage(context);
        return;
      } else {
        print('오류: ${jsonDecode(response.body)}');
      }
    } else {
      print('멤버 초대 실패: ${response.body}');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: DefaultAppBar(title: "초대"),
      body: SafeArea(
        child: invitations.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: MainText(label: "초대가 없습니다.", fontSize: 18),
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
                      itemCount: invitations.length + 1,
                      separatorBuilder: (context, index) {
                        return Divider(
                          thickness: 3,
                          height: 1,
                          color: Theme.of(context).colorScheme.primary,
                        );
                      },
                      itemBuilder: (context, index) {
                        if (index < invitations.length) {
                          final invitation = invitations[index];
                          return InkWell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 10),

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
                                                  text:
                                                      '${invitation['bandName']}',
                                                  style: TextStyle(
                                                    fontFamily: 'PixelFont',
                                                    fontSize: 23,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondaryContainer,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isSelected == false)
                                      MiniPrimaryButton(
                                        onPressed: () => acceptInvitation(
                                            invitation['bandId']),
                                        label: "수락",
                                      ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    if (isSelected == false)
                                      MiniSecondaryButton(
                                        onPressed: () => rejectInvitation(
                                            invitation['bandId']),
                                        label: "거절",
                                      ),
                                  ],
                                )
                              ]),
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
