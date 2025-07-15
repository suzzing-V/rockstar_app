import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rockstar_app/page/band_list_page.dart';
import 'package:rockstar_app/page/create_band_page.dart';

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
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 10,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo/rockstar_icon.png',
                  height: 40,
                ),
                Image.asset(
                  'assets/logo/rockstar_text.png',
                  height: 25,
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding:
                  const EdgeInsets.only(right: 5), // ← 기본은 16, 8로 줄이면 왼쪽으로 붙음
              child: IconButton(
                icon: const Icon(Icons.add_rounded),
                color: Theme.of(context).colorScheme.primaryFixed,
                iconSize: 40,
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateBandPage()), // 밴드 상세 페이지
                  )
                },
              ),
            ),
          ],
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
          padding: const EdgeInsets.only(left: 110, right: 110, bottom: 40),
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
                  children: List.generate(2, (index) {
                    final isSelected = _selectedIndex == index;
                    final iconData = index == 0 ? Icons.home : Icons.person;

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
