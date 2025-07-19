import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/services/api/band_service.dart';
import 'package:rockstar_app/views/band/appbar/band_app_bar.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/band/drawer/band_drawer.dart';
import 'package:rockstar_app/views/band/navbar/band_bottom_nav_bar.dart';
import 'package:rockstar_app/views/band/pages/band_%08news_page.dart';
import 'package:rockstar_app/views/band/pages/band_member_page.dart';
import 'package:rockstar_app/views/band/pages/band_schedule_page.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandPage extends StatefulWidget {
  final int bandId;

  const BandPage({super.key, required this.bandId});

  @override
  State<BandPage> createState() => _BandPageState();
}

class _BandPageState extends State<BandPage> {
  bool isValid = false;
  String? errorMessage;
  String nickname = "";
  bool isManager = false;
  String bandName = "";
  int? userId;
  int? managerId;

  int _selectedIndex = 0;

  List<Widget> get pages => [
        BandSchedulePage(bandId: widget.bandId, isManager: managerId == userId),
        BandNewsPage(
          bandId: widget.bandId,
        ),
        BandMemberPage(bandId: widget.bandId, isManager: managerId == userId),
      ];

  @override
  void initState() {
    super.initState();
    // _pages = [
    //   BandSchedulePage(
    //     bandId: widget.bandId,
    //   ), // 일정
    //   BandNewsPage(
    //     bandId: widget.bandId,
    //   ), // 소식
    //   BandMemberPage(bandId: widget.bandId), // 멤버
    // ];
    getUserInfoInBand();
    getBandInfo();
  }

  Future<void> getUserInfoInBand() async {
    final response = await UserService.getUserInfo();

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        nickname = decoded['nickname'];
        userId = decoded['userId'];
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
        final retry = await UserService.getUserInfo();
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

  Future<void> getBandInfo() async {
    final response = await BandService.getBandInfo(widget.bandId);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        bandName = decoded['name'];
        managerId = decoded['managerId'];
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
        final retry = await UserService.getUserInfo();
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
      appBar: BandAppBar(bandName: bandName),
      endDrawer: BandDrawer(
        nickname: nickname,
        isManager: managerId == userId,
        bandId: widget.bandId,
        bandName: bandName,
        onBandNameChanged: (newBandName) {
          if (newBandName != null) {
            setState(() {
              bandName = newBandName;
            }); // 닉네임, isManager 등 갱신
          }
        },
        onManagerChanged: (isChanged) {
          if (isChanged) {
            getUserInfoInBand();
            getBandInfo(); // 닉네임, isManager 등 갱신
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        // ✅ 이거 추가
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
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
