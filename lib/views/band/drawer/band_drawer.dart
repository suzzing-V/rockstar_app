import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/dialog/one_button_dialog.dart';
import 'package:rockstar_app/common/icon/crown_icon.dart';
import 'package:rockstar_app/common/listtile/drawer_list_tile.dart';
import 'package:rockstar_app/common/text/primary_text.dart';
import 'package:rockstar_app/services/api/band_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/band/pages/update_band_name_page.dart';
import 'package:rockstar_app/views/home/dialogs/one_title_two_button_dialog.dart';
import 'package:rockstar_app/views/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandDrawer extends StatelessWidget {
  final String nickname;
  final bool isManager;
  final int bandId;
  final String bandName;
  final void Function(String? newBandName) onBandNameChanged;

  const BandDrawer({
    super.key,
    required this.nickname,
    required this.isManager,
    required this.bandId,
    required this.bandName,
    required this.onBandNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                PrimaryText(label: nickname, fontSize: 25),
                const SizedBox(width: 5),
                if (isManager) const CrownIcon(size: 20),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Divider(
              thickness: 1,
              color: Theme.of(context)
                  .colorScheme
                  .onPrimaryContainer
                  .withOpacity(0.3),
            ),
          ),
          if (isManager)
            DrawerListTile(
              label: '밴드 이름 수정하기',
              icon: const Icon(Icons.edit),
              onTap: () async {
                String? newBandName = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UpdateBandNamePage(bandId: bandId)), // TODO
                );
                onBandNameChanged(newBandName); // ✅ true만 전달
              },
            ),
          DrawerListTile(
            label: '밴드 나가기',
            icon: const Icon(Icons.exit_to_app),
            onTap: () async {
              await showDialog<bool>(
                context: context,
                builder: (dialogContext) => OneTitleTwoButtonDialog(
                    title: '밴드를 탈퇴하시겠습니까?',
                    onConfirm: () async {
                      final response = await BandService.withdrawBand(bandId);

                      if (response.statusCode == 204) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => HomePage()),
                          (route) => false,
                        ); // HomePage에 true 전달
                      } else if (response.statusCode == 400) {
                        Navigator.pop(context);
                        await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => OneButtonDialog(
                                title: '밴드를 탈퇴할 수 없습니다.',
                                content: '관리자 권한을 위임하거나\n밴드를 삭제하세요.',
                                onConfirm: () async {
                                  Navigator.pop(context);
                                }));
                      } else if (response.statusCode == 401) {
                        final response = await UserService.reissueToken();

                        if (response.statusCode == 200) {
                          final decoded =
                              jsonDecode(utf8.decode(response.bodyBytes));
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(
                              'accessToken', decoded['accessToken']);
                          await prefs.setString(
                              'refreshToken', decoded['refreshToken']);

                          /// ✅ 토큰 재발급 성공 후 재시도
                          final retry = await BandService.withdrawBand(bandId);
                          if (retry.statusCode != 204) {
                            // TODO: 오류 발생 시 행동
                          }
                        } else if (response.statusCode == 401) {
                          // refresh token 만료 시
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnimatedStartPage(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                          return;
                        } else {
                          // TODO: 서버 오류 시 행동
                        }
                      } else {
// TODO: 서버 오류 시 행동
                        print('닉네임 등록 실패: ${jsonDecode(response.body)}');
                      }
                    }),
              );
            },
          ),
        ],
      ),
    );
  }
}
