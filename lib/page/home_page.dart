import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rockstar_app/api/api_call.dart';
import 'package:rockstar_app/page/nickname_page.dart';
import 'package:rockstar_app/page/phonenum_input_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashRouterPage extends StatelessWidget {
  final bool isLoggedIn;

  const SplashRouterPage({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // 로그인 되어 있으면 바로 HomePage, 아니면 애니메이션 페이지
    return isLoggedIn ? HomePage() : AnimatedLandingPage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () async {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      final url = Uri.parse("http://${ApiCall.host}/api/v0/user");
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );

      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes)); // ✅ UTF-8 보장
        final nickname = decoded['nickname'];
        print('유저 조회 성공: $decoded');

        if (nickname == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NicknamePage(),
            ),
          );
          return;
        }
      } else if (response.statusCode == 404) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnimatedLandingPage(), // 홈화면
          ),
        );
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Placeholder(), // 홈화면
          ),
        );
      }
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
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Image.asset(
                'assets/logo/rockstar_logo.png',
                width: 300,
                height: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedLandingPage extends StatefulWidget {
  @override
  State<AnimatedLandingPage> createState() => _AnimatedLandingPageState();
}

class _AnimatedLandingPageState extends State<AnimatedLandingPage> {
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
              child: Image.asset(
                'assets/logo/rockstar_logo.png',
                width: 270,
                height: 270,
              ),
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: 600),
              opacity: _showButtons ? 1.0 : 0.0,
              child: Column(
                children: [
                  FilledButton.tonal(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(250, 60), // 버튼 자체 크기
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PhonenumInputPage(isNew: true)),
                      );
                    },
                    child: Text('시작하기',
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                        )),
                  ),
                  SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(250, 60), // 버튼 자체 크기
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PhonenumInputPage(isNew: false)),
                      );
                    },
                    child: Text('로그인',
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
