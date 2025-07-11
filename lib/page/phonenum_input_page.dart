import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class PhonenumInputPage extends StatefulWidget {
  final bool isNew;

  const PhonenumInputPage({super.key, required this.isNew});

  @override
  State<PhonenumInputPage> createState() => _PhonenumInputPageState();
}

class _PhonenumInputPageState extends State<PhonenumInputPage> {
  final _controller = TextEditingController();
  bool isValid = false;

  void _onChange(String value) {
    setState(() {
      isValid = value.length == 11;
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
            Padding(
              padding: const EdgeInsets.all(10), // 여백을 줘서 너무 붙지 않게
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new),
                color: Theme.of(context).colorScheme.secondaryContainer,
                iconSize: 23,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      fontSize: 23,
                    ),
                  ),
                  SizedBox(height: 40),
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
                              "http://3.34.183.135/api/v0/user/verification-code");
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
                                  builder: (context) => Placeholder()),
                            );
                          } else if (response.statusCode == 400) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Placeholder()), // 이미 가입한 유저
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Placeholder()), // 오류 발생 페이지
                            );
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
