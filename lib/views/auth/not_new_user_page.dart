import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/buttons/primary_button.dart';
import 'package:rockstar_app/common/styles/app_text_styles.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/common/buttons/custom_back_button.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/auth/verification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotNewUserPage extends StatefulWidget {
  final String phonenum;

  const NotNewUserPage({super.key, required this.phonenum});

  @override
  State<NotNewUserPage> createState() => _NotNewUserPageState();
}

class _NotNewUserPageState extends State<NotNewUserPage> {
  String? errorMessage;

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
                    '이미 가입한 사용자입니다.',
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      fontSize: 23,
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    height: 20,
                    child: errorMessage != null
                        ? Text(errorMessage!, style: AppTextStyles.errorText)
                        : null,
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: PrimaryButton(
                        label: '이 번호로 로그인',
                        onPressed: () async {
                          final response = await UserService.requestCode(
                              widget.phonenum, false);

                          if (response.statusCode == 200) {
                            final responseBody = jsonDecode(response.body);
                            print('인증번호 전송 성공: ${responseBody}');
                            toVerificationPage(context);
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
                              final retry = await UserService.requestCode(
                                  widget.phonenum, false);
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
                              errorMessage = '인증번호를 보내지 못했습니다.';
                            });

                            print('인증번호 전송 실패: ${response.body}');
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

  void toVerificationPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              VerificationPage(isNew: false, phonenum: widget.phonenum)),
    );
  }
}
