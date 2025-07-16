import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rockstar_app/api/api_call.dart';
import 'package:rockstar_app/button/custom_back_button.dart';
import 'package:rockstar_app/page/auth/verification_page.dart';

class NewUserPage extends StatefulWidget {
  final String phonenum;

  const NewUserPage({super.key, required this.phonenum});

  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
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
                    '가입 내역이 없습니다.',
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      fontSize: 23,
                    ),
                  ),
                  SizedBox(height: 30),
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
                        final url = Uri.parse(
                            "http://${ApiCall.host}/api/v0/user/verification-code");
                        final response = await http.post(
                          url,
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'phoneNum': widget.phonenum,
                            'isNew': true,
                          }),
                        );

                        if (response.statusCode == 200) {
                          final responseBody = jsonDecode(response.body);
                          print('인증번호 전송 성공: ${responseBody}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VerificationPage(
                                    isNew: true, phonenum: widget.phonenum)),
                          );
                        } else {
                          setState(() {
                            errorMessage = '인증번호를 보내지 못했습니다.';
                          });

                          print('인증번호 전송 실패: ${response.body}');
                        }
                      },
                      child: Text('이 번호로 가입',
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
