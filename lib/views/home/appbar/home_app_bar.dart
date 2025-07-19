import 'package:flutter/material.dart';
import 'package:rockstar_app/views/band/pages/create_band_page.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
          padding: const EdgeInsets.only(right: 10, bottom: 6),
          child: IconButton(
            icon: const Icon(Icons.notifications_none),
            color: Theme.of(context).colorScheme.secondaryContainer,
            iconSize: 30,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Placeholder(), // 알림 페이지
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
