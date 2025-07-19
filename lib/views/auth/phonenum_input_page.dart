import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rockstar_app/common/appBar/default_app_bar.dart';
import 'package:rockstar_app/common/buttons/primary_button.dart';
import 'package:rockstar_app/common/styles/app_text_styles.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/new_user_page.dart';
import 'package:rockstar_app/views/auth/not_new_user_page.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/auth/verification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhonenumInputPage extends StatefulWidget {
  final bool isNew;

  const PhonenumInputPage({super.key, required this.isNew});

  @override
  State<PhonenumInputPage> createState() => _PhonenumInputPageState();
}

class _PhonenumInputPageState extends State<PhonenumInputPage> {
  final _controller = TextEditingController();
  bool isValid = false;
  String? errorMessage;

  void _onChange(String value) {
    setState(() {
      isValid = value.length == 11;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.isNew;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: DefaultAppBar(title: ""),
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
                    '전화번호를 \n입력해주세요',
                    style: AppTextStyles.pixelFont23.copyWith(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    onChanged: _onChange,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
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
                  if (isValid)
                    Align(
                        alignment: Alignment.center,
                        child: PrimaryButton(
                          label: '인증번호 보내기',
                          onPressed: () async {
                            final phonenum = _controller.text.trim();
                            final response =
                                await UserService.requestCode(phonenum, isNew);

                            if (response.statusCode == 200) {
                              final responseBody = jsonDecode(response.body);
                              print('인증번호 전송 성공: $responseBody');

                              toVerificationPage(context, phonenum);
                            } else if (response.statusCode == 400) {
                              toNotNewUserPage(context, phonenum);
                            } else if (response.statusCode == 404) {
                              toNewUserPage(context, phonenum);
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
                                    phonenum, isNew);
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

  void toNewUserPage(BuildContext context, String phonenum) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewUserPage(phonenum: phonenum)), // 새 유저
    );
  }

  void toNotNewUserPage(BuildContext context, String phonenum) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NotNewUserPage(
                phonenum: phonenum,
              )), // 이미 가입한 유저
    );
  }

  void toVerificationPage(BuildContext context, String phonenum) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              VerificationPage(isNew: widget.isNew, phonenum: phonenum)),
    );
  }
}
