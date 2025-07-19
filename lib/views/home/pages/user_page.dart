import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/text/main_text.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/home/dialogs/one_title_two_button_dialog.dart';
import 'package:rockstar_app/views/home/pages/nickname_update_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String nickname = "";

  @override
  void initState() {
    super.initState();
    getMyInfo();
  }

  Future<void> getMyInfo() async {
    final response = await UserService.getUserInfo();

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        nickname = decoded['nickname'];
      });
      print("유저 불러오기: ${utf8.decode(response.bodyBytes)}");
    } else if (response.statusCode == 401) {
      final retryResponse = await UserService.reissueToken();
      if (retryResponse.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(retryResponse.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);
        getMyInfo(); // 재시도
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const SizedBox(width: 10),
                MainText(label: nickname, fontSize: 25),
              ]),
              SizedBox(height: 20),
              Divider(
                  thickness: 3,
                  height: 1,
                  color: Theme.of(context).colorScheme.primary),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        // const SizedBox(height: 0),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListTile(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NicknameUpdatePage() // 닉네임 수정 페이지
                    ),
              );

              if (result == true) {
                getMyInfo(); // ✅ 돌아왔을 때 갱신
              }
            },
            leading: Icon(
              Icons.edit,
              size: 24,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            title: MainText(
              label: '닉네임 수정하기',
              fontSize: 20,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListTile(
            onTap: () async {
              await showDialog<bool>(
                context: context,
                builder: (dialogContext) => OneTitleTwoButtonDialog(
                  title: '로그아웃 하시겠습니까?',
                  onConfirm: () async {
                    await logout(context); // ← 여기에서 true 반환
                  },
                ),
              );
            },
            leading: Icon(
              Icons.logout,
              size: 24,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            title: MainText(
              label: '로그아웃',
              fontSize: 20,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListTile(
            onTap: () async {
              await showDialog<bool>(
                context: context,
                builder: (dialogContext) => OneTitleTwoButtonDialog(
                  title: '탈퇴하시겠습니까?',
                  content: '탈퇴 시 밴드 관리자 권한은 위임됩니다.',
                  onConfirm: () => handleWithdraw(context),
                ),
              );
            },
            leading: Icon(
              Icons.delete_forever,
              size: 24,
              color: Colors.red,
            ),
            title: MainText(
              label: '탈퇴하기',
              fontSize: 20,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> logout(BuildContext context) async {
    await UserService.logout();

    await clearTokens();

    toAnimatedStartPage(context);
  }

  void toAnimatedStartPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => AnimatedStartPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> handleWithdraw(BuildContext context) async {
    final response = await UserService.withdraw();

    if (response.statusCode == 200) {
      await clearTokens();
      toAnimatedStartPage(context);
    } else if (response.statusCode == 401) {
      final retryResponse = await UserService.reissueToken();

      if (retryResponse.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(retryResponse.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);

        /// ✅ 토큰 재발급 성공 후 재시도
        final retry = await UserService.withdraw();
        if (retry.statusCode == 200) {
          await clearTokens();
          toAnimatedStartPage(context);
        } else {
          // TODO: 재시도 실패 시 처리
        }
      } else if (retryResponse.statusCode == 401) {
        toAnimatedStartPage(context);
      } else {
        // TODO: 서버 오류 시 처리
      }
    } else {
      // TODO: 서버 오류 시 처리
    }
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }
}
