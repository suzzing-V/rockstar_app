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
import 'package:rockstar_app/views/band/band_page.dart';
import 'package:rockstar_app/views/band/pages/band_schedule_page.dart';
import 'package:rockstar_app/views/band/pages/schedule_info_page.dart';
import 'package:rockstar_app/views/home/pages/invitation_page.dart';
import 'firebase_options.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 🔔 로컬 알림 플러그인 전역 객체
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ✅ navigatorKey 전역 선언
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ✅ 알림 클릭 시 초기 메시지 저장용
RemoteMessage? _initialMessage;

void _handleLocalNotificationTap(String? payload) {
  if (payload == null) return;

  final data = jsonDecode(payload);
  final type = data['type'];

  if (type == 'SCHEDULE_INFO') {
    final scheduleId = int.tryParse(data['scheduleId'] ?? '');
    final bandId = int.tryParse(data['bandId'] ?? '');
    if (scheduleId != null && bandId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ScheduleInfoPage(
            scheduleId: scheduleId,
            bandId: bandId,
          ),
        ),
      );
    }
  }
  if (type == 'SCHEDULE_LIST') {
    final bandId = int.tryParse(data['bandId'] ?? '');
    if (bandId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => BandPage(
            bandId: bandId,
          ),
        ),
      );
    }
  }
  if (type == 'INVITATION') {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => InvitationPage(),
      ),
    );
  }
  if (type == 'INVITATION_ACCEPT') {
    final bandId = int.tryParse(data['bandId'] ?? '');
    if (bandId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => BandPage(
            bandId: bandId,
          ),
        ),
      );
    }
  }
}

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

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      _handleLocalNotificationTap(response.payload);
    },
  );
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
  await initializeLocalNotification();

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

  // ✅ 포그라운드 수신 → 로컬 알림 띄우기
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('🟢 포그라운드 메시지 수신: ${message.notification?.title}');
    RemoteNotification? notification = message.notification;

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
        payload: jsonEncode(message.data),
      );
    }
  });

  // ✅ 백그라운드 상태 → 알림 클릭 시
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📲 알림 클릭 후 앱 오픈: ${message.notification?.title}');
    _handleNotificationTap(message);
  });

  // ✅ 종료 상태 → 알림 클릭 시
  _initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  // ✅ FCM 토큰 저장
  // ✅ 시뮬레이터일 경우 FCM 토큰 요청 생략
  if (!Platform.isIOS ||
      !Platform.environment.containsKey('SIMULATOR_DEVICE_NAME')) {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print('📱 디바이스 FCM 토큰: $fcmToken');
      if (fcmToken != null) {
        final prefs = await SharedPreferences.getInstance();
        String? savedFcmToken = prefs.getString('fcmToken');
        if (savedFcmToken == null || fcmToken != savedFcmToken) {
          prefs.setString('fcmToken', fcmToken);
          prefs.setBool('isFcmTokenUpdated', true);
        } else {
          prefs.setBool('isFcmTokenUpdated', false);
        }
      }
    } catch (e) {
      print('⚠️ FCM 토큰 가져오기 실패 (시뮬레이터 또는 네트워크 문제): $e');
    }
  } else {
    print('🛑 시뮬레이터에서 FCM 토큰 요청 생략됨');
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
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, // ✅ 여기 중요
        title: 'Rockstar',
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
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
        builder: (context, child) {
          // ✅ 앱 종료 → 알림 클릭 시 한 번만 처리
          if (_initialMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleNotificationTap(_initialMessage!);
              _initialMessage = null;
            });
          }
          return child!;
        },
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

// ✅ 푸시 알림 클릭 처리
void _handleNotificationTap(RemoteMessage message) {
  final data = message.data;
  final type = data['type'];

  if (type == 'SCHEDULE_INFO') {
    final scheduleId = int.tryParse(data['scheduleId'] ?? '');
    final bandId = int.tryParse(data['bandId'] ?? '');
    if (scheduleId != null && bandId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ScheduleInfoPage(
            scheduleId: scheduleId,
            bandId: bandId,
          ),
        ),
      );
    }
  }
  if (type == 'SCHEDULE_LIST') {
    final bandId = int.tryParse(data['bandId'] ?? '');
    if (bandId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => BandPage(
            bandId: bandId,
          ),
        ),
      );
    }
  }
  if (type == 'INVITATION') {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => InvitationPage(),
      ),
    );
  }
  if (type == 'INVITATION_ACCEPT') {
    final bandId = int.tryParse(data['bandId'] ?? '');
    if (bandId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => BandPage(
            bandId: bandId,
          ),
        ),
      );
    }
  }
}

// ✅ 딥링크 핸들러 (기존 코드 그대로)
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
