import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rockstar_app/api/api_call.dart';
import 'package:rockstar_app/button/custom_back_button.dart';
import 'package:rockstar_app/page/new_user_page.dart';
import 'package:rockstar_app/page/not_new_user_page.dart';
import 'package:rockstar_app/page/verification_page.dart';

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
                    '전화번호를 \n입력해주세요',
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      fontSize: 23,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    onChanged: _onChange,
                    // inputFormatters: [
                    //   FilteringTextInputFormatter.digitsOnly,
                    // ],
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
                  if (isValid)
                    Align(
                      alignment: Alignment.center,
                      child: FilledButton.tonal(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(220, 55), // 버튼 자체 크기
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        onPressed: () async {
                          final phonenum = _controller.text.trim();
                          final url = Uri.parse(
                              "http://${ApiCall.host}/api/v0/user/verification-code");
                          final response = await http.post(
                            url,
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              'phoneNum': phonenum,
                              'isNew': isNew,
                            }),
                          );

                          if (response.statusCode == 200) {
                            final responseBody = jsonDecode(response.body);
                            print('인증번호 전송 성공: ${responseBody}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VerificationPage(
                                      isNew: widget.isNew, phonenum: phonenum)),
                            );
                          } else if (response.statusCode == 400) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotNewUserPage(
                                        phonenum: phonenum,
                                      )), // 이미 가입한 유저
                            );
                          } else if (response.statusCode == 404) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NewUserPage(phonenum: phonenum)), // 새 유저
                            );
                          } else {
                            setState(() {
                              errorMessage = '인증번호를 보내지 못했습니다.';
                            });

                            print('인증번호 전송 실패: ${response.body}');
                          }
                        },
                        child: Text('인증번호 보내기',
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
