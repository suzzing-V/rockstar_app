import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/appBar/default_app_bar.dart';
import 'package:rockstar_app/common/buttons/primary_button.dart';
import 'package:rockstar_app/common/styles/app_text_styles.dart';
import 'package:rockstar_app/common/buttons/custom_back_button.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/verification_page.dart';

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
      appBar: DefaultAppBar(title: ""),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 뒤로가기 버튼은 Padding 밖
            Padding(
              padding: const EdgeInsets.all(40), // 여백을 줘서 너무 붙지 않게
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 수평 왼쪽 정렬
                mainAxisAlignment: MainAxisAlignment.start, // 수직 위 정렬
                children: [
                  Text(
                    '가입 내역이 없습니다.',
                    style: AppTextStyles.pixelFont23.copyWith(
                      color: Theme.of(context).colorScheme.secondaryContainer,
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
                      label: '이 번호로 가입',
                      onPressed: () async {
                        final response = await UserService.requestCode(
                            widget.phonenum, true);
                        if (response.statusCode == 200) {
                          final responseBody = jsonDecode(response.body);
                          print('인증번호 전송 성공: ${responseBody}');
                          toVerificationPage(context);
                        } else {
                          setState(() {
                            errorMessage = '인증번호를 보내지 못했습니다.';
                          });

                          print('인증번호 전송 실패: ${response.body}');
                        }
                      },
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

  void toVerificationPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              VerificationPage(isNew: true, phonenum: widget.phonenum)),
    );
  }
}
