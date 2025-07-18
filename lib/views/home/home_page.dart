import 'package:flutter/material.dart';
import 'package:rockstar_app/views/home/appbar/home_app_bar.dart';
import 'package:rockstar_app/views/home/navbar/home_bottom_nav_bar.dart';
import 'package:rockstar_app/views/home/pages/band_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isValid = false;
  String? errorMessage;

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    BandListPage(), // 홈
    Placeholder(), // 내 정보
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
        },
      ),
    );
  }
}
