import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/views/band/appbar/band_app_bar.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/band/drawer/band_drawer.dart';
import 'package:rockstar_app/views/band/navbar/band_bottom_nav_bar.dart';
import 'package:rockstar_app/views/band/pages/band_schedule_page.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandPage extends StatefulWidget {
  final int bandId;
  final bandName;

  const BandPage({super.key, required this.bandId, required this.bandName});

  @override
  State<BandPage> createState() => _BandPageState();
}

class _BandPageState extends State<BandPage> {
  bool isValid = false;
  String? errorMessage;
  String nickname = "";
  bool isManager = false;

  int _selectedIndex = 0;

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages = [
      BandSchedulePage(
        bandId: widget.bandId,
        bandName: widget.bandName,
      ), // 일정
      Placeholder(), // 소식
      Placeholder(), // 멤버
    ];
    getUserInfoInBand();
  }

  Future<void> getUserInfoInBand() async {
    final response = await UserService.getUserInfoInBand(widget.bandId);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        nickname = decoded['nickname'];
        isManager = decoded['isManager'];
      });
      print("유저 정보 불러오기 성공: $decoded");
    } else if (response.statusCode == 401) {
      final response = await UserService.reissueToken();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);

        /// ✅ 토큰 재발급 성공 후 재시도
        final retry = await UserService.getUserInfoInBand(widget.bandId);
        if (retry.statusCode != 200) {
          // TODO: 오류 시 행동
        }
      } else if (response.statusCode == 401) {
        // refresh token 만료 시
        toAnimatedStartPage();
        return;
      } else {
        // TODO: 오류 시 행동
      }
    } else {
      // TODO: 서버 오류 시 행동
      print("유저 정보 조회 실패: ${jsonDecode(utf8.decode(response.bodyBytes))}");
    }
  }

  void toAnimatedStartPage() {
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
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: BandAppBar(bandName: widget.bandName),
      endDrawer: BandDrawer(
        nickname: nickname,
        isManager: isManager,
        bandId: widget.bandId,
        bandName: widget.bandName,
      ),
      body: SafeArea(
        bottom: false,
        // ✅ 이거 추가
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BandBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
