import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rockstar_app/common/buttons/custom_back_button.dart';
import 'package:rockstar_app/common/buttons/primary_button.dart';
import 'package:rockstar_app/common/styles/app_text_styles.dart';
import 'package:rockstar_app/common/text/main_text.dart';
import 'package:rockstar_app/services/api/band_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/home/home_page.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateBandPage extends StatefulWidget {
  const CreateBandPage({super.key});

  @override
  State<CreateBandPage> createState() => _CreateBandPageState();
}

class _CreateBandPageState extends State<CreateBandPage> {
  final _controller = TextEditingController();
  bool isValid = false;
  String? errorMessage;

  void _onChange(String value) {
    setState(() {
      isValid = value.length >= 1;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    createBand() async {
      final bandName = _controller.text.trim();
      final response = await BandService.createBand(bandName);
      print('{$jsonDecode(response.body)}');
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('밴드 생성 성공: $responseBody');
        toHomePage(context);
      } else if (response.statusCode == 401) {
        final response = await UserService.reissueToken();

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', decoded['accessToken']);
          await prefs.setString('refreshToken', decoded['refreshToken']);

          /// ✅ 토큰 재발급 성공 후 재시도
          final retry = await BandService.createBand(bandName);
          if (retry.statusCode != 200) {
            // TODO: 오류 발생 시 행동
          }
        } else if (response.statusCode == 401) {
          // refresh token 만료 시
          toAnimatedStartPage(context);
          return;
        } else {
          print('{$jsonDecode(response.body)}');
        }
      } else {
        // 오류 시 행동

        print('밴드 생성 실패: ${response.body}');
      }
    }

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
                  MainText(
                    label: '밴드 이름을 \n입력해주세요',
                    fontSize: 23,
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.text,
                    onChanged: _onChange,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
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
                        ? Text(errorMessage!, style: AppTextStyles.errorText)
                        : null, // 메시지 없을 땐 비움 (공간만 차지)
                  ),
                  SizedBox(height: 20),
                  if (isValid)
                    Align(
                      alignment: Alignment.center,
                      child: PrimaryButton(
                        label: '확인',
                        onPressed: createBand,
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
