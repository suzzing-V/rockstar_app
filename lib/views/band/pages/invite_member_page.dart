import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rockstar_app/common/appBar/default_app_bar.dart';
import 'package:rockstar_app/common/buttons/custom_back_button.dart';
import 'package:rockstar_app/common/buttons/mini_primary_button.dart';
import 'package:rockstar_app/common/buttons/mini_secondary_button.dart';
import 'package:rockstar_app/common/styles/app_text_styles.dart';
import 'package:rockstar_app/common/text/main_text.dart';
import 'package:rockstar_app/common/text/primary_text.dart';
import 'package:rockstar_app/services/api/band_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InviteMemberPage extends StatefulWidget {
  final int bandId;

  const InviteMemberPage({super.key, required this.bandId});

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? foundUser;
  bool isInvited = false;

  void _onChange(String value) {
    setState(() {
      errorMessage = null;
    });
  }

  void _searchUser() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      foundUser = null;
    });

    try {
      final response = await UserService.searchByNickname(
          widget.bandId, _controller.text.trim());
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        setState(() {
          foundUser = jsonDecode(response.body);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = "사용자를 찾을 수 없습니다.";
        });
      } else if (response.statusCode == 401) {
        final response = await UserService.reissueToken();

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', decoded['accessToken']);
          await prefs.setString('refreshToken', decoded['refreshToken']);

          /// ✅ 토큰 재발급 성공 후 재시도
          final retry = await UserService.searchByNickname(
              widget.bandId, _controller.text.trim());
          if (retry.statusCode == 200) {
            setState(() {
              foundUser = jsonDecode(retry.body);
            });
          } else {
            setState(() {
              errorMessage = "사용자를 찾을 수 없습니다.";
            });
          }
        } else if (response.statusCode == 401) {
          // refresh token 만료 시
          toAnimatedStartPage(context);
          return;
        } else {
          print('오류: ${jsonDecode(response.body)}');
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = "검색 중 오류가 발생했습니다.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _inviteUser() async {
    final response =
        await BandService.inviteUser(widget.bandId, foundUser!['userId']);
    print('응답: ${jsonDecode(response.body)}');
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print('멤버 초대 성공: $responseBody');
      setState(() {
        isInvited = true; // ✅ 초대 성공 후 버튼 숨기기
      });
    } else if (response.statusCode == 401) {
      final response = await UserService.reissueToken();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);

        /// ✅ 토큰 재발급 성공 후 재시도
        final retry =
            await BandService.inviteUser(widget.bandId, foundUser!['userId']);
        if (retry.statusCode != 200) {
          // TODO: 오류 발생 시 행동
        }
      } else if (response.statusCode == 401) {
        toAnimatedStartPage(context);
        return;
      } else {
        print('오류: ${jsonDecode(response.body)}');
      }
    } else {
      print('멤버 초대 실패: ${response.body}');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: DefaultAppBar(title: '멤버 초대하기'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.text,
                onChanged: _onChange,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ],
                style: AppTextStyles.pixelFont23.copyWith(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              MiniPrimaryButton(
                onPressed: () {
                  if (!isLoading) _searchUser();
                },
                label: "검색",
              ),
              SizedBox(height: 40),
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: AppTextStyles.errorText,
                )
              else if (foundUser != null)
                Column(
                  children: [
                    ListTile(
                      title: MainText(label: foundUser!['nickname']),
                      subtitle: (foundUser!['isPossible'] == false)
                          ? Text(
                              "초대 불가",
                              style: AppTextStyles.errorText,
                            )
                          : null,
                      trailing: (foundUser!['isPossible'] == true && !isInvited)
                          ? MiniSecondaryButton(
                              onPressed: _inviteUser,
                              label: "초대",
                            )
                          : null,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
