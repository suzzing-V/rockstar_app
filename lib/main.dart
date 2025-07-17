import 'dart:convert';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // TODO: 테스트용 자동 로그인 해제
  String? accessToken = prefs.getString('accessToken');
  String? refreshToken = prefs.getString('refreshToken');
  // String? accessToken = null;
  // String? refreshToken = null;

  print(accessToken);
  // 앱 시작할 때마다 토큰 재발급
  if (refreshToken != null) {
    final response = await UserService.reissueToken();

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final prefs = await SharedPreferences.getInstance();

      prefs.setString('accessToken', decoded['accessToken']);
      prefs.setString('refreshToken', decoded['refreshToken']);

      accessToken = decoded['accessToken'];
      refreshToken = decoded['refreshToken'];
    } else if (response.statusCode == 401) {
      // refresh token 만료 시
      prefs.remove('accessToken');
      prefs.remove('refreshToken');
      accessToken = null;
      refreshToken = null;
    } else {
      // TODO: 서버 오류 시 행동
    }
  }

  print("new $accessToken");
  runApp(MyApp(isLoggedIn: accessToken != null && refreshToken != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Rockstar',
        theme: ThemeData(
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android:
                  CupertinoPageTransitionsBuilder(), // 예: iOS 스타일
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            },
          ),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 41, 15, 64)),
        ),
        home: SplashRouterPage(isLoggedIn: isLoggedIn),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko'), // ✅ 한국어 추가
          Locale('en'), // 기본 영어
        ],
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}
