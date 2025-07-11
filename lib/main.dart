import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rockstar_app/page/phonenum_input_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // TO
  // final accessToken = prefs.getString('accessToken');
  // final refreshToken = prefs.getString('refreshToken');
  final accessToken = null;
  final refreshToken = null;

  print(accessToken);
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
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 41, 15, 64)),
        ),
        home: SplashRouterPage(isLoggedIn: isLoggedIn),
      ),
    );
  }
}

class SplashRouterPage extends StatelessWidget {
  final bool isLoggedIn;

  const SplashRouterPage({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // 로그인 되어 있으면 바로 HomePage, 아니면 애니메이션 페이지
    return isLoggedIn ? HomePage() : AnimatedLandingPage();
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
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

    Future.delayed(const Duration(seconds: 1), () {
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
                'assets/rtr_logo.png',
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
                'assets/rtr_logo.png',
                width: 300,
                height: 300,
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
                  SizedBox(height: 10),
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
