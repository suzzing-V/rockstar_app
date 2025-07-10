import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Rule The Rock',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 41, 15, 64)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
                      // TODO: 버튼1 액션
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
                      // TODO: 버튼2 액션
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
