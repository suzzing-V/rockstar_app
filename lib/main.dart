import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 🔔 로컬 알림 플러그인 전역 객체
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 🔔 로컬 알림 초기화 함수
Future<void> initializeLocalNotification() async {
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosInitSettings =
      DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
    iOS: iosInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

// 🔁 백그라운드 메시지 핸들러
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('📩 백그라운드 메시지 수신: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeLocalNotification(); // ✅ 알림 초기화

  if (Platform.isIOS) {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🔐 권한 상태: ${settings.authorizationStatus}');
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ 포그라운드 메시지 수신 처리
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('🟢 포그라운드 메시지 수신: ${message.notification?.title}');

    RemoteNotification? notification = message.notification;
    AppleNotification? apple = message.notification?.apple;

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          android: AndroidNotificationDetails(
            'default_channel',
            '기본 채널',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📲 알림 클릭 후 앱 오픈: ${message.notification?.title}');
    // TODO: 특정 화면 이동 처리
  });

  String? fcmToken = await FirebaseMessaging.instance.getToken();
  print('📱 디바이스 FCM 토큰: $fcmToken');
  if (fcmToken == null) {
    debugPrint("⚠️ FCM 토큰이 null입니다.");
  } else {
    final prefs = await SharedPreferences.getInstance();
    String? savedFcmToken = prefs.getString('fcmToken');
    if (savedFcmToken == null || fcmToken != savedFcmToken) {
      print('📌 fcmToken 저장됨');
      prefs.setString('fcmToken', fcmToken);
      prefs.setBool('isFcmTokenUpdated', true);
    } else {
      prefs.setBool('isFcmTokenUpdated', false);
    }
  }

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

  print('runApp 실행전');
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

    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleUri(uri);
    });

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
