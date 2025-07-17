import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rockstar_app/common/button/custom_back_button.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/home/home_page.dart';
import 'package:rockstar_app/views/auth/nickname_page.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationPage extends StatefulWidget {
  final bool isNew;
  final String phonenum;

  const VerificationPage(
      {super.key, required this.isNew, required this.phonenum});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _controller = TextEditingController();
  String? errorMessage;
  late Timer _timer;
  int _remainingSeconds = 10;
  String get timerText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    _startTimer(); // ✅ 여기서 시작
  }

  @override
  void dispose() {
    _timer.cancel(); // ✅ 타이머 정리
    super.dispose();
  }

  void _onChange(String value) {}

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            errorMessage = '시간을 초과했습니다.';
          });
        }
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 뒤로가기 버튼은 Padding 밖
            CustomBackButton(),
            Padding(
              padding: const EdgeInsets.all(40), // 여백을 줘서 너무 붙지 않게
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 수평 왼쪽 정렬
                mainAxisAlignment: MainAxisAlignment.start, // 수직 위 정렬
                children: [
                  Text(
                    '인증번호를 \n입력해주세요',
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      fontSize: 23,
                    ),
                  ),
                  SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        onChanged: _onChange,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          fontSize: 23,
                        ),
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.only(right: 70), // 오른쪽 여백 확보
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          timerText, // ex: 01:00
                          style: TextStyle(
                            fontFamily: 'PixelFont',
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 20, // ✅ 항상 20px 공간 확보 (텍스트 높이에 맞게 조절)
                    child: errorMessage != null
                        ? Text(
                            errorMessage!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontFamily: 'PixelFont',
                            ),
                          )
                        : null, // 메시지 없을 땐 비움 (공간만 차지)
                  ),
                  SizedBox(height: 20),
                  Align(
                      alignment: Alignment.center,
                      child: Column(children: [
                        FilledButton.tonal(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(220, 55), // 버튼 자체 크기
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            textStyle: TextStyle(fontSize: 18),
                          ),
                          onPressed: () async {
                            final code = _controller.text.trim();
                            final response = await UserService.login(
                                code, widget.phonenum, widget.isNew);

                            final decoded = jsonDecode(
                                utf8.decode(response.bodyBytes)); // ✅ UTF-8 보장
                            final statusCodeName = decoded['code'];
                            final nickname = decoded['nickname'];

                            if (response.statusCode == 200) {
                              final responseBody = jsonDecode(response.body);
                              final accessToken = responseBody['accessToken'];
                              final refreshToken = responseBody['refreshToken'];

                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('accessToken', accessToken);
                              await prefs.setString(
                                  'refreshToken', refreshToken);

                              print(widget.isNew);
                              print('인증 성공: $responseBody');
                              if (nickname == null) {
                                print('닉네임 없음');
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NicknamePage()),
                                );
                              } else {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()),
                                  (Route<dynamic> route) => false,
                                );
                              }
                            } else if (response.statusCode == 401) {
                              final response = await UserService.reissueToken();

                              if (response.statusCode == 200) {
                                final decoded =
                                    jsonDecode(utf8.decode(response.bodyBytes));
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                    'accessToken', decoded['accessToken']);
                                await prefs.setString(
                                    'refreshToken', decoded['refreshToken']);

                                /// ✅ 토큰 재발급 성공 후 재시도
                                final retry = await UserService.login(
                                    code, widget.phonenum, widget.isNew);
                                if (retry.statusCode != 200) {
                                  // TODO: 오류 발생 시 행동
                                }
                              } else if (response.statusCode == 401) {
                                // refresh token 만료 시
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnimatedStartPage(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                                return;
                              } else {
                                // TODO: 서버 오류 시 행동
                              }
                            } else if (statusCodeName ==
                                'VERIFICATION_CODE_INCORRECT') {
                              print('인증 실패: ${response.body}');
                              setState(() {
                                errorMessage = '인증번호가 틀렸습니다.';
                              });
                            } else {
                              setState(() {
                                errorMessage = '다시 시도해주세요.';
                              });

                              print('인증 실패: ${response.body}');
                            }
                          },
                          child: Text('확인',
                              style: TextStyle(
                                fontFamily: 'PixelFont',
                              )),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                            onTap: () async {
                              final response = await UserService.requestCode(
                                  widget.phonenum, widget.isNew);

                              if (response.statusCode == 200) {
                                final responseBody = jsonDecode(response.body);
                                _remainingSeconds = 10;
                                _startTimer();
                                print('인증번호 전송 성공: $responseBody');
                              } else if (response.statusCode == 401) {
                                final response =
                                    await UserService.reissueToken();

                                if (response.statusCode == 200) {
                                  final decoded = jsonDecode(
                                      utf8.decode(response.bodyBytes));
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'accessToken', decoded['accessToken']);
                                  await prefs.setString(
                                      'refreshToken', decoded['refreshToken']);

                                  /// ✅ 토큰 재발급 성공 후 재시도
                                  final retry = await UserService.requestCode(
                                      widget.phonenum, widget.isNew);
                                  if (retry.statusCode != 200) {
                                    // TODO: 오류 발생 시 행동
                                  }
                                } else if (response.statusCode == 401) {
                                  // refresh token 만료 시
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AnimatedStartPage(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                  return;
                                } else {
                                  // TODO: 서버 오류 시 행동
                                }
                              } else {
                                setState(() {
                                  errorMessage = '인증번호를 보내지 못했습니다.';
                                });

                                print('인증번호 전송 실패: ${response.body}');
                              }
                            },
                            child: Text(
                              '인증번호 다시 보내기',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 14,
                                fontFamily: 'PixelFont',
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                            )),
                      ])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
