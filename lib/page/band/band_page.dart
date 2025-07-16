import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rockstar_app/api/user_service.dart';
import 'package:rockstar_app/button/custom_back_button.dart';
import 'package:rockstar_app/page/band/band_schedule_page.dart';
import 'package:rockstar_app/page/start_page.dart';
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnimatedStartPage(),
          ),
        );
        return;
      } else {
        // TODO: 오류 시 행동
      }
    } else {
      // TODO: 서버 오류 시 행동
      print("유저 정보 조회 실패: ${jsonDecode(utf8.decode(response.bodyBytes))}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          leading: CustomBackButton(),
          leadingWidth: 50,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.bandName,
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 25,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.only(
                    right: 10), // ← 기본은 16, 8로 줄이면 왼쪽으로 붙음
                child: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    color: Theme.of(context).colorScheme.primaryFixed,
                    iconSize: 35,
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                )),
          ],
        ),
        endDrawer: Drawer(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              SafeArea(
                bottom: false,
                child: // 노치 공간 확보 (SafeArea 대체)
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(children: [
                          Text(
                            nickname,
                            style: TextStyle(
                              fontFamily: 'PixelFont',
                              fontSize: 25,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          if (isManager)
                            Icon(FontAwesomeIcons.crown,
                                size: 20, color: Colors.amber),
                        ])),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15), // ← 좌우 여백
                child: Divider(
                  thickness: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withOpacity(0.3),
                ),
              ),
              if (isManager)
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text(
                    '밴드 이름 수정하기',
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Placeholder()), // 밴드 수정 페이지
                    );
                  },
                ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text(
                  '밴드 나가기',
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Placeholder()), // 밴드 탈퇴 행동
                  );
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          bottom: false,
          // ✅ 이거 추가
          child: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 64.5, right: 64.5, bottom: 40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 65,
                color: Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(3, (index) {
                    final isSelected = _selectedIndex == index;
                    final iconData = [
                      Icons.calendar_month,
                      Icons.campaign,
                      Icons.group, // 👥 멤버 아이콘
                    ][index];

                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30), // 동그랗고 길게
                        ),
                        child: Icon(
                          iconData,
                          size: 31,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Colors.grey,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ));
  }
}
