import 'package:flutter/material.dart';
import 'package:rockstar_app/views/home/appbar/home_app_bar.dart';
import 'package:rockstar_app/views/home/navbar/home_bottom_nav_bar.dart';
import 'package:rockstar_app/views/home/pages/band_list_page.dart';
import 'package:rockstar_app/views/home/pages/user_page.dart';
import 'package:rockstar_app/views/home/pages/user_schedule_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isValid = false;
  String? errorMessage;

  int _selectedIndex = 0;
  final GlobalKey<UserSchedulePageState> _schedulePageKey = GlobalKey<UserSchedulePageState>();

  late final List<Widget> _pages = [
    BandListPage(), // 홈
    UserSchedulePage(key: _schedulePageKey), // 스케줄
    UserPage(), // 내 정보
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: const HomeAppBar(),
      body: SafeArea(
        bottom: false,
        // ✅ 이거 추가
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          // 달력 탭(index 1)을 클릭할 때 현재 월로 이동
          if (index == 1) {
            _schedulePageKey.currentState?.goToCurrentMonth();
          }
        },
      ),
    );
  }
}
