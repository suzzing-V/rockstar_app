import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
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
  String? accessToken = prefs.getString('accessToken');
  String? refreshToken = prefs.getString('refreshToken');

  if (refreshToken != null) {
    final response = await UserService.reissueToken();
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      prefs.setString('accessToken', decoded['accessToken']);
      prefs.setString('refreshToken', decoded['refreshToken']);

      accessToken = decoded['accessToken'];
      refreshToken = decoded['refreshToken'];
    } else if (response.statusCode == 401) {
      prefs.remove('accessToken');
      prefs.remove('refreshToken');
      accessToken = null;
      refreshToken = null;
    }
  }

  runApp(
    MyApp(isLoggedIn: accessToken != null && refreshToken != null),
  );
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
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            },
          ),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 41, 15, 64)),
        ),
        home: DeepLinkHandler(
          child: SplashRouterPage(isLoggedIn: isLoggedIn),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko'),
          Locale('en'),
        ],
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class DeepLinkHandler extends StatefulWidget {
  final Widget child;

  const DeepLinkHandler({required this.child, super.key});

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();

    // 앱 실행 중 딥링크 수신
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleUri(uri);
    });

    // 앱 처음 실행 시 딥링크 수신
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        _handleUri(uri);
      }
    });
  }

  void _handleUri(Uri uri) {
    print("💡 딥링크 URI 수신: $uri");

    if (uri.host == 'invite' || uri.path.contains('/invite')) {
      final code = uri.pathSegments.last;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed('/invite/$code');
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
