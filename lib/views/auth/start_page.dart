import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/buttons/primary_button.dart';
import 'package:rockstar_app/common/buttons/secondary_button.dart';
import 'package:rockstar_app/common/logo/main_logo.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/nickname_page.dart';
import 'package:rockstar_app/views/auth/phonenum_input_page.dart';
import 'package:rockstar_app/views/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashRouterPage extends StatelessWidget {
  final bool isLoggedIn;

  const SplashRouterPage({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // 로그인 되어 있으면 바로 HomePage, 아니면 애니메이션 페이지
    return isLoggedIn ? StartPage() : AnimatedStartPage();
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    super.initState();

    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: MainLogo(
                  width: 300,
                  height: 300,
                )),
          ],
        ),
      ),
    );
  }

  void getUserInfo() {
    Future.delayed(const Duration(seconds: 1), () async {
      final response = await UserService.getUserInfo();

      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes)); // ✅ UTF-8 보장
        final nickname = decoded['nickname'];
        print('유저 조회 성공: $decoded');

        if (nickname == null) {
          toNicknamePage();
          return;
        }
      } else if (response.statusCode == 404) {
        toAnimatedStartPage();
      } else if (response.statusCode == 401) {
        final response = await UserService.reissueToken();

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', decoded['accessToken']);
          await prefs.setString('refreshToken', decoded['refreshToken']);

          /// ✅ 토큰 재발급 성공 후 재시도
          final retry = await UserService.getUserInfo();
          if (retry.statusCode != 200) {
            // TODO: 오류 발생 시 행동
          }
        } else if (response.statusCode == 401) {
          // refresh token 만료 시
          toAnimatedStartPage();
          return;
        } else {
          // TODO: 서버 오류 시 행동
        }
      } else {
        // TODO: 서버 오류 시 행동
      }
      // if (mounted) {
      toHomePage();
      // }
    });
  }

  void toHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(), // 홈화면
      ),
    );
  }

  void toAnimatedStartPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AnimatedStartPage(),
      ),
    );
  }

  void toNicknamePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NicknamePage(),
      ),
    );
  }
}

class AnimatedStartPage extends StatefulWidget {
  @override
  State<AnimatedStartPage> createState() => _AnimatedStartPageState();
}

class _AnimatedStartPageState extends State<AnimatedStartPage> {
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();

    // 2초 후 상태 변경 (애니메이션 트리거)
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _showButtons = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedPadding(
                duration: Duration(milliseconds: 600),
                padding: EdgeInsets.only(
                  top: _showButtons ? 0 : 100,
                  bottom: _showButtons ? 40 : 0,
                ),
                curve: Curves.easeOut,
                child: MainLogo(
                  width: 300,
                  height: 300,
                )),
            AnimatedOpacity(
              duration: Duration(milliseconds: 600),
              opacity: _showButtons ? 1.0 : 0.0,
              child: Column(
                children: [
                  PrimaryButton(
                    label: '시작하기',
                    onPressed: () {
                      toPhonenumInputPage(context, true);
                    },
                  ),
                  SizedBox(height: 20),
                  SecondaryButton(
                    label: '로그인',
                    onPressed: () {
                      toPhonenumInputPage(context, false);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toPhonenumInputPage(BuildContext context, bool isNew) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhonenumInputPage(isNew: isNew)),
    );
  }
}
