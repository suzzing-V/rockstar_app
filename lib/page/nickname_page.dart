import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rockstar_app/api/api_call.dart';
import 'package:rockstar_app/button/custom_back_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NicknamePage extends StatefulWidget {
  const NicknamePage({super.key});

  @override
  State<NicknamePage> createState() => _NicknamePageState();
}

class _NicknamePageState extends State<NicknamePage> {
  final _controller = TextEditingController();
  String? errorMessage;

  void _onChange(String value) {
    setState(() {
      errorMessage = null;
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
                    '사용하실 닉네임을 \n입력해주세요',
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      fontSize: 23,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.text,
                    onChanged: _onChange,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                      FilteringTextInputFormatter.deny(
                          RegExp(r'\s')), // 공백 문자 차단
                    ],
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      fontSize: 23,
                    ),
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
                    child: FilledButton.tonal(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(220, 55), // 버튼 자체 크기
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      onPressed: () async {
                        final nickname = _controller.text.trim();
                        if (nickname.isEmpty) {
                          setState(() {
                            errorMessage = '닉네임을 입력해주세요';
                          });
                        } else {
                          final prefs = await SharedPreferences.getInstance();
                          final accessToken = prefs.getString('accessToken');

                          final url = Uri.parse(
                              "http://${ApiCall.host}/api/v0/user/nickname");
                          final response = await http.patch(
                            url,
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $accessToken'
                            },
                            body: jsonEncode({
                              'nickname': nickname,
                            }),
                          );

                          if (response.statusCode == 200) {
                            final responseBody = jsonDecode(response.body);
                            print('닉네임 등록 성공: $responseBody');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Placeholder(), // 홈화면
                              ),
                            );
                          } else if (response.statusCode == 400) {
                            setState(() {
                              errorMessage = '이미 사용 중인 닉네임입니다.';
                            });
                          } else {
                            setState(() {
                              errorMessage = '닉네임을 등록하지 못했습니다.';
                            });

                            print('닉네임 등록 실패: ${response.body}');
                          }
                        }
                      },
                      child: Text('확인',
                          style: TextStyle(
                            fontFamily: 'PixelFont',
                          )),
                    ),
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
