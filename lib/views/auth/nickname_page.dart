import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rockstar_app/common/appBar/default_app_bar.dart';
import 'package:rockstar_app/common/buttons/primary_button.dart';
import 'package:rockstar_app/common/styles/app_text_styles.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/home/home_page.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
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
      appBar: DefaultAppBar(
        title: "",
        onBack: () => toAnimatedStartPage(context),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(40), // 여백을 줘서 너무 붙지 않게
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 수평 왼쪽 정렬
                mainAxisAlignment: MainAxisAlignment.start, // 수직 위 정렬
                children: [
                  Text(
                    '사용하실 닉네임을 \n입력해주세요',
                    style: AppTextStyles.pixelFont23.copyWith(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.text,
                    onChanged: _onChange,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.deny(
                          RegExp(r'\s')), // 공백 문자 차단
                    ],
                    style: AppTextStyles.pixelFont23.copyWith(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 20, // ✅ 항상 20px 공간 확보 (텍스트 높이에 맞게 조절)
                    child: errorMessage != null
                        ? Text(errorMessage!, style: AppTextStyles.errorText)
                        : null, // 메시지 없을 땐 비움 (공간만 차지)
                  ),
                  SizedBox(height: 20),
                  Align(
                      alignment: Alignment.center,
                      child: PrimaryButton(
                        label: '확인',
                        onPressed: () async {
                          final nickname = _controller.text.trim();
                          if (nickname.isEmpty) {
                            setState(() {
                              errorMessage = '닉네임을 입력해주세요';
                            });
                          } else {
                            final response =
                                await UserService.updateNickname(nickname);

                            if (response.statusCode == 200) {
                              final responseBody = jsonDecode(response.body);
                              print('닉네임 등록 성공: $responseBody');
                              toHomePage(context);
                            } else if (response.statusCode == 400) {
                              setState(() {
                                errorMessage = '이미 사용 중인 닉네임입니다.';
                              });
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
                                final retry =
                                    await UserService.updateNickname(nickname);
                                if (retry.statusCode != 200) {
                                  // TODO: 오류 발생 시 행동
                                }
                              } else if (response.statusCode == 401) {
                                // refresh token 만료 시
                                toAnimatedStartPage(context);
                                return;
                              } else {
                                // TODO: 서버 오류 시 행동
                              }
                            } else {
                              setState(() {
                                errorMessage = '닉네임을 등록하지 못했습니다.';
                              });

                              print('닉네임 등록 실패: ${response.body}');
                            }
                          }
                        },
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toAnimatedStartPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => AnimatedStartPage(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void toHomePage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false,
    );
  }
}
